import '../../domain/entities/post_entity.dart';

// Modular UI component representing a single post card
class PostCardWidget {
  final PostEntity post;

  const PostCardWidget({required this.post});

  String render() {
    return '[Card #${post.id}] ${post.title}\n${post.body} (User: ${post.userId})';
  }
}
