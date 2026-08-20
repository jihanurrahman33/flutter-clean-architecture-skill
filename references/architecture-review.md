# Architecture Review & Audit Runbook

This document defines the formal auditing protocol, severity classification rubric, and reporting template for reviewing Flutter Clean Architecture codebases.

---

## 1. Severity Classification Rubric

When performing an architectural review, classify every discovered issue according to this rubric:

| Severity Level | Definition | Examples |
| :--- | :--- | :--- |
| **CRITICAL** | Direct architectural invariant violation that breaks layer isolation or corrupts core business logic. | • Domain importing `package:flutter/*` or `dio`.<br>• Presentation importing `*_repository_impl.dart` or `*_data_source.dart`.<br>• Raw API calls executed inside Widget `build()` or `initState()`. |
| **HIGH** | Architectural leak that impairs testability, error handling, or creates tight infrastructure coupling. | • BLoC directly instantiated with `Dio` instead of Use Cases.<br>• Uncaught exceptions escaping Data layer into UI (missing `Either<Failure, T>`).<br>• Entities containing `fromJson()` / `toJson()` serialization logic. |
| **MEDIUM** | Structural or organizational code smell that degrades maintainability. | • Giant 500-line `main.dart` with all global dependencies registered in one place.<br>• Feature-specific business logic placed inside `lib/core/`.<br>• State destruction on loading (empty screen flash on refresh). |
| **LOW** | Minor styling, naming, or cosmetic inconsistency. | • Missing `const` constructor on immutable entities.<br>• Non-standard file naming (e.g. `userModel.dart` instead of `user_model.dart`).<br>• Inconsistent barrel file exports. |

---

## 2. Comprehensive Review Checklist

### 2.1 Domain Purity & Invariants
- [ ] Are all entities pure Dart classes with no Flutter UI, Dio, or database imports?
- [ ] Are repository contracts abstract interfaces located in `domain/repositories/`?
- [ ] Are use cases single-purpose interactors implementing `UseCase<Type, Params>`?
- [ ] Are entities and params immutable and value-comparable (`Equatable` / `props`)?

### 2.2 Data Layer & Serialization
- [ ] Are data sources separated into interfaces and concrete implementations?
- [ ] Do data sources throw typed exceptions (`ServerException`, `CacheException`) instead of returning failures?
- [ ] Are models placed in `data/models/` handling all `fromJson`/`toJson` conversions?
- [ ] Does `RepositoryImpl` wrap all calls in `try/catch` and return `Either<Failure, T>`?

### 2.3 Presentation Layer & State
- [ ] Do widgets and screens only dispatch events/intents to controllers?
- [ ] Do state controllers depend exclusively on Domain Use Cases?
- [ ] Does the UI state preserve existing list/entity data during loading/refresh?
- [ ] Are one-time side-effects (SnackBars, navigation) handled in listeners rather than builders?

### 2.4 Dependency Injection & Routing
- [ ] Are dependencies injected via constructor parameters?
- [ ] Are feature dependencies isolated in `features/<feature>/di.dart`?
- [ ] Are routes centralized in `core/app/routes.dart`?

---

## 3. Architecture Review Report Template

When asked to perform an architecture review or evaluate a PR, format the findings using this structured markdown format:

```markdown
# Architecture Review Report: [Feature or Codebase Name]

## Executive Summary
- **Overall Architecture Status**: [Pass / Requires Changes / Critical Remediation Needed]
- **Total Issues Found**: [X] Critical, [Y] High, [Z] Medium, [W] Low

---

## Detailed Findings

### [CRITICAL | HIGH | MEDIUM | LOW] 1. [Short Descriptive Title]
- **Affected Files**: `lib/features/post/presentation/screens/post_screen.dart`
- **Rule Violated**: INVARIANT-04 (Presentation must not depend directly on Data implementations)
- **Observed Code**:
  ```dart
  import 'package:app/features/post/data/repositories/post_repository_impl.dart';
  final repo = PostRepositoryImpl(remoteDataSource: ...);
  ```
- **Architectural Impact**: Creates hard coupling between UI and concrete networking layer, preventing unit testing without mocking network sockets.
- **Recommended Remediation**:
  Inject `GetPostsUseCase` into `PostBloc` via `di.dart`, and have the screen read `context.read<PostBloc>()`.

---

## Recommended Action Plan
1. Fix Critical layer leakage violations in `lib/features/...`
2. Extract Data layer models from Domain entities.
3. Decouple DI registration from `main.dart` into feature-specific `di.dart` modules.
```
