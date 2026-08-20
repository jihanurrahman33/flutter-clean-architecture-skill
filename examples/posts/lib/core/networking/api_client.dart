import 'dart:convert';
import '../error/exceptions.dart';

class ApiResponse {
  final int statusCode;
  final dynamic data;

  const ApiResponse({required this.statusCode, required this.data});
}

abstract class ApiClient {
  Future<ApiResponse> get(String path, {Map<String, dynamic>? queryParameters});
  Future<ApiResponse> post(String path, {dynamic data});
}

class FakeApiClient implements ApiClient {
  final List<Map<String, dynamic>> _inMemoryPosts = [
    {
      'id': 1,
      'userId': 101,
      'title': 'Introduction to Clean Architecture',
      'body': 'Domain, Data, and Presentation layers working in harmony.',
    },
    {
      'id': 2,
      'userId': 102,
      'title': 'Inversion of Control in Flutter',
      'body': 'How abstract repository contracts isolate business logic.',
    },
  ];

  @override
  Future<ApiResponse> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (path == '/posts') {
      return ApiResponse(statusCode: 200, data: _inMemoryPosts);
    }
    throw const ServerException(message: 'Endpoint not found', statusCode: 404);
  }

  @override
  Future<ApiResponse> post(String path, {dynamic data}) async {
    if (path == '/posts' && data is Map<String, dynamic>) {
      final newPost = Map<String, dynamic>.from(data);
      newPost['id'] = _inMemoryPosts.length + 1;
      _inMemoryPosts.insert(0, newPost);
      return ApiResponse(statusCode: 201, data: newPost);
    }
    throw const ServerException(message: 'Invalid payload', statusCode: 400);
  }
}
