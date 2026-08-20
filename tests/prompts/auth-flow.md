# Test Scenario: Authentication Flow & Session Management

## Input Task Prompt
```text
Implement authentication flow with JWT tokens in our Flutter app:
- Login with email & password (POST /api/v1/auth/login).
- Store JWT accessToken and refreshToken in secure local storage.
- Intercept 401 Unauthorized responses to automatically refresh tokens using ApiClient.
- Maintain global authentication state in Presentation.
- Follow Clean Architecture principles.
```
