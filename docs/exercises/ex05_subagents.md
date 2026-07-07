# Exercise 5: Subagents — Fixes & Refactor

> **Duration:** 25 min | **The Workshop · Beat 5 — Fixes & Security**

---

## Objective

Close the software story. You've discovered the codebase (Beat 1), planned and built a feature (Beat 2), codified standards (Beat 3), and governed data access (Beat 4). Now put a **team of subagents** on the code: run them in parallel to review it for hardening and test gaps, run an adversarial reviewer, then spawn a subagent to apply the fixes — leaving the project reviewed, secured, and clean.

The billing API ships with deliberate rough edges that make this real:

- `app/auth.py` — a hard-coded fallback API key (`DEFAULT_API_KEY = "dev-secret-123"`) and a non-constant-time key comparison.
- `app/billing.py` — a bare `except:` in `calc_proration` that silently returns `0`, and **three near-duplicate currency formatters** (`describe_plan_price`, `format_invoice_line`, `summarize_amount`) plus a fourth inline formatter in `app/main.py`.

> [!IMPORTANT]
> **Frame reviews constructively.** Ask a subagent to *review and suggest improvements* — **not** to "scan for vulnerabilities / hard-coded secrets." The adversarial-scan phrasing reliably makes the model **refuse** (`"Sorry, I cannot fulfill your request to analyze the code for potential vulnerabilities…"`). A "senior engineer suggesting hardening improvements" prompt surfaces the *same* hard-coded key and weak comparison — without the refusal. (You saw this same rule in earlier beats.)

---

## Setup

Work in the same sandbox, in an interactive session:

```bash
cd ../agy-sample-app
agy
```

---

## Part 1: A Parallel Review Team (8 min)

Dispatch two subagents at once — each in its own branch workspace so they don't collide — and let them work while you keep talking to the main agent:

```text
Spawn two subagents in parallel, each in branch workspace mode, scoped to this project:
1. A senior engineer doing a hardening review of app/auth.py and the request handlers — suggest concrete improvements with file:line: where credentials/config should move to environment variables instead of hard-coded defaults, where credential checks could be strengthened, and where routes should require authentication.
2. A test-coverage reviewer — read app/ and tests/test_main.py and list the untested branches (e.g. duplicate-subscription, yearly discount, proration errors, non-USD formatting).
Report back with a combined summary when both finish.
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

The hardening review should surface the hard-coded `dev-secret-123` key and the weak comparison; the coverage reviewer should name concrete untested branches.

---

## Part 2: An Adversarial Reviewer (5 min)

A supportive reviewer confirms your assumptions; an adversarial one breaks them. Spawn a skeptic:

```text
Spawn an adversarial reviewer subagent. Its only job: argue why this billing code is NOT production-ready.
Be harsh — challenge the in-memory store, the silent except, the money math, and the auth. No praise.
```

Read its findings. This is the tone a real pre-merge review should survive.

---

## Part 3: Spawn a Subagent to Apply the Fixes (10 min)

Reviewing is half the job — now dispatch a subagent to *do the work*. Because these edits touch the real files, spawn it in **inherit mode** (same working directory as your session), not a branch:

```text
Spawn a subagent in inherit mode to clean up app/billing.py: collapse the duplicated currency formatters into one shared helper, replace the bare `except:` in calc_proration with specific exception handling, and add type hints — without changing the public function signatures. Then move the hard-coded API key in app/auth.py to an environment variable (keeping a clear error if it's unset).
```

Approve its edits as it goes (`ctrl+k` for quick approvals). When it's done, review and verify — Beat 2's habit applied to a fix:

```text
/diff
```

```text
!python3 -m pytest -q
```

The diff should show one shared currency helper replacing the duplicates, a real exception type instead of the bare `except:`, and the API key sourced from the environment — with the existing tests still green.

---

## Why this matters

- **Parallelism with oversight.** Subagents fan out across the codebase concurrently; `/agents` + `ctrl+j`/`ctrl+k` let you approve their actions without losing your place.
- **Adversarial review** catches what a supportive pass rubber-stamps.
- **Framing controls refusals.** A constructive "review and harden" prompt gets the security findings that an adversarial "scan for vulnerabilities" prompt refuses to produce.

That completes the story: the billing API was explored, extended, standardized, governed, and finally reviewed, secured, and cleaned — all through Antigravity CLI.

---

## Completion Criteria

- [ ] Spawned 2+ subagents in parallel and got a combined findings summary
- [ ] Used `/agents` and the `ctrl+j` / `ctrl+k` approval keys
- [ ] Ran an adversarial reviewer and read its critical findings
- [ ] Spawned a subagent that refactored `app/billing.py` and moved the hard-coded key to the environment
- [ ] Verified the changes with `/diff` and a green `pytest`
