import '../../../../core/error/exceptions.dart';
import '../../../../core/networking/api_client.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts();
  Future<PostModel> createPost(PostModel post);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final ApiClient apiClient;

  const PostRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await apiClient.get('/posts');
      if (response.statusCode == 200 && response.data is List) {
        final rawList = response.data as List<dynamic>;
        return rawList
            .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException(
        message: 'Failed to fetch posts',
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
      final response = await apiClient.post('/posts', data: post.toJson());
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
}
