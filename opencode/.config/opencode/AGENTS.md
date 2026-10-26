# OpenCode Agent Instructions

This project uses oh-my-opencode-slim with OpenCode v2. All models are from the OpenCode Console free tier ($0 input / $0 output — no billing required).

## Agent Roster

oh-my-opencode-slim provides these built-in agents. Skill assignments are configured in `oh-my-opencode-slim.jsonc`:

| Agent | Model | Role | Skills |
|-------|-------|------|--------|
| `@orchestrator` | nemotron-3.5-super-vl-free | Slim orchestration agent — master delegator | `"*"` (all slim skills) |
| `@sisyphus` | nemotron-3.5-super-vl-free | Main orchestration — ultrawork loop, goals, boulder state | ultrawork, memory, verification |
| `@oracle` | nemotron-3-ultra-free | Strategic advisor, debugger, QA gate reviewer | simplify, verification |
| `@explorer` | glm-5.3-flash-free | Codebase reconnaissance, external research | — |
| `@librarian` | flint-40b-free | Documentation, code lookup, persistent memory | memory |
| `@fixer` | deepseek-v4.1-flash-free | Fast implementation specialist — edits, TDD | refactor, verification |
| `@designer` | nemotron-3.5-super-vl-free | UI/UX implementation and visual excellence | — |
| `@hephaestus` | deepseek-v4.1-flash-free | Build agent — refactoring, code edits, build/verify | refactor, verification |
| `@prometheus` | nemotron-3-ultra-free | Planning — work plans, boulder state, plan files | ultrawork, memory |
| `@metis` | nemotron-3-ultra-free | Plan consultation, architecture review | memory, verification |
| `@momus` | nemotron-3-ultra-free | QA gate review — plan review, final approval (read-only) | verification |
| `@atlas` | nemotron-3.5-super-vl-free | Execution agent — carries out approved work plans | ultrawork, refactor, verification |
| `@sisyphus-junior` | deepseek-v4.1-flash-free | Junior orchestration — assisted task execution | refactor |
| `@multimodal-looker` | nemotron-3.5-super-vl-free | Visual analysis — images, PDFs, diagrams (read-only, NVIDIA vision only) | — |

### Slim Built-in Skills

oh-my-opencode-slim registers these skills at load. Same-named skills in `~/.config/opencode/skills/` override bundled versions:

| Skill | Description | Default Agent |
|-------|-------------|---------------|
| `codemap` | Hierarchical repository maps | orchestrator |
| `deepwork` | Autonomous pass-by-pass workflow (sketch→structure→detail) | orchestrator |
| `simplify` | Behavior-preserving simplification | oracle |
| `verification-planning` | Plans project-specific evidence path before non-trivial changes | orchestrator |
| `clonedeps` | Clone dependency source locally for library inspection | orchestrator |
| `worktrees` | Git worktrees as safe isolated coding lanes | orchestrator |
| `step-back` | Pauses snowballing patches to reassess direction | orchestrator |
| `deanchor` | Generalizes from examples instead of copying | orchestrator |
| `ai-estimates` | Estimates task duration for human working with AI | orchestrator |
| `reflect` | Turns workflow friction into reusable skills/config | orchestrator |
| `oh-my-opencode-slim` | Configures and tunes the plugin setup | orchestrator |

Skill assignment format: `"*"` = all skills available; explicit list = only those skills.

## Slash Commands

| Command | Description |
|---------|-------------|
| `/handoff [output-path]` | Create context summary for continuing work in a new session |
| `/refactor <target> [--scope=<...>] [--strategy=<safe\|aggressive>]` | Intelligent refactoring with LSP, AST-grep, TDD |
| `/hyperplan [topic]` | Adversarial team planning workflow |
| `/deepwork <task>` | Multi-pass workflow with review gates (sketch→structure→detail) (slim built-in) |
| `/reflect` | Review workflow and suggest improvements (slim built-in) |

## Conflict Resolution

- **Slim provides**: orchestrator, oracle, explorer, fixer, designer, librarian (built-in agents — no OpenCode native definitions needed)
- **OpenCode native agents**: sisyphus, hephaestus, prometheus, metis, momus, atlas, sisyphus-junior, multimodal-looker
- **Goal tracking / continuation**: Slim's built-in wake system (`backgroundJobs.orchestratorWake`) handles goal tracking and continuation — no custom `/goal` or `/stop-continuation` commands needed
- **Deepwork**: Slim's built-in `/deepwork` command is used — no custom `/deepwork` command needed

