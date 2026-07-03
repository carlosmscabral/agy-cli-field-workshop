# Module 2 (continued) — Advanced CLI: Subagents, Steering & Automation <span class="duration-badge">45 min</span>

> **The second half of Module 2 — where the CLI goes beyond a chat assistant.** Building on the modernization primitives from the [first half](legacy-modernization.md), this half covers the advanced CLI features that separate agy-cli from every other AI coding tool: parallel subagents, mid-task steering with `/btw`, background scheduling, and session resumption.

---

## 2.8 — The agy Agent Model <span class="duration-badge">5 min</span>

agy-cli can spawn **subagents** — isolated task runners that operate in parallel, each with their own workspace context. Unlike running multiple terminal tabs with separate agy sessions, subagents are coordinated: they can share a workspace, work on isolated branches, or operate on a cloned copy.

Three workspace modes:

| Mode | What it means | Use when |
| :-- | :-- | :-- |
| `inherit` | Subagent shares the same workspace | Additive tasks — no conflicts expected |
| `branch` | Subagent gets an isolated clone | Parallel changes to the same files |
| `share` | Git worktree — isolated branch, shared repo | True parallel development |

### Switching Models

Use `/model` to switch the active model mid-session — useful when you want heavier reasoning for a specific task:

```bash
/model
```

This opens a model picker showing available options (Gemini 3.5 Flash, Gemini 3.1 Pro, Claude Sonnet 4.6, etc.).

