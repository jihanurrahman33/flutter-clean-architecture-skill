# Test Scenario: Modifying an Existing Feature

## Input Task Prompt
```text
In the existing Posts feature, add a "likeCount" integer field to posts:
- Display likeCount in PostCardWidget.
- Add an "incrementLike" operation that calls PATCH /api/v1/posts/:id/like.
- Keep the diff minimal and surgical without breaking existing tests.
```
