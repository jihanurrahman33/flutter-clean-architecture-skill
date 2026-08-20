# Flutter Clean Architecture Anti-Patterns

This catalog documents forbidden architectural patterns, why they violate Clean Architecture, concrete Bad vs. Good code examples, and remediation steps.

---

## 1. Anti-Pattern: Direct API Calls Inside Widgets

### Bad Code:
```dart
// lib/features/post/presentation/screens/post_list_screen.dart
class PostListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Dio().get('https://api.example.com/posts'),
      builder: (context, snapshot) {
        if (snapshot.hasData) return ListView(...);
        return CircularProgressIndicator();
      },
    );
  }
}
```

### Why It Is Forbidden:
Tightly couples the UI to a specific HTTP package and network endpoint. Eliminates separation of concerns, makes UI widget testing impossible without network mocks, and bypasses caching, error handling, and state management.

### Good Code:
```dart
class PostListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state.status == PostStatus.loaded) {
          return ListView.builder(
            itemCount: state.posts.length,
            itemBuilder: (ctx, i) => PostCardWidget(post: state.posts[i]),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
```

---

## 2. Anti-Pattern: HTTP Client (`Dio`) Inside BLoC / Controller

### Bad Code:
```dart
// lib/features/post/presentation/bloc/post_bloc.dart
class PostBloc extends Bloc<PostEvent, PostState> {
  final Dio dio;

  PostBloc({required this.dio}) : super(PostInitialState()) {
    on<FetchPostsEvent>((event, emit) async {
      final response = await dio.get('/posts');
      emit(PostLoadedState(posts: response.data));
    });
  }
}
```

### Why It Is Forbidden:
Controllers belong to the Presentation layer. Injecting `Dio` into a BLoC skips the entire Domain and Data layers, coupling UI state controllers directly to network transport details.

### Good Code:
```dart
class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPostsUseCase;

  PostBloc({required this.getPostsUseCase}) : super(const PostState()) {
    on<FetchPostsEvent>((event, emit) async {
      emit(state.copyWith(status: PostStatus.loading));
      final result = await getPostsUseCase(const NoParams());
      result.fold(
        (failure) => emit(state.copyWith(status: PostStatus.error, errorMessage: failure.message)),
        (posts) => emit(state.copyWith(status: PostStatus.loaded, posts: posts)),
      );
    });
  }
}
```

---

## 3. Anti-Pattern: JSON Serialization Inside Domain Entities

### Bad Code:
```dart
// lib/features/post/domain/entities/post_entity.dart
class PostEntity {
  final int id;
  final String title;

  const PostEntity({required this.id, required this.title});

  factory PostEntity.fromJson(Map<String, dynamic> json) {
    return PostEntity(id: json['id'], title: json['title']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'title': title};
}
```

### Why It Is Forbidden:
Entities represent pure enterprise business rules. Adding `fromJson`/`toJson` tightly couples Domain to external API schemas. When an API field name changes from `title` to `post_title`, the Domain layer is forced to modify.

### Good Code:
```dart
// Entity in Domain: Pure
class PostEntity extends Equatable {
  final int id;
  final String title;
  const PostEntity({required this.id, required this.title});
  @override List<Object?> get props => [id, title];
}

// Model in Data: Handles Serialization
class PostModel extends PostEntity {
  const PostModel({required super.id, required super.title});

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(id: json['id'] as int, title: json['title'] as String);
  }
  Map<String, dynamic> toJson() => {'id': id, 'title': title};
}
```

---

## 4. Anti-Pattern: Presentation Importing Concrete Data Implementations

### Bad Code:
```dart
// lib/features/post/presentation/screens/post_screen.dart
import 'package:app/features/post/data/repositories/post_repository_impl.dart';
import 'package:app/features/post/data/datasources/post_remote_data_source.dart';

final repo = PostRepositoryImpl(remoteDataSource: PostRemoteDataSourceImpl());
```

### Why It Is Forbidden:
Violates the Dependency Inversion Principle. Presentation MUST depend only on abstract Domain contracts (`PostRepository`) and Domain Use Cases, wired via Dependency Injection.

---

## 5. Anti-Pattern: Massive Monolithic `main.dart`

### Bad Code:
```dart
// lib/main.dart (1,200 lines long)
void main() {
  sl.registerSingleton(Dio());
  sl.registerSingleton(AuthRemoteDataSourceImpl(...));
  sl.registerSingleton(AuthRepositoryImpl(...));
  sl.registerSingleton(LoginUseCase(...));
  sl.registerSingleton(PostRemoteDataSourceImpl(...));
  sl.registerSingleton(PostRepositoryImpl(...));
  sl.registerSingleton(GetPostsUseCase(...));
  // 100 more registrations...
  runApp(MyApp());
}
```

### Why It Is Forbidden:
`main.dart` becomes a massive merge-conflict bottleneck that degrades maintainability.

### Good Code:
Decentralize registration into feature modules:
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initCoreDependencies(sl);
  initAuthFeature(sl);
  initPostFeature(sl);
  runApp(const MyApp());
}
```

---

## 6. Anti-Pattern: Feature-Specific Code Polluting `lib/core/`

### Bad Code:
```text
lib/core/
├── post_service.dart          <-- FORBIDDEN in core
├── auth_interceptor.dart       <-- Should be in core/networking if generic, or features/auth
└── product_calculator.dart    <-- FORBIDDEN in core
```

### Why It Is Forbidden:
Core is for application-wide reusable primitives. Placing business logic in Core destroys modular feature isolation.

---

## 7. Anti-Pattern: Destructive Loading States (Empty Screen Flashing)

### Bad Code:
```dart
// In BLoC:
on<FetchPostsEvent>((event, emit) {
  emit(PostLoadingState()); // Destroys previous posts!
});
```

### Why It Is Forbidden:
When refreshing or paginating, the screen completely wipes the visible content and displays a full-screen loading spinner.

### Good Code:
```dart
on<FetchPostsEvent>((event, emit) {
  // Preserve currently loaded posts in state
  emit(state.copyWith(status: PostStatus.loading));
});
```

---

## 8. Anti-Pattern: Premature Generic Repository Overengineering

### Bad Code:
```dart
abstract class IGenericRepository<T, ID, QueryParams, MutationParams> {
  Future<Either<Failure, List<T>>> getAll(QueryParams params);
  Future<Either<Failure, T>> getById(ID id);
  Future<Either<Failure, T>> create(MutationParams params);
  Future<Either<Failure, T>> update(ID id, MutationParams params);
  Future<Either<Failure, void>> delete(ID id);
}
```

### Why It Is Forbidden:
Forces every domain concept into rigid CRUD semantics even when features require non-CRUD actions (e.g. `TransferFunds`, `VerifyOtp`, `SubmitExam`).

### Good Code:
Create explicit, tailored repository contracts for each domain aggregate: `PostRepository`, `AuthRepository`, `PaymentRepository`.
