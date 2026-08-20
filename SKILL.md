---
name: flutter-clean-architecture
description: >-
  Expert architectural standard, decision engine, and procedural workflow for Flutter applications utilizing Clean Architecture and Feature-First modularization. Activates when analyzing, designing, implementing, modifying, refactoring, or reviewing Flutter features, domain entities, use cases, repository contracts, data models, data sources, presentation controllers (BLoC, Cubit, Riverpod), dependency injection, navigation, functional error handling, and testing.
---

# Flutter Clean Architecture Agent Skill

A production-grade, reusable AI engineering skill for creating, modifying, refactoring, reviewing, and validating Flutter applications following Clean Architecture and Feature-First organization.

---

## 1. Architectural Invariants (Non-Negotiable)

The AI agent MUST enforce the following invariants across all Flutter tasks:

1. **INVARIANT-01 (Domain Purity)**: The Domain layer MUST NOT import `package:flutter/*`, HTTP/network packages (`dio`, `http`), local storage packages, or any file from `data/` or `presentation/`.
2. **INVARIANT-02 (Contract Location)**: Repository interfaces MUST reside in `domain/repositories/`. Repository implementations MUST reside in `data/repositories/`.
3. **INVARIANT-03 (Model/Entity Separation)**: JSON serialization (`fromJson`/`toJson`) MUST reside in `data/models/` and NEVER inside `domain/entities/`.
4. **INVARIANT-04 (Presentation Inversion)**: Presentation MUST communicate with Domain exclusively via Use Cases (or Domain Repository contracts). Presentation MUST NEVER import `*_impl.dart` or `*_data_source.dart`.
5. **INVARIANT-05 (Infrastructure Encapsulation)**: Low-level exceptions (`DioException`, `SocketException`, `DatabaseException`) MUST be caught inside the Data layer and mapped to Domain `Failure` objects before crossing into Domain or Presentation.
6. **INVARIANT-06 (Explicit Injection)**: Dependencies MUST be injected via constructor parameters rather than instantiated directly inside classes.
7. **INVARIANT-07 (Feature Isolation)**: Features MUST NOT import internal Data or Presentation files from other features. Cross-feature communication MUST occur via Domain contracts or shared Core abstractions.

---

## 2. Rule Severity Definitions (RFC 2119)

- **MUST / MUST NOT / NEVER**: Hard architectural constraints and invariants. Violations trigger review failure.
- **SHOULD / SHOULD NOT**: Strong architectural recommendations. Deviations require explicit justification.
- **MAY**: Permitted implementation options (e.g. choice between BLoC and Riverpod based on existing project conventions).

---

## 3. Golden Decision Hierarchy

When determining where a piece of code belongs, apply this decision tree:

```text
1. Is it enterprise or application business logic?
   └── DOMAIN (entities, repository contracts, usecases)

2. Is it external data communication, API, DB, or serialization logic?
   └── DATA (models, datasources, repository implementations)

3. Is it UI layout, widget rendering, navigation, or UI state coordination?
   └── PRESENTATION (screens, widgets, controllers/blocs, states, events)

4. Is it reusable application-wide infrastructure used across multiple features?
   └── CORE (networking client, base failures, base usecases, theme, global router)
```

---

## 4. Compile-Time Dependency & Runtime Data Flow

```text
Compile-Time Dependencies:
Presentation ───> Domain <─── Data
                     ▲
                     │
                   Core

Runtime Execution Flow:
[UI Widget] ──> [BLoC / Controller] ──> [Use Case] ──> [Repo Contract]
                                                             ▲
                                                             │ (implemented by)
                                                       [Repo Impl] ──> [Data Source] ──> [API / DB]
```

---

## 5. Mandatory Pre-Coding Workflow

Before modifying or creating any code in a Flutter project, the AI MUST:

1. **Inspect `pubspec.yaml`**: Identify dependencies (state manager, HTTP client, DI, router).
2. **Inspect `lib/core/`**: Locate existing base classes (`ApiClient`, `Failure`, `UseCase`, `Theme`).
3. **Inspect an Existing Feature (`lib/features/`)**: Identify existing architectural style (BLoC vs Cubit vs Riverpod, Model extension vs composition).
4. **Preserve Established Architecture**: If the project has a coherent pattern that differs from your default preference, extend the established pattern. NEVER introduce a competing state manager or folder structure without explicit user instruction.
5. **Search Before Creating**: Check if required utilities or contracts already exist before writing new ones.

---

## 6. Procedural Workflows

### 6.1 New Feature Workflow
Follow the 12-step implementation pipeline detailed in [feature-development.md](references/feature-development.md):
1. Requirements analysis $\rightarrow$ 2. Project inspection $\rightarrow$ 3. Domain entities & repo contract $\rightarrow$ 4. Use cases $\rightarrow$ 5. Data models & data sources $\rightarrow$ 6. Repository implementation $\rightarrow$ 7. Presentation BLoC/state $\rightarrow$ 8. Screens & widgets $\rightarrow$ 9. Feature DI (`di.dart`) $\rightarrow$ 10. Route registration $\rightarrow$ 11. Unit/BLoC tests $\rightarrow$ 12. Format & Static analysis.

