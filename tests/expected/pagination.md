# Evaluation Scenario 4: Infinite Scrolling Pagination

## 1. Input Task Prompt
```text
Add pagination to the existing Feed feature:
- Endpoint: GET /api/v1/feed?page=1&limit=20
- Infinite scroll trigger when user scrolls within 200px of list bottom.
- Must preserve already-loaded posts in state while fetching subsequent pages.
- Handle pagination end (hasReachedMax) and page-level errors without wiping existing data.
```

## 2. Expected Agent Behavior
- Adds `PaginationParams(int page, int limit)` in Domain layer.
- Updates `GetFeedUseCase` to take `PaginationParams`.
- Updates `FeedState` with `bool hasReachedMax`, `int currentPage`, and preserves `List<FeedItemEntity> items`.
- In `FeedBloc`, appends new page items to current items list (`List.of(state.items)..addAll(newItems)`) rather than overwriting.
- Implements `ScrollController` listener in Presentation widget with threshold check without calling APIs directly from the widget.

## 3. Architectural Requirements
- **State Preservation**: When `FeedBloc` processes page > 1 fetch, it emits `status: FeedStatus.loadingMore` while keeping `items: state.items`.
- **Error Handling**: When next page fails, emits `FeedStatus.paginationError` with error message, keeping current list visible.

## 4. Forbidden Behavior
- Resetting `items: const []` when loading subsequent pages.
- Embedding HTTP pagination parameters directly in the UI widget without passing through BLoC/Use Case.
- Modifying Domain entities to add pagination metadata (e.g. `isLastPage`).

## 5. Validation Criteria
- `bloc_test` verifies state sequence: `[FeedLoading, FeedLoaded(page 1)]` $\rightarrow$ `[FeedLoadingMore(items: [1..20]), FeedLoaded(items: [1..40])]`.
- Architecture validator reports 0 violations.
