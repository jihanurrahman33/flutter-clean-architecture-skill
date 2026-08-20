# Error Handling & Failure Architecture

This document defines the functional error-handling architecture, the Domain Failure hierarchy, Exception-to-Failure mapping rules in the Data layer, and presentation error rendering.

---

## 1. Functional Error Handling Philosophy

In Clean Architecture, expected system failures (e.g. invalid inputs, network drops, 404/500 API responses, cache misses) are treated as **typed return values**, not unhandled runtime exceptions.

```text
Data Layer (Catches raw low-level Exceptions)
       │
       ▼ (Maps to Domain Failure)
Domain Layer (Returns Either<Failure, Success>)
       │
       ▼ (Propagates Either without side-effects)
Presentation Layer (Folds Either into LoadedState or ErrorState)
```

---

## 2. The `Either<L, R>` Pattern

The `Either<Failure, Success>` monad encapsulates two possible outcomes:
- **Left (L)**: Represents a **Failure** (error state).
- **Right (R)**: Represents **Success** (domain data).

> **Universal Rule**: Left is ALWAYS Failure, Right is ALWAYS Success. Never invert this convention.

```dart
// lib/core/utils/either.dart
abstract class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  T fold<T>(T Function(L left) fnL, T Function(R right) fnR);
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  T fold<T>(T Function(L left) fnL, T Function(R right) fnR) => fnL(value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  T fold<T>(T Function(L left) fnL, T Function(R right) fnR) => fnR(value);
}
```

---

## 3. Domain Failure Hierarchy (`lib/core/error/failures.dart`)

Domain `Failure` classes represent application-level failure conditions that the UI and business layers understand:

```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Remote backend or API failure
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Connectivity or socket timeout failure
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Please check your internet connection.',
    super.code,
  });
}

/// Local SQLite/Hive/Cache read/write failure
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to load data from local cache.',
    super.code,
  });
}

/// User input validation or domain invariant violation
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Authentication / Token expiration failure
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Session expired. Please log in again.',
    super.code = 401,
  });
}

/// Fallback failure for unclassified errors
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code,
  });
}
```

---

## 4. Infrastructure Exceptions (`lib/core/error/exceptions.dart`)

Data Sources throw low-level `Exception`s when external operations fail. These are internal to the Data layer:

```dart
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({required this.message});
}
```

---

## 5. Exception-to-Failure Mapping (Data Layer)

Repository implementations MUST catch all infrastructure exceptions and convert them into explicit Domain Failures:

```dart
// lib/features/post/data/repositories/post_repository_impl.dart
@override
Future<Either<Failure, List<PostEntity>>> getPosts() async {
  try {
    final models = await remoteDataSource.getPosts();
    return Right(models);
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message, code: e.statusCode));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(message: e.message));
  } catch (e) {
    return Left(UnknownFailure(message: e.toString()));
  }
}
```

---

## 6. Presentation Consumption of Failures

State controllers (BLoCs / Notifiers) process results using `.fold()` and map Failures to UI states:

```dart
final result = await getPostsUseCase(const NoParams());

result.fold(
  (failure) {
    emit(state.copyWith(
      status: PostStatus.error,
      errorMessage: _mapFailureToMessage(failure),
    ));
  },
  (posts) {
    emit(state.copyWith(
      status: PostStatus.loaded,
      posts: posts,
    ));
  },
);

String _mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return failure.message;
    case NetworkFailure:
      return 'No internet connection detected.';
    case AuthenticationFailure:
      return 'Please log in to continue.';
    default:
      return 'An unexpected error occurred.';
  }
}
```

---

## 7. Error Handling Anti-Patterns

| Anti-Pattern | Why It Is Forbidden | Clean Architecture Remedy |
| :--- | :--- | :--- |
| Catching `DioException` in UI/Widget | Tight couples UI to Dio networking package. | Catch `DioException` in ApiClient/DataSource, map to `ServerException`, then in RepoImpl map to `ServerFailure`. |
| Returning `null` on error | Erases failure context; UI cannot explain why the action failed. | Return `Either<Failure, T>` with explicit `Failure.message`. |
| Unhandled async exceptions in UseCase | Crashes application or causes uncaught zone errors. | Ensure Repositories catch all exceptions and return `Left(Failure)`. |
| Inverting Either (Left=Data, Right=Error) | Violates industry convention and breaks caller expectations. | Always use `Left` for `Failure` and `Right` for `Success`. |
