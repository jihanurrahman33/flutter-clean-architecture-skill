# Expected Architectural Outcome: Refactoring Legacy Code

## 1. Incremental Strangler Fig Migration
1. Extract `UserEntity` into `domain/entities/`.
2. Extract `UserModel` & `UserRemoteDataSource` into `data/`.
3. Extract `UserRepository` interface (Domain) and `UserRepositoryImpl` (Data).
4. Extract `GetUserProfileUseCase` into `domain/usecases/`.
5. Create `ProfileBloc` (Presentation) emitting `ProfileState`.
6. Refactor screen into `ProfileScreen` consuming `BlocBuilder<ProfileBloc, ProfileState>`.

## 2. Invariant Assertions
- Zero `setState()` or `http.get()` remaining in UI widgets.
- User-facing functionality and visual layout remain 100% preserved.
