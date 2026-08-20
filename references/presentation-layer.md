# Presentation Layer Architecture & Standards

The **Presentation Layer** contains everything related to the user interface: Screens, Widgets, State Management Controllers (BLoCs, Cubits, Notifiers), Events, and UI States. It transforms user interactions into Domain Use Case invocations and reflects application state back to the user.

---

## 1. Presentation Layer Components

```text
features/<feature_name>/presentation/
├── bloc/                         # (or cubit/riverpod/controller)
│   ├── post_bloc.dart            # State controller / mediator
│   ├── post_event.dart           # User intentions / triggers
│   └── post_state.dart           # Immutable UI state snapshots
├── screens/                      # Full-screen pages bound to routes
│   ├── create_post_screen.dart
│   └── post_list_screen.dart
└── widgets/                      # Modular, reusable UI components
    ├── post_card_widget.dart
    └── post_empty_view.dart
```

---

## 2. Separation of Concerns in UI

### 2.1 Screens vs Widgets
- **Screens (`*_screen.dart`)**:
  - Full-screen page widgets representing route targets.
  - Coordinate high-level layout (`Scaffold`, `AppBar`).
  - Provide or access the feature's state controller (`BlocProvider`, `ConsumerWidget`).
  - Listen for one-time side-effects (`BlocListener` for SnackBars, navigation, dialogs).
- **Widgets (`*_widget.dart`)**:
  - Small, focused, reusable UI components.
  - Receive data via constructor parameters or narrow context reads.
  - Dispatch events or execute callbacks without embedding business decisions.

### 2.2 Strict UI Invariants
- **MUST NOT** instantiate HTTP clients or call remote APIs inside widgets (`FutureBuilder(future: Dio().get(...))` is forbidden).
- **MUST NOT** perform business calculations or validation logic in widgets (delegate to Domain Use Cases or Entities).
- **MUST NOT** import `data/` concrete implementations (e.g. `*_repository_impl.dart`, `*_remote_data_source.dart`, `*_model.dart`).

---

## 3. UI State Preservation Pattern

> **Critical Rule**: UI states MUST NOT wipe out previously loaded data during loading or minor error events.

### Bad Pattern (Destructive State Transitions):
```text
State: PostLoadedState([Post1, Post2])
                ↓ (User pulls to refresh)
State: PostLoadingState()  --> Screen flashes empty spinner, destroying cached list!
                ↓ (Network error occurs)
State: PostErrorState()    --> Screen shows full-page error, losing all content!
```

### Clean Architecture Pattern (Preserving State):
```text
State: PostLoadedState(posts: [Post1, Post2])
                ↓ (User pulls to refresh)
State: PostLoadingState(posts: [Post1, Post2])  --> UI displays list with subtle overlay/refresh indicator!
                ↓ (Network error occurs)
State: PostErrorState(posts: [Post1, Post2], errorMessage: "Offline") --> UI shows cached list + SnackBar error!
```

#### Example State Hierarchy:
```dart
import 'package:equatable/equatable.dart';
import 'package:app/features/post/domain/entities/post_entity.dart';

enum PostStatus { initial, loading, loaded, error }

class PostState extends Equatable {
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
  List<Object?> get props => [status, posts, errorMessage];
}
```

---

## 4. State Controller Implementation (BLoC Example)

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/usecases/usecase.dart';
import 'package:app/features/post/domain/usecases/create_post_usecase.dart';
import 'package:app/features/post/domain/usecases/get_posts_usecase.dart';
import 'package:app/features/post/presentation/bloc/post_event.dart';
import 'package:app/features/post/presentation/bloc/post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPostsUseCase;
  final CreatePostUseCase createPostUseCase;

  PostBloc({
    required this.getPostsUseCase,
    required this.createPostUseCase,
  }) : super(const PostState()) {
    on<FetchPostsEvent>(_onFetchPosts);
    on<CreatePostEvent>(_onCreatePost);
  }

  Future<void> _onFetchPosts(
    FetchPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    // Preserve current posts during loading
    emit(state.copyWith(status: PostStatus.loading));

    final result = await getPostsUseCase(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      )),
      (posts) => emit(state.copyWith(
        status: PostStatus.loaded,
        posts: posts,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onCreatePost(
    CreatePostEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading));

    final result = await createPostUseCase(
      CreatePostParams(
        title: event.title,
        body: event.body,
        userId: event.userId,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      )),
      (newPost) {
        final updatedPosts = List.of(state.posts)..insert(0, newPost);
        emit(state.copyWith(
          status: PostStatus.loaded,
          posts: updatedPosts,
        ));
      },
    );
  }
}
```

---

## 5. Screen Implementation Standards

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/post/presentation/bloc/post_bloc.dart';
import 'package:app/features/post/presentation/bloc/post_event.dart';
import 'package:app/features/post/presentation/bloc/post_state.dart';
import 'package:app/features/post/presentation/widgets/post_card_widget.dart';

class PostListScreen extends StatelessWidget {
  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clean Architecture Posts')),
      body: BlocConsumer<PostBloc, PostState>(
        listener: (context, state) {
          if (state.status == PostStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == PostStatus.loading && state.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.posts.isEmpty && state.status == PostStatus.loaded) {
            return const Center(child: Text('No posts found.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PostBloc>().add(const FetchPostsEvent());
            },
            child: ListView.builder(
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                return PostCardWidget(post: state.posts[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-post'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

## 6. Presentation Invariant Checklist

Before finalizing any Presentation layer file, verify:
- [ ] No direct API/HTTP/database calls inside widgets or screens.
- [ ] Controllers depend only on Domain Use Cases.
- [ ] UI states preserve cached/existing data where appropriate.
- [ ] Side-effects (SnackBars, navigation) are handled via listeners, not builders.
- [ ] Presentation imports zero files from `data/` or internal modules of other features.
