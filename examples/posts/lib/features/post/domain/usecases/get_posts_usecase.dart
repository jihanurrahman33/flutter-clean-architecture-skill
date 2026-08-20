import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

// Single-purpose UseCase for fetching posts
class GetPostsUseCase implements UseCase<List<PostEntity>, NoParams> {
  final PostRepository repository;

  const GetPostsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<PostEntity>>> call(NoParams params) async {
    return await repository.getPosts();
  }
}
