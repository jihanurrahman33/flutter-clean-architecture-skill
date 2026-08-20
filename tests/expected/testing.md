# Evaluation Scenario 9: Adding Layer-by-Layer Tests

## 1. Input Task Prompt
```text
Write a complete automated test suite for the Bookmark feature:
1. Domain: Unit test for AddBookmarkUseCase with MockBookmarkRepository.
2. Data: Unit test for BookmarkModel serialization and BookmarkRepositoryImpl exception mapping.
3. Presentation: bloc_test for BookmarkBloc testing AddBookmarkEvent -> [loading, loaded] and error transitions.
```

## 2. Expected Agent Behavior
- Creates test files mirroring `lib/` layout in `test/features/bookmark/`:
  - `domain/usecases/add_bookmark_usecase_test.dart`
  - `data/models/bookmark_model_test.dart`
  - `data/repositories/bookmark_repository_impl_test.dart`
  - `presentation/bloc/bookmark_bloc_test.dart`
- Uses `mocktail` or `mockito` to stub repository contracts and data sources.
- Uses `bloc_test` for presentation state transitions.
- Tests both success (`Right`) and failure (`Left`) execution branches.

## 3. Architectural Requirements
- Unit tests MUST NOT make actual HTTP or database network calls.
- Domain tests depend only on Domain contracts and mocktail.
- Presentation tests verify exact state emissions and failure messages.

## 4. Forbidden Behavior
- Hardcoding real network URLs or file paths in tests.
- Testing private implementation details instead of public interfaces and state transitions.

## 5. Validation Criteria
- `flutter test test/features/bookmark/` passes with 100% test success rate.
- All edge cases (success, server error, validation failure) covered.
