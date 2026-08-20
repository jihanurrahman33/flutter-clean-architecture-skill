# Dependency Injection & Inversion of Control

This document defines the Dependency Injection (DI) architecture, dependency graph resolution, feature-scoped registration modules, and container-agnostic integration patterns for Flutter Clean Architecture.

---

## 1. Dependency Graph & Injection Order

Clean Architecture demands explicit dependency injection. Dependencies MUST flow inward, wired in the following strict order:

```text
1. Infrastructure Clients (ApiClient, DatabaseHelper, LocalStorage)
       ↓ (injected into)
2. Data Sources (RemoteDataSource, LocalDataSource)
       ↓ (injected into)
3. Repositories (Repository Implementation fulfilling Domain Contract)
       ↓ (injected into)
4. Use Cases (Single-purpose domain interactors)
       ↓ (injected into)
5. Presentation Controllers (BLoCs, Cubits, Notifiers)
       ↓ (provided to)
6. UI Screens & Widgets
```

---

## 2. Feature-Level Dependency Injection (`di.dart`)

To prevent `main.dart` from turning into an unmaintainable multi-thousand-line god-file, dependency registration MUST be decentralized into feature-level DI modules (`features/<feature_name>/di.dart`).

### 2.1 Pattern A: Service Locator (`get_it`)

```dart
// lib/features/post/di.dart
import 'package:get_it/get_it.dart';
import 'package:app/core/networking/api_client.dart';
import 'package:app/features/post/data/datasources/post_remote_data_source.dart';
import 'package:app/features/post/data/repositories/post_repository_impl.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:app/features/post/domain/usecases/create_post_usecase.dart';
import 'package:app/features/post/domain/usecases/get_posts_usecase.dart';
import 'package:app/features/post/presentation/bloc/post_bloc.dart';

void initPostFeature(GetIt sl) {
  // 1. Data Sources
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // 2. Repositories (Register contract interface with concrete implementation)
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(remoteDataSource: sl<PostRemoteDataSource>()),
  );

  // 3. Use Cases
  sl.registerLazySingleton<GetPostsUseCase>(
    () => GetPostsUseCase(repository: sl<PostRepository>()),
  );
  sl.registerLazySingleton<CreatePostUseCase>(
    () => CreatePostUseCase(repository: sl<PostRepository>()),
  );

  // 4. Presentation Controllers (Factory for stateful controllers)
  sl.registerFactory<PostBloc>(
    () => PostBloc(
      getPostsUseCase: sl<GetPostsUseCase>(),
      createPostUseCase: sl<CreatePostUseCase>(),
    ),
  );
}
```

Then in global initialization (`lib/core/app/injection_container.dart` or `main.dart`):
```dart
final sl = GetIt.instance;

Future<void> initGlobalDependencies() async {
  // Global Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Features
  initAuthFeature(sl);
  initPostFeature(sl);
}
```

---

### 2.2 Pattern B: Declarative Providers (`flutter_bloc` / `provider`)

For projects using widget-tree dependency injection:

```dart
// lib/features/post/presentation/screens/post_feature_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/networking/api_client.dart';
import 'package:app/features/post/data/datasources/post_remote_data_source.dart';
import 'package:app/features/post/data/repositories/post_repository_impl.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:app/features/post/domain/usecases/create_post_usecase.dart';
import 'package:app/features/post/domain/usecases/get_posts_usecase.dart';
import 'package:app/features/post/presentation/bloc/post_bloc.dart';
import 'package:app/features/post/presentation/screens/post_list_screen.dart';

class PostFeatureProvider extends StatelessWidget {
  const PostFeatureProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PostRemoteDataSource>(
          create: (context) => PostRemoteDataSourceImpl(
            apiClient: context.read<ApiClient>(),
          ),
        ),
        RepositoryProvider<PostRepository>(
          create: (context) => PostRepositoryImpl(
            remoteDataSource: context.read<PostRemoteDataSource>(),
          ),
        ),
        RepositoryProvider<GetPostsUseCase>(
          create: (context) => GetPostsUseCase(
            repository: context.read<PostRepository>(),
          ),
        ),
        RepositoryProvider<CreatePostUseCase>(
          create: (context) => CreatePostUseCase(
            repository: context.read<PostRepository>(),
          ),
        ),
      ],
      child: BlocProvider<PostBloc>(
        create: (context) => PostBloc(
          getPostsUseCase: context.read<GetPostsUseCase>(),
          createPostUseCase: context.read<CreatePostUseCase>(),
        ),
        child: const PostListScreen(),
      ),
    );
  }
}
```

---

### 2.3 Pattern C: `riverpod` Functional Dependency Graph

```dart
// lib/features/post/di.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/networking/api_client.dart';
import 'package:app/features/post/data/datasources/post_remote_data_source.dart';
import 'package:app/features/post/data/repositories/post_repository_impl.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:app/features/post/domain/usecases/get_posts_usecase.dart';

final postRemoteDataSourceProvider = Provider<PostRemoteDataSource>((ref) {
  return PostRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(
    remoteDataSource: ref.watch(postRemoteDataSourceProvider),
  );
});

final getPostsUseCaseProvider = Provider<GetPostsUseCase>((ref) {
  return GetPostsUseCase(repository: ref.watch(postRepositoryProvider));
});
```

---

## 3. Dependency Injection Rules & Invariants

1. **Explicit Parameters**: Classes MUST declare all required collaborators as constructor parameters.
2. **Contract Registration**: Repositories MUST be registered under their **Domain Abstract Interface Type** (`PostRepository`), NOT the concrete class (`PostRepositoryImpl`).
3. **Lifecycles**:
   - Singletons / Lazy Singletons: Clients, Data Sources, Repositories, Use Cases (stateless).
   - Factories / Transient: Presentation Controllers (BLoCs, Cubits, Notifiers) tied to UI screen lifecycles.
4. **No Direct Instantiation**: Classes MUST NOT instantiate their collaborators via default constructor calls (`final repo = PostRepositoryImpl(...)` inside a BLoC or Use Case is strictly prohibited).
