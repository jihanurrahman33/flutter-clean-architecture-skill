# Test Scenario: Infinite Scrolling Pagination

## Input Task Prompt
```text
Add pagination to the existing Feed feature:
- Endpoint: GET /api/v1/feed?page=1&limit=20
- Infinite scroll trigger when user scrolls within 200px of list bottom.
- Must preserve already-loaded posts in state while fetching subsequent pages.
- Handle pagination end (hasReachedMax) and page-level errors without wiping existing data.
```
