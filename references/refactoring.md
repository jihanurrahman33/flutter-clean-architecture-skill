# Refactoring & Migration Runbook

This document defines the protocols for refactoring existing Flutter codebases into Clean Architecture without introducing regressions or breaking existing behaviors.

---

## 1. Refactoring vs Architectural Migration

An AI agent MUST distinguish between two types of codebase transformations:

| Operation Type | Scope | Objective | Risk Level |
| :--- | :--- | :--- | :--- |
| **Behavior-Preserving Refactoring** | Localized (single file or widget) | Clean up code smells, extract widgets, simplify functions, fix linter warnings without changing layer structure. | Low |
| **Architectural Migration** | Global / Feature-wide | Move legacy imperative code (e.g. `StatefulWidget` making `http.get` calls) into Clean Architecture layers. | Medium / High |

> **Rule**: NEVER perform a full-project rewrite in one step. Always migrate incrementally, feature-by-feature, using the **Strangler Fig Pattern**.

---

## 2. Strangler Fig Migration Pattern (Step-by-Step)

When refactoring a legacy Flutter screen (e.g. `LegacyPostScreen` containing `http.get`, `jsonDecode`, and internal state):

```text
Step 1: Extract Domain Entity
   ↓ (Define pure business object)
Step 2: Extract Data Model & Remote Data Source
   ↓ (Move raw HTTP & JSON logic out of the widget)
Step 3: Define Domain Repository Interface & Data Implementation
   ↓ (Wrap DataSource calls & handle failures)
Step 4: Extract Domain Use Cases
   ↓ (Move business logic out of UI)
Step 5: Create Presentation State Controller (BLoC / Cubit)
   ↓ (Connect UI to Use Cases)
Step 6: Refactor UI Widget to Pure Consumer
   ↓ (Remove setState & network calls from UI)
Step 7: Wire DI & Validate
```

---

## 3. Legacy Migration Walkthrough

### 3.1 Initial Legacy Code (Spaghetti Anti-Pattern):
```dart
// legacy_post_screen.dart (BEFORE)
class LegacyPostScreen extends StatefulWidget {
  @override
  _LegacyPostScreenState createState() => _LegacyPostScreenState();
}

class _LegacyPostScreenState extends State<LegacyPostScreen> {
  List<dynamic> posts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('https://api.example.com/posts'));
      if (response.statusCode == 200) {
        setState(() {
          posts = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return CircularProgressIndicator();
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (ctx, i) => Text(posts[i]['title']),
    );
  }
}
```

### 3.2 Systematic Migration Execution:
1. **Create `post_entity.dart`** with `id`, `title`, `body`.
2. **Create `post_model.dart`** with `fromJson()` and `toJson()`.
3. **Create `post_remote_data_source.dart`** taking `ApiClient` and returning `List<PostModel>`.
4. **Create `post_repository.dart`** contract and `post_repository_impl.dart` returning `Future<Either<Failure, List<PostEntity>>>`.
5. **Create `get_posts_usecase.dart`** executing `repository.getPosts()`.
6. **Create `post_bloc.dart`** emitting `PostState(status, posts)`.
7. **Replace `LegacyPostScreen` with `PostListScreen`** consuming `BlocBuilder<PostBloc, PostState>`.

---

## 4. Zero-Breakage Safety Rules for Refactoring

1. **Write Characterization Tests First**: If tests exist, ensure they pass before refactoring. If not, write regression tests against current behavior before moving files.
2. **Keep Legacy Interfaces During Migration (Deprecation Period)**: If other features depend on legacy services, create adapter classes pointing to the new Clean Architecture Use Cases rather than deleting legacy entry points immediately.
3. **Verify Static Analysis After Every Layer**: Do not wait until the entire feature is migrated to run `flutter analyze`. Run analysis after each step to catch type mismatches immediately.
4. **No Unrequested Scope Expansion**: When asked to fix a bug in Feature A, do NOT refactor Feature B or rearrange global folder structures unless explicitly requested.
