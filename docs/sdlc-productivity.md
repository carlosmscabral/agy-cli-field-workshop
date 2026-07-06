# Module 1 — Antigravity CLI Fundamentals <span class="duration-badge">90 min</span>

> **Your first real Antigravity CLI session.** This module covers the core daily-driver workflows — understanding code, refactoring, generating tests, and reviewing changes — plus how to extend the CLI with your own Custom Skills and Rules.

---

## 1.0 — First Interactive Session <span class="duration-badge">5 min</span>

Launch Antigravity CLI in your target sandbox directory (`agy-sample-app`). First activate the sample app's own `.venv` (set up in [Exercise 1](exercises/ex01_first_session.md)) — this is the environment that runs the app and its tests throughout Modules 1–2:

```bash
cd ../agy-sample-app
source .venv/bin/activate
agy
```

You'll land in the interactive prompt. Try:

```text
What files are in this project and what does each one do?
```

Observe how `agy` reads your workspace — it indexes the git repo, reads file contents, and responds with context. This is **automatic**: no configuration or complex prompt engineering required.

---

## 1.1 — Continuous Sessions & Shell Escapes <span class="duration-badge">10 min</span>

> 💡 **Core Pattern: Continuous Context** — Stay inside the `agy` session instead of repeatedly entering and exiting. This preserves the agent's short-term memory and prevents context-reloading latency.

### The Shell Escape Prefix (`!`)

If you need to run a shell command, check Git status, or run a test suite, you **do not** need to exit `agy`. **Type** a `!` at the start of your input at the agy prompt to run the rest of the line in your shell:

```text
!git status
!python3 -m pytest
```

> [!NOTE]
> The leading `!` is a keystroke you **type** at the agy prompt (it switches that line to shell mode) — it's not a terminal command to copy-paste elsewhere. The prompts and slash commands shown in these blocks, by contrast, *can* be pasted straight into agy.

### Exercise: Map an Unfamiliar Codebase

Without exiting your active session, ask `agy` to guide you through the sandbox:

```text
Give me a high-level architecture overview of this project. What are the main components and how do they connect?
```

Then steer the session interactively with follow-ups:

```text
Which file handles the entry point?
What external dependencies does this project have?
Are there any obvious code smells or tech debt?
```

---

## 1.2 — Refactoring <span class="duration-badge">10 min</span>

> **Pattern: Propose, Review, Apply** — Always review proposed changes before applying them.

### Exercise: Targeted Refactor

Still inside the same `agy` session, request a target refactoring:

```text
I want to refactor the error handling in the main module. First, show me all the places where errors are currently caught or returned — don't change anything yet.
```

Review the findings. Then, steer the agent to propose a change:

```text
Now propose a refactored version using a consistent error handling pattern. Show me the diff before applying.
```

Only approve the write tool when you are satisfied with the proposed code.

### Permissions Model

`agy` has a **3-level permissions model** that controls how it handles tool approvals:

| Level | Behavior |
| :-- | :-- |
| `request-review` | **Default.** `agy` asks for approval before writing files or running commands |
| `always-proceed` | Auto-approve all tool calls — useful for trusted scripts and CI |
| `strict` | Deny all tool use unless explicitly allowed — maximum control |

Set the mode from `/config` → **Tool Permissions** (the settings overlay). You can also configure fine-grained settings in your `settings.json`:

```json
{
  "permissions": {
    "mode": "request-review",
    "allow": ["command(git)", "read_file"],
    "deny": ["command(rm -rf)"]
  }
}
```

---

## 1.3 — Test Generation <span class="duration-badge">10 min</span>

> **Pattern: Test What Exists** — Generate tests for real codebase paths, not hypotheticals.

### Exercise: Generate Unit Tests

Use `agy` to write unit tests for the sandbox code. Ask:

```text
Look at the main module. Generate a comprehensive unit test suite for it. Include happy path, edge cases, and error conditions. Use the testing framework already in this project.
```

Once the files are written, use the TUI shell escape to execute them live without exiting (the sample app uses **pytest**):

```text
!python3 -m pytest
```

If any tests fail, feed the output back to the agent:

```text
The test suite returned errors. Analyze the failures and correct the code to pass.
```

---

## 1.4 — Code Review & Diff Navigation <span class="duration-badge">10 min</span>

> **Pattern: Pre-Commit Review** — Use `agy` as a senior reviewer before every git push.

### Exercise: Review and Diff

`agy` has a **built-in diff view** — type the `/diff` slash command to review the changes from your session inside the TUI:

```text
/diff
```

Prefer raw `git`? Use the shell escape (`!`) to run `git diff` without leaving `agy`:

```text
!git diff
```

The difference: **`/diff`** opens agy's native diff viewer, integrated with its change-review UI; **`!git diff`** simply runs `git` and prints the plain unified diff into the session. You can also ask `agy` to walk you through the changes in natural language:

```text
Show me the diff of my changes and summarize what I modified.
```

Once you are done reviewing, run a comprehensive code review query:

```text
Review my unsaved changes for correctness, security gaps, and styling consistency. Be direct and list any potential bugs.
```