## Skills

oh-my-opencode-slim registers built-in skills at load. The same-named skills in `~/.config/opencode/skills/` override bundled versions. Skills with `"*"` permission grants are available to all agents.

| Skill | Description | Available To |
|-------|-------------|--------------|
| `codemap` | Hierarchical repository maps | orchestrator |
| `deepwork` | Autonomous pass-by-pass workflow (sketch→structure→detail) | orchestrator |
| `simplify` | Behavior-preserving simplification | oracle |
| `verification-planning` | Plans project-specific evidence path before non-trivial changes | orchestrator |
| `clonedeps` | Clone dependency source locally for library inspection | orchestrator |
| `worktrees` | Git worktrees as safe isolated coding lanes | orchestrator |
| `step-back` | Pauses snowballing patches to reassess direction | orchestrator |
| `deanchor` | Generalizes from examples instead of copying | orchestrator |
| `ai-estimates` | Estimates task duration for human working with AI | orchestrator |
| `reflect` | Turns workflow friction into reusable skills/config | orchestrator |
| `oh-my-opencode-slim` | Configures and tunes the plugin setup | orchestrator |

Skill assignment format: `"*"` = all skills available to that agent; explicit list = only those skills; `"!skill-name"` = deny specific skill.

## Storage Layout (`.omo/`)

```
.omo/
├── memory/          # Persistent git-backed memory entries (.md with frontmatter)
├── goal/            # Goal state files (<sessionID>.json)
├── plans/           # Work plans created by prometheus/hyperplan
├── boulder/         # Boulder state for multi-step work
├── notepad/         # Notepad state for task tracking
└── handoff-*.md     # Session handoff documents
```

## Free Models

All models are OpenCode Console free tier ($0/$0). Already authenticated via OAuth — no billing required.

- **Default**: `opencode/nemotron-3.5-super-vl-free`
- **Small**: `opencode/glm-5.3-flash-free`

## Web Research (MANDATORY)

ALWAYS use `websearch` and `webfetch` before answering any technical question.
Do NOT rely solely on training data. Search first, verify, then act.

- **Before answering any question about a library, framework, API, or tool** — search the web first
- **When the user mentions a specific technology** — look it up
- **When debugging** — search for the error message, check docs
- **When implementing** — fetch relevant documentation
- **When making claims** — verify with docs
- **Use `gh_grep`** — for real-world code examples on GitHub

Skip only when: the user says "don't search", or the task is purely internal (file edits, code refactoring).

## Search Quality Standards

**Agents must use high-quality search strategies:**

### Query Formulation
- Use **specific, technical terms** — not vague descriptions
- Include **version numbers**, **platform specifics**, **error codes**
- Search **official docs first** (context7 MCP), then GitHub (gh_grep), then web
- Combine **site:** filters for authoritative sources (e.g., `site:docs.rs`, `site:github.com`)

### Multi-Source Validation (via `multi-source-search` skill)
- **Minimum 2 independent sources** for any claim
- **Confidence scoring**: 3+ sources = high, 2 = medium, 1 = low
- **Source diversity**: Official docs + GitHub code + community discussions
- **Cross-reference**: Trace derivative articles to primary sources
- **Cite sources** inline with claims

### Search Budget & Stop Conditions
- **Max 6 searches + 6 page opens** per research task
- **Stop early** when all material claims have enough independent sources
- **Never repeat failed queries** — change hypothesis, source type, or date window
- **Report gaps** explicitly when budget exhausted

### Tools Available (All Free)
| Tool | Purpose | Cost |
|------|---------|------|
| `websearch` | General web search | Free (OpenCode built-in) |
| `webfetch` | Fetch page content | Free (OpenCode built-in) |
| `gh_grep` | GitHub code search | Free (MCP) |
| `context7` | Official documentation | Free (MCP) |
| `multi-source-search` skill | Structured multi-source workflow | Free (uses host tools) |

### Mandatory Workflow for Technical Questions
1. **Define the claim/decision** being researched
2. **Search official docs** (context7) for authoritative answer
3. **Search GitHub** (gh_grep) for real-world implementations
4. **Search web** (websearch) for community knowledge, issues, recent changes
4. **Cross-validate** findings across sources
5. **Synthesize** with confidence scores and source citations
6. **Report gaps** if sources disagree or are missing

## Quality vs Token Balance

