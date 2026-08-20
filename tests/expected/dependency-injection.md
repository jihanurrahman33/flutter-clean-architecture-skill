# Expected Architectural Outcome: Dependency Injection Configuration

## 1. Expected File
`lib/features/order/di.dart`

## 2. Invariant Wiring Order
1. Register `OrderRemoteDataSourceImpl(apiClient: sl<ApiClient>())` as `OrderRemoteDataSource`.
2. Register `OrderRepositoryImpl(remoteDataSource: sl<OrderRemoteDataSource>())` under Domain contract `OrderRepository`.
3. Register `CreateOrderUseCase(repository: sl<OrderRepository>())` and `GetOrdersUseCase(repository: sl<OrderRepository>())`.
4. Register `OrderBloc` factory injecting both Use Cases.
5. Provide single registration hook `initOrderFeature(GetIt sl)` to `main.dart`.
