# Evaluation Scenario 1: New Feature Implementation

## 1. Input Task Prompt
```text
Implement a new "Product Catalog" feature in our Flutter application:
- Fetch products from REST API (GET /api/v1/products).
- Support category filtering and search queries.
- Render products in a grid view with loading, error, and empty states.
- Follow Clean Architecture and feature-first modularization.
```

## 2. Expected Agent Behavior
- Inspects existing project configuration (`pubspec.yaml`, `lib/core/`, state management, DI).
- Implements Domain entities, repository interfaces, and use cases first.
- Implements Data models with serialization, remote data sources, and repository implementations with error mapping.
- Implements Presentation state controller (preserving loaded items), screens, and widgets.
- Registers dependencies in feature-specific `di.dart`.

## 3. Architectural Requirements
- **Directory Layout**:
  ```text
  lib/features/product/
  ├── domain/
  │   ├── entities/product_entity.dart
  │   ├── repositories/product_repository.dart
  │   └── usecases/
  │       ├── get_products_usecase.dart
  │       └── search_products_usecase.dart
  ├── data/
  │   ├── models/product_model.dart
  │   ├── datasources/product_remote_data_source.dart
  │   └── repositories/product_repository_impl.dart
  ├── presentation/
  │   ├── bloc/ (or cubit/riverpod controller)
  │   │   ├── product_bloc.dart
  │   │   ├── product_event.dart
  │   │   └── product_state.dart
  │   ├── screens/product_grid_screen.dart
  │   └── widgets/product_card_widget.dart
  └── di.dart
  ```
- `ProductEntity`: Immutable, extends `Equatable`, zero Flutter UI or Dio imports, no `fromJson`/`toJson`.
- `ProductRepository`: Interface in `domain/repositories/` returning `Future<Either<Failure, List<ProductEntity>>>`.
- `ProductModel`: Contains serialization (`fromJson`/`toJson`) and mapping to/from `ProductEntity`.
- `ProductRemoteDataSource`: Injects `ApiClient`, throws `ServerException` on HTTP failures.
- `ProductRepositoryImpl`: Catches `ServerException`/`NetworkException` and returns `Left(Failure)`.
- `ProductBloc`: Injects use cases only; does not import `data/` implementations.

## 4. Forbidden Behavior
- Importing `package:flutter/*` or `dio` inside `domain/`.
- Putting `fromJson` / `toJson` inside `ProductEntity`.
- Calling `Dio().get(...)` or HTTP client directly inside widgets or BLoC.
- Registering all feature dependencies in a monolithic 500-line `main.dart`.
- Emitting destructive loading states that erase existing products during filter changes.

## 5. Validation Criteria
- `validate_architecture.js lib/features/product` reports 0 violations.
- `dart analyze` passes with zero errors and warnings.
- `dart format --output=none --set-exit-if-changed lib/features/product` passes cleanly.