> 📖 Full model list: [Models docs](https://www.antigravity.google/docs/models)

---

## 2.9 — Spawning Subagents <span class="duration-badge">15 min</span>

> **Pattern: Parallel Execution** — dispatch multiple agents to work simultaneously.
> 📖 Full reference: [Subagents docs](https://www.antigravity.google/docs/subagents)

### From an Interactive Session

```text
> Spawn a subagent to write unit tests for the auth module while I work on the API refactor.
```

agy will spawn a subagent, report its ID, and continue your main session. The subagent works independently.

```text
> What's the status of the test-writing subagent?
```

```text
> Show me what the test subagent produced.
```

### Managing Subagents with /agents

Use the `/agents` panel to see all active subagents, their status, and output:

```bash
/agents
```

Key shortcuts from the main conversation:

| Shortcut | Action |
| :-- | :-- |
| `Ctrl+J` | Teleport to a subagent pending approval — jump directly to review its request |
| `Ctrl+K` | Fast-approve from the main conversation — approve a subagent's pending action without switching |

Subagent lifecycle: **Running → Idle → Killed**

### Limits and Built-in Types

- **Max depth:** 10 (subagents can spawn their own subagents, up to 10 levels)
- **Built-in types:** `research` (web research), `browser` (browser automation), `self` (general purpose)

### Parallel Audit Pattern

```text
> Spawn three subagents in parallel:
> 1. Security audit — scan for hardcoded credentials, injection risks, and insecure dependencies
> 2. Performance audit — find N+1 queries, unindexed lookups, and memory leaks
> 3. Coverage audit — identify untested functions and missing integration tests
>
> Use branch workspace mode for each. Report back when all three complete.
```

Watch three independent analyses run simultaneously. When they finish, agy synthesizes the results.

!!! tip "The Wow Moment"
    Three specialized agents running in parallel on your codebase, each with full context, each producing independent findings. This is the pattern that makes agy qualitatively different from a chat-based assistant.

### Adversarial Review Pattern

```text
> Spawn a subagent to act as an adversarial reviewer for the changes in this branch.
> Its only job: find reasons why this code should NOT be merged.
> It should challenge every assumption and look for edge cases the implementer missed.
```

The adversarial reviewer pattern is particularly powerful for security-sensitive changes, infrastructure modifications, or any PR where "looks good to me" isn't sufficient.

### Ready-Made Sample Subagents

This repo ships four ready-to-use subagent definitions under [`samples/agents/`](https://github.com/carlosmscabral/agy-cli-field-workshop/tree/main/samples/agents) — copy one into `.agents/agents/<name>.md` to use it. All are read-only (no `write_file`/`run_command`), so they analyze without touching your code:

| Sample agent | Purpose |
| :-- | :-- |
| `pr-reviewer` | Review code changes for quality, bugs, and style before a merge |
| `security-scanner` | Scan code for security vulnerabilities (PR / pre-deployment) |
| `doc-writer` | Generate API docs, README sections, and inline comments from source |
| `migration-validator` | Verify a Gemini CLI project is fully migrated to Antigravity CLI |

---

## 2.10 — /btw: Mid-Task Steering <span class="duration-badge">10 min</span>

> **Pattern: Steer Without Interrupting** — inject context into a running task without stopping it.

!!! note "`/btw` is a workshop convention, not a built-in command"
    In this workshop, `/btw` is shorthand for a **mid-task steering message** — extra context you type ("by the way, also...") while the agent is still working. It is not a built-in slash command. What matters is the underlying capability: agy can absorb new instructions mid-task without you having to cancel and restart.

Mid-task steering is one of agy's most distinctive workflows. When agy is mid-task, you can send it a message without cancelling the current operation.

### How It Works

```text
> Refactor the entire authentication module to use JWT instead of sessions. This will touch multiple files. Start with the backend.
```

*agy starts working... while it's running:*

```bash
/btw Actually, keep backward compatibility with sessions for 30 days — implement a dual-mode auth.
```

agy incorporates your note into the ongoing task without stopping. It's like leaving a sticky note for a developer in the middle of a sprint — they see it and adjust.

### Use Cases for /btw

```bash
/btw The API rate limit is 100 req/min, factor that into any retry logic you add.
```

```bash
/btw The team uses conventional commits — make sure any commit messages follow that format.
```

```bash
/btw Skip the frontend changes for now, just focus on the backend API.
```

!!! info "Contrast with interrupting"
    Without `/btw`, steering a long-running task means cancelling it, adjusting your prompt, and restarting — losing all progress. `/btw` lets you course-correct without that cost.

---

## 2.11 — Background Execution & Scheduling <span class="duration-badge">10 min</span>

> **Pattern: Async Agy** — kick off long-running tasks and get notified when they finish.

### Background Tasks

agy supports asynchronous execution — you can kick off a task and continue working. agy notifies you when it completes.

```text
> In the background, do a comprehensive security audit of this entire codebase. Take as long as you need. Notify me when done.
```

agy runs the audit without blocking your terminal. When it finishes, you receive a notification with the results.

### Scheduled Tasks

agy supports cron-style scheduling for recurring analysis:

```text
> Schedule a nightly code quality report every day at 2am. It should check for new TODOs, failing tests, and dependency updates. Save the report to reports/nightly-YYYY-MM-DD.md.
```

Cron expressions (up to 5 fields) are supported:

```bash
# Run at 2am daily
0 2 * * *

# Run every Monday at 9am
0 9 * * 1

# Run every 15 minutes
*/15 * * * *
```

!!! warning "Scheduling is session-persistent"
    Scheduled tasks persist across sessions as long as agy is running. Check `/tasks` to view and manage scheduled tasks.

---

## 2.12 — Session Resumption <span class="duration-badge">5 min</span>

> **Pattern: Long-Running Work** — pick up exactly where you left off.
> 📖 Full reference: [Using Antigravity CLI](https://www.antigravity.google/docs/cli-using)

### Resume the Most Recent Session

From inside agy, use the `/resume` slash command:

```bash
/resume
```

This opens a session picker showing your recent conversations. Select one to resume.

### Browse and Switch Sessions

```bash
/switch
```

Same as `/resume` — both commands open the session picker.

### Auto-Resume on Exit

When you exit an agy session, agy prints the exact command to resume it:

```bash
Session saved. Resume with: agy --conversation <conversation-id>
```

You can use this command directly from the terminal to jump back in.

### Use Case: Multi-Day Feature Work

```bash
# Day 1: Start a feature
agy -i "I'm building a payment integration feature. Let's start with the backend API design."

# Day 2: Resume from terminal
agy --conversation <conversation-id>

# Or from inside agy:
# /resume
```

```text
> What was the last thing we decided about the payment API schema?
```

agy will have the full context, including code written, decisions made, and open questions.

---

## 2.13 — Advanced: Combining Patterns <span class="duration-badge">Optional</span>

> **The full power stack:** subagents + /btw + background + scheduling + conversation resumption.

### Enterprise Incident Response

```text
> I'm starting an incident response for a production issue. Spawn:
> 1. A log-analyzer subagent (branch mode) — read the last 1000 lines of app.log and identify the root cause
> 2. A config-checker subagent (branch mode) — review all environment configs and recent deploys for anomalies
>
> Report back when both complete. I'll be monitoring in the meantime.
```

While they run:

```bash
/btw The incident started at 14:32 UTC. Focus analysis on that window.
```

This is multi-agent incident triage — two parallel investigations, steerable mid-flight.

---

## Module 2 Exercises — Advanced CLI

> **How the module runs:** ① the facilitator presents the concepts and demos above → ② you work the exercises below **on your own** → ③ the facilitator wraps up by walking through each exercise's solution (live or pre-done) and answering questions. Do the **Core** exercises in order; **Optional** ones are stretch goals if you finish early.

### Core

<div class="exercise-card" markdown>

### :material-account-group: Subagents &nbsp;·&nbsp; `Core`

**File:** [`ex07_subagents.md`](exercises/ex07_subagents.md)  
**Duration:** 20 min  
**Objective:** Spawn parallel subagents and an adversarial reviewer; manage them via /agents.

</div>

<div class="exercise-card" markdown>

### :material-steering: Mid-Task Steering with /btw &nbsp;·&nbsp; `Core`

**File:** [`ex08_btw_scheduling.md`](exercises/ex08_btw_scheduling.md)  
**Duration:** 20 min  
**Objective:** Steer a running task mid-flight using the /btw convention.

</div>

<div class="exercise-card" markdown>

### :material-console-line: Headless --print Pipelines &nbsp;·&nbsp; `Core`

**File:** [`ex12_print_mode_pipeline.md`](exercises/ex12_print_mode_pipeline.md)  
**Duration:** 20 min  
**Objective:** Chain non-interactive `agy -p` calls into an automation pipeline.

</div>

---

## Next Module

That completes Module 2. Next, you'll shift from *using* the CLI to *building agents* with it.

→ **[Module 3 — ADK Agents with agents-cli](agents-cli.md)** — scaffold, evaluate, and deploy a production-grade ADK agent from inside your agy session.

→ **[Reference: DevOps Patterns](devops-automation.md)** — `--print` pipelines, CI/CD, sandbox deep dive

→ **[Reference: Plugin Ecosystem](plugin-ecosystem.md)** — full plugin lifecycle reference