### 6.2 Modification & Bugfix Workflow
Follow the surgical modification guidelines detailed in [modification-workflow.md](references/modification-workflow.md):
1. Locate target layer (UI $\rightarrow$ Presentation, Logic $\rightarrow$ Domain, Network/Data $\rightarrow$ Data).
2. Apply minimal, surgical diffs.
3. Preserve existing state data during loading/error transitions.
4. Update corresponding tests in `test/`.
5. Run `flutter analyze` to guarantee zero regressions.

### 6.3 Refactoring & Migration Workflow
Follow the Strangler Fig pattern detailed in [refactoring.md](references/refactoring.md):
- Extract Domain $\rightarrow$ Extract Data $\rightarrow$ Extract Use Cases $\rightarrow$ Wire Presentation $\rightarrow$ Deprecate legacy paths incrementally.

### 6.4 Architecture Review Workflow
Evaluate code against the rubric detailed in [architecture-review.md](references/architecture-review.md):
- Classify issues as **CRITICAL**, **HIGH**, **MEDIUM**, or **LOW**.
- Provide file path, violated invariant, and actionable remediation steps.

---

## 7. Progressive Disclosure Reference Index

For detailed deep-dives, code templates, and exhaustive explanations, refer to:

- **[Architecture Invariants & Principles](references/architecture.md)**: Core layers, dependency boundaries, and non-negotiable invariants.
- **[Feature-First Project Layout](references/project-structure.md)**: Standard directory structures and component placement decision matrix.
- **[Domain Layer Specifications](references/domain-layer.md)**: Entities, Value Objects, Domain Repositories, and Use Cases (`UseCase<Type, Params>`).
- **[Data Layer & Serialization](references/data-layer.md)**: Models, DTOs, Data Sources, and Repository Implementations.
- **[Presentation Layer & UI States](references/presentation-layer.md)**: Screens vs Widgets, UI State Preservation, and Event/State lifecycles.
- **[Dependency Injection Patterns](references/dependency-injection.md)**: Feature-level DI (`di.dart`), Service Locator (`get_it`), and Riverpod.
- **[Error Handling & Failure Hierarchy](references/error-handling.md)**: `Either<Failure, T>` monad, typed `Failure` hierarchy, and exception conversion.
- **[State Management Guidelines](references/state-management.md)**: Framework-agnostic rules (BLoC, Cubit, Riverpod, Provider).
- **[Navigation & Routing Architecture](references/navigation.md)**: Centralized routing, `go_router` patterns, and decoupled navigation.
- **[Testing Strategy & Test Matrix](references/testing.md)**: Layer-by-layer test matrix with `mocktail` and `bloc_test` suites.
- **[API Integration & Remote Data](references/api-integration.md)**: Centralized `ApiClient`, interceptors, pagination, and remote data sources.
- **[Feature Development Pipeline](references/feature-development.md)**: 12-step deterministic new feature implementation pipeline.
- **[Feature Modification Workflow](references/modification-workflow.md)**: Surgical modification & bugfix runbook.
- **[Refactoring & Migration Runbook](references/refactoring.md)**: Strangler Fig migration runbook for legacy Flutter codebases.
- **[Architecture Review & Audit Protocol](references/architecture-review.md)**: Audit checklist, scoring matrix, and PR review reporting template.
- **[Forbidden Anti-Patterns Catalog](references/anti-patterns.md)**: 15+ anti-patterns with Bad vs Good code, rationales, and fixes.
- **[AI Agent Behavioral Guardrails](references/ai-behavior.md)**: AI cognitive principles, search-before-create, and source of truth hierarchy.
- **[Coding Style & SOLID Principles](references/coding-rules.md)**: Immutability, const constructors, null safety, and SOLID principles.
- **[Data Flow & Transformations](references/data-flow.md)**: Complete request & response flow diagrams.

---

## 8. Final Verification Checklist

Before declaring any Flutter task complete, verify:
- [ ] **Domain Purity**: Zero Flutter UI or Dio imports in `domain/`.
- [ ] **No Inverted Dependencies**: Presentation does not import Data implementations.
- [ ] **No Direct UI Network Calls**: Widgets do not call HTTP or DB APIs directly.
- [ ] **State Preservation**: UI states preserve existing list data during refresh/loading.
- [ ] **Error Handling**: Repository implementation maps all exceptions to `Either<Failure, T>`.
- [ ] **Dependency Injection**: Feature DI module created and registered.
- [ ] **Static Analysis**: Code is formatted (`dart format`) and static analysis (`flutter analyze`) passes with zero errors.