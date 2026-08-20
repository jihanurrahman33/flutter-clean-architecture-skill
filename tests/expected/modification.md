# Evaluation Scenario 10: Modifying an Existing Feature

## 1. Input Task Prompt
```text
In the existing Posts feature, add a "likeCount" integer field to posts:
- Display likeCount in PostCardWidget.
- Add an "incrementLike" operation that calls PATCH /api/v1/posts/:id/like.
- Keep the diff minimal and surgical without breaking existing tests.
```

## 2. Expected Agent Behavior
- Applies minimal, surgical edits across layers:
  1. `PostEntity`: Adds `final int likeCount` with default or required parameter, updates `props`.
  2. `PostRepository`: Adds `Future<Either<Failure, PostEntity>> likePost(int id);`.
  3. `LikePostUseCase`: Creates `UseCase<PostEntity, int>` interactor.
  4. `PostModel`: Updates `fromJson` / `toJson` / `fromEntity` with `likeCount`.
  5. `PostRemoteDataSource`: Adds `likePost(int id)` calling `ApiClient.patch('/posts/$id/like')`.
  6. `PostRepositoryImpl`: Implements `likePost` with exception mapping.
  7. `PostBloc`: Handles `LikePostEvent(int id)` and updates the specific post in `state.posts` without refetching the entire list.
  8. `PostCardWidget`: Displays `post.likeCount` with a like button dispatching `LikePostEvent`.
- Updates existing tests to include `likeCount`.

## 3. Architectural Requirements
- Minimizes blast radius: Does NOT refactor unrelated features or rewrite `main.dart`.
- Preserves existing state: Modifies the liked item in-place in `state.posts` rather than wiping out the list.

## 4. Forbidden Behavior
- Refetching the whole list from scratch on a single like button tap.
- Making direct HTTP PATCH calls inside `PostCardWidget`.
- Breaking existing unit tests without updating them.

## 5. Validation Criteria
- All existing and new tests pass.
- `validate_architecture.js` passes with 0 violations.
- Diff contains zero modifications to unrelated features.
