---
name: refactor
description: Intelligent refactoring with LSP, AST-grep, architecture analysis, and TDD verification.
---

# /refactor — Intelligent Refactoring

Intelligent refactoring with full toolchain: LSP-powered rename/navigation, AST-grep pattern matching, architecture analysis, and TDD verification.

## Usage

```
/refactor <target> [--scope=<file\|module\|project>] [--strategy=<safe\|aggressive>]
```

## Options

| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `<target>` | file path, module, or project | required | What to refactor |
| `--scope` | `file`, `module`, `project` | `file` | Scope of refactoring |
| `--strategy` | `safe`, `aggressive` | `safe` | Refactoring strategy |

## Workflow

### Phase 1: Analysis
1. **Read target files**: Read all files in scope before making changes
2. **LSP analysis**: Use `lsp_goto_definition`, `lsp_find_references`, `lsp_symbols` to understand code structure
3. **AST-grep search**: Use `ast-grep` for structural pattern matching (find similar patterns across codebase)
4. **Architecture review**: Consult `@metis` for architecture impact analysis

### Phase 2: Plan
1. Create refactor plan with file-by-file changes
2. Identify all callers/dependents that need updates
3. Define tests that must pass before and after

### Phase 3: Execute (with hash-anchored edits)
1. Read each file before editing (never overwrite unread files)
2. Apply hash-anchored edits validating content hashes before applying
3. Reject stale hash edits if file changed since read

### Phase 4: TDD Verify
1. Run existing tests: must pass before changes
2. Make changes
3. Run tests again: must pass after changes
4. Run `@momus` QA gate review before marking complete

## Strategies

- **safe**: Minimal changes, preserve behavior exactly, only touch files in scope
- **aggressive**: Broader refactoring, may change interfaces and update all callers

## Integration

- `@hephaestus` — primary refactoring agent (strong coding model)
- `@oracle` — architecture review and debugging
- `@momus` — QA gate review (read-only, cannot write)
- `@metis` — architecture consultation

## Example

```
/refactor src/auth/password.ts --scope=module --strategy=safe
```