- **High variant** (max reasoning): orchestrator, oracle, metis, momus, prometheus — complex decisions, planning, QA
- **High variant** (strong coding): hephaestus, fixer, atlas — implementation, refactoring
- **Medium variant** (balanced): designer, multimodal-looker, sisyphus-junior — vision + routine work
- **Low variant** (token-efficient): explorer, librarian — scouting, documentation lookup

## Usage Examples

```bash
# Start OpenCode with background subagents
OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true OPENCODE_ENABLE_EXA=1 opencode

# Inside a session:
# Orchestrator auto-delegates to specialists:
@sisyphus "Build a REST API with authentication"
# Or invoke specialists directly:
@fixer "Implement feature X"
@oracle "Review architecture"
@prometheus "Plan the migration"

# Slim commands:
/refactor src/auth.js --strategy safe
/deepwork <task>
/handoff
/hyperplan "Migrate to JWT authentication"
/reflect

# Orchestrator tuning:
# "tune your setup" → uses oh-my-opencode-slim skill
```

## Background Orchestration (Auto-Delegation)

oh-my-opencode-slim provides **background orchestration by default**. The Orchestrator (`@sisyphus`) automatically:

1. **Parses your request** and identifies the work graph
2. **Routes each part** to the best specialist agent
3. **Dispatches specialists as background subagents**
4. **Reconciles results** and verifies outcomes before continuing

You do not need to manually dispatch subagents. Just describe what you want to build or fix, and the Orchestrator handles delegation.

### Agent to Role Mapping

| Agent | Best For |
|-------|----------|
| `@sisyphus` | Main orchestration — delegates and coordinates all work |
| `@oracle` | Debugging, architecture, QA gate review |
| `@explorer` | Codebase reconnaissance, external research |
| `@fixer` | Fast implementation, edits, TDD verification |
| `@designer` | UI/UX, visual excellence |
| `@librarian` | Documentation, code lookup, persistent memory |
| `@hephaestus` | Build agent, refactoring, code edits |
| `@prometheus` | Planning, work plans, boulder state |
| `@metis` | Plan consultation, architecture review |
| `@momus` | QA gate review, plan review, final approval |
| `@atlas` | Execution of approved work plans |
| `@sisyphus-junior` | Junior orchestration, notepad state |
| `@multimodal-looker` | Visual analysis (images, PDFs, diagrams — NVIDIA vision only) |

### Automatic Verification Dispatch (MANDATORY)

**The Orchestrator MUST dispatch review/verification agents after every implementation task.**

| After Task Type | Verification Agent | What It Checks |
|-----------------|-------------------|----------------|
| Code implementation | `@momus` | QA gate review — quality, correctness, edge cases |
| Architecture changes | `@oracle` | Architecture review, trade-offs, risks |
| Planning phase | `@momus` | Plan review — feasibility, completeness |
| Refactoring | `@oracle` | Code review — no regressions, no breaking changes |
| Bug fix | `@oracle` | Root cause verified, fix correct, tests pass |
| Any code change | `verification` skill | QA gate: quality, security, context completeness |

### Verification Workflow
1. **Implementation completes** → Orchestrator dispatches `@momus` for QA gate review
2. **Architecture decision** → Orchestrator dispatches `@oracle` for review
3. **Plan created** → Orchestrator dispatches `@momus` for plan review
4. **Review passes** → Orchestrator proceeds to next task
5. **Review fails** → Orchestrator routes back to `@fixer` for corrections

### Enforcement
- `@sisyphus` (Orchestrator) has `task: "allow"` — can dispatch any verification agent
- `verification` skill is loaded by `@sisyphus`, `@oracle`, `@fixer`, `@atlas`, `@hephaestus`
- `@momus` is read-only (cannot edit, cannot run bash) — pure review
- Every implementation task should trigger at least one verification dispatch

## Test Writing Enforcement (MANDATORY)

**All agents MUST write tests for code they create or modify.** No exceptions.

- **Unit tests** for every new function/module (Jest, Vitest, pytest, Go test, Rust test)
- **Integration tests** for API endpoints, database operations, external services
- **Test-first/TDD** preferred: write failing test → make pass → refactor
- **Coverage targets**: aim for >80% line coverage on new code
- **Mock external dependencies** — never call real APIs/DBs in unit tests
- **Run tests in CI** — all PRs must pass test suite

### Enforcement:
- `test-master` skill provides patterns and coverage analysis
- `verification` skill gates: review must confirm tests exist and pass
- `hephaestus`/`fixer`/`atlas` agents have `verification` skill loaded

