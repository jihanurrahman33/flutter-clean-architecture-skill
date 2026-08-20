# Flutter Clean Architecture Agent Skill

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20Feature--First-green.svg)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![AI Agent Compatible](https://img.shields.io/badge/AI%20Agent-Antigravity%20%7C%20Claude%20Code%20%7C%20Cursor-purple.svg)](https://github.com/)

A production-grade, reusable, open-source **AI Engineering Skill** that teaches coding agents (Antigravity, Claude Code, Cursor, Codex, OpenCode) how to analyze, design, implement, modify, refactor, review, and validate Flutter applications following Clean Architecture and Feature-First modularization.

---

## 🏗 Architectural Overview

Clean Architecture isolates core enterprise business logic from UI, frameworks, network protocols, databases, and third-party SDKs.

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                             Presentation Layer                              │
│         (Screens, Widgets, BLoC / Cubit / Riverpod Notifiers, States)       │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       │ (Depends on Use Cases & Domain Entities)
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                Domain Layer                                 │
│          (Entities, Value Objects, Use Cases, Repository Contracts)         │
└──────────────────────────────────────▲──────────────────────────────────────┘
                                       │
                                       │ (Implements Repository Contracts)
┌──────────────────────────────────────┴──────────────────────────────────────┐
│                                 Data Layer                                  │
│       (Models / DTOs, Remote & Local Data Sources, Repository Implementations)│
└─────────────────────────────────────────────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          External Infrastructure                            │
│                 (REST API, GraphQL, SQLite, Hive, Firebase)                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Key Features & Capabilities

- **Strict Invariant Enforcement**: Ensures Domain purity (no Flutter UI or Dio in Domain), explicit dependency injection, and functional error handling (`Either<Failure, T>`).
- **Framework-Agnostic Presentation**: Adapts seamlessly to existing project state management (`flutter_bloc`, `riverpod`, `provider`, `cubit`).
- **Feature-First Organization**: Modular directory layout (`lib/core/` vs `lib/features/<feature>/`).
- **Automated Architecture Validator**: Includes Node.js and Python linter scripts to verify layer boundaries and detect cross-layer import leaks in CI/CD.
- **Deterministic Workflows**: 12-step new feature pipeline, Strangler Fig refactoring runbook, and formal PR architecture review rubric.

---

## 📂 Repository Structure

```text
flutter-clean-architecture-skill/
│
├── SKILL.md                          # Master AI agent entrypoint & decision rules
├── README.md                         # Open-source human documentation
├── LICENSE                           # MIT License
├── CHANGELOG.md                      # Semantic version release history
├── CONTRIBUTING.md                   # Contribution & rule governance guidelines
├── SECURITY.md                       # Local execution & security policy
├── CODE_OF_CONDUCT.md                # Community Code of Conduct
├── .editorconfig                     # Consistent code formatting rules
├── .gitignore                        # Git exclusion rules
│
├── references/                       # Progressive disclosure deep-dive references
│   ├── architecture.md               # Core layers, dependency rule & invariants
│   ├── project-structure.md          # Feature-first anatomy & placement matrix
│   ├── domain-layer.md               # Entities, Value Objects, Repositories, UseCases
│   ├── data-layer.md                 # Models, Data Sources, Repository Implementations
│   ├── presentation-layer.md         # Screens, Widgets, State Preservation, BLoC
│   ├── dependency-injection.md       # Feature DI (di.dart) & container patterns
│   ├── state-management.md           # State management guidelines (BLoC, Riverpod)
│   ├── navigation.md                 # Centralized routing & go_router integration
│   ├── error-handling.md             # Functional error handling & Failure hierarchy
│   ├── api-integration.md            # Centralized ApiClient & remote data sources
│   ├── testing.md                    # Layer-by-layer test matrix with mocks
│   ├── feature-development.md        # 12-step end-to-end new feature pipeline
│   ├── modification-workflow.md      # Surgical modification & bugfix runbook
│   ├── refactoring.md                # Strangler Fig legacy migration runbook
│   ├── architecture-review.md        # Audit criteria & PR evaluation rubric
│   ├── anti-patterns.md              # 15+ anti-patterns with Bad vs Good examples
│   ├── ai-behavior.md                # AI cognitive principles & source of truth hierarchy
│   ├── coding-rules.md               # Dart style, immutability & SOLID principles
│   └── data-flow.md                  # Complete request & response flow diagrams
│
├── examples/                         # Working reference implementations
│   └── posts/                        # Production-grade Posts feature implementation
│       ├── README.md                 # Architecture documentation for example
│       └── lib/
│           ├── core/                 # Core contracts (Either, Failure, UseCase, ApiClient)
│           └── features/post/        # Domain, Data, Presentation, di.dart
│
├── scripts/                          # Architecture & skill validation tooling
│   ├── validate_skill.js / .py       # SKILL.md metadata & structure linter
│   ├── validate_architecture.js / .py# Clean Architecture layer validator
│   ├── check_references.js / .py     # Cross-link and reference integrity checker
│   └── package.json                  # NPM script runner
│
├── tests/                            # Skill evaluation benchmark suite
│   ├── prompts/                      # 10+ evaluation prompt scenarios
│   │   ├── new-feature.md            # Scenario 1: New API feature
│   │   ├── api-integration.md        # Scenario 2: REST API integration & mapping
│   │   ├── auth-flow.md              # Scenario 3: JWT session & storage
│   │   ├── pagination.md             # Scenario 4: Infinite scrolling pagination
│   │   ├── local-caching.md          # Scenario 5: Offline-first caching fallback
│   │   ├── refactoring.md            # Scenario 6: Legacy StatefulWidget migration
│   │   ├── architecture-review.md    # Scenario 7: Pull request architecture audit
│   │   ├── violation-fix.md          # Scenario 8: Layer boundary leak remediation
│   │   ├── testing.md                # Scenario 9: Layer-by-layer unit/bloc tests
│   │   └── modification.md           # Scenario 10: Surgical feature modification
│   └── expected/                     # Expected architectural assertions
│       ├── new-feature.md
│       ├── api-integration.md
│       ├── auth-flow.md
│       ├── pagination.md
│       ├── local-caching.md
│       ├── refactoring.md
│       ├── architecture-review.md
│       ├── violation-fix.md
│       ├── testing.md
│       └── modification.md
│
└── .github/                          # Open-source CI & GitHub configuration
    ├── workflows/
    │   ├── validate.yml              # Automated PR & push validation workflow
    │   └── release.yml               # Automated release packaging workflow
    ├── ISSUE_TEMPLATE/
    │   ├── bug_report.md
    │   └── feature_request.md
    └── pull_request_template.md
```

---

## 🚀 Installation & Usage

### Option 1: Global Agent Skill (Antigravity IDE / Claude Code)
Clone or copy this repository to your global or workspace skills directory:

```bash
# Global Antigravity / Gemini CLI configuration
mkdir -p ~/.gemini/config/skills/
cp -r flutter-clean-architecture ~/.gemini/config/skills/flutter-clean-architecture

# Workspace-specific configuration
mkdir -p .agents/skills/
cp -r flutter-clean-architecture .agents/skills/flutter-clean-architecture
```

### Option 2: Running the Automated Architecture Validator
Validate any Flutter codebase against Clean Architecture rules:

```bash
# Using Node.js
node scripts/validate_architecture.js path/to/your_flutter_app/lib

# Using Python 3
python3 scripts/validate_architecture.py path/to/your_flutter_app/lib

# Test the bundled reference example
npm test --prefix scripts
```

---

## 🛡 Architectural Invariants

| Rule ID | Invariant Summary | Severity |
| :--- | :--- | :--- |
| **INVARIANT-01** | Domain layer MUST NOT import `package:flutter/*`, HTTP clients (`dio`, `http`), or Data/Presentation files. | **CRITICAL** |
| **INVARIANT-02** | Repository contracts reside in `domain/repositories/`. Implementations reside in `data/repositories/`. | **CRITICAL** |
| **INVARIANT-03** | `fromJson` / `toJson` serialization belongs in `data/models/`, NEVER in `domain/entities/`. | **CRITICAL** |
| **INVARIANT-04** | Presentation MUST NOT import `*_repository_impl.dart` or `*_data_source.dart`. | **CRITICAL** |
| **INVARIANT-05** | Data layer MUST catch infrastructure exceptions and map them to `Either<Failure, T>`. | **CRITICAL** |
| **INVARIANT-06** | Collaborators MUST be injected via constructor parameters rather than instantiated internally. | **HIGH** |
| **INVARIANT-07** | Features MUST NOT import internal Data/Presentation files from other features. | **HIGH** |

---

## 🧪 Testing & Verification

Run the bundled test suite and benchmark prompts to ensure your AI coding agent follows Clean Architecture:

```bash
# Validate reference implementation
node scripts/validate_architecture.js examples/posts/lib
```

---

## 🤝 Contributing

Contributions, rule suggestions, and new reference implementations are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a Pull Request.

---

## 📄 License

Distributed under the **MIT License**. See [LICENSE](LICENSE) for more information.
