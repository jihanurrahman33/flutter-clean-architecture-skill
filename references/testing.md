# Testing Strategy & Test Matrix

Clean Architecture makes Flutter codebases inherently testable because every layer depends strictly on abstract interfaces rather than concrete implementations.

---

## 1. Test Directory Structure

The `test/` directory MUST mirror the exact layout of `lib/`:

```text
test/
├── core/
│   ├── networking/
│   └── utils/
│
└── features/
    └── post/
        ├── data/
        │   ├── datasources/
        │   │   └── post_remote_data_source_test.dart
        │   ├── models/
        │   │   └── post_model_test.dart
        │   └── repositories/
        │       └── post_repository_impl_test.dart
        ├── domain/
        │   ├── entities/
        │   │   └── post_entity_test.dart
        │   └── usecases/
        │       ├── create_post_usecase_test.dart
        │       └── get_posts_usecase_test.dart
        └── presentation/
            ├── bloc/
            │   └── post_bloc_test.dart
            └── screens/
                └── post_list_screen_test.dart
```

---

## 2. Layer-by-Layer Test Matrix

| Layer | Component Under Test | Collaborators / Dependencies | Test Type | What to Verify |
| :--- | :--- | :--- | :--- | :--- |
| **Domain** | `PostEntity` | None | Unit Test | Field values, value equality (`props`), domain validation logic. |
| **Domain** | `GetPostsUseCase` | `MockPostRepository` | Unit Test | Calls `repository.getPosts()`, forwards success `Right` and `Left(Failure)`. |
| **Data** | `PostModel` | None | Unit Test | `fromJson` parsing, `toJson` output, `fromEntity`/`toEntity` mapping. |
| **Data** | `PostRemoteDataSource` | `MockApiClient` / `MockDio` | Unit Test | Correct endpoint URL, HTTP method, payload, throws `ServerException` on HTTP 500. |
| **Data** | `PostRepositoryImpl` | `MockRemoteDataSource`, `MockLocalDataSource` | Unit Test | Exception-to-Failure mapping (`ServerException` $\rightarrow$ `ServerFailure`), caching logic. |
| **Presentation** | `PostBloc` / `PostCubit` | `MockGetPostsUseCase`, `MockCreatePostUseCase` | Unit Test (`bloc_test`) | Event $\rightarrow$ State transitions: `[loading, loaded]` or `[loading, error]`. |
| **Presentation** | `PostListScreen` | `MockPostBloc` | Widget Test | Renders loading spinner, renders list items when loaded, displays SnackBar on error. |

---

## 3. Concrete Layer Test Examples (Using `mocktail`)

### 3.1 Domain: Use Case Unit Test
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/core/error/failures.dart';
import 'package:app/core/usecases/usecase.dart';
import 'package:app/core/utils/either.dart';
import 'package:app/features/post/domain/entities/post_entity.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:app/features/post/domain/usecases/get_posts_usecase.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late GetPostsUseCase useCase;
  late MockPostRepository mockRepository;

  setUp(() {
    mockRepository = MockPostRepository();
    useCase = GetPostsUseCase(repository: mockRepository);
  });

  const tPosts = [
    PostEntity(id: 1, userId: 1, title: 'Title', body: 'Body'),
  ];

  test('should return list of PostEntity when repository call is successful', () async {
    // Arrange
    when(() => mockRepository.getPosts())
        .thenAnswer((_) async => const Right(tPosts));

    // Act
    final result = await useCase(const NoParams());

    // Assert
    expect(result, const Right(tPosts));
    verify(() => mockRepository.getPosts()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository fails', () async {
    // Arrange
    const tFailure = ServerFailure(message: 'Server Error');
    when(() => mockRepository.getPosts())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase(const NoParams());

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.getPosts()).called(1);
  });
}
```

---

### 3.2 Data: Model Serialization Test
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/post/data/models/post_model.dart';
import 'package:app/features/post/domain/entities/post_entity.dart';

void main() {
  const tPostModel = PostModel(
    id: 1,
    userId: 1,
    title: 'Test Title',
    body: 'Test Body',
  );

  test('should be a subclass of PostEntity', () {
    expect(tPostModel, isA<PostEntity>());
  });

  test('fromJson should return a valid model from JSON map', () {
    final jsonMap = {
      'id': 1,
      'userId': 1,
      'title': 'Test Title',
      'body': 'Test Body',
    };

    final result = PostModel.fromJson(jsonMap);

    expect(result, tPostModel);
  });

  test('toJson should return a JSON map containing proper data', () {
    final expectedMap = {
      'id': 1,
      'userId': 1,
      'title': 'Test Title',
      'body': 'Test Body',
    };

    final result = tPostModel.toJson();

    expect(result, expectedMap);
  });
}
```

