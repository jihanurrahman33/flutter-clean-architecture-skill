# Expected Architectural Outcome: API Integration

## 1. Expected File Updates
- `domain/entities/user_entity.dart`: Updated with `fullName`, `bio`.
- `domain/repositories/auth_repository.dart`: Declares `Future<Either<Failure, UserEntity>> updateProfile(UpdateProfileParams params);`.
- `domain/usecases/update_profile_usecase.dart`: Implements `UseCase<UserEntity, UpdateProfileParams>`.
- `data/models/user_model.dart`: Contains `toJson()` and `fromJson()`.
- `data/datasources/auth_remote_data_source.dart`: Invokes `apiClient.put('/users/me', data: model.toJson())`.
- `data/repositories/auth_repository_impl.dart`: Maps 401 $\rightarrow$ `AuthenticationFailure`, 422 $\rightarrow$ `ValidationFailure`, socket $\rightarrow$ `NetworkFailure`.

## 2. Forbidden Patterns
- NO direct `Dio().put` calls in BLoC or Screens.
- NO unhandled exceptions escaping into UI.
