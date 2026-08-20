# Expected Architectural Outcome: Unit & BLoC Testing

## 1. Expected Tests
- `GetPostsUseCaseTest`: Mocks `PostRepository`, tests success `Right(posts)` and failure `Left(ServerFailure)`.
- `PostBlocTest`: Uses `blocTest`, tests emission of `[PostStatus.loading, PostStatus.loaded]` and `[PostStatus.loading, PostStatus.error]`.

## 2. Invariant Expectations
- All external dependencies are properly mocked via abstract domain interfaces.
- Zero network or database interaction occurs during unit testing.
