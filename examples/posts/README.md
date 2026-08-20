# Posts Feature Reference Implementation

This directory contains a complete, working reference implementation of a Flutter feature adhering strictly to Clean Architecture and Feature-First organization.

---

## 📁 Directory Structure

```text
lib/
├── core/                                 # Cross-cutting application infrastructure
│   ├── error/
│   │   ├── exceptions.dart               # Infrastructure exceptions (Data layer)
│   │   └── failures.dart                 # Typed domain failures (Domain & Presentation)
│   ├── networking/
│   │   └── api_client.dart               # Centralized ApiClient interface & fake backend
│   ├── usecases/
│   │   └── usecase.dart                  # Base UseCase contract & NoParams
│   └── utils/
│       └── either.dart                   # Either<Failure, Success> functional monad
│
└── features/post/                        # Self-contained Posts Feature
    ├── domain/                           # Pure business rules
    │   ├── entities/
    │   │   └── post_entity.dart          # Pure Post domain object
    │   ├── repositories/
    │   │   └── post_repository.dart      # Abstract repository contract
    │   └── usecases/
    │       ├── create_post_usecase.dart  # Post creation interactor
    │       └── get_posts_usecase.dart    # Post fetching interactor
    │
    ├── data/                             # Data retrieval & serialization
    │   ├── datasources/
    │   │   └── post_remote_data_source.dart # REST client implementation
    │   ├── models/
    │   │   └── post_model.dart           # DTO with fromJson & toJson
    │   └── repositories/
    │       └── post_repository_impl.dart # Concrete repo with exception mapping
    │
    ├── presentation/                     # User interface & state management
    │   ├── bloc/
    │   │   ├── post_bloc.dart            # State controller
    │   │   ├── post_event.dart           # User events
    │   │   └── post_state.dart           # Immutable state preserving cached data
    │   ├── screens/
    │   │   ├── create_post_screen.dart   # Post creation form page
    │   │   └── post_list_screen.dart     # Post listing & refresh page
    │   └── widgets/
    │       └── post_card_widget.dart     # Modular card UI component
    │
    └── di.dart                           # Feature-level dependency wiring
```

---

## 🔍 Key Architectural Characteristics

1. **Pure Domain**: Zero framework or serialization dependencies in `domain/`.
2. **Inversion of Control**: `PostRepositoryImpl` (Data) implements `PostRepository` (Domain).
3. **Model/Entity Separation**: `PostModel` (Data) handles `fromJson`/`toJson`; `PostEntity` (Domain) handles domain equality.
4. **State Preservation**: `PostState` preserves cached post items during loading and error states.
5. **Decentralized DI**: `di.dart` wires the dependency graph in strict bottom-up order.
