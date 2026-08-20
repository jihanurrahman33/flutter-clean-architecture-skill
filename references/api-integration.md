# API Integration & Remote Data Layer Standards

This document defines the architectural patterns, caching strategies, interceptors, and data serialization protocols for integrating external REST/GraphQL APIs in Flutter Clean Architecture.

---

## 1. API Integration Architecture Flow

```text
Presentation Layer (UI / Controller)
       │ (Invokes with Domain Params)
       ▼
Domain Use Case
       │ (Calls abstract contract)
       ▼
Domain Repository Contract (PostRepository)
       │ (Dispatches to concrete implementation)
       ▼
Data Repository Implementation (PostRepositoryImpl)
       │ (Coordinates data fetching, caching & exception mapping)
       ▼
Remote Data Source (PostRemoteDataSourceImpl)
       │ (Serializes payload to JSON Map)
       ▼
Centralized ApiClient (ApiClient / Dio)
       │ (Applies BaseURL, Headers, Interceptors, SSL pinning)
       ▼
External REST API Wire
```

---

## 2. Centralized `ApiClient` Standards

All HTTP communication MUST be funneled through a centralized `ApiClient` located in `lib/core/networking/`.

### 2.1 Requirements:
- **Centralized Base URL & Timeouts**: Connect timeout (15s), receive timeout (15s).
- **Global Auth & Refresh Interceptor**: Automatically attach JWT `Bearer` tokens and handle transparent 401 token refresh.
- **Logging Interceptor**: Pretty-print requests and responses in debug mode only. Never log passwords, tokens, or sensitive payload data.
- **Unified Error Normalization**: Convert `DioException` into standard `ServerException`, `NetworkException`, or `AuthException`.

---

## 3. Remote Data Source Implementation Pattern

```dart
abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts({int page = 1, int limit = 20});
  Future<PostModel> getPostById(int id);
  Future<PostModel> createPost(PostModel post);
  Future<void> deletePost(int id);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final ApiClient apiClient;

  const PostRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PostModel>> getPosts({int page = 1, int limit = 20}) async {
    try {
      final response = await apiClient.get(
        '/posts',
        queryParameters: {'_page': page, '_limit': limit},
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw ServerException(
        message: 'Failed to parse posts response',
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PostModel> createPost(PostModel post) async {
    try {
      final response = await apiClient.post(
        '/posts',
        data: post.toJson(),
      );

      if (response.statusCode == 201 && response.data is Map<String, dynamic>) {
        return PostModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(
        message: 'Failed to create post',
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PostModel> getPostById(int id) async {
    try {
      final response = await apiClient.get('/posts/$id');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return PostModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(message: 'Post not found', statusCode: 404);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deletePost(int id) async {
    try {
      final response = await apiClient.delete('/posts/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(message: 'Failed to delete', statusCode: response.statusCode);
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
```

---

## 4. Invariant Rules for API Integration

1. **MUST NOT** instantiate HTTP clients inside widgets or BLoCs.
2. **MUST NOT** expose HTTP status codes or header dictionaries to the Domain layer.
3. **MUST** catch all networking exceptions inside `RepositoryImpl` and return `Left(Failure)`.
4. **MUST** isolate all JSON parsing inside `data/models/`.
