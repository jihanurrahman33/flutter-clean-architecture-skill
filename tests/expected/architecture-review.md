# Evaluation Scenario 7: Architectural Review & Audit

## 1. Input Task Prompt
```text
Perform an architectural audit on this pull request:
1. File lib/features/cart/domain/entities/cart_entity.dart imports package:dio/dio.dart and contains fromJson().
2. File lib/features/cart/presentation/screens/cart_screen.dart directly instantiates CartRepositoryImpl().checkout().
3. File lib/features/cart/presentation/bloc/cart_bloc.dart wipes items list when emitting CartLoadingState.
4. File lib/core/payment_calculator.dart contains cart discount business calculations.
```

## 2. Expected Agent Behavior
- Produces a formal architectural audit report adhering to the severity classification rubric.
- Classifies Issue 1 as **CRITICAL** (INVARIANT-01 Domain Purity violation + INVARIANT-03 Model vs Entity violation).
- Classifies Issue 2 as **CRITICAL** (INVARIANT-04 Presentation Inversion violation).
- Classifies Issue 3 as **MEDIUM** (Destructive loading state / UI glitch).
- Classifies Issue 4 as **HIGH** (Core layer pollution / Feature logic misplaced).
- Provides concrete code diffs and remediation plans for each finding.

## 3. Architectural Requirements
- Report must specify: Severity, File path, Rule violated, Architectural impact, and Recommended fix.
- Output MUST NOT invent fake metrics or rubber-stamp violations.

## 4. Forbidden Behavior
- Missing critical layer boundary violations (e.g. failing to flag `Dio` in Domain).
- Suggesting a rewrite of the entire codebase when only 4 specific files are audited.
- Marking the review as "Pass" when Critical violations exist.

## 5. Validation Criteria
- All 4 issues identified with accurate RFC 2119 severity levels.
- Actionable code examples provided for remediation.
