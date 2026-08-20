# Evaluation Scenario 2: REST API Integration & Data Mapping

## 1. Input Task Prompt
```text
Integrate a user profile update endpoint into the existing auth feature:
- Endpoint: PUT /api/v1/users/me
- Request payload: { "full_name": "Jane Doe", "bio": "Software Architect" }
- Response: 200 OK with updated User JSON
- Must handle 401 Unauthorized, 422 Validation Error, and Network timeouts.
```

## 2. Expected Agent Behavior
- Locates existing `auth` feature in `lib/features/auth/`.
- Updates `UserEntity` with domain fields (`fullName`, `bio`).
- Extends `AuthRepository` domain contract with `updateProfile(UpdateProfileParams params)`.
- Implements `UpdateProfileUseCase` implementing `UseCase<UserEntity, UpdateProfileParams>`.
- Adds `updateProfile` method to `AuthRemoteDataSource` using `ApiClient`.
- Updates `AuthRepositoryImpl` with `try/catch` block mapping 401 $\rightarrow$ `AuthenticationFailure`, 422 $\rightarrow$ `ValidationFailure`, socket $\rightarrow$ `NetworkFailure`.

## 3. Architectural Requirements
- **Domain Layer**:
  - `UpdateProfileParams`: Immutable parameter object holding `fullName` and `bio`.
  - `UpdateProfileUseCase`: Calls `authRepository.updateProfile(params)`.
- **Data Layer**:
  - `UserModel`: Updated serialization logic for new fields.
  - `AuthRemoteDataSourceImpl`: Throws `ServerException` with status codes.
  - `AuthRepositoryImpl`: Returns `Future<Either<Failure, UserEntity>>`.

## 4. Forbidden Behavior
- Direct `Dio.put` call in Presentation widgets or BLoCs.
- Uncaught exceptions escaping the Data layer without mapping to Domain `Failure`.
- Inverting the `Either` monad convention (`Left` MUST be `Failure`, `Right` MUST be `Success`).
- Mutating entity objects instead of creating new instances.

## 5. Validation Criteria
- `validate_architecture.js lib/features/auth` passes with 0 violations.
- Exception-to-Failure mapping unit tests verify all status codes (401, 422, timeout).
- Static analysis passes with zero warnings.
