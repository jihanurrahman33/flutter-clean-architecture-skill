# Dart & Flutter Clean Architecture Coding Rules

This document defines code style, immutability, null safety, SOLID principles, and naming standards for Clean Architecture Flutter projects.

---

## 1. Immutability & Const Constructors

- **Entities, Models, Events, and States MUST be immutable**.
- All fields MUST be marked `final`.
- Classes MUST provide `const` constructors where possible.
- Collections in state/entities SHOULD use unmodifiable lists or copies (`List.unmodifiable(...)` or `List.of(...)`).

```dart
class UserEntity extends Equatable {
  final int id;
  final String name;

  const UserEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
```

---

## 2. Null Safety Best Practices

- **Avoid the force-unwrap operator (`!`)**: Handle null values explicitly with default fallbacks (`??`) or conditional unwrapping (`if (val != null)`).
- **Default to Non-Nullable**: Only declare fields as nullable (`String?`) when `null` represents a valid domain state (e.g. `optionalMiddleName`).
- **Domain Defaults**: Value objects and entities should encapsulate validation logic rather than allowing invalid/null state to propagate.

---

## 3. SOLID Principles Applied to Flutter

| Principle | Clean Architecture Application |
| :--- | :--- |
| **Single Responsibility (SRP)** | Each Use Case does exactly one business action. Each Data Source communicates with one service. Each Widget renders one component. |
| **Open / Closed (OCP)** | Adding a new payment provider requires a new `PaymentRepositoryImpl` and Data Source, without changing existing checkout Use Cases. |
| **Liskov Substitution (LSP)** | `PostModel` can be passed anywhere `PostEntity` is expected without altering domain correctness. `PostRepositoryImpl` can replace any mock repository. |
| **Interface Segregation (ISP)** | Keep repository contracts focused. Do not create a single 50-method `MegaRepository`. |
| **Dependency Inversion (DIP)** | Use Cases and Presentation depend exclusively on abstract `Repository` interfaces, not concrete implementations. |

---

## 4. Asynchronous Code & Error Handling

- Always use `async` / `await` instead of raw `.then()` chains.
- Avoid floating `unawaited()` Futures unless explicitly intended for background fire-and-forget telemetry.
- Always handle both success and failure branches when resolving `Either<Failure, T>` using `.fold()`.
