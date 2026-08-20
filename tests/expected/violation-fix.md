# Evaluation Scenario 8: Fixing Architectural Violations

## 1. Input Task Prompt
```text
The architecture validator failed with 3 critical errors:
1. lib/features/order/domain/entities/order_entity.dart: contains fromJson() and imports dio.dart.
2. lib/features/order/presentation/screens/order_screen.dart: imports order_remote_data_source.dart.
3. lib/features/order/data/repositories/order_repository_impl.dart: unhandled DioException causes unhandled crashes.

Fix all 3 violations without altering external screen behavior or business logic.
```

## 2. Expected Agent Behavior
- **Fix 1**: Removes `dio` import and `fromJson()` from `OrderEntity`. Creates `OrderModel` in `lib/features/order/data/models/order_model.dart` extending/mapping to `OrderEntity` with JSON serialization.
- **Fix 2**: Removes `order_remote_data_source.dart` import from `OrderScreen`. Connects screen to `OrderBloc` / Use Case via `context.read<OrderBloc>()`.
- **Fix 3**: Wraps datasource call in `OrderRepositoryImpl` with `try/catch (ServerException/DioException)` and returns `Left(ServerFailure(message: ...))` on failure.
- Runs `validate_architecture.js` to confirm all violations are resolved.

## 3. Architectural Requirements
- `OrderEntity` becomes 100% pure Dart.
- `OrderScreen` depends only on Presentation controller and Domain entities.
- `OrderRepositoryImpl` returns `Future<Either<Failure, OrderEntity>>`.

## 4. Forbidden Behavior
- Leaving any of the 3 violations partially unresolved.
- Deleting tests or disabling linter rules instead of fixing code.
- Moving business logic into Data layer models.

## 5. Validation Criteria
- `validate_architecture.js lib/features/order` returns exit code 0 with 0 violations.
- Analyzer passes with 0 warnings.
