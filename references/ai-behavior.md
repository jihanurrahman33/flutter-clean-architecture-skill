# AI Coding Agent Behavioral Guidelines

This document establishes the cognitive rules, operational principles, and decision hierarchies that an AI coding agent MUST follow when working on Flutter Clean Architecture codebases.

---

## 1. Core Operating Principles

1. **INSPECT BEFORE MODIFYING**:
   - Before writing or editing code, read `pubspec.yaml`, inspect `lib/core/`, and explore existing features in `lib/features/`. Never assume package versions or architectural styles.
2. **SEARCH BEFORE CREATING**:
   - Before creating a new `ApiClient`, `Failure`, `BaseUseCase`, `Button`, or utility function, search the codebase using ripgrep or file search. Do NOT generate duplicate utility classes.
3. **REUSE BEFORE DUPLICATING**:
   - Reuse existing application-wide infrastructure (error handlers, theme styles, network interceptors, shared domain contracts).
4. **FOLLOW EXISTING CONVENTIONS**:
   - If an existing codebase uses `flutter_bloc` with `freezed`, mirror that exact style. If it uses plain Dart classes with `Equatable`, use `Equatable`. Do not mix disparate state management patterns.
5. **MINIMAL DIFF & SURGICAL EDITS**:
   - When modifying a feature or fixing a bug, make the smallest possible architectural change. Do not reformat or refactor unrelated files unless explicitly requested.
6. **NEVER SILENTLY CHANGE ARCHITECTURE**:
   - If a project uses an established pattern that differs from your ideal preference, preserve the project's pattern. Never perform unsolicited global architecture rewrites.
7. **DO NOT INTRODUCE DEPENDENCIES WITHOUT REASON**:
   - Never add third-party packages to `pubspec.yaml` without verifying they are strictly necessary and compatible with the project's SDK constraints.
8. **VALIDATE GENERATED CODE**:
   - Always run static analysis (`flutter analyze` or `dart analyze`) and layer validation scripts after creating or modifying code.
9. **FIX ERRORS BEFORE COMPLETION**:
   - Never leave unhandled compiler errors, lint warnings, or broken imports in modified files.
10. **CLARIFY ONLY WHEN CRITICAL**:
    - Ask for clarification only when user requirements are ambiguous and materially affect architecture or data schemas. For standard implementation details, follow established codebase patterns.

---

## 2. Source of Truth Hierarchy

When resolving conflicting guidelines or patterns, resolve decisions in this strict order of priority:

```text
1. Explicit User Requirements (Highest Priority)
       ↓
2. Existing Project Conventions & Patterns
       ↓
3. Architectural Invariants (Domain purity, Dependency Rule)
       ↓
4. Skill Reference Guidelines
       ↓
5. General Best Practices (Lowest Priority)
```

---

## 3. Cognitive Guardrails

- **No Hallucinated Packages**: Do not import packages that are not declared in `pubspec.yaml`.
- **No Inverted Either Types**: Always enforce `Left = Failure` and `Right = Success`.
- **No Leaked Exceptions**: Ensure every `RepositoryImpl` method wraps data source calls in `try/catch` and maps exceptions to `Failure`.
- **No Direct UI Networking**: Reject any solution that places `Dio().get(...)` inside a Flutter Widget or BLoC.
