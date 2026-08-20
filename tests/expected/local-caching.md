# Evaluation Scenario 5: Offline-First Local Caching

## 1. Input Task Prompt
```text
Implement offline-first caching for the Articles feature:
- Save fetched remote articles into local storage (Hive / SQLite).
- If device is offline (NetworkException), return cached articles from local storage.
- If both remote and local fail, return appropriate Domain Failure.
- Synchronize local cache whenever fresh remote data arrives.
```

## 2. Expected Agent Behavior
- Creates `ArticleLocalDataSource` contract and implementation in `lib/features/articles/data/datasources/`.
- Injects both `ArticleRemoteDataSource` and `ArticleLocalDataSource` into `ArticleRepositoryImpl`.
- In `ArticleRepositoryImpl.getArticles()`:
  - Attempts remote fetch $\rightarrow$ writes to local data source $\rightarrow$ returns `Right(articles)`.
  - On `NetworkException` / `SocketException` $\rightarrow$ attempts local cache fetch $\rightarrow$ returns `Right(cachedArticles)`.
  - On `CacheException` or empty cache $\rightarrow$ returns `Left(NetworkFailure(message: ...))`.
- Domain and Presentation layers remain completely unchanged (offline transparency).

## 3. Architectural Requirements
- Storage packages (`hive`, `sqflite`, `shared_preferences`) MUST remain inside `data/datasources/`.
- Domain Use Cases MUST NOT know whether data originated from network or disk cache.
- Local cache exceptions (`CacheException`) MUST be caught inside RepositoryImpl and mapped to `CacheFailure`.

## 4. Forbidden Behavior
- Importing SQLite/Hive packages inside Domain or Presentation.
- Exposing caching policy flags to UI widgets (e.g. `widget.readFromHive()`).

## 5. Validation Criteria
- Unit tests verify repository falls back to local data source when remote data source throws `NetworkException`.
- Architecture validator reports 0 violations.
