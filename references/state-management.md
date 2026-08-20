# State Management Architecture & Guidelines

Clean Architecture isolates domain logic from UI concerns. Consequently, **Clean Architecture is independent of any specific state-management library**.

Whether a project uses **BLoC**, **Cubit**, **Riverpod**, **Provider**, or **Signals**, the architectural boundaries and dependency flow remain identical:

```text
UI (Widget / Screen)
       │ (dispatches intent)
       ▼
State Controller (BLoC / Cubit / Notifier)
       │ (invokes)
       ▼
Domain Use Case
       │ (calls)
       ▼
Domain Repository Contract
```

---

## 1. State Management Agnostic Principles

1. **State Controllers Are Presentation-Only**: BLoCs, Cubits, and Riverpod Notifiers reside strictly in `presentation/`. They MUST NOT contain business algorithms or raw API requests.
2. **Domain Isolation**: Domain entities and use cases MUST NOT import `flutter_bloc`, `flutter_riverpod`, `provider`, or `flutter/material.dart`.
3. **Immutable State Objects**: All UI state classes MUST be immutable with value-equality (`Equatable`, `@freezed`, or custom `==`).
4. **Preserve Existing State**: Do not wipe out previously loaded data when transitioning into loading or minor error states.
5. **Respect Existing Project Choice**: An AI agent MUST inspect the project's existing state management solution and continue using it. NEVER introduce a competing state manager without explicit user request.

---

## 2. Supported State Management Patterns

### 2.1 Pattern A: BLoC (Event-Driven)
Best for complex features with multiple asynchronous user actions and clear audit-trail requirements.

```dart
// Event
abstract class PostEvent extends Equatable {
  const PostEvent();
  @override
  List<Object?> get props => [];
}

class FetchPostsEvent extends PostEvent {
  const FetchPostsEvent();
}

// State
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

// BLoC Controller
class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPostsUseCase;

  PostBloc({required this.getPostsUseCase}) : super(const PostState()) {
    on<FetchPostsEvent>((event, emit) async {
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
    });
  }
}
```

---

### 2.2 Pattern B: Cubit (Function-Driven)
Best for medium-complexity features where explicit event classes would introduce unnecessary boilerplate.

```dart
class PostCubit extends Cubit<PostState> {
  final GetPostsUseCase getPostsUseCase;

  PostCubit({required this.getPostsUseCase}) : super(const PostState());

  Future<void> fetchPosts() async {
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
}
```

---

### 2.3 Pattern C: Riverpod (`AsyncNotifier` / `Notifier`)
Best for modern declarative Flutter codebases utilizing compile-safe global dependency graph.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/usecases/usecase.dart';
import 'package:app/features/post/domain/entities/post_entity.dart';
import 'package:app/features/post/domain/usecases/get_posts_usecase.dart';

class PostsNotifier extends AutoDisposeAsyncNotifier<List<PostEntity>> {
  @override
  Future<List<PostEntity>> build() async {
    return _fetchPosts();
  }

  Future<List<PostEntity>> _fetchPosts() async {
    final getPostsUseCase = ref.read(getPostsUseCaseProvider);
    final result = await getPostsUseCase(const NoParams());
    return result.fold(
      (failure) => throw Exception(failure.message),
      (posts) => posts,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPosts());
  }
}

final postsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<PostsNotifier, List<PostEntity>>(
  PostsNotifier.new,
);
```

---

## 3. State Management Selection & Inspection Rules

When working on a Flutter project:
1. **Check `pubspec.yaml`**:
   - `flutter_bloc` present $\rightarrow$ Use BLoC / Cubit.
   - `flutter_riverpod` present $\rightarrow$ Use Riverpod Notifiers.
   - `provider` present $\rightarrow$ Use `ChangeNotifier` / `ValueNotifier`.
2. **Inspect Existing Feature**: Look at an established feature in `lib/features/` to mirror its exact controller style and state structure.
3. **Do Not Mix Paradigms**: Do NOT build one feature with BLoC and another with Riverpod in the same project unless part of an explicit, planned migration.
