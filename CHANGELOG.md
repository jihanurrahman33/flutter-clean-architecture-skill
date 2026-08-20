# Changelog

All notable changes to the `flutter-clean-architecture` Agent Skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-08-20

### Added
- **Master Skill Entrypoint (`SKILL.md`)**:
  - Progressive disclosure instructions, Golden Decision Hierarchy, and mandatory pre-coding inspection workflows.
  - Strict RFC 2119 severity definitions (`MUST`, `SHOULD`, `MAY`, `MUST NOT`, `NEVER`).
- **Comprehensive Reference Guides (`references/`)**:
  - Core layers & invariants (`architecture.md`).
  - Feature-first anatomy & placement matrix (`project-structure.md`).
  - Pure Domain layer specifications (`domain-layer.md`).
  - Data layer, Models, Data Sources & Repository Implementations (`data-layer.md`).
  - Presentation layer, UI state preservation & Screen/Widget separation (`presentation-layer.md`).
  - Feature-level Dependency Injection (`dependency-injection.md`).
  - Functional error handling with `Either<Failure, T>` (`error-handling.md`).
  - State management guidelines supporting BLoC, Cubit, Riverpod (`state-management.md`).
  - Centralized routing with `go_router` integration (`navigation.md`).
  - Layer-by-layer test matrix with mocks (`testing.md`).
  - 12-step deterministic feature development pipeline (`feature-development.md`).
  - Strangler Fig refactoring & legacy migration runbook (`refactoring.md`).
  - Formal PR architecture review checklist & severity rubric (`architecture-review.md`).
  - 15+ comprehensive forbidden anti-patterns with Bad vs Good examples (`anti-patterns.md`).
  - AI coding agent cognitive guardrails (`ai-behavior.md`).
  - Dart coding conventions & SOLID principles (`coding-rules.md`).
  - End-to-end data flow & layer transformation diagrams (`data-flow.md`).
- **Reference Example (`examples/posts/`)**:
  - Full working implementation of a Clean Architecture Posts feature with Domain, Data, Presentation (BLoC), DI, and Core contracts.
- **Automated Validation Tooling (`scripts/`)**:
  - Cross-platform architecture linters in Node.js (`validate_architecture.js`) and Python 3 (`validate_architecture.py`).
- **Skill Evaluation Benchmark Prompts (`tests/prompts/`)**:
  - 6 end-to-end evaluation scenarios for new features, refactoring, code review, API integration, state management, and violation detection.