## Compaction Quality: Use `/handoff` Over Auto-Compaction

**Auto-compaction degrades free-model quality** (summary capped at 4k tokens, same model).

**Instead: proactively `/handoff` before context gets large.**

| Trigger | Action |
|---------|--------|
| Session > 50% context | `/handoff` to create structured checkpoint |
| Before complex multi-step task | `/handoff` to capture clean state |
| After major milestone | `/handoff` + start fresh session |
| Context quality degrades | `/handoff` + `/new-session` |

### Why `/handoff` wins:
- Structured sections: Objective, Work State, Next Move, Relevant Files, Decisions, Blockers
- Full token budget (not capped at 4k)
- Human-readable, reusable across sessions
- Integrates with `.omo/goal/`, `.omo/boulder/`, `.omo/memory/`

## Linux Environment Scouting (MANDATORY Before System Changes)

**Agents MUST scout the target environment before making any system-level changes.**

### Required Pre-Change Checks

```bash
# 1. Identify distro and version
cat /etc/os-release
# OR: lsb_release -a 2>/dev/null || cat /etc/*release

# 2. Identify package manager
command -v apt && echo "apt (Debian/Ubuntu)"
command -v dnf && echo "dnf (Fedora/RHEL 8+)"
command -v yum && echo "yum (RHEL/CentOS 7)"
command -v pacman && echo "pacman (Arch)"
command -v zypper && echo "zypper (openSUSE)"
command -v apk && echo "apk (Alpine)"
command -v xbps-install && echo "xbps (Void)"

# 3. Check init system
ps -p 1 -o comm=
# systemd, sysvinit, openrc, runit

# 4. Check available tools
command -v systemctl && echo "systemd available"
command -v service && echo "sysvinit available"
command -v rc-service && echo "openrc available"

# 5. Check kernel and architecture
uname -r
uname -m

# 6. Check if running in container
[ -f /.dockerenv ] && echo "Docker container"
grep -qa container /proc/1/environ 2>/dev/null && echo "Container (systemd)"
```

### Distro-Specific Package Manager Commands

| Distro Family | Package Manager | Install | Update | Search | Remove |
|---------------|----------------|---------|--------|--------|--------|
| Debian/Ubuntu | `apt` | `apt install pkg` | `apt update && apt upgrade` | `apt search pkg` | `apt remove pkg` |
| Fedora/RHEL 8+ | `dnf` | `dnf install pkg` | `dnf upgrade` | `dnf search pkg` | `dnf remove pkg` |
| RHEL/CentOS 7 | `yum` | `yum install pkg` | `yum update` | `yum search pkg` | `yum remove pkg` |
| Arch/Manjaro | `pacman` | `pacman -S pkg` | `pacman -Syu` | `pacman -Ss pkg` | `pacman -R pkg` |
| openSUSE | `zypper` | `zypper in pkg` | `zypper up` | `zypper se pkg` | `zypper rm pkg` |
| Alpine | `apk` | `apk add pkg` | `apk upgrade` | `apk search pkg` | `apk del pkg` |
| Void | `xbps` | `xbps-install pkg` | `xbps-install -Su` | `xbps-query -Rs pkg` | `xbps-remove pkg` |

### Mandatory Workflow for System Changes

1. **Scout first** — Run the pre-change checks above
2. **Verify package manager** — Use the correct commands for the detected distro
3. **Check existing packages** — `dpkg -l | grep pkg` / `rpm -qa | grep pkg` / `pacman -Q | grep pkg`
4. **Dry-run when possible** — `apt install -s pkg` / `dnf install --assumeno pkg` / `pacman -Sp pkg`
5. **Use system-admin skill** — For service management, monitoring, troubleshooting
6. **Test after changes** — Verify services start, configs are valid

### Container/VM Awareness
- **Docker/Podman**: Prefer `apk` (Alpine) or minimal `apt` installs; avoid systemd
- **systemd-nspawn**: Full systemd available
- **WSL**: systemd may be limited; check `systemctl` availability
- **CI runners**: Often minimal; install only what's needed

## Directory Sandbox (MANDATORY)

**Agents MUST stay within the project directory** (where `opencode` was launched). 

