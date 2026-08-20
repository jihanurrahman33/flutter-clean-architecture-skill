// Presentation Events: Represent user intentions
abstract class PostEvent {
  const PostEvent();
}

class FetchPostsEvent extends PostEvent {
  const FetchPostsEvent();
}

class CreatePostEvent extends PostEvent {
  final String title;
  final String body;
  final int userId;

  const CreatePostEvent({
    required this.title,
    required this.body,
    required this.userId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatePostEvent &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          body == other.body &&
          userId == other.userId;

  @override
  int get hashCode => title.hashCode ^ body.hashCode ^ userId.hashCode;
}
