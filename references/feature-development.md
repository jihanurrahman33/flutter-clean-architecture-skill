# Feature Development Workflow (12-Step Implementation Guide)

This document provides the mandatory step-by-step procedure for AI coding agents implementing new features in a Flutter Clean Architecture application.

---

## 1. End-to-End Execution Pipeline

```text
Step 1: Understand Requirements & Inputs
   ↓
Step 2: Inspect Existing Project Conventions (pubspec, DI, router, state manager)
   ↓
Step 3: Model Domain Concepts (Entities, Operations, Invariants)
   ↓
Step 4: Implement Domain Layer (Entities -> Repo Contract -> Use Cases)
   ↓
Step 5: Implement Data Layer (Models -> Data Sources -> Repo Impl)
   ↓
Step 6: Implement Presentation Layer (Events -> States -> Controller -> Screens -> Widgets)
   ↓
Step 7: Configure Feature Dependency Injection (di.dart)
   ↓
Step 8: Register Feature Routes (core/app/routes.dart)
   ↓
Step 9: Write Layer Unit & BLoC Tests (test/features/<feature>/)
   ↓
Step 10: Format Code (dart format)
   ↓
Step 11: Execute Static Analysis (flutter analyze / dart analyze)
   ↓
Step 12: Architectural Review & Change Summary
```

---

## 2. Step-by-Step Instructions

### Step 1 — Understand Requirements
- Identify core business operations (e.g. `Login`, `FetchProducts`, `SubmitReview`).
- Identify required external services (REST API endpoints, WebSocket streams, SQLite storage).
- Identify required UI views (List screen, Detail screen, Form dialog).

### Step 2 — Inspect Existing Project
- Open `pubspec.yaml` to identify packages:
  - Networking: `dio`, `http`
  - State Management: `flutter_bloc`, `flutter_riverpod`, `provider`
  - Routing: `go_router`, `auto_route`, standard `Navigator`
  - DI: `get_it`, `provider`, `riverpod`
- Inspect an established feature in `lib/features/` to replicate exact conventions (naming, imports, error mapping).

### Step 3 & 4 — Implement Domain Layer (`features/<feature>/domain/`)
1. Create `entities/<feature>_entity.dart`:
   - Declare immutable fields.
   - Inherit from `Equatable` and implement `props`.
   - Ensure zero imports of `package:flutter/*` or serialization logic.
2. Create `repositories/<feature>_repository.dart`:
   - Declare abstract interface with methods returning `Future<Either<Failure, T>>`.
3. Create `usecases/<operation>_usecase.dart`:
   - Implement `UseCase<Type, Params>`.
   - Encapsulate single-purpose business logic.

### Step 5 — Implement Data Layer (`features/<feature>/data/`)
1. Create `models/<feature>_model.dart`:
   - Implement `fromJson`, `toJson`, and mapping to/from Entity.
2. Create `datasources/<feature>_remote_data_source.dart` & `local_data_source.dart`:
   - Interface + Implementation.
   - Inject `ApiClient` and throw typed `ServerException`/`CacheException`.
3. Create `repositories/<feature>_repository_impl.dart`:
   - Implement domain repository contract.
   - Wrap datasource calls in `try/catch` and map exceptions to `Failure`s.

### Step 6 — Implement Presentation Layer (`features/<feature>/presentation/`)
1. Create `bloc/<feature>_event.dart` & `bloc/<feature>_state.dart`:
   - Immutable states preserving existing data during loading/error.
2. Create `bloc/<feature>_bloc.dart`:
   - Inject domain use cases.
   - Emit state changes using `Either.fold()`.
3. Create `screens/<feature>_screen.dart`:
   - Declarative page widget with `BlocConsumer`/`BlocListener` for side effects.
4. Create `widgets/<feature>_card_widget.dart`:
   - Modular child components.

### Step 7 — Configure Feature Dependency Injection (`features/<feature>/di.dart`)
- Register Data Sources $\rightarrow$ Repositories $\rightarrow$ Use Cases $\rightarrow$ Controllers.
- Hook into app-wide injection container (`lib/core/app/injection_container.dart`).

### Step 8 — Register Routes (`lib/core/app/routes.dart`)
- Add route path constants and page builder declarations to global router.

### Step 9 — Implement Tests (`test/features/<feature>/`)
- Domain: Entity equality and Use Case mock tests.
- Data: Model serialization and Repository mock exception tests.
- Presentation: BLoC event-to-state `bloc_test` suites.

### Step 10 & 11 — Format & Analyze
- Format code: `dart format lib/ test/`
- Run linter: `flutter analyze` or `dart analyze`
- Fix all warnings and lints prior to completion.

### Step 12 — Architecture Review
- Verify layer boundaries:
  - Did any UI widget import a Data implementation?
  - Did Domain import Flutter or Dio?
  - Are all dependencies injected?
