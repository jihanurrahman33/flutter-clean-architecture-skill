# Data Layer Architecture & Standards

The **Data Layer** bridges the abstract domain contracts to concrete external implementations (REST APIs, GraphQL, SQLite, Hive, SecureStorage, Firebase). It is responsible for raw data access, serialization, deserialization, caching, and exception-to-failure conversion.

---

## 1. Data Layer Components

```text
features/<feature_name>/data/
├── datasources/                  # Concrete data fetching & storage clients
│   ├── post_local_data_source.dart
│   └── post_remote_data_source.dart
├── models/                       # Data Transfer Objects (DTOs) & JSON parsers
│   └── post_model.dart
└── repositories/                 # Concrete repository implementations
    └── post_repository_impl.dart
```

---

## 2. Models (Data Transfer Objects)

A **Model** is a technical representation of data from an external system. It handles parsing, serialization, and schema adaptation.

### 2.1 Model Strategies: Inheritance vs Composition
Two valid patterns exist for relating Models to Entities. Choose the pattern that matches the project convention:

#### Pattern A: Model Extends Entity (Preferred for direct 1:1 schemas)
```dart
import 'package:app/features/post/domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }

  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      body: entity.body,
    );
  }
}
```

#### Pattern B: Model Composes / Maps to Entity (Preferred when API schema differs heavily from domain)
```dart
class PostModel {
  final int rawId;
  final int authorId;
  final String postHeader;
  final String postContent;

  const PostModel({
    required this.rawId,
    required this.authorId,
    required this.postHeader,
    required this.postContent,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      rawId: json['raw_id'] as int,
      authorId: json['author_id'] as int,
      postHeader: json['post_header'] as String,
      postContent: json['post_content'] as String,
    );
  }

  PostEntity toEntity() {
    return PostEntity(
      id: rawId,
      userId: authorId,
      title: postHeader,
      body: postContent,
    );
  }
}
```

---

## 3. Data Sources

A **Data Source** communicates with one specific data provider (Network API, Local SQLite, In-Memory Cache).

### 3.1 Data Source Rules:
- **Contract vs Impl**: Define an abstract data source interface and a concrete implementation.
- **Exceptions, Not Failures**: Data Sources throw low-level typed `Exception`s (e.g. `ServerException`, `CacheException`, `NetworkException`). They do NOT return `Either<Failure, T>`. The Repository implementation handles the try/catch mapping.
- **Work with Models**: Data Sources accept and return Models, raw JSON, or primitive data, NOT Domain Entities.

#### Remote Data Source Example:
```dart
import 'package:app/core/error/exceptions.dart';
import 'package:app/core/networking/api_client.dart';
import 'package:app/features/post/data/models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts();
  Future<PostModel> createPost(PostModel post);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final ApiClient apiClient;

  const PostRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await apiClient.get('/posts');
      final data = response.data as List<dynamic>;
      return data
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PostModel> createPost(PostModel post) async {
    try {
      final response = await apiClient.post('/posts', data: post.toJson());
      return PostModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
```

---

## 4. Repository Implementations

The **Repository Implementation** (`*_repository_impl.dart`) fulfills the Domain Repository contract by coordinating one or more Data Sources and handling failure conversion.

### 4.1 Responsibilities:
1. Orchestrate remote and local data sources (e.g., fetch from remote, save to local cache).
2. Catch all infrastructure exceptions (`ServerException`, `CacheException`, `SocketException`) and return `Left(Failure)`.
3. Convert Data Models into Domain Entities and return `Right(Entity)`.

#### Example:
```dart
import 'package:app/core/error/exceptions.dart';
import 'package:app/core/error/failures.dart';
import 'package:app/core/utils/either.dart';
import 'package:app/features/post/data/datasources/post_local_data_source.dart';
import 'package:app/features/post/data/datasources/post_remote_data_source.dart';
import 'package:app/features/post/data/models/post_model.dart';
import 'package:app/features/post/domain/entities/post_entity.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final PostLocalDataSource? localDataSource;

  const PostRepositoryImpl({
    required this.remoteDataSource,
    this.localDataSource,
  });

  @override
  Future<Either<Failure, List<PostEntity>>> getPosts() async {
    try {
      final models = await remoteDataSource.getPosts();
      // Optional: Cache locally
      await localDataSource?.cachePosts(models);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      // Optional fallback to local cache on network outage
      if (localDataSource != null) {
        try {
          final cached = await localDataSource!.getCachedPosts();
          return Right(cached);
        } catch (_) {}
      }
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> createPost(PostEntity post) async {
    try {
      final model = PostModel.fromEntity(post);
      final createdModel = await remoteDataSource.createPost(model);
      return Right(createdModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(int id) async {
    // Implementation following same pattern
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deletePost(int id) async {
    // Implementation following same pattern
    throw UnimplementedError();
  }
}
```

---

## 5. Data Layer Invariant Checklist

Before finalizing any Data layer file, verify:
- [ ] Models handle JSON serialization (`fromJson`/`toJson`) and mapping to/from Entities.
- [ ] Data Sources throw typed `Exception`s and never return `Either<Failure, T>`.
- [ ] Repository implementations wrap all data source invocations in try/catch blocks and return `Either<Failure, T>`.
- [ ] No `data/` implementation files are imported into `domain/` or `presentation/`.
- [ ] Low-level third-party types (e.g. `DioException`, `Response`) do not escape the Data layer.
