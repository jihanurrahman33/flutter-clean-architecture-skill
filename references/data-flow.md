# Data Flow & Layer Transformations

This document details the exact end-to-end request and response flows across all Clean Architecture layers, specifying data structure transformations at each boundary.

---

## 1. Complete Request-Response Flow Diagram

```text
========================================================================================
                                  REQUEST FLOW (Top to Bottom)
========================================================================================

[ User Interacts with UI ]
            │ (User taps "Load Posts" button)
            ▼
[ UI Screen / Widget ]
            │ Dispatches PostEvent (e.g. FetchPostsEvent())
            ▼
[ Presentation Controller (BLoC / Cubit) ]
            │ Emits PostState(status: loading, posts: cachedPosts)
            │ Calls UseCase: getPostsUseCase(NoParams())
            ▼
[ Domain Use Case (GetPostsUseCase) ]
            │ Executes business validation
            │ Calls Domain Repository: repository.getPosts()
            ▼
[ Domain Repository Contract (PostRepository) ]
            │ (Abstract Interface - Dispatched to Implementation via DI)
            ▼
[ Data Repository Implementation (PostRepositoryImpl) ]
            │ Calls Remote Data Source: remoteDataSource.getPosts()
            ▼
[ Data Remote Data Source (PostRemoteDataSourceImpl) ]
            │ Calls Centralized ApiClient: apiClient.get('/posts')
            ▼
[ ApiClient & Dio / HTTP Client ]
            │ Sends HTTP GET request to external server
            ▼
[ External REST API / Database / Cache ]

========================================================================================
                                 RESPONSE FLOW (Bottom to Top)
========================================================================================

[ External REST API / Database ]
            │ Returns raw HTTP 200 JSON payload: [{"id": 1, "title": "Hello"}]
            ▼
[ ApiClient & Dio / HTTP Client ]
            │ Returns Response(data: List<dynamic>)
            ▼
[ Data Remote Data Source (PostRemoteDataSourceImpl) ]
            │ Parses JSON into Data Models: List<PostModel>
            │ (Throws ServerException if status != 200)
            ▼
[ Data Repository Implementation (PostRepositoryImpl) ]
            │ Catches ServerException -> maps to Left(ServerFailure())
            │ If successful -> returns Right(List<PostEntity>) (Polymorphic Model -> Entity)
            ▼
[ Domain Use Case (GetPostsUseCase) ]
            │ Receives Either<Failure, List<PostEntity>>
            │ Forwards Either to caller
            ▼
[ Presentation Controller (BLoC / Cubit) ]
            │ Unwraps result using .fold():
            │   - on Left(failure) -> emits PostState(status: error, errorMessage: failure.message)
            │   - on Right(posts)   -> emits PostState(status: loaded, posts: posts)
            ▼
[ UI Screen / Widget ]
            │ Re-renders UI based on new immutable PostState snapshot
            ▼
[ User Views Updated Screen ]
```

---

## 2. Layer Transformation Table

| Boundary | Sending Layer | Receiving Layer | Data Structure Transferred |
| :--- | :--- | :--- | :--- |
| **External $\rightarrow$ Data** | Network Wire / DB | Data Source | Raw JSON (`Map<String, dynamic>`) / Raw DB Rows |
| **Data Source $\rightarrow$ Repo** | Data Source | Repository Impl | Data Transfer Object / `PostModel` (or throws `Exception`) |
| **Data $\rightarrow$ Domain** | Repository Impl | Use Case | `Either<Failure, PostEntity>` (Model cast/mapped to Entity) |
| **Domain $\rightarrow$ Presentation** | Use Case | BLoC / Controller | `Either<Failure, PostEntity>` |
| **Presentation $\rightarrow$ UI** | BLoC / Controller | Widgets / Screens | Immutable UI State snapshot (`PostState`) |
