# Project Structure & Directory Layout

This document defines the canonical directory structure, file naming standards, and placement rules for Flutter applications utilizing Clean Architecture with Feature-First organization.

---

## 1. Top-Level Directory Organization

```text
lib/
├── core/                         # Shared application-wide infrastructure
│   ├── app/                      # App root configuration, observers, router
│   ├── constants/                # App-wide global constants, asset paths
│   ├── error/                    # Base Failure classes, Exception definitions
│   ├── extensions/               # General Dart & Flutter extensions
│   ├── networking/               # Central ApiClient, Dio interceptors, endpoints
│   ├── theme/                    # Color schemes, typography, ThemeData
│   ├── usecases/                 # Base UseCase interface & NoParams
│   ├── utils/                    # Common formatters, validators, Either utilities
│   └── widgets/                  # Generic reusable UI primitives (Buttons, Inputs)
│
├── features/                     # Self-contained business feature modules
│   ├── auth/                     # Authentication & Authorization feature
│   ├── post/                     # Posts management feature
│   ├── profile/                  # User profile feature
│   └── settings/                 # Application settings feature
│
└── main.dart                     # Application bootstrap & entry point
```

---

## 2. Feature Module Anatomy

Every self-contained feature within `lib/features/<feature_name>/` follows this exact three-layer structure:

```text
lib/features/post/
│
├── data/                         # Data Layer: external interactions & models
│   ├── datasources/              # Remote & local data sources
│   │   ├── post_local_data_source.dart
│   │   └── post_remote_data_source.dart
│   ├── models/                   # DTOs & JSON serialization models
│   │   └── post_model.dart
│   └── repositories/             # Repository implementations
│       └── post_repository_impl.dart
│
├── domain/                       # Domain Layer: pure business rules & contracts
│   ├── entities/                 # Business domain objects
│   │   └── post_entity.dart
│   ├── repositories/             # Abstract repository contracts
│   │   └── post_repository.dart
│   └── usecases/                 # Single-purpose business use cases
│       ├── create_post_usecase.dart
│       ├── delete_post_usecase.dart
│       └── get_posts_usecase.dart
│
├── presentation/                 # Presentation Layer: UI & state management
│   ├── bloc/                     # (Or cubit/riverpod/controllers)
│   │   ├── post_bloc.dart
│   │   ├── post_event.dart
│   │   └── post_state.dart
│   ├── screens/                  # Top-level full-screen pages
│   │   ├── create_post_screen.dart
│   │   └── post_list_screen.dart
│   └── widgets/                  # Feature-specific reusable UI components
│       ├── post_card_widget.dart
│       └── post_filter_bar.dart
│
└── di.dart                       # Feature-specific dependency injection module
```

---

## 3. Directory Placement Decision Matrix

When creating or moving a file, use this decision table:

| If the file contains... | It belongs in... | Example File Path |
| :--- | :--- | :--- |
| Business object with identity/properties | `features/<feat>/domain/entities/` | `features/auth/domain/entities/user_entity.dart` |
| Abstract data contract / interface | `features/<feat>/domain/repositories/` | `features/auth/domain/repositories/auth_repository.dart` |
| Single business action interactor | `features/<feat>/domain/usecases/` | `features/auth/domain/usecases/login_usecase.dart` |
| JSON parsing (`fromJson`/`toJson`) | `features/<feat>/data/models/` | `features/auth/data/models/user_model.dart` |
| Direct HTTP / DB / Cache calls | `features/<feat>/data/datasources/` | `features/auth/data/datasources/auth_remote_data_source.dart` |
| Concrete repository implementation | `features/<feat>/data/repositories/` | `features/auth/data/repositories/auth_repository_impl.dart` |
| State controller (BLoC/Cubit/Notifier) | `features/<feat>/presentation/bloc/` | `features/auth/presentation/bloc/auth_bloc.dart` |
| Full page / Route target | `features/<feat>/presentation/screens/` | `features/auth/presentation/screens/login_screen.dart` |
| Feature-scoped reusable UI component | `features/<feat>/presentation/widgets/` | `features/auth/presentation/widgets/auth_text_field.dart` |
| Feature DI registration container | `features/<feat>/` | `features/auth/di.dart` |
| Cross-cutting HTTP client / Interceptor | `core/networking/` | `core/networking/api_client.dart` |
| App-wide reusable base failure | `core/error/` | `core/error/failures.dart` |
| App-wide generic UI primitive (e.g. PrimaryButton) | `core/widgets/` | `core/widgets/app_primary_button.dart` |

---

## 4. File Naming Conventions

All Dart files MUST follow `snake_case` naming with explicit descriptive suffixes:

```text
[feature_or_concept]_[layer_component].dart
```

### Mandatory Suffix Table:
- Entities: `*_entity.dart` (e.g., `user_entity.dart`)
- Models: `*_model.dart` (e.g., `user_model.dart`)
- Domain Repository Interfaces: `*_repository.dart` (e.g., `user_repository.dart`)
- Data Repository Implementations: `*_repository_impl.dart` (e.g., `user_repository_impl.dart`)
- Data Sources: `*_remote_data_source.dart` / `*_local_data_source.dart`
- Use Cases: `*_usecase.dart` (e.g., `get_user_usecase.dart`)
- BLoC / State Files: `*_bloc.dart`, `*_event.dart`, `*_state.dart`, `*_cubit.dart`
- Screens: `*_screen.dart` or `*_page.dart` (be consistent within project)
- Widgets: `*_widget.dart` or `*_component.dart`

---

## 5. Barrel Files (`index.dart` / `*.dart` exports)

Barrel files can reduce import clutter but MUST be used judiciously.

### Recommended Usage:
```dart
// lib/features/post/presentation/screens/screens.dart
export 'post_list_screen.dart';
export 'create_post_screen.dart';
```

### Rules for Barrel Files:
1. **MAY** export screens or widgets within the same sub-layer for cleaner routing imports.
2. **MUST NOT** create global barrel files that re-export `data/` implementations into `presentation/`.
3. **MUST NOT** introduce circular dependency loops between barrels.
