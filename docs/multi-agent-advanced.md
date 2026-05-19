# Module 4: Multi-Agent & Advanced <span class="duration-badge">45 min</span>

> **Where agy goes beyond a chat assistant.** This module covers the features that separate agy-cli from every other AI coding tool: parallel subagents, mid-task steering with `/btw`, background scheduling, and session resumption.

---

## 4.0 — The agy Agent Model <span class="duration-badge">5 min</span>

agy-cli can spawn **subagents** — isolated task runners that operate in parallel, each with their own workspace context. Unlike running multiple terminal tabs with separate agy sessions, subagents are coordinated: they can share a workspace, work on isolated branches, or operate on a cloned copy.

Three workspace modes:

| Mode | What it means | Use when |
|---|---|---|
| `inherit` | Subagent shares the same workspace | Additive tasks — no conflicts expected |
| `branch` | Subagent gets an isolated clone | Parallel changes to the same files |
| `share` | Git worktree — isolated branch, shared repo | True parallel development |

---

## 4.1 — Spawning Subagents <span class="duration-badge">15 min</span>

> **Pattern: Parallel Execution** — dispatch multiple agents to work simultaneously.

### From an Interactive Session

```
> Spawn a subagent to write unit tests for the auth module while I work on the API refactor.
```

agy will spawn a subagent, report its ID, and continue your main session. The subagent works independently.

```
> What's the status of the test-writing subagent?
```

```
> Show me what the test subagent produced.
```

### Parallel Audit Pattern

```
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

```
> Spawn a subagent to act as an adversarial reviewer for the changes in this branch.
> Its only job: find reasons why this code should NOT be merged.
> It should challenge every assumption and look for edge cases the implementer missed.
```

The adversarial reviewer pattern is particularly powerful for security-sensitive changes, infrastructure modifications, or any PR where "looks good to me" isn't sufficient.

---

## 4.2 — /btw: Mid-Task Steering <span class="duration-badge">10 min</span>

> **Pattern: Steer Without Interrupting** — inject context into a running task without stopping it.

`/btw` is one of agy's most distinctive features. When agy is mid-task, you can send it a message without cancelling the current operation.

### How It Works

```
> Refactor the entire authentication module to use JWT instead of sessions. This will touch multiple files. Start with the backend.
```

*agy starts working... while it's running:*

```
/btw Actually, keep backward compatibility with sessions for 30 days — implement a dual-mode auth.
```

agy incorporates your note into the ongoing task without stopping. It's like leaving a sticky note for a developer in the middle of a sprint — they see it and adjust.

### Use Cases for /btw

```
/btw The API rate limit is 100 req/min, factor that into any retry logic you add.
```

```
/btw The team uses conventional commits — make sure any commit messages follow that format.
```

```
/btw Skip the frontend changes for now, just focus on the backend API.
```

!!! info "Contrast with interrupting"
    Without `/btw`, steering a long-running task means cancelling it, adjusting your prompt, and restarting — losing all progress. `/btw` lets you course-correct without that cost.

---

## 4.3 — Background Execution & Scheduling <span class="duration-badge">10 min</span>

> **Pattern: Async Agy** — kick off long-running tasks and get notified when they finish.

### Background Tasks

agy supports asynchronous execution — you can kick off a task and continue working. agy notifies you when it completes.

```
> In the background, do a comprehensive security audit of this entire codebase. Take as long as you need. Notify me when done.
```

agy runs the audit without blocking your terminal. When it finishes, you receive a notification with the results.

### Scheduled Tasks

agy supports cron-style scheduling for recurring analysis:

```
> Schedule a nightly code quality report every day at 2am. It should check for new TODOs, failing tests, and dependency updates. Save the report to reports/nightly-YYYY-MM-DD.md.
```

Cron expressions (up to 5 fields) are supported:

```
# Run at 2am daily
0 2 * * *

# Run every Monday at 9am
0 9 * * 1

# Run every 15 minutes
*/15 * * * *
```

!!! warning "Scheduling is session-persistent"
    Scheduled tasks persist across sessions as long as agy is running. Ask your facilitator about the exact persistence model for your environment.

---

## 4.4 — Session Resumption <span class="duration-badge">5 min</span>

> **Pattern: Long-Running Work** — pick up exactly where you left off.

### Resume the Most Recent Session

```bash
# Short form
agy -c

# Long form
agy --continue
```

### Resume a Specific Session by ID

```bash
# List recent conversations (check agy's log directory)
agy --conversation <conversation-id>
```

agy maintains full conversation history. You can resume a session from days ago and agy will have full context of everything discussed — files reviewed, decisions made, code written.

### Use Case: Multi-Day Feature Work

```bash
# Day 1: Start a feature
agy -i "I'm building a payment integration feature. Let's start with the backend API design."

# Day 2: Continue exactly where you left off
agy -c
```

```
> What was the last thing we decided about the payment API schema?
```

agy will have the full context, including code written, decisions made, and open questions.

---

## 4.5 — Advanced: Combining Patterns <span class="duration-badge">Optional</span>

> **The full power stack:** subagents + /btw + background + scheduling + conversation resumption.

### Enterprise Incident Response

```
> I'm starting an incident response for a production issue. Spawn:
> 1. A log-analyzer subagent (branch mode) — read the last 1000 lines of app.log and identify the root cause
> 2. A config-checker subagent (branch mode) — review all environment configs and recent deploys for anomalies
>
> Report back when both complete. I'll be monitoring in the meantime.
```

While they run:

```
/btw The incident started at 14:32 UTC. Focus analysis on that window.
```

This is multi-agent incident triage — two parallel investigations, steerable mid-flight.

---

## Module 4 Exercises

<div class="exercise-card" markdown>

#### :material-file-document: Exercise 4: Subagents

**File:** `exercises/ex04_subagents.md`
**Duration:** 20 min
**Objective:** Spawn a parallel audit team. Practice the adversarial reviewer pattern.

</div>

<div class="exercise-card" markdown>

#### :material-file-document: Exercise 5: /btw & Scheduling

**File:** `exercises/ex05_btw_scheduling.md`
**Duration:** 20 min
**Objective:** Use /btw to steer a long-running task. Schedule a recurring code quality report.

</div>

<div class="exercise-card" markdown>

#### :material-file-document: Exercise 6: Sandbox Governance

**File:** `exercises/ex06_sandbox_governance.md`
**Duration:** 15 min
**Objective:** Run agy with --sandbox and --dangerously-skip-permissions in a safe audit scenario.

</div>
