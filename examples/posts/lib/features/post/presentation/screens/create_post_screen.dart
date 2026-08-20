import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';

// Presentation Screen: Collects user form input and dispatches CreatePostEvent
class CreatePostScreen {
  final PostBloc bloc;

  const CreatePostScreen({required this.bloc});

  void onSubmitPost({
    required String title,
    required String body,
    required int userId,
  }) {
    bloc.add(
      CreatePostEvent(
        title: title,
        body: body,
        userId: userId,
      ),
    );
  }
}
