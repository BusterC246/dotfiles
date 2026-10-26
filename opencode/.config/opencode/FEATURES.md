# Feature Reference — oh-my-opencode-slim + OpenCode v2

This configuration replicates oh-my-openagent's core features on OpenCode v2 using
oh-my-opencode-slim (v2-native) plus OpenCode native skills, commands, and agents.

All models are from the **OpenCode Console free tier** ($0 input / $0 output).
No billing, API key, or subscription required.

---

## Agent Roster (omo-style)

| Agent | Model Chain | Role | omo Equivalent |
|-------|-------------|------|----------------|
| `@sisyphus` | nemotron-3.5-super-vl-free → nemotron-3-ultra-free → deepseek-v4.1-flash-free → glm-5.3-flash-free | Main orchestration — ultrawork loop, goals, boulder state | Sisyphus |
| `@hephaestus` | deepseek-v4.1-flash-free → nemotron-3.5-super-vl-free → glm-5.3-flash-free | Build/refactoring, code edits, TDD verification | Hephaestus |
| `@prometheus` | nemotron-3-ultra-free → nemotron-3.5-super-vl-free → deepseek-v4.1-flash-free | Planning — work plans, boulder state, plan files | Prometheus (Planner) |
| `@metis` | nemotron-3-ultra-free → nemotron-3.5-super-vl-free → deepseek-v4.1-flash-free | Plan consultation, architecture review | Metis (Plan Consultant) |
| `@momus` | nemotron-3-ultra-free → nemotron-3.5-super-vl-free → deepseek-v4.1-flash-free | QA gate review, plan review, final approval (read-only) | Momus (Plan Reviewer) |
| `@atlas` | nemotron-3.5-super-vl-free → deepseek-v4.1-flash-free → glm-5.3-flash-free | Execution of approved work plans | Atlas |
| `@sisyphus-junior` | deepseek-v4.1-flash-free → glm-5.3-flash-free → flint-40b-free | Junior orchestration, notepad state | Sisyphus Junior |
| `@multimodal-looker` | nemotron-3.5-super-vl-free → deepseek-v4.1-flash-free | Visual analysis — images, PDFs, diagrams (read-only) | Multimodal Looker |
| `@oracle` | nemotron-3-ultra-free → nemotron-3.5-super-vl-free → deepseek-v4.1-flash-free | Debugging, architecture, QA gate reviewer | Oracle |
| `@explorer` | glm-5.3-flash-free → deepseek-v4.1-flash-free → flint-40b-free | Codebase reconnaissance, research | Explore |
| `@librarian` | flint-40b-free → glm-5.3-flash-free → deepseek-v4.1-flash-free | Documentation, code lookup, persistent memory | Librarian |
| `@designer` | nemotron-3.5-super-vl-free → deepseek-v4.1-flash-free | UI/UX, visual excellence | Designer |
| `@fixer` | deepseek-v4.1-flash-free → nemotron-3.5-super-vl-free → glm-5.3-flash-free | Implementation, refactoring, TDD | Fixer |

All agents use **fallback chains** (arrays) — if the primary model is rate-limited, the next in
chain is tried automatically. Models can be swapped by editing the preset.

---

## Slash Commands

| Command | Description | omo Equivalent |
|---------|-------------|----------------|
| `/goal <text>` | Set, show, pause, resume, or clear the active thread goal | `/goal` |
| `/ulw-execute [plan] [--worktree <path>] [--make-pr] [--ship]` | Execute ultrawork work plan with boulder state | `/ulw-execute` |
| `/stop-continuation` | Stop all continuation mechanisms (goal, boulder, todos) | `/stop-continuation` |
| `/refactor <target> [--scope=<...>] [--strategy=<safe\|aggressive>]` | Intelligent refactoring with LSP, AST-grep, TDD | `/refactor` |
| `/handoff` | Create context summary for continuing in a new session | `/handoff` |
| `/hyperplan` | Adversarial team planning workflow | `/hyperplan` |
| `/deepwork <task>` | Multi-pass workflow with review gates (sketch→structure→detail) | (slim built-in) |
| `/reflect` | Review workflow and suggest improvements | (slim built-in) |

---

## Skills

