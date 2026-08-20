import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../bloc/post_state.dart';
import '../widgets/post_card_widget.dart';

// Presentation Screen: Observes PostBloc state and dispatches user actions
class PostListScreen {
  final PostBloc bloc;

  const PostListScreen({required this.bloc});

  void onUserPullToRefresh() {
    bloc.add(const FetchPostsEvent());
  }

  String render(PostState state) {
    if (state.status == PostStatus.loading && state.posts.isEmpty) {
      return 'Loading posts spinner...';
    }
    if (state.status == PostStatus.error && state.posts.isEmpty) {
      return 'Error view: ${state.errorMessage}';
    }
    if (state.posts.isEmpty) {
      return 'Empty view: No posts found.';
    }

    final buffer = StringBuffer();
    if (state.status == PostStatus.loading) {
      buffer.writeln('[Refreshing indicator active]');
    }
    for (final post in state.posts) {
      buffer.writeln(PostCardWidget(post: post).render());
      buffer.writeln('--------------------');
    }
    return buffer.toString();
  }
}