To stage changes from inside the session, run:

```text
!git add -p
```

---

## 1.4a — Artifacts: Verifiable, Reviewable Agent Output <span class="duration-badge">5 min</span>

> **Pattern: Review Milestones, Not Tool Calls** — Steer the agent by reviewing structured deliverables instead of scrolling raw output.

As `agy` works, it emits **artifacts** — structured, verifiable deliverables you review at a high level, rather than watching every individual tool call scroll past. This is the capability that most distinguishes `agy` from chat-style coding tools: the agent shows its work as reviewable milestones you can actually steer.

Three core artifact types cover the everyday loop:

| Artifact | What it is | When it appears |
| :-- | :-- | :-- |
| **Implementation Plan** | Markdown plan: the approach, which files change, and how the change fits the codebase | *Before* code is written |
| **Task List** | A `task.md` the agent ticks off step by step | During implementation |
| **Walkthrough** | A post-completion summary of what changed and how to verify it | After completion |

Artifacts can embed code diffs and Mermaid diagrams. Enter planning mode with `/planning` to make `agy` produce an Implementation Plan (and Task List) *before* implementing — the plan-then-implement loop. View artifacts for the current session with `/artifact`.

The review workflow is where co-steering happens. Press `ctrl+r` to open the **Artifact Review panel**, or `ctrl+g` to open the current artifact in your `$EDITOR`. You can leave **inline comments** on an artifact — like commenting on a shared doc — and the agent incorporates your feedback *without stopping its flow*. Whether the agent pauses for your approval or auto-proceeds is governed by your Tool Permissions mode (set via `/config` → Tool Permissions): `request-review` waits for you, `always-proceed` auto-approves and keeps going.

> **Try it:** [Exercise 15 — Artifacts: Plan, Review, and Verify](exercises/ex15_artifacts.md) implements the `GET /health` endpoint you scoped in Exercise 1, entirely through the Artifacts workflow.

---

## 1.5 — Project Context with AGENTS.md <span class="duration-badge">10 min</span>

> **Pattern: Persistent Context** — Tell `agy` once, and it remembers it across every future session.

`agy` reads context files at session start. By default, it does **not** auto-create directories like `.agents/` to prevent project clutter. We initialize the workspace directory manually:

```bash
# Run this in your terminal (outside agy) to set up local workspace customization
mkdir -p .agents
```

Next, create an `AGENTS.md` file at your project root to codify your conventions:

```bash
cat > AGENTS.md << 'EOF'
# Project Context

This is a Python REST API built with FastAPI.

## Key Conventions
- Style: PEP 8 compliant, type hints required on all function signatures
- Testing: Pytest with 80% coverage minimum; run `python3 -m pytest` to validate
- DO NOT use generic `except Exception` blocks; always catch specific errors
- All database operations must utilize transaction handlers
EOF
```

Start a new session and verify `agy` loads your context:

```bash
agy --print "What do you know about this project's conventions?" --print-timeout 30s
```

`agy` will incorporate your `AGENTS.md` into every subsequent session automatically.

---

## 1.6 — Interactive TUI Navigation <span class="duration-badge">5 min</span>

### Key Slash Commands

| Command | What it does |
| :-- | :-- |
| `/rewind` (or `/undo`) | Roll back conversation history to a previous checkpoint |
| `/resume` (or `/switch`) | Open conversation picker to resume or switch sessions |
| `/rename <name>` | Rename the active conversation thread |
| `/config` (or `/settings`) | Open full-screen settings overlay |
| `/config` → Tool Permissions | Set agent autonomy mode (`request-review`, `always-proceed`, `proceed-in-sandbox`, `strict`) |
| `/model` | Select reasoning model (persists across sessions) |
| `/tasks` | Monitor, view logs for, or terminate background tasks |
| `/skills` | Browse local and global agent skills |
| `/mcp` | Configure and manage MCP servers |
| `/open <path>` | Open a file in your preferred external editor |
| `/usage` | Open the inline interactive help manual |

### Quick Tips

| Shortcut | What it does |
| :-- | :-- |
| `@` | File path autocomplete — type `@` to trigger path suggestions |
| `!` | Run terminal commands directly without leaving `agy` |
| `esc esc` | Clear the current prompt input (when no streaming is active) |
| `ctrl+l` | Clear TUI screen |
| `ctrl+d` | Exit the CLI |

---

## 1.7 — Extend with Custom Skills <span class="duration-badge">15 min</span>

> **Pattern: Core Customization** — Extend `agy` by creating reusable **Skills** and **Rules** for your team's custom patterns, internal libraries, and code quality guardrails.

A **Skill** is a portable directory containing a `SKILL.md` instruction file with YAML frontmatter. `agy` auto-discovers and loads skills from:

* **Workspace-level**: `.agents/skills/<skill_name>/`
* **Global-level**: `~/.gemini/config/skills/<skill_name>/`

### Skill Structure

```text
.agents/skills/my-rest-skill/
├── SKILL.md                 # ← required instructions & metadata
├── examples/                # ← optional reference implementations
└── scripts/                 # ← optional utility scripts
```

### The SKILL.md Format

