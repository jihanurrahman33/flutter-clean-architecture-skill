# Evaluation Scenario 6: Refactoring Legacy Monolithic Code

## 1. Input Task Prompt
```text
Refactor this legacy monolithic StatefulWidget into Clean Architecture:

class LegacyProfileScreen extends StatefulWidget { ... } // Contains direct http.get, setState, and jsonDecode
```

## 2. Expected Agent Behavior
- Applies the **Strangler Fig pattern** in incremental steps.
- Extracts `UserEntity` in `lib/features/profile/domain/entities/user_entity.dart`.
- Extracts `UserModel` (with `fromJson`) and `ProfileRemoteDataSource` in `data/`.
- Declares `ProfileRepository` domain contract and `ProfileRepositoryImpl` with `try/catch` error mapping.
- Implements `GetProfileUseCase` implementing `UseCase<UserEntity, NoParams>`.
- Creates `ProfileBloc` / `ProfileCubit` emitting `ProfileState(status, user, errorMessage)`.
- Replaces `LegacyProfileScreen` with `ProfileScreen` reading state via `BlocBuilder`.
- Preserves existing user behavior while eliminating all raw HTTP and JSON parsing from the widget.

## 3. Architectural Requirements
- **Complete Decoupling**: Widget must contain zero networking code, zero JSON decoding, and zero state mutations outside the state controller.
- **Pure Domain**: `UserEntity` has no Flutter UI or HTTP dependencies.
- **Inversion of Control**: `ProfileScreen` communicates with Domain only through Use Cases / BLoC.

## 4. Forbidden Behavior
- Performing a big-bang rewrite that breaks existing routing or external references.
- Leaving `http.get` inside the newly created BLoC or State notifier.
- Inverting dependencies by importing `ProfileRepositoryImpl` directly into `ProfileScreen`.

## 5. Validation Criteria
- All 3 layers (Domain, Data, Presentation) created cleanly.
- `validate_architecture.js` passes with 0 violations.
- Widget test validates loading and loaded states render properly with mock BLoC.
