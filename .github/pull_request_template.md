## Summary of Changes

A concise description of the architectural rule, reference document, or validation update.

## Invariant Alignment
- [ ] Does this change preserve the core Clean Architecture dependency rule (Presentation $\rightarrow$ Domain $\leftarrow$ Data)?
- [ ] Are all RFC 2119 keywords (`MUST`, `SHOULD`, `MAY`, `MUST NOT`, `NEVER`) used deterministically?
- [ ] Does the change keep `SKILL.md` concise via progressive disclosure?

## Testing & Validation
- [ ] `node scripts/validate_skill.js` passed.
- [ ] `node scripts/check_references.js` passed.
- [ ] `node scripts/validate_architecture.js examples/posts/lib` passed.
