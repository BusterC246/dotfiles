---
name: verification
description: QA gate review and verification workflow. Runs post-implementation checks on code quality, security, and context completeness.
license: MIT
compatibility: opencode
metadata:
  audience: all
  workflow: verification
  opencode/slash: "true"
  opencode/autoinvoke: "false"
---

# Verification Skill

Gate-based verification for code changes. Performs post-implementation gate review: code quality, security, context completeness, and testing. Passes only on a clean QA matrix plus APPROVE.

## Invocation

```
skill(name="verification", operation="review", scope="<file|module|project>")
```
or `/verify <scope>`

## Verification Gates

All gates must pass before marking work complete:

### Gate 1: Code Quality
- [ ] Code follows project conventions
- [ ] No AI slop (verbose comments, redundant error handling, over-engineered patterns)
- [ ] Functions are focused and well-named
- [ ] No dead code left behind
- [ ] Proper error handling

### Gate 2: Security
- [ ] No secrets or credentials in code
- [ ] Input validation where needed
- [ ] No injection vulnerabilities
- [ ] Proper authentication/authorization checks

### Gate 3: Context Completeness
- [ ] All relevant files considered
- [ ] Edge cases handled
- [ ] Error handling complete
- [ ] Documentation updated if needed

### Gate 4: Testing
- [ ] Existing tests still pass
- [ ] New behavior covered by tests
- [ ] Manual verification on real surface

### Gate 5: Approval
- [ ] `@momus` QA gate reviewer signs off (APPROVE)

## Operations

### review
Run full QA gate review:
```
skill(name="verification", operation="review", scope="<file|module|project>")
```

### approve
Mark all gates as passed:
```
skill(name="verification", operation="approve", reason="<justification>")
```

### reject
Mark gates as failed:
```
skill(name="verification", operation="reject", reason="<failure reasons>")
```

## Output

QA matrix with gate statuses:
```
Gate 1 (Code Quality):  PASS/FAIL
Gate 2 (Security):      PASS/FAIL
Gate 3 (Context):       PASS/FAIL
Gate 4 (Testing):       PASS/FAIL
Gate 5 (Approval):      PASS/FAIL
Overall:                APPROVED/REJECTED
```

## Integration

- `@momus` — primary QA gate reviewer (read-only, APPROVE/REJECT)
- `@oracle` — architecture and security review
- `@hephaestus` / `@atlas` — implementation agents being reviewed
- Used after every implementation step in ultrawork loop