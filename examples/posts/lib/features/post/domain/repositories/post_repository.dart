import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/post_entity.dart';

// Domain Repository Contract: Defines WHAT data operations exist
abstract class PostRepository {
  Future<Either<Failure, List<PostEntity>>> getPosts();
  Future<Either<Failure, PostEntity>> createPost(PostEntity post);
}
