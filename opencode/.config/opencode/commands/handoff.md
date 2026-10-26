---
name: handoff
description: Create a detailed context summary for continuing work in a new session.
---

# /handoff — Session Handoff

Creates a detailed context summary (handoff document) for continuing work in a new session. Captures current state, completed work, remaining tasks, relevant file paths, active goals, and boulder state.

## Usage

```
/handoff [output-path]
```

## Output

Writes `.omo/handoff-<sessionID>-<timestamp>.md` (or specified path) with:

### Sections

1. **Session Summary**: Session ID, start time, duration, models used
2. **Active Goal**: Current `/goal` objective and status (from `.omo/goal/`)
3. **Boulder State**: Current step, pending steps, blocked items (from `.omo/boulder/`)
4. **Completed Work**: What was accomplished, files changed, decisions made
5. **Remaining Work**: What's still pending, next steps
6. **Relevant Files**: File paths and code locations touched
7. **Key Decisions**: Architectural decisions and their rationale
8. **Blockers**: Anything preventing progress
9. **Recommended Next Actions**: Ordered next steps for the new session

## Integration

- Reads `.omo/goal/<sessionID>.json` for active goal
- Reads `.omo/boulder/<sessionID>.json` for boulder state
- Scans recent session history for completed work
- Output can be read in a new session to quickly resume

## Example

```
/handoff
# → writes .omo/handoff-ses_abc123-20261018.md
```

Then in a new session, read the handoff file to resume work immediately.