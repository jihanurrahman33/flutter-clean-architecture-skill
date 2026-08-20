# Feature Modification & Bugfix Workflow

This document defines the surgical protocol for modifying existing features, adding fields/endpoints, fixing regressions, and maintaining Clean Architecture integrity in active codebases.

---

## 1. Feature Modification Decision Protocol

Before modifying any existing feature, determine the **impacted layers**:

```text
Modification Request
       │
       ├─► Adding UI Component / Visual Change ────► PRESENTATION ONLY (Widgets / Screens)
       │
       ├─► Adding/Altering UI State Field ─────────► PRESENTATION (Event, State, BLoC)
       │
       ├─► Adding Business Rule / Validation ──────► DOMAIN (Use Case / Entity)
       │
       ├─► Adding Field to Data Model & Entity ───► DOMAIN (Entity) -> DATA (Model) -> PRESENTATION (UI)
       │
       └─► Adding New API Endpoint to Feature ────► DOMAIN (Repo/UseCase) -> DATA (DataSource/RepoImpl) -> PRESENTATION (BLoC/UI)
```

---

## 2. Step-by-Step Modification Pipeline

### Step 1: Trace Existing Data Flow
- Inspect `lib/features/<feature>/` to understand the existing Use Cases, Repository contracts, and State Controllers.
- Identify all classes that consume the component being modified.

### Step 2: Modify Inward-to-Outward (Domain First)
If business logic or data contracts are changing:
1. **Domain Layer**: Update `Entity` and `Repository` interface contracts. Update or create new `UseCase`s.
2. **Data Layer**: Update `Model` (`fromJson`/`toJson`), `DataSource` implementation, and `RepositoryImpl`.
3. **Presentation Layer**: Update `Event`, `State`, and `BLoC`/Controller event handlers.
4. **UI Layer**: Update `Screens` and `Widgets` to render new state fields.

### Step 3: Surgical Diff Principle
- Make the **smallest possible change** that fulfills the requirement.
- DO NOT reformat or refactor unrelated files.
- DO NOT rename working classes or move files unless requested.

### Step 4: Update Layer Tests
- Update existing tests in `test/features/<feature>/` to cover the new parameters, models, or state transitions.

### Step 5: Validate
- Run static analysis (`flutter analyze` or `dart analyze`).
- Run architecture validation script (`node scripts/validate_architecture.js lib`).
