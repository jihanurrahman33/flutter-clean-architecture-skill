# Test Scenario: Offline-First Local Caching

## Input Task Prompt
```text
Implement offline-first caching for the Articles feature:
- Save fetched remote articles into local storage (Hive / SQLite).
- If device is offline (NetworkException), return cached articles from local storage.
- If both remote and local fail, return appropriate Domain Failure.
- Synchronize local cache whenever fresh remote data arrives.
```
