import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class CreatePostParams {
  final String title;
  final String body;
  final int userId;

  const CreatePostParams({
    required this.title,
    required this.body,
    required this.userId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatePostParams &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          body == other.body &&
          userId == other.userId;

  @override
  int get hashCode => title.hashCode ^ body.hashCode ^ userId.hashCode;
}

// Single-purpose UseCase for creating a post with domain validation
class CreatePostUseCase implements UseCase<PostEntity, CreatePostParams> {
  final PostRepository repository;

  const CreatePostUseCase({required this.repository});

  @override
  Future<Either<Failure, PostEntity>> call(CreatePostParams params) async {
    if (params.title.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Title cannot be empty.'));
    }
    if (params.body.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Body cannot be empty.'));
    }

    final post = PostEntity(
      id: 0,
      userId: params.userId,
      title: params.title.trim(),
      body: params.body.trim(),
    );

    return await repository.createPost(post);
  }
}
