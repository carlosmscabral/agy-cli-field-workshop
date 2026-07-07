# The Workshop — An End-to-End Software Story <span class="duration-badge">~105 min</span>

> **One project, one story.** Instead of scattered labs, this workshop follows a single real codebase — the **`agy-sample-app`** FastAPI subscription-billing API — through the arc of everyday software work: **discovery → planning → coding → governed access → fixes & security.** Each beat exercises a core Antigravity CLI (`agy`) capability, and each builds on the last.

---

## The project

`agy-sample-app` is a small but realistic FastAPI service: plans, users, subscriptions, and invoices over an in-memory store, with pricing/proration logic and API-key auth. It ships with deliberate rough edges — no health endpoint, a hard-coded fallback API key, a silent `except:`, and duplicated currency-formatting code — that give the story something real to fix.

You set it up once in the [Pre-Work](setup.md); every beat runs against it.

---

## The five beats

| Beat | Exercise | What you do | AGY concepts |
| :-- | :-- | :-- | :-- |
| **1. Discovery** | [First Session](exercises/ex01_first_session.md) | Explore the codebase, focus files with `@`, set Tool Permissions, capture context in `AGENTS.md`. | interactive session, `@`-focus, Tool Permissions, `AGENTS.md` |
| **2. Planning & Build** | [Artifacts](exercises/ex02_artifacts.md) | Plan, review, and build the missing `GET /health` endpoint through the Artifacts workflow. | `/planning`, Artifact Review panel, plan→review→verify |
| **3. Coding Standards** | [Skills & Rules](exercises/ex03_skills_rules.md) | Codify your team's conventions as a Custom Skill + an always-on Rule, then watch them shape new code. | `.agents/skills/`, `.agents/rules/` (`trigger` frontmatter), `/diff` |
| **4. Governed Access** | [Governed Access with MCP](exercises/ex04_mcp_governed_access.md) | Give the agent a *governed* channel to the billing data — an MCP server under `strict` permissions. | `.agents/mcp_config.json`, `/mcp`, `strict` mode |
| **5. Fixes & Security** | [Subagents](exercises/ex05_subagents.md) | Run parallel review subagents, then build a custom `code-cleaner` subagent to refactor the messy module. | native subagents, `/agents`, custom `.agents/agents/` |

---

## Core concepts you'll touch

A quick primer the facilitator demos before you work the beats:

- **Stay in the session.** Type a leading `!` at the `agy` prompt to run a shell command (`!git status`, `!python3 -m pytest`) without leaving. The `!` is a keystroke you *type* — not something to paste.
- **Tool Permissions.** `agy` has four modes — `request-review` (default), `always-proceed`, `proceed-in-sandbox`, `strict` — set from `/config` → **Tool Permissions**. Approvals you grant persist as an allow-list in `~/.gemini/antigravity-cli/settings.json` (global-only, by design — a workspace `.agents/settings.json` is deliberately ignored).
- **Review, don't scroll.** `/diff` opens agy's built-in diff viewer; **Artifacts** (Implementation Plan → Task List → Walkthrough) let you review structured milestones and co-steer with inline comments instead of watching raw tool calls.
- **Context that persists.** `AGENTS.md` at the repo root is loaded every interactive session (verify it in a *fresh interactive* session — **not** `agy --print`, which skips workspace context).
- **Workspace customization.** Skills (`.agents/skills/`), Rules (`.agents/rules/*.md` with a `trigger`), MCP servers (`.agents/mcp_config.json`), and subagents (`.agents/agents/`) all live in the project's `.agents/` folder and travel with the repo.

See the [Cheatsheet](cheatsheet.md) for the full command/flag reference and the [Workspace Customization reference](plugin-ecosystem.md) for the file formats.

---

## How the workshop runs

> ① The facilitator presents the concepts and demos each beat → ② you work the exercise on your own → ③ the facilitator wraps up by walking the solution and answering questions. Do the beats **in order** — each one builds on the state the previous one left in `agy-sample-app`.

<div class="exercise-card" markdown>

### :material-compass: Beat 1 — First Session (Discovery)

**File:** [`ex01_first_session.md`](exercises/ex01_first_session.md)
**Objective:** Launch `agy` in the sandbox, explore the code with `@`, learn Tool Permissions, and author a project-scoped `AGENTS.md`.

</div>

<div class="exercise-card" markdown>

### :material-lightbulb-on: Beat 2 — Artifacts (Plan, Review & Build)

**File:** [`ex02_artifacts.md`](exercises/ex02_artifacts.md)
**Objective:** Use the Artifacts workflow (`/planning` → review → co-steer → verify) to build the `GET /health` endpoint.

</div>

<div class="exercise-card" markdown>

### :material-puzzle: Beat 3 — Skills & Rules (Coding Standards)

**File:** [`ex03_skills_rules.md`](exercises/ex03_skills_rules.md)
**Objective:** Write a Custom Skill and an always-on Rule, then confirm via `/diff` that new code follows them.

</div>

<div class="exercise-card" markdown>

### :material-transit-connection-variant: Beat 4 — Governed Access with MCP

**File:** [`ex04_mcp_governed_access.md`](exercises/ex04_mcp_governed_access.md)
**Objective:** Connect `agy` to a billing database via MCP, deny shell with `strict` mode, and answer questions *only* through the governed tool.

</div>

<div class="exercise-card" markdown>

### :material-account-group: Beat 5 — Subagents (Fixes & Refactor)

**File:** [`ex05_subagents.md`](exercises/ex05_subagents.md)
**Objective:** Run parallel review subagents, then create a custom `code-cleaner` subagent to refactor `app/billing.py` and fix the security findings.

</div>
