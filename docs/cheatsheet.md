# agy-cli Cheatsheet

> Quick reference for everything covered in this workshop.
> All commands verified against [antigravity.google/docs](https://antigravity.google/docs/cli-overview).

---

## Installation & Version

```bash
curl -fsSL https://antigravity.google/cli/install.sh | bash
agy --help         # Show all flags and subcommands
agy changelog      # Show release notes
agy update         # Self-update
agy install        # Configure PATH and shell aliases
```

---

## Launch Modes

| Mode | Command | When to use |
| :-- | :-- | :-- |
| **Interactive** | `agy` | Default — full conversational session |
| **Seeded interactive** | `agy -i "<prompt>"` | Start with direction, continue conversationally |
| **Print (headless)** | `agy -p "<prompt>"` | Single shot, pipe to stdout |
| **Continue last** | `agy -c` | Resume most recent session |
| **Resume by ID** | `agy --conversation <id>` | Resume a specific past session |
| **Resume in-session** | `/resume` or `/switch` | Switch conversations without leaving agy |

---

## Key Flags

> Source: [`agy --help`](https://antigravity.google/docs/cli-getting-started) · [cli-using](https://antigravity.google/docs/cli-using)

| Flag | Short | Description |
| :-- | :-- | :-- |
| `--print "<prompt>"` | `-p` | Non-interactive single prompt |
| `--prompt-interactive "<prompt>"` | `-i` | Seeded interactive session |
| `--continue` | `-c` | Resume most recent conversation |
| `--conversation <id>` | — | Resume by conversation ID |
| `--add-dir <path>` | — | Add directory to workspace (repeatable) |
| `--sandbox` | — | Enable terminal sandbox restrictions |
| `--dangerously-skip-permissions` | — | Auto-approve all tool requests (CI only) |
| `--print-timeout <duration>` | — | Timeout for print mode (default: 5m) |
| `--log-file <path>` | — | Override log output path |
| `--model <name>` | — | Select the reasoning model for this run |
| `--new-project` | — | Start the session in a new project workspace |
| `--project <path>` | — | Target a specific project workspace |

> **Note:** `--model` sets the reasoning model for a single run; the `/model` slash command sets the persistent default. Strict mode is set via the `/permissions` slash command — there is no `--strict` flag. See [Features docs](https://antigravity.google/docs/cli-features).

---

## Slash Commands (Interactive Mode)

> Source: [CLI Features — Core Slash Commands](https://antigravity.google/docs/cli-features) · [Using Antigravity CLI](https://antigravity.google/docs/cli-using)

| Command | Category | Purpose |
| :-- | :-- | :-- |
| `/resume` (`/switch`) | Conversation | Open conversation picker to resume or switch sessions |
| `/rewind` (`/undo`) | Conversation | Roll back conversation history to a previous checkpoint |
| `/fork` | Conversation | Branch the current conversation into a parallel isolated workspace — trial risky steps without affecting the original |
| `/rename <name>` | Conversation | Rename the active conversation thread |
| `/planning` | Artifacts | Enter planning mode — produce an Implementation Plan (and Task List) before writing code |
| `/artifact` (`/artifacts`) | Artifacts | View the artifacts for the current session |
| `/diff` | Review | Open agy's built-in diff view of the changes made in your session |
| `/permissions` | Autonomy | Set tool-permission mode: `request-review`, `always-proceed`, `proceed-in-sandbox`, `strict` (also via `/config` → Tool Permissions) |
| `/grill-me` | Autonomy | Have agy ask **you** clarifying questions to align on the spec/plan *before* it implements |
| `/goal` | Autonomy | Run autonomously to completion — agy auto-approves its own plan and won't stop for input *(reported — verify against the CLI)* |
| `/model` | Config | Select default reasoning model (persists across sessions) |
| `/config` (`/settings`) | Config | Open full-screen settings overlay |
| `/keybindings` | Config | Open the interactive keyboard shortcut editor |
| `/statusline` | Config | Customize real-time CLI status bar indicators |
| `/tasks` | Monitoring | Monitor, view logs for, or terminate background tasks |
| `/skills` | Monitoring | Browse local and global agent skills |
| `/mcp` | Monitoring | Configure and manage MCP servers |
| `/agents` | Monitoring | View, manage, and approve subagent actions |
| `/open <path>` | Utility | Open a file in your preferred external editor |
| `/usage` | Utility | Open the inline interactive help manual |
| `/logout` | Account | Log out and clear cached credentials |

> **The autonomy spectrum.** Dial how much the agent checks in with you: `/grill-me` (agent interrogates you first — max alignment) → `/permissions request-review` (review artifacts at milestones — the default) → `/permissions always-proceed` / `/goal` (agent runs to completion, auto-approving its own plan). Tighten for ambiguous/high-stakes work; loosen for well-scoped, low-risk, or batch tasks.

---

## Artifacts

> Structured, verifiable deliverables the agent emits as it works — review milestones instead of raw tool calls. Types: **Implementation Plan** (approach + files to change, before coding), **Task List** (`task.md` ticked off during implementation), **Walkthrough** (post-completion summary + how to verify). See [Exercise 15](exercises/ex15_artifacts.md).

| Action | How |
| :-- | :-- |
| Plan before coding | `/planning` (produces an Implementation Plan artifact) |
| View session artifacts | `/artifact` (alias `/artifacts`) |
| Open the Artifact Review panel | `ctrl+r` — leave inline comments to co-steer without stopping the agent |
| Edit an artifact in `$EDITOR` | `ctrl+g` |
| Control approval flow | `/permissions` — `request-review` pauses for you, `always-proceed` auto-approves |

---

## Quick Tips

> Source: [Using Antigravity CLI — Quick Tips & Keybindings](https://antigravity.google/docs/cli-using)

| Shortcut / Tip | Action |
| :-- | :-- |
| `@` | File path autocomplete (type `@` to trigger path suggestions) |
| `!` | Run terminal commands directly from the prompt |
| `esc esc` | Clear your prompt box (when no streaming is active) |
| `?` | Get help and list all slash commands |
| `alt+enter` / `shift+enter` | Insert newline without submitting |
| `ctrl+r` | Open the Artifact Review panel (leave inline comments to co-steer the agent) |
| `ctrl+g` | Open the current prompt or artifact in your `$EDITOR` |
| `ctrl+l` | Clear TUI screen |
| `ctrl+d` | Exit the CLI session |
| `ctrl+z` | Suspend CLI to terminal background |
| `ctrl+j` (in `/agents`) | Teleport to next pending subagent approval |
| `ctrl+k` | Fast-approve pending subagent permission from main conversation |

---

## Custom Skills & Rules

### Configuration Locations

| Scope | Rules / Workspace Context | Custom Skills (SKILL.md) |
| :-- | :-- | :-- |
| **Workspace** | `.agents/AGENTS.md` | `.agents/skills/<skill_name>/SKILL.md` |
| **Global** | `~/.gemini/config/AGENTS.md` | `~/.gemini/config/skills/<skill_name>/SKILL.md` |

### Custom Skill Structure (`SKILL.md`)

```markdown
---
name: code-reviewer
description: Triggered when analyzing code syntax, styling, or structural debt.
---

# Code Reviewer Skill

Provide feedback focusing on:
1. Performance and algorithmic complexity
2. Strict compliance with standard naming conventions
```

### Key Skill Slash Commands (Interactive Mode)

| Command | Purpose |
| :-- | :-- |
| `/skills` | Browse, inspect, and toggle local and global agent skills |
| `/config` | Access setting menus to manage global skills and rules |

---

## Sidecars

> Background processes AGY manages for you — launches, restarts, and runs independently of any conversation. Source: [antigravity.google/docs/sidecars](https://antigravity.google/docs/sidecars)

```bash
# Config locations:
~/.gemini/config/sidecars/<name>/sidecar.json                         # global
~/.gemini/config/plugins/<plugin>/sidecars/<name>/sidecar.json        # plugin-scoped

# Enable (disabled by default) — edit ~/.gemini/config/config.json:
#   { "sidecars": { "<name>": { "enabled": true } } }

# Check logs:
ls ~/.gemini/antigravity/sidecar_data/<name>/logs/

# agentapi (auto-available inside sidecars):
agentapi new-conversation "<prompt>"
agentapi send-message <conversation_id> "<prompt>"
```

Minimal `sidecar.json` — background script:

```json
{ "command": "python3", "args": ["worker.py"], "restart_policy": "on-failure" }
```

Minimal `sidecar.json` — scheduled recurring task:

```json
{
  "builtin": "schedule",
  "args": ["0 9 * * 1-5", "agentapi", "new-conversation", "Summarise open PRs."]
}
```

---

## Workspace & Context

```bash
# Project config directory:
.agents/                    # settings.json (permissions + hooks), mcp_config.json, rules.md, skills/, plugins/

# Global config directory:
~/.gemini/config/           # settings.json (permissions + hooks), mcp_config.json, rules.md, skills/, plugins/

# User settings:
~/.gemini/antigravity/settings.json

# Context file (hierarchical: cwd → parent → home):
AGENTS.md

# agy also reads:
.gemini/                    # Gemini CLI config (compatible)
```

### AGENTS.md Pattern

```markdown
# Project Context

Brief description of what this project is.

## Conventions
- Language: TypeScript, Node 20
- Testing: Jest + Supertest
- DO NOT run database migrations without explicit approval
```

---

## Useful Patterns

```bash
# Review staged changes before commit
git diff --cached | agy -p "Review for bugs, security issues, missing tests."

# Generate docs for a file
cat src/api.ts | agy -p "Generate OpenAPI documentation for all exported functions."

# Analyze logs
tail -n 500 app.log | agy -p "Group these errors by root cause. Output as JSON."

# Multi-dir cross-repo analysis
agy --add-dir ../api --add-dir ../frontend \
    -p "Map data flow from frontend form submission to database write."

# Full headless CI audit (safe)
agy --sandbox --dangerously-skip-permissions \
    -p "Audit for hardcoded secrets and insecure patterns." \
    --print-timeout 5m > audit.md

# Schedule a recurring task (in interactive mode)
# > Schedule a daily code quality report at 9am weekdays.
```

---

## Multi-Agent Patterns

```text
# Spawn parallel subagents (in interactive mode)
Spawn a security auditor and a performance auditor in parallel (branch mode).

# Adversarial review
Spawn an adversarial reviewer subagent — its job is to find reasons to NOT merge this PR.

# Steer mid-task — `/btw` is a workshop convention, NOT a built-in command.
# Just type the steering message inline while the agent is working:
/btw Focus only on the authentication module, skip the frontend.

# Background task
In the background, audit all dependencies for known CVEs. Notify me when done.
```

---

## Print Mode Pipeline Examples

```bash
# Step 1: plan
agy -p "Create a refactoring plan for moving from callbacks to async/await. JSON output." \
  > plan.json

# Step 2: execute
cat plan.json | agy -p "Execute step 1 of this plan."

# Batch: process multiple files
for f in src/*.ts; do
  agy --add-dir "$(dirname $f)" \
      -p "Add JSDoc to all exported functions in $(basename $f)."
done
```

---

## Official Docs

| Topic | Link |
| :-- | :-- |
| CLI Overview | [antigravity.google/docs/cli-overview](https://antigravity.google/docs/cli-overview) |
| Getting Started | [antigravity.google/docs/cli-getting-started](https://antigravity.google/docs/cli-getting-started) |
| Using Antigravity CLI (settings, tips, keybindings) | [antigravity.google/docs/cli-using](https://antigravity.google/docs/cli-using) |
| Features (plugins, sandbox, slash commands, subagents) | [antigravity.google/docs/cli-features](https://antigravity.google/docs/cli-features) |
| Permissions | [antigravity.google/docs/permissions](https://antigravity.google/docs/permissions) |
| Strict Mode | [antigravity.google/docs/strict-mode](https://antigravity.google/docs/strict-mode) |
| Plugins | [antigravity.google/docs/plugins](https://antigravity.google/docs/plugins) |
| MCP | [antigravity.google/docs/mcp](https://antigravity.google/docs/mcp) |
| Skills | [antigravity.google/docs/skills](https://antigravity.google/docs/skills) |
| Rules | [antigravity.google/docs/rules-workflows](https://antigravity.google/docs/rules-workflows) |
| Hooks | [antigravity.google/docs/hooks](https://antigravity.google/docs/hooks) |
| Sidecars | [antigravity.google/docs/sidecars](https://antigravity.google/docs/sidecars) |
| Subagents | [antigravity.google/docs/subagents](https://antigravity.google/docs/subagents) |
| Enterprise | [antigravity.google/docs/enterprise](https://antigravity.google/docs/enterprise) |