The `SKILL.md` must have a YAML frontmatter block with a `name` and `description` (which `agy` uses for semantic trigger matching):

```markdown
---
name: fastapi-security-standards
description: Enforces FastAPI OAuth2 and CORS security configurations. Triggers on security, CORS, or user authentication queries.
---

# FastAPI Security Standards

Always apply the following patterns when writing or reviewing FastAPI endpoints:

1. Always set `allow_credentials=True` on CORS middleware but restrict `allow_origins` to trusted domains.
2. Utilize `SecurityScopes` to check granular permissions on endpoints.
3. Password hashing must use Argon2id via `passlib`.
```

### Registering and Testing Skills

When `agy` starts, it automatically registers your skills. Run `/skills` inside your interactive TUI session to browse active skills and verify your custom skill is loaded.

You can also write custom directives as rule files under `.agents/rules/*.md` — each with `trigger` frontmatter (use `trigger: always_on` to unconditionally inject the rule into the agent's system prompt). A bare `.agents/rules.md` is not loaded.

---

## 1.8 — Governed Access with MCP <span class="duration-badge">10 min</span>

Skills and rules customize how `agy` *thinks*. **MCP (Model Context Protocol)** servers change what it can *reach* — but the value isn't raw capability: `agy` already reads files, runs shell, and hits URLs, so wrapping those in MCP adds nothing. MCP's real payoff is **governance** — the server owns the connection and credentials and exposes only *scoped, structured* operations, so you can grant the agent a specific capability **without handing it raw shell or secrets**, even when shell is switched off.

MCP servers are declared in a JSON config file, not via an `agy` subcommand. This build reads them from the **global** `~/.gemini/config/mcp_config.json` (all projects) or from a **plugin**'s `plugins/<name>/mcp_config.json`:

```json
{
  "mcpServers": {
    "billing-db": {
      "command": "uvx",
      "args": ["mcp-server-sqlite", "--db-path", "/absolute/path/to/billing.db"]
    }
  }
}
```

A local server runs as a subprocess (`command` + `args`); a remote server uses `serverUrl` instead — and there the server, not the agent, holds the credentials. (The transport is inferred from which field you set; there is no separate `type` field.) Run `/mcp` inside the TUI to confirm a server is connected and see the scoped tools it exposes.

> **Try it:** [Exercise: Governed Access with MCP](exercises/ex16_mcp_basics.md) connects agy to a billing database, denies shell with `strict` mode (`/config` → Tool Permissions), and has the agent answer business questions *only* through the MCP server's query tools.

---

## Module 1 Exercises

> **How the module runs:** ① the facilitator presents the concepts and demos above → ② you work the exercises below **on your own** → ③ the facilitator wraps up by walking through each exercise's solution (live or pre-done) and answering questions. Do the **Core** exercises in order; **Optional** ones are stretch goals if you finish early.

### Core

<div class="exercise-card" markdown>

### :material-file-document: First Session &nbsp;·&nbsp; `Core`

**File:** [`ex01_first_session.md`](exercises/ex01_first_session.md)  
**Duration:** 15 min  
**Objective:** Launch `agy` inside the sandbox application, explore the code, and author your first project-scoped `AGENTS.md`.

</div>

<div class="exercise-card" markdown>

### :material-lightbulb-on: Artifacts — Plan, Review & Verify &nbsp;·&nbsp; `Core`

**File:** [`ex15_artifacts.md`](exercises/ex15_artifacts.md)  
**Duration:** 20 min  
**Objective:** Use the Artifacts workflow (`/planning` → review the plan → co-steer with `ctrl+r` → Task List → Walkthrough) to implement the `GET /health` endpoint you scoped in the First Session exercise.

</div>

<div class="exercise-card" markdown>

### :material-puzzle: Custom Skills & Workspace Customization &nbsp;·&nbsp; `Core`

**File:** [`ex02_custom_skills.md`](exercises/ex02_custom_skills.md)  
**Duration:** 20 min  
**Objective:** Design and write a local Custom Skill, register a project-scoped rule, and run validation checks.

</div>

<div class="exercise-card" markdown>

### :material-transit-connection-variant: Governed Access with MCP &nbsp;·&nbsp; `Core`

**File:** [`ex16_mcp_basics.md`](exercises/ex16_mcp_basics.md)  
**Duration:** 20 min  
**Objective:** Connect agy to a billing database via MCP, deny shell with `strict` mode (`/config` → Tool Permissions), and answer business questions *only* through the server's scoped query tools.

</div>

### Optional

<div class="exercise-card" markdown>

### :material-shield-lock: Sandbox & Governance &nbsp;·&nbsp; `Optional`

**File:** [`ex09_sandbox_governance.md`](exercises/ex09_sandbox_governance.md)  
**Duration:** 15 min  
**Objective:** Run `agy --sandbox` for safe, read-only automated reviews and model a two-phase governance workflow. A stretch lab — do it if you finish the core exercises early.

</div>

---

## Next Module

→ **[Module 2: Legacy Modernization & Advanced CLI](legacy-modernization.md)** — strict mode, agent self-onboarding, subagents, and `/rewind` as your safety net.