| Allowed | Restricted |
|---------|------------|
| Project dir (`.`) — read, write, edit, list, glob, grep | Parent dirs (`..`, `../..`) — **denied** |
| `/tmp` — create temp dirs, scratch files | Home dir (`~`) — **denied** unless explicit |
| System dirs (`/etc`, `/usr`, `/var`) — **read-only** via `shell` | Other projects — **denied** |

### Enforcement (via `opencode.json` permissions)
```json
"permissions": {
  "read":  { "resource": ".", "effect": "allow" },
  "write": { "resource": ".", "effect": "allow" },
  "edit":  { "resource": ".", "effect": "allow" },
  "list":  { "resource": ".", "effect": "allow" },
  "glob":  { "resource": ".", "effect": "allow" },
  "grep":  { "resource": ".", "effect": "allow" },
  "shell": { "resource": "*", "effect": "allow" },
  "external_directory": { "resource": "/tmp", "effect": "allow" }
}
```

### Rules
1. **Never** use absolute paths outside project unless in `/tmp`
2. **Never** write to `~`, `~/.config`, `~/Projects/other` without explicit user approval
3. **Temp work** → create under `/tmp/<session>-<task>/` and clean up after
4. **System configs** → read-only via `shell` (e.g., `cat /etc/os-release`), never edit
5. **User approval required** for any `external_directory` beyond `/tmp`

### Agent Behavior: Directory Access
**CRITICAL: DO NOT ATTEMPT to access directories outside the project unless the user explicitly instructs you to.**

**If you need to access an external directory:**
1. **STOP** — do not try to `cd`, `read`, `write`, or `shell` into it
2. **ASK THE USER** in plain text: "I need to access [path]. Is that okay?"
3. **WAIT** for explicit approval before proceeding
4. Only after approval, use the appropriate tool

**NEVER print shell commands as text** — either execute them with the tool or ask the user for permission first.

**If a permission is `ask` and you cannot prompt (autonomous mode):** do not attempt the operation — ask the user in text instead.

Default assumption: **stay in the project directory.** External directory access requires explicit user instruction.

### Skills to Use
- `system-admin` — system info, service management, monitoring
- `file-operations` — safe file/directory ops
- `process-management` — process control
- `network-tools` — network diagnostics
- `user-permissions` — user/group management
- `ssh` — remote access
- `shell-scripting` — portable shell scripts

## Token Optimization Plugins (Installed)

Three community plugins are configured in `opencode.json` to reduce token usage **without degrading quality**. They operate at different layers and are complementary:

| Plugin | Layer | Reduction | Mechanism |
|--------|-------|-----------|-----------|
| **OpenSlimedit** | Tool schemas + read output | 11-45% | Compresses tool descriptions (sent every API call), compacts file paths, adds line-range edit support |
| **opencode-dcp** | Conversation context | 50-70% (long sessions) | Dynamic Context Pruning — model decides when to compress stale messages; preserves history on disk |
| **opencode-snip** | Shell output | 60-90% | Rewrites bash commands via `snip` binary to filter verbose output before it reaches context |

**Stacked reduction**: All three together can achieve 90%+ token savings on bash-heavy, long sessions.

### Plugin Details

#### OpenSlimedit (`openslimedit@latest`)
- Zero config, works via standard hooks (`tool.definition`, `tool.execute.before/after`)
- Benchmarked on free models (Minimax Free -24.8%, Nemotron/DeepSeek/GLM compatible)
- No model-specific code — safe for all `opencode/*` models

#### opencode-dcp (`@tarquinen/opencode-dcp@latest`)
- Adds `compress` tool the model can invoke when tasks complete
- Configurable: `~/.config/opencode/dcp.jsonc` for thresholds
- For small-context free models: consider lowering `compress.minContextLimit`
- Never mutates session history — only rewrites outgoing requests

#### opencode-snip (`opencode-snip@latest`)
- Requires `snip` binary: `go install github.com/edouard-claude/snip/cmd/snip@latest` or `brew install edouard-claude/tap/snip`
- Uses `tool.execute.before` hook to prefix shell commands with `snip`
- 100+ supported commands (git, cargo, npm, pytest, docker, k8s, etc.)
- **Do NOT combine with RTK** — both rewrite bash output (pick one)

### Verification
```bash
# Check plugins loaded
opencode plugin list

# Verify snip binary
snip --version

# Check DCP config
cat ~/.config/opencode/dcp.jsonc
```

## Todos (opencode v2)

`todowrite` is enabled via `experimental.todo: true`. Use it to track multi-step work:
keep the list current as tasks progress, mark items in_progress/completed.
