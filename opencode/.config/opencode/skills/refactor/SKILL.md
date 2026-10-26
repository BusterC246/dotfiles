---
name: refactor
description: Intelligent refactoring with LSP, AST-grep, architecture analysis, and TDD verification.
license: MIT
compatibility: opencode
metadata:
  audience: hephaestus
  workflow: refactor
  opencode/slash: "true"
  opencode/autoinvoke: "false"
---

# Refactor Skill

Intelligent refactoring with LSP-powered rename/navigation, AST-grep pattern matching, architecture analysis, and TDD verification.

## Invocation

```
skill(name="refactor", target="<path>", scope="<file|module|project>", strategy="<safe|aggressive>")
```
or `/refactor <target> [--scope=<...>] [--strategy=<...>]`

## Workflow

### Phase 1: Analysis
1. Read all target files before making changes
2. LSP analysis: `lsp_goto_definition`, `lsp_find_references`, `lsp_symbols`, `lsp_diagnostics`
3. AST-grep: structural pattern matching to find similar patterns across codebase
4. Architecture review: consult `@metis` for impact analysis

### Phase 2: Plan
- Create refactor plan with file-by-file changes
- Identify all callers/dependents needing updates
- Define tests that must pass before and after

### Phase 3: Execute (Hash-Anchored Edits)
- Read each file before editing (never overwrite unread files)
- Apply edits validating content hashes
- Reject stale hash edits if file changed since read

### Phase 4: TDD Verify
- Run existing tests (must pass before)
- Make changes
- Run tests again (must pass after)
- `@momus` QA gate review before marking complete

## Strategies

- **safe**: Minimal changes, preserve behavior exactly
- **aggressive**: Broader refactoring, may change interfaces

## Output

Refactor summary:
```
Files changed: <list>
Tests before: <pass/fail>
Tests after: <pass/fail>
QA Gate: <APPROVE/REJECT>
```

## Integration

- `@hephaestus` — primary refactoring agent
- `@metis` — architecture consultation
- `@oracle` — debugging during refactor
- `@momus` — QA gate approval