| Skill | Description | Location |
|-------|-------------|----------|
| `memory` | Persistent git-backed memory (`.omo/memory/`) | `~/.config/opencode/skills/memory/` |
| `verification` | QA gate review workflow | `~/.config/opencode/skills/verification/` |
| `ultrawork` | Read-plan-prove-verify loop | `~/.config/opencode/skills/ultrawork/` |
| `refactor` | Refactoring with LSP, AST-grep, TDD | `~/.config/opencode/skills/refactor/` |
| `codemap` | Hierarchical repository maps | slim built-in |
| `deepwork` | Autonomous pass-by-pass workflow | slim built-in |
| `verification-planning` | Evidence path planning before changes | slim built-in |
| `simplify` | Behavior-preserving simplification | slim built-in |
| `worktrees` | Git worktrees as isolated coding lanes | slim built-in |
| `clonedeps` | Clone dependency source locally | slim built-in |
| `step-back` | Reassess direction when fixes stack | slim built-in |
| `deanchor` | Generalize from examples | slim built-in |
| `ai-estimates` | Estimate task duration | slim built-in |
| `oh-my-opencode-slim` | Configure and improve the plugin setup | slim built-in |

---

## Storage Layout (`.omo/`)

```
.omo/
├── memory/     # Persistent git-backed memory entries (.md with frontmatter)
├── goal/       # Goal state files (<sessionID>.json)
├── plans/      # Work plans created by prometheus
├── boulder/    # Boulder state for multi-step work
└── notepad/    # Notepad state for task tracking
```

---

## Feature Mapping: oh-my-openagent → This Config

| oh-my-openagent Feature | This Config | Notes |
|-------------------------|-------------|-------|
| `mass ulw` / `ulw` keyword | `/ulw-execute` + ultrawork skill | Same read-plan-prove-verify loop |
| `/goal` | `/goal` command | Goal persists across turns |
| `/stop-continuation` | `/stop-continuation` command | Stops goal, boulder, todo continuation |
| `/refactor` | `/refactor` command + refactor skill | LSP, AST-grep, TDD verification |
| `/handoff` | `/handoff` command | Context summary for new sessions |
| `/hyperplan` | `/hyperplan` command | Adversarial team planning |
| Persistent memory (kibitzer) | `memory` skill + `.omo/memory/` | Git-backed, per-agent overrides |
| Gates & verification | `verification` skill + `@momus` | QA gate review, APPROVE/reject |
| Boulder state | `.omo/boulder/` + `/ulw-execute` | Multi-step work state |
| Subagents | 13 specialist agents | Full omo-style roster |
| Model fallback chains | Model arrays in preset | Swap-able, rate-limit resilient |
| Council (multi-model consensus) | council preset with 3 free models | `/council` via @council |
| Team Mode (12 team_* tools) | backgroundJobs + subagent delegation | Via OpenCode v2 subagent tool |
| LSP tools | `lsp: true` in opencode.json | goto-definition, references, etc. |
| Hashline edits | refactor skill + slim | Hash-anchored edits |
| Comment checker | verification skill | Blocks AI slop patterns |
| Computer use (experimental) | Not available | Not supported on OpenCode v2 plugin |
| 58 lifecycle hooks | slim hooks (phase-reminder, cache-monitor, etc.) | Different hook set from omo |

---

## Quality vs Token Balance

- **High variant** (max reasoning): orchestrator, oracle, metis, momus, prometheus, atlas — complex decisions, planning, QA review
- **High variant** (strong coding): hephaestus, fixer — implementation, refactoring
- **Medium variant** (balanced): designer, multimodal-looker, sisyphus-junior — vision + routine work
- **Low variant** (token-efficient): explorer, librarian — scouting, documentation lookup

---

## Free Models (OpenCode Console)

| Model ID | Use | Cost |
|----------|-----|------|
| `opencode/nemotron-3.5-super-vl-free` | Orchestrator, designer, vision tasks | $0 / $0 |
| `opencode/nemotron-3-ultra-free` | Oracle, planner, QA review | $0 / $0 |
| `opencode/deepseek-v4.1-flash-free` | Implementation, refactoring | $0 / $0 |
| `opencode/glm-5.3-flash-free` | Exploration, small tasks | $0 / $0 |
| `opencode/flint-40b-free` | Documentation, memory | $0 / $0 |

Already authenticated via OpenCode Console OAuth — no additional setup needed.

---

## Usage

```bash
# Start OpenCode with background subagents
OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true OPENCODE_ENABLE_EXA=1 opencode

# Inside a session:
@sisyphus "Build a REST API with authentication"
/goal "Build a REST API with authentication"
/ulw-execute --worktree ./wt-auth --make-pr
/refactor src/auth.js --strategy safe
/handoff
/stop-continuation
```
