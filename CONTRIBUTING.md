# Contributing to Flutter Clean Architecture Skill

Thank you for your interest in contributing to the `flutter-clean-architecture` Agent Skill! We welcome contributions that improve architectural clarity, agent precision, validation coverage, and reference examples.

---

## 1. Code of Conduct
Please be respectful, collaborative, and constructive in all discussions and contributions.

---

## 2. How to Propose Rule Changes or New References

1. **Focus on Invariants**: Ensure all rules reinforce core Clean Architecture boundaries (Presentation $\rightarrow$ Domain $\leftarrow$ Data).
2. **Deterministic Instructions**: AI agents perform best with explicit, unambiguous rules (RFC 2119 keywords: `MUST`, `SHOULD`, `MAY`, `MUST NOT`, `NEVER`).
3. **Progressive Disclosure**: Keep `SKILL.md` concise. Deep explanations, edge cases, and code examples belong in `references/`.
4. **Bad vs Good Examples**: When adding anti-patterns, always provide both the forbidden anti-pattern and the recommended Clean Architecture remedy.

---

## 3. Pull Request Guidelines

1. Fork the repository and create a new feature branch (`git checkout -b feature/awesome-rule`).
2. Update relevant markdown files in `references/` or `examples/`.
3. If modifying code or rules, run the architecture validator:
   ```bash
   node scripts/validate_architecture.js examples/posts/lib
   ```
4. Verify that all markdown links resolve correctly.
5. Submit your Pull Request with a clear description of the rationale.
