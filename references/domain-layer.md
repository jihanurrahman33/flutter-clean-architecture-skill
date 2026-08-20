# Domain Layer Architecture & Standards

The **Domain Layer** is the core of a Clean Architecture Flutter application. It encapsulates core business concepts, rules, and operations. It MUST remain completely independent of external libraries, frameworks, UI components, and data sources.

---

## 1. Domain Layer Components

```text
features/<feature_name>/domain/
├── entities/                     # Enterprise business models & value objects
│   └── post_entity.dart
├── repositories/                 # Abstract contracts defining data operations
│   └── post_repository.dart
└── usecases/                     # Single-purpose business interactors
    ├── create_post_usecase.dart
    └── get_posts_usecase.dart
```

---

## 2. Entities & Value Objects

### 2.1 Entity Definition
An **Entity** represents a fundamental business concept with an identity (e.g. `id`) and domain business logic/invariants.

#### Requirements:
- **MUST** be immutable (`final` fields, `const` constructor).
- **MUST** support value-based equality (using `Equatable` or custom `operator ==`/`hashCode`).
- **MUST NOT** contain JSON serialization logic (`fromJson`, `toJson`, `jsonDecode`).
- **MUST NOT** import `package:flutter/*`, `package:dio/*`, or any infrastructure libraries.

#### Example:
```dart
import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final int id;
  final int userId;
  final String title;
  final String body;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  /// Domain business logic method
  bool get isValid => title.isNotEmpty && body.isNotEmpty;

  @override
  List<Object?> get props => [id, userId, title, body];
}
```

### 2.2 Value Objects
A **Value Object** has no conceptual identity; it is defined entirely by its attributes (e.g., `EmailAddress`, `Money`, `DateRange`).

```dart
class EmailAddress extends Equatable {
  final String value;

  const EmailAddress._(this.value);

  static EmailAddress? create(String raw) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(raw)) return null;
    return EmailAddress._(raw);
  }

  @override
  List<Object?> get props => [value];
}
```

---

## 3. Domain Repository Contracts

The Domain layer defines the **WHAT**, not the **HOW**. It declares abstract repository interfaces that specify the data contracts required by Use Cases.

### 3.1 Repository Contract Rules:
- **MUST** be an abstract class.
- **MUST** return `Future<Either<Failure, T>>` or `Stream<Either<Failure, T>>`.
- **MUST** accept and return Domain **Entities** (or primitive types), NEVER Data Models.
- **MUST NOT** expose HTTP status codes, headers, or raw database row cursors.

#### Example:
```dart
import 'package:app/core/error/failures.dart';
import 'package:app/core/utils/either.dart';
import 'package:app/features/post/domain/entities/post_entity.dart';

abstract class PostRepository {
  Future<Either<Failure, List<PostEntity>>> getPosts();
  
  Future<Either<Failure, PostEntity>> getPostById(int id);
  
  Future<Either<Failure, PostEntity>> createPost(PostEntity post);
  
  Future<Either<Failure, void>> deletePost(int id);
}
```

---

## 4. Use Cases (Interactors)

A **Use Case** represents a single, cohesive business operation. Each Use Case orchestrates the execution flow between Domain Repositories and applies business validation rules.

### 4.1 Base Use Case Contract (`lib/core/usecases/usecase.dart`)
```dart
import 'package:app/core/error/failures.dart';
import 'package:app/core/utils/either.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
```

### 4.2 Single Responsibility Principle for Use Cases
- **MUST** encapsulate exactly one business action (e.g. `GetPostsUseCase`, `CreatePostUseCase`).
- **MUST NOT** combine all CRUD operations into a single massive `PostService` class.
- **MUST** invoke `call()` so the Use Case instance can be invoked directly as a callable object.

#### Example 1: Use Case Without Parameters
```dart
import 'package:app/core/error/failures.dart';
import 'package:app/core/usecases/usecase.dart';
import 'package:app/core/utils/either.dart';
import 'package:app/features/post/domain/entities/post_entity.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';

class GetPostsUseCase implements UseCase<List<PostEntity>, NoParams> {
  final PostRepository repository;

  const GetPostsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<PostEntity>>> call(NoParams params) async {
    return await repository.getPosts();
  }
}
```

#### Example 2: Use Case With Parameters
```dart
import 'package:equatable/equatable.dart';
import 'package:app/core/error/failures.dart';
import 'package:app/core/usecases/usecase.dart';
import 'package:app/core/utils/either.dart';
import 'package:app/features/post/domain/entities/post_entity.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';

class CreatePostParams extends Equatable {
  final String title;
  final String body;
  final int userId;

  const CreatePostParams({
    required this.title,
    required this.body,
    required this.userId,
  });

  @override
  List<Object?> get props => [title, body, userId];
}

class CreatePostUseCase implements UseCase<PostEntity, CreatePostParams> {
  final PostRepository repository;

  const CreatePostUseCase({required this.repository});

  @override
  Future<Either<Failure, PostEntity>> call(CreatePostParams params) async {
    if (params.title.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Title cannot be empty'));
    }

    final postToCreate = PostEntity(
      id: 0,
      userId: params.userId,
      title: params.title,
      body: params.body,
    );

    return await repository.createPost(postToCreate);
  }
}
```

---

## 5. Domain Invariant Checklist

Before finalizing any Domain layer file, verify:
- [ ] No imports of `package:flutter/*` or third-party UI/networking packages.
- [ ] No `fromJson`, `toJson`, or JSON decoding in Entities.
- [ ] Repository interface methods return `Either<Failure, T>`.
- [ ] Use Cases implement `UseCase<Type, Params>` and possess a single responsibility.
- [ ] All entities and parameters are immutable and provide value-equality (`props`).
