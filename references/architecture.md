# Architecture Core Principles & Invariants

This document establishes the foundational architectural concepts, layer boundaries, dependency rules, and invariant constraints for Flutter applications following Clean Architecture.

---

## 1. Architectural Layers & Boundaries

The system is organized into three primary layers, flanked by a shared Core infrastructure layer:

```text
┌─────────────────────────────────────────────────────────────────┐
│                      Presentation Layer                         │
│   (Screens, Widgets, BLoC / Cubit / Notifiers, UI State)        │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                │ depends on (Calls Use Cases & Observes State)
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Domain Layer                             │
│   (Entities, Value Objects, Use Cases, Repository Contracts)    │
└───────────────────────────────▲─────────────────────────────────┘
                                │
                                │ implements contracts (Inversion of Control)
┌───────────────────────────────┴─────────────────────────────────┐
│                         Data Layer                              │
│   (Models, Remote/Local Data Sources, Repository Implementations)│
└─────────────────────────────────────────────────────────────────┘
```

```text
┌─────────────────────────────────────────────────────────────────┐
│                         Core Layer                              │
│   (Cross-cutting utilities, Base Failures, Global Network Client)│
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. The Dependency Rule

> **The Dependency Rule**: Source code dependencies MUST only point inward toward the Domain layer. Inner layers MUST NOT know anything about outer layers.

| Layer | Can Import / Depend On | MUST NOT Import / Depend On |
| :--- | :--- | :--- |
| **Domain** | `core/error/failures.dart`, `core/usecases/usecase.dart`, pure Dart packages | Flutter UI (`package:flutter/*`), `Data` implementations, `Presentation`, HTTP clients (`dio`, `http`), local storage (`hive`, `shared_preferences`, `sqflite`), state managers (`flutter_bloc`, `riverpod`) |
| **Data** | `Domain`, `core/networking/*`, `core/error/*`, storage/network libraries | `Presentation`, Flutter UI widgets |
| **Presentation** | `Domain`, `core/theme/*`, `core/widgets/*`, state managers (`flutter_bloc`, `riverpod`), UI libraries | `Data` layer implementations (`*_repository_impl.dart`, `*_data_source.dart`, `*_model.dart`) |
| **Core** | Pure Dart, common shared utilities | Specific feature domain/data/presentation logic |

---

## 3. Layer Responsibilities Summary

### 3.1 Domain Layer (The Pure Core)
- **Role**: Encapsulates enterprise and application business logic.
- **Components**:
  - **Entities**: Business objects holding state and domain validation rules.
  - **Repository Contracts**: Abstract interfaces defining operations without implementation details.
  - **Use Cases**: Single-purpose interactors coordinating specific business workflows.
- **Rule**: Pure Dart only. Zero knowledge of serialization, network protocols, databases, or UI frameworks.

### 3.2 Data Layer (External Systems & Infrastructure)
- **Role**: Coordinates data retrieval, local persistence, caching, and network communication.
- **Components**:
  - **Models**: Data transfer representations containing serialization logic (`fromJson`, `toJson`, `toEntity`).
  - **Data Sources**: Concrete clients for external mechanisms (`RemoteDataSource` for APIs, `LocalDataSource` for DB/Cache).
  - **Repository Implementations**: Concrete classes implementing Domain repository contracts, converting raw Exceptions into domain `Failure`s and Models into Entities.
- **Rule**: Isolates external formats and third-party SDKs from the rest of the application.

### 3.3 Presentation Layer (User Interface & State)
- **Role**: Renders UI, receives user inputs, dispatches events to controllers/blocs, and reflects domain state.
- **Components**:
  - **Screens & Widgets**: Pure declarative Flutter widgets.
  - **State Controllers (BLoC / Cubit / Notifiers)**: Mediators that invoke Use Cases and produce immutable UI states.
  - **Events & States**: Explicit data structures representing user intentions and rendered UI snapshots.
- **Rule**: MUST NOT execute network calls directly, parse JSON, or access repository implementations.

### 3.4 Core Layer (Cross-Cutting Infrastructure)
- **Role**: Houses reusable application-wide infrastructure used across multiple independent features.
- **Components**:
  - Global `ApiClient` and HTTP interceptors.
  - Base `Failure` and `UseCase<Type, Params>` interfaces.
  - Global routing configuration (`routes.dart`).
  - App-wide themes, design tokens, formatters, and universal base widgets.
- **Rule**: Core MUST NOT become a dumping ground for feature-specific logic.

---

## 4. Architectural Invariants (Non-Negotiable)

The following invariants MUST be enforced without exception in every Clean Architecture codebase:

1. **INVARIANT-01: Domain Purity**
   - The Domain layer MUST NOT import `package:flutter/*`, network clients (`dio`, `http`), local storage packages, or any file from the `data/` or `presentation/` directories.
2. **INVARIANT-02: Contract Location**
   - Repository interfaces MUST reside in `domain/repositories/`. Repository implementations MUST reside in `data/repositories/`.
3. **INVARIANT-03: Model vs Entity Separation**
   - Serialization methods (`fromJson`, `toJson`, `toEntity`, `fromEntity`) MUST reside in `data/models/` and NEVER inside `domain/entities/`.
4. **INVARIANT-04: Inversion of Presentation Dependencies**
   - The Presentation layer MUST communicate with the Domain layer exclusively via Use Cases (or Domain Repository contracts if explicitly opted into simple queries). It MUST NEVER import `*_impl.dart` or `*_data_source.dart`.
5. **INVARIANT-05: Infrastructure Error Encapsulation**
   - Low-level network/database exceptions (e.g. `DioException`, `SocketException`, `DatabaseException`) MUST be caught inside the Data layer and mapped to domain-level `Failure` objects before crossing the boundary into Domain or Presentation.
6. **INVARIANT-06: Explicit Dependency Graph**
   - Classes MUST NOT instantiate their own dependencies internally using `new` / default constructors. All external dependencies MUST be injected via constructor parameters.
7. **INVARIANT-07: Feature Isolation**
   - Features MUST NOT import internal Data or Presentation files from other features. Cross-feature communication MUST occur via Domain contracts or shared Core abstractions.
8. **INVARIANT-08: Stateless Business Logic**
   - Use Cases MUST be stateless interactors. They execute a business action and return a result (`Future<Either<Failure, T>>` or `Stream<Either<Failure, T>>`).

---

## 5. Inversion of Control in Practice

Consider fetching a user profile. In traditional architectures, UI calls a service which calls an API:

```text
[UI Screen] ──> [UserService] ──> [HttpClient]  (Tight Coupling)
```

In Clean Architecture, the compile-time dependency points in the opposite direction of the runtime data flow:

```text
Compile-Time Dependency Direction:
[Presentation Screen] ──> [GetUserProfileUseCase] ──> [UserRepository Interface] (Domain)
                                                              ▲
                                                              │ (implements)
                                                    [UserRepositoryImpl] (Data)
                                                              │
                                                              ▼
                                                    [UserRemoteDataSource]

Runtime Execution Flow:
UI -> UseCase -> UserRepository Interface -> UserRepositoryImpl -> RemoteDataSource -> API
UI <- UseCase <- UserRepository Interface <- UserRepositoryImpl <- RemoteDataSource <- API
```

This guarantees that:
- You can replace Dio with HTTP or GraphQL without touching Domain or Presentation.
- You can replace BLoC with Riverpod or Cubit without touching Domain or Data.
- You can test Use Cases and BLoCs in complete isolation using pure mocks without mocking network sockets or Flutter widgets.
