# Evaluation Scenario 3: Authentication Flow & Session Management

## 1. Input Task Prompt
```text
Implement authentication flow with JWT tokens in our Flutter app:
- Login with email & password (POST /api/v1/auth/login).
- Store JWT accessToken and refreshToken in secure local storage.
- Intercept 401 Unauthorized responses to automatically refresh tokens using ApiClient.
- Maintain global authentication state in Presentation.
- Follow Clean Architecture principles.
```

## 2. Expected Agent Behavior
- Implements `AuthLocalDataSource` (wrapping `FlutterSecureStorage` or equivalent) in `lib/features/auth/data/datasources/`.
- Implements `AuthRemoteDataSource` for `/auth/login` and `/auth/refresh`.
- Adds `AuthInterceptor` to `lib/core/networking/` to handle token injection and automated token refreshes.
- Defines pure `UserEntity` / `AuthTokenEntity` in `domain/entities/`.
- Declares `AuthRepository` domain contract and `LoginUseCase`, `GetAuthStatusUseCase`, `LogoutUseCase`.
- Emits authenticated/unauthenticated states in `AuthBloc` without exposing raw token strings in the UI.

## 3. Architectural Requirements
- Storage SDKs (`flutter_secure_storage`, `shared_preferences`) MUST remain strictly in `data/datasources/`.
- Domain layer MUST NOT know about token storage mechanisms or encryption.
- HTTP Interceptors reside in `lib/core/networking/` and collaborate with `AuthLocalDataSource` via an abstract contract or injected dependency.

## 4. Forbidden Behavior
- Importing `flutter_secure_storage` inside `domain/entities/` or `domain/usecases/`.
- Performing token refresh inside UI widgets or BLoC.
- Exposing raw JWT parsing exceptions to UI layer.

## 5. Validation Criteria
- Zero architecture violations in `lib/features/auth`.
- Unit tests verify token storage on login and token removal on logout.
- Analyzer passes with 0 warnings.