---

### 3.3 Data: Repository Implementation Exception Mapping Test
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/core/error/exceptions.dart';
import 'package:app/core/error/failures.dart';
import 'package:app/core/utils/either.dart';
import 'package:app/features/post/data/datasources/post_remote_data_source.dart';
import 'package:app/features/post/data/models/post_model.dart';
import 'package:app/features/post/data/repositories/post_repository_impl.dart';

class MockPostRemoteDataSource extends Mock implements PostRemoteDataSource {}

void main() {
  late PostRepositoryImpl repository;
  late MockPostRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockPostRemoteDataSource();
    repository = PostRepositoryImpl(remoteDataSource: mockDataSource);
  });

  const tPostModels = [
    PostModel(id: 1, userId: 1, title: 'Title', body: 'Body'),
  ];

  test('should return ServerFailure when remote data source throws ServerException', () async {
    // Arrange
    when(() => mockDataSource.getPosts())
        .thenThrow(const ServerException(message: 'Internal Error', statusCode: 500));

    // Act
    final result = await repository.getPosts();

    // Assert
    expect(result, const Left(ServerFailure(message: 'Internal Error', code: 500)));
    verify(() => mockDataSource.getPosts()).called(1);
  });
}
```

---

### 3.4 Presentation: BLoC Test (`bloc_test`)
```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/core/error/failures.dart';
import 'package:app/core/usecases/usecase.dart';
import 'package:app/core/utils/either.dart';
import 'package:app/features/post/domain/entities/post_entity.dart';
import 'package:app/features/post/domain/usecases/create_post_usecase.dart';
import 'package:app/features/post/domain/usecases/get_posts_usecase.dart';
import 'package:app/features/post/presentation/bloc/post_bloc.dart';
import 'package:app/features/post/presentation/bloc/post_event.dart';
import 'package:app/features/post/presentation/bloc/post_state.dart';

class MockGetPostsUseCase extends Mock implements GetPostsUseCase {}
class MockCreatePostUseCase extends Mock implements CreatePostUseCase {}

void main() {
  late PostBloc bloc;
  late MockGetPostsUseCase mockGetPostsUseCase;
  late MockCreatePostUseCase mockCreatePostUseCase;

  setUp(() {
    mockGetPostsUseCase = MockGetPostsUseCase();
    mockCreatePostUseCase = MockCreatePostUseCase();
    bloc = PostBloc(
      getPostsUseCase: mockGetPostsUseCase,
      createPostUseCase: mockCreatePostUseCase,
    );
  });

  const tPosts = [
    PostEntity(id: 1, userId: 1, title: 'Title', body: 'Body'),
  ];

  blocTest<PostBloc, PostState>(
    'emits [PostStatus.loading, PostStatus.loaded] when FetchPostsEvent succeeds',
    build: () {
      when(() => mockGetPostsUseCase(const NoParams()))
          .thenAnswer((_) async => const Right(tPosts));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchPostsEvent()),
    expect: () => [
      const PostState(status: PostStatus.loading),
      const PostState(status: PostStatus.loaded, posts: tPosts),
    ],
  );

  blocTest<PostBloc, PostState>(
    'emits [PostStatus.loading, PostStatus.error] when FetchPostsEvent fails',
    build: () {
      when(() => mockGetPostsUseCase(const NoParams()))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'API Failure')));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchPostsEvent()),
    expect: () => [
      const PostState(status: PostStatus.loading),
      const PostState(status: PostStatus.error, errorMessage: 'API Failure'),
    ],
  );
}
```
