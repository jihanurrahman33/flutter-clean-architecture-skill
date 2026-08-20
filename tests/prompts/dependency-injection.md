# Test Scenario: Dependency Injection Configuration

## Input Task Prompt
```text
Wire up dependencies for a new feature "Order" using feature-first DI:
- OrderRemoteDataSource requires ApiClient.
- OrderRepository requires OrderRemoteDataSource.
- CreateOrderUseCase and GetOrdersUseCase require OrderRepository.
- OrderBloc requires CreateOrderUseCase and GetOrdersUseCase.
- Avoid bloating main.dart.
```
