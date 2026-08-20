import '../../domain/entities/post_entity.dart';

enum PostStatus { initial, loading, loaded, error }

// Presentation State: Preserves cached posts on loading/error
class PostState {
  final PostStatus status;
  final List<PostEntity> posts;
  final String? errorMessage;

  const PostState({
    this.status = PostStatus.initial,
    this.posts = const [],
    this.errorMessage,
  });

  PostState copyWith({
    PostStatus? status,
    List<PostEntity>? posts,
    String? errorMessage,
  }) {
    return PostState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          errorMessage == other.errorMessage &&
          posts.length == other.posts.length;

  @override
  int get hashCode => status.hashCode ^ posts.hashCode ^ errorMessage.hashCode;
}
