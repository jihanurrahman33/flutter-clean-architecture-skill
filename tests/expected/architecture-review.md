# Expected Architectural Outcome: Architecture Review

## 1. Classification & Findings
- **CRITICAL Issue 1**: `domain/entities/cart_entity.dart` violates INVARIANT-01 (Domain purity) by importing `dio.dart` and `flutter/material.dart`.
- **CRITICAL Issue 2**: `presentation/screens/cart_screen.dart` violates INVARIANT-04 & INVARIANT-06 by directly importing and instantiating `CartRepositoryImpl`.

## 2. Actionable Remediation
- Remove `dio` and `flutter` from `CartEntity`.
- Inject `CheckoutUseCase` via feature DI into `CartBloc`, and have the screen read `CartBloc`.
