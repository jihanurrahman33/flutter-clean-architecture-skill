# Navigation & Routing Architecture

This document defines the routing architecture, route modularization, argument passing standards, and UI decoupling for Flutter Clean Architecture.

---

## 1. Centralized Routing Architecture

Application routes MUST be centralized in `lib/core/app/routes.dart` (or `router.dart`). Navigation logic MUST NOT be scattered across unrelated widgets with ad-hoc `MaterialPageRoute` calls.

```text
lib/core/app/
├── app.dart                      # MaterialApp / CupertinoApp configuration
├── routes.dart                   # Global route registry & path constants
└── route_observer.dart           # App-wide navigation analytics / logging
```

---

## 2. Declarative Routing with `go_router` (Recommended)

When `go_router` is present in `pubspec.yaml`, define route constants and modular feature routes:

```dart
// lib/core/app/routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart';
import 'package:app/features/post/presentation/screens/create_post_screen.dart';
import 'package:app/features/post/presentation/screens/post_detail_screen.dart';
import 'package:app/features/post/presentation/screens/post_list_screen.dart';

abstract class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String posts = '/posts';
  static const String postDetail = '/posts/:id';
  static const String createPost = '/create-post';

  static String postDetailPath(int id) => '/posts/$id';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.posts,
  routes: [
    GoRoute(
      path: AppRoutes.posts,
      builder: (context, state) => const PostListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final postId = int.parse(state.pathParameters['id']!);
            return PostDetailScreen(postId: postId);
          },
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.createPost,
      builder: (context, state) => const CreatePostScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);
```

---

## 3. Imperative / Named Routes Fallback

For legacy or non-`go_router` codebases:

```dart
// lib/core/app/routes.dart
import 'package:flutter/material.dart';
import 'package:app/features/post/presentation/screens/create_post_screen.dart';
import 'package:app/features/post/presentation/screens/post_list_screen.dart';

class AppRoutes {
  static const String posts = '/posts';
  static const String createPost = '/create-post';

  static Map<String, WidgetBuilder> get routes => {
        posts: (context) => const PostListScreen(),
        createPost: (context) => const CreatePostScreen(),
      };
}
```

---

## 4. Parameter Passing Rules

1. **Pass Identifiers, Not Full Mutable Objects**: When navigating to detail screens, pass primitive identifiers (`id: 42`) via route parameters rather than entire mutable objects. The destination screen/BLoC fetches fresh entity data from its own Use Case (`GetPostByIdUseCase`).
2. **Deep-Link Friendly**: Parameterized URLs (`/posts/42`) allow seamless web URLs and deep-linking into specific application states.
3. **No Direct Data/Repository Coupling in Router**: The router only instantiates Presentation screens and extracts parameters. It MUST NOT execute use cases or database queries.
