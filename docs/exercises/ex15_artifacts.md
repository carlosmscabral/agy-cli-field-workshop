# Exercise 15: Artifacts — Plan, Review, and Verify

> **Duration:** 20 min | **Module:** 1 — Antigravity CLI Fundamentals

---

## Objective

Use `agy`'s **Artifacts** workflow to implement a feature end to end: plan it, steer it with an inline comment, watch the agent execute against a checklist, and verify the result. Artifacts are the flagship capability that sets `agy` apart from raw chat-style coding tools — instead of scrolling through hundreds of individual tool calls, you review a handful of structured, verifiable milestones and co-steer the agent as it works.

> [!NOTE]
> **Continuity callback to Exercise 1.** In your first session you asked `agy` *where* you would add a health check endpoint — the sample app deliberately ships without one. This exercise actually implements that `GET /health` endpoint, but drives it through the Artifacts workflow instead of ad-hoc prompting.

---

## What are Artifacts?

As the agent works, it emits **artifacts** — structured deliverables you review instead of raw tool output. Three core types show up in this exercise:

| Artifact | What it is |
| :-- | :-- |
| **Implementation Plan** | A markdown plan: the approach, which files change, and how the change fits the existing codebase. Produced *before* any code is written. |
| **Task List** | A `task.md` the agent ticks off step by step as it implements. |
| **Walkthrough** | A post-completion summary of what changed and how to verify it. |

Artifacts can embed code diffs and Mermaid diagrams, and you can leave **inline comments** on them — like commenting on a shared doc — which the agent incorporates without stopping its flow.

---

## Setup

Work inside the same sandbox you used in Exercise 1 — the FastAPI subscription-billing API.

```bash
# Navigate to the sandbox project directory
cd ../agy-sample-app

# Launch your Antigravity CLI interactive shell
agy
```

---

## Part 1: Enter Planning Mode (5 min)

> [!TIP]
> **Optional — align first with `/grill-me`.** For an ambiguous task, run `/grill-me` before planning: `agy` interrogates *you* with clarifying questions to pin down the spec, so the Implementation Plan starts from a shared understanding. This is the "tighten the spec" end of the autonomy spectrum (the opposite of `/goal`, which runs autonomously — see the Sandbox & Governance exercise).

Put `agy` into planning mode so it produces a plan *before* touching code:

```text
/planning
```

Then describe the feature. Ask for the health endpoint you scoped back in Exercise 1:

```text
Add a GET /health endpoint to this FastAPI app. It should return an overall status, the application version, and a count of the seeded records (plans, subscriptions, invoices, users). Produce an implementation plan first.
```

`agy` responds with an **Implementation Plan** artifact rather than immediately editing files. Read it: it should name `app/main.py` as the primary edit, reference the app `version` and the in-memory store in `app/database.py`, and explain how the endpoint fits the existing routing.

---

## Part 2: Review and Co-Steer with an Inline Comment (6 min)

Now review the plan and steer it — this is the core Artifacts loop. Open the **Artifact Review panel** — either with the `/artifact` command or the `ctrl+r` shortcut:

```text
/artifact
```

Read the Implementation Plan in the panel, then leave an inline comment to broaden the health check. The keys are:

1. Press **`c`** to start a comment on the plan.
2. Type the comment, for example:

   ```text
   Also include a dependency / data-store readiness check — confirm the in-memory store is reachable and report it in the response, not just a static "ok".
   ```

3. Press **`esc`** to finish the comment.
4. Press **`y`** to approve the plan.

`agy` incorporates your comment and moves into implementation — no restart or re-prompt. The revised plan now accounts for the store-readiness check.

> [!TIP]
> Prefer your own editor? Press `ctrl+g` to open the current artifact in `$EDITOR`; edits there flow back into the session the same way.

That `y` approval step only appears when the agent is set to pause for you:

> [!NOTE]
> **Who approves, and when?** Whether `agy` pauses for your approval or auto-proceeds is governed by your autonomy level. Run `/permissions` to check it: in `request-review` (default) the agent waits for you to approve artifacts; in `always-proceed` it auto-approves and keeps going; `strict` holds tightest control. Keep it on `request-review` for this exercise so you see each artifact.

---

## Part 3: Watch the Task List Execute (5 min)

Once you approve the plan, `agy` produces a **Task List** artifact — a `task.md` broken into concrete steps (add the route, wire in the version and counts, add the readiness check, add/adjust a test) — and begins implementing, ticking off each item as it completes.

Open the **artifact panel** at any time to follow along:

```text
/artifact
```

`/artifact` opens the artifact panel, where you can browse this session's artifacts — the Implementation Plan, the **Task List** (watch its items get checked off as the agent works), and, once the agent finishes, the **Walkthrough**.

> [!NOTE]
> The command is `/artifact` (singular). `/artifacts` (plural) is **not** accepted.

---

## Part 4: Analyze the Walkthrough, Then Verify (4 min)

When the agent finishes, open the **Walkthrough** artifact from the `/artifact` panel and read it end to end — this is your finalize step. The Walkthrough is the agent's own account of the work: which files it changed, the new `GET /health` route and the store-readiness check you requested, and the exact steps to verify. Reviewing it is how you close the plan → review → implement → **verify** loop before trusting the change.

Then confirm it yourself. Run the existing test suite from inside the session using the shell escape:

```text
!python3 -m pytest -q
```

Or run the app and hit the new endpoint directly. In a separate terminal:

```bash
cd ../agy-sample-app
uvicorn app.main:app --reload
```

```bash
curl http://localhost:8000/health
```

You should get back a JSON payload with a status, the app version (`0.1.0`), and the record counts — plus the store readiness signal you added via your inline comment.

---

## Why this matters

Artifacts turn the agent from a black box into a reviewable collaborator:

- **Co-steering, not babysitting.** You correct course with an inline comment on the plan and the agent keeps flowing — no stop-and-restart.
- **Review at the right altitude.** You approve a plan and a checklist, not hundreds of raw tool calls.
- **Trust through verification.** The Walkthrough gives you a concrete way to confirm the work, and the plan-then-implement loop means surprises surface *before* code is written, not after.
- **Async-friendly.** Because artifacts persist in the session, you can step away, come back, and pick up the review where you left off.

This plan → review → implement → verify loop is the differentiator: `agy` shows its work as structured milestones you can actually steer.

---

## Completion Criteria

- [ ] Entered planning mode with `/planning` and received an **Implementation Plan** artifact before any code was written
- [ ] Opened the artifact panel with `/artifact` (or `ctrl+r`)
- [ ] Left an inline comment (`c` → type → `esc`) and approved the plan (`y`), and watched the agent incorporate the comment
- [ ] Observed the **Task List** artifact tick off steps during implementation
- [ ] Opened and analyzed the generated **Walkthrough** artifact (what changed + how to verify)
- [ ] Verified the `GET /health` endpoint via `pytest` or `curl http://localhost:8000/health`
