# Exercise 5: Subagents — Fixes & Refactor

> **Duration:** 25 min | **The Workshop · Beat 5 — Fixes & Security**

---

## Objective

Close the software story. You've discovered the codebase (Beat 1), planned and built a feature (Beat 2), codified standards (Beat 3), and governed data access (Beat 4). Now put a **team of agents** on the code: run **native subagents** in parallel to review it for security and test gaps, then build a **custom `code-cleaner` subagent** that refactors the messiest module — leaving the project reviewed, secured, and clean.

The billing API ships with deliberate rough edges that make this real:

- `app/auth.py` — a **hard-coded fallback API key** (`DEFAULT_API_KEY = "dev-secret-123"`) and a non-constant-time key comparison.
- `app/billing.py` — a **bare `except:`** in `calc_proration` that silently returns `0`, and **three near-duplicate currency formatters** (`describe_plan_price`, `format_invoice_line`, `summarize_amount`) plus a fourth inline formatter in `app/main.py`.

---

## Setup

Work in the same sandbox, in an interactive session:

```bash
cd ../agy-sample-app
agy
```

---

## Part 1: A Parallel Review Team (8 min)

Dispatch two **native subagents** at once — each in its own branch workspace so they don't collide — and let them work while you keep talking to the main agent:

```text
Spawn two subagents in parallel, each in branch workspace mode, scoped to this project:
1. A security auditor — check app/auth.py and the request handlers for hard-coded secrets, weak credential comparison, and unauthenticated routes.
2. A test-coverage auditor — read app/ and tests/test_main.py and list the untested branches (e.g. duplicate-subscription, yearly discount, proration errors, non-USD formatting).
Report back with a combined findings summary when both finish.
```

Monitor them without blocking. Open the subagents panel:

```text
/agents
```

The panel shows each subagent as `running` / `done` / `killed`. Two keys make this fast from the main conversation:

- **`ctrl+j`** — teleport to the next subagent waiting for your approval.
- **`ctrl+k`** — fast-approve a pending subagent permission without leaving the main chat.

When both finish, ask for the synthesis:

```text
Show me the combined findings. What are the top 3 to fix, most severe first?
```

The security auditor should surface the hard-coded `dev-secret-123` key; the coverage auditor should name concrete untested branches.

---

## Part 2: An Adversarial Reviewer (5 min)

A supportive reviewer confirms your assumptions; an adversarial one breaks them. Spawn a skeptic:

```text
Spawn an adversarial reviewer subagent. Its only job: argue why this billing code is NOT production-ready.
Be harsh — challenge the in-memory store, the silent except, the money math, and the auth. No praise.
```

Read its findings. This is the tone a real pre-merge review should survive.

---

## Part 3: Build a Custom Subagent — `code-cleaner` (10 min)

Native subagents are spun up by prompt. For a **repeatable specialist**, define one as a file so anyone on the team gets the same behavior. Custom subagents live in the workspace at `.agents/agents/<name>.md`.

1. Create `.agents/agents/code-cleaner.md`:

   ```markdown
   ---
   description: >-
     Refactors and cleans up messy code — structure, naming, formatting, readability —
     without changing behavior. Invoke it to tidy a module.
   model: gemini-3.1-pro-preview
   tools:
     allow:
       - read_file
       - edit
       - run_command
   ---

   # Code Cleaner Persona

   You are a software design expert who values clean code, descriptive naming, and
   separation of concerns.

   ## Instructions

   - Remove redundant comments.
   - Refactor long functions into smaller, descriptive helper functions.
   - Collapse duplicated logic (e.g. repeated formatting) into a single shared helper.
   - Add type hints and concise docstrings where they aid readability.
   - Keep the public API backwards-compatible — callers must not break.
   - After refactoring, run `python3 -m pytest -q` and confirm it stays green.
   ```

   > [!NOTE]
   > **The frontmatter fields:** `model` plus a `tools.allow` list (the tools the subagent may use); the agent's **name comes from the filename** (`code-cleaner`); the body is its system prompt. The bundled CLI does not ship a subagent-format reference, so **confirm the agent loads** in the next step — if it doesn't appear in `/agents`, re-check the frontmatter against the live [subagents docs](https://antigravity.google/docs/subagents).

2. Start a **fresh** `agy` session (definitions are read at launch), then confirm it registered:

   ```text
   /agents
   ```

   `code-cleaner` should appear in the list of available agents.

3. Put it to work on the messiest module:

   ```text
   Use the code-cleaner subagent to refactor app/billing.py: collapse the duplicated currency formatters into one shared helper, replace the bare `except:` in calc_proration with specific handling, and add type hints — without changing the public function signatures.
   ```

4. Review and verify — this is Beat 2's habit applied to a refactor:

   ```text
   /diff
   ```

   ```text
   !python3 -m pytest -q
   ```

   The diff should show one shared currency helper replacing the duplicates and a real exception type instead of the bare `except:`, with the existing tests still green.

---

## Why this matters

- **Parallelism with oversight.** Subagents fan out across the codebase concurrently; `/agents` + `ctrl+j`/`ctrl+k` let you approve their actions without losing your place.
- **Adversarial review** catches what a supportive pass rubber-stamps.
- **Custom subagents are reusable governance.** A checked-in `.agents/agents/code-cleaner.md` gives every teammate the same scoped, single-purpose specialist — with exactly the tools you granted, and nothing more.

That completes the story: the billing API was explored, extended, standardized, governed, and finally reviewed, secured, and cleaned — all through Antigravity CLI.

---

## Completion Criteria

- [ ] Spawned 2+ native subagents in parallel and got a combined findings summary
- [ ] Used `/agents` and the `ctrl+j` / `ctrl+k` approval keys
- [ ] Ran an adversarial reviewer and read its critical findings
- [ ] Created `.agents/agents/code-cleaner.md` and confirmed it appears in `/agents`
- [ ] Used `code-cleaner` to refactor `app/billing.py`; verified with `/diff` and a green `pytest`
