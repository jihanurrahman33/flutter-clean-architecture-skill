# Test Scenario: API Integration & Data Mapping

## Input Task Prompt
```text
Integrate a user profile update endpoint into the auth feature:
- Endpoint: PUT /api/v1/users/me
- Request: { "full_name": "Jane Doe", "bio": "Software Architect" }
- Response: 200 OK with updated User JSON
- Must handle 401 Unauthorized, 422 Validation Error, and Network timeouts.
```
