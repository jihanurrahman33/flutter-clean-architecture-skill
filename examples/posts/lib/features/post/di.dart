import '../../core/networking/api_client.dart';
import 'data/datasources/post_remote_data_source.dart';
import 'data/repositories/post_repository_impl.dart';
import 'domain/repositories/post_repository.dart';
import 'domain/usecases/create_post_usecase.dart';
import 'domain/usecases/get_posts_usecase.dart';
import 'presentation/bloc/post_bloc.dart';

// Feature Dependency Container: Wires layers in strict order
class PostFeatureDependencies {
  final ApiClient apiClient;

  late final PostRemoteDataSource remoteDataSource;
  late final PostRepository repository;
  late final GetPostsUseCase getPostsUseCase;
  late final CreatePostUseCase createPostUseCase;

  PostFeatureDependencies({required this.apiClient}) {
    // 1. Data Source
    remoteDataSource = PostRemoteDataSourceImpl(apiClient: apiClient);

    // 2. Repository (Domain contract interface implemented by Data concrete class)
    repository = PostRepositoryImpl(remoteDataSource: remoteDataSource);

    // 3. Use Cases (Domain interactors)
    getPostsUseCase = GetPostsUseCase(repository: repository);
    createPostUseCase = CreatePostUseCase(repository: repository);
  }

  // 4. Factory for transient presentation controller
  PostBloc createBloc() {
    return PostBloc(
      getPostsUseCase: getPostsUseCase,
      createPostUseCase: createPostUseCase,
    );
  }
}
