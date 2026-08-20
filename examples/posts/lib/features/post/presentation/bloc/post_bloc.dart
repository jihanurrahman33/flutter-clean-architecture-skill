import 'dart:async';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/get_posts_usecase.dart';
import 'post_event.dart';
import 'post_state.dart';

// Pure State Controller (BLoC Pattern)
class PostBloc {
  final GetPostsUseCase getPostsUseCase;
  final CreatePostUseCase createPostUseCase;

  PostState _state = const PostState();
  final _stateController = StreamController<PostState>.broadcast();

  PostBloc({
    required this.getPostsUseCase,
    required this.createPostUseCase,
  });

  PostState get state => _state;
  Stream<PostState> get stream => _stateController.stream;

  void add(PostEvent event) {
    if (event is FetchPostsEvent) {
      _onFetchPosts();
    } else if (event is CreatePostEvent) {
      _onCreatePost(event);
    }
  }

  Future<void> _onFetchPosts() async {
    _emit(_state.copyWith(status: PostStatus.loading));

    final result = await getPostsUseCase(const NoParams());

    result.fold(
      (failure) => _emit(_state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      )),
      (posts) => _emit(_state.copyWith(
        status: PostStatus.loaded,
        posts: posts,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onCreatePost(CreatePostEvent event) async {
    _emit(_state.copyWith(status: PostStatus.loading));

    final result = await createPostUseCase(
      CreatePostParams(
        title: event.title,
        body: event.body,
        userId: event.userId,
      ),
    );

    result.fold(
      (failure) => _emit(_state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      )),
      (createdPost) {
        final updatedPosts = List.of(_state.posts)..insert(0, createdPost);
        _emit(_state.copyWith(
          status: PostStatus.loaded,
          posts: updatedPosts,
          errorMessage: null,
        ));
      },
    );
  }

  void _emit(PostState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  void dispose() {
    _stateController.close();
  }
}
