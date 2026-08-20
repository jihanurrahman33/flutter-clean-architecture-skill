# Expected Architectural Outcome: New Feature Implementation

## 1. Expected File Structure
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
│   ├── bloc/
│   │   ├── product_bloc.dart
│   │   ├── product_event.dart
│   │   └── product_state.dart
│   ├── screens/product_list_screen.dart
│   └── widgets/product_card_widget.dart
└── di.dart
```

## 2. Invariant Expectations
- `ProductEntity`: Immutable, extends `Equatable`, NO `fromJson`/`toJson`, NO Flutter imports.
- `ProductRepository`: Interface returning `Future<Either<Failure, List<ProductEntity>>>`.
- `ProductModel`: Contains `fromJson()` / `toJson()` and maps to `ProductEntity`.
- `ProductRemoteDataSource`: Injects `ApiClient`, throws `ServerException`.
- `ProductRepositoryImpl`: Catches `ServerException` and returns `Left(ServerFailure)`.
- `ProductBloc`: Injects `GetProductsUseCase` and `SearchProductsUseCase`, depends on NO Data classes.
- `ProductState`: Preserves loaded products during `ProductStatus.loading`.
