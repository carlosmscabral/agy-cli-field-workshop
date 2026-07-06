# Exercise 9: Sandbox & Governance

> **Duration:** 15 min | **Module:** 1 — Antigravity CLI Fundamentals

---

## Objective

Run agy in `--sandbox` mode for safe code audits, understand the `--dangerously-skip-permissions` flag, and model a governance-appropriate workflow for enterprise environments.

---

## Part 1: Sandbox Mode — Safe Automated Review (7 min)

Run an automated code review with terminal restrictions enabled:

```bash
agy --sandbox \
    --print "As a senior engineer doing a code review, read this project (the FastAPI app in ./app) and write a markdown report of concrete improvements, each with a severity and a suggested fix. Focus on: configuration values hard-coded in source that belong in environment variables, error handling that hides failures, request handlers that don't validate their inputs, and any config or .env files that shouldn't be committed. Cite file:line for each." \
    --print-timeout 5m > audit-sandbox.md

cat audit-sandbox.md
```

> [!TIP]
> **Prompt framing matters.** Ask for a constructive *code review* ("improvements to make", "values that should move to env vars") — **not** an adversarial "scan for vulnerabilities / secrets", which reliably triggers a refusal. Note the model is nondeterministic: even a well-framed review prompt may *occasionally* decline. If `audit-sandbox.md` comes back with a one-line refusal instead of findings, just **re-run the command** (or lightly rephrase) — it succeeds on retry.

Key properties of this run:

- `--sandbox` restricts terminal command execution — agy reads files but cannot run arbitrary shell commands
- `--print` means no interactive session — purely automated
- Output is captured to a file for audit trail

**When to use this pattern:**

- Auditing code you don't fully trust
- Compliance scanning in regulated environments
- Running on production codebases where side effects are unacceptable

---

## Part 2: Auto-Approve Mode — Understand the Risk (5 min)

`--dangerously-skip-permissions` bypasses all tool approval prompts. agy executes file writes and shell commands without asking.

> [!NOTE]
> **The autonomy spectrum (interactive).** The same trade-off exists inside a session, dialed with `/grill-me` and your Tool Permissions mode (set via `/config` → Tool Permissions) instead of flags: `/grill-me` (agy asks *you* clarifying questions before acting — maximum alignment) → **request-review** (approve artifacts at milestones — the default) → **always-proceed** or `/goal` (agy runs to completion, auto-approving its own plan). `/goal` is the interactive cousin of `--dangerously-skip-permissions` — reserve it for well-scoped, low-risk, or batch tasks. *(`/goal` is reported in the I/O 2026 update; confirm it against your CLI version before relying on it.)*

**Safe demonstration:** run it with `--sandbox` to show auto-approval without actual command execution:

```bash
agy --sandbox --dangerously-skip-permissions \
    --print "List all TODO comments in this codebase and generate a prioritized backlog." \
    --print-timeout 3m
```

Without `--sandbox`, this flag would allow agy to write files, run tests, and execute commands without prompting. **Only use it:**

- In CI/CD where no human is present
- Paired with `--sandbox` for read-only audits
- On throwaway environments where writes are acceptable

!!! warning "Never in production"
    `--dangerously-skip-permissions` without `--sandbox` in an interactive session on a live codebase is a footgun. There's no undo for overwritten files.

---

## Part 3: Governance Workflow (3 min)

Model a two-phase governance workflow:

### Phase 1: Safe analysis (no side effects)

```bash
agy --sandbox \
    --print "As a senior engineer, review the API request handlers in this project (the FastAPI app in ./app). For each endpoint, note inputs that aren't validated at the boundary and any error handling that could silently swallow failures, and suggest a concrete improvement with file:line. Write the report to stdout." \
    --print-timeout 3m > phase1-analysis.md
```

> [!IMPORTANT]
> **Same framing rule as Part 1.** Keep this a constructive *review* ("improvements to make", "inputs that should be validated") — an adversarial "flag vulnerabilities / transaction-safety flaws" prompt reliably **refuses** (`"Sorry, I cannot fulfill your request…"`). Also **anchor the prompt to this project** ("the FastAPI app in `./app`"): in `--sandbox --print` the agent won't always scope itself to your current directory, and a vaguely-scoped prompt can wander off and analyze an unrelated repo on your machine. If the output is a one-line refusal or clearly about the wrong code, re-run (the model is nondeterministic).

### Phase 2: Human reviews, then approves interactive session

```bash
cat phase1-analysis.md  # human reviews findings

# If approved, continue with interactive session for remediation
agy -i "Based on the findings in phase1-analysis.md, fix the top 3 input-validation and error-handling issues."
```

This pattern is the enterprise-grade model: **read without trust, write only after review**.

---

## Completion Criteria

- [ ] `agy --sandbox --print "..."` ran and produced an audit file
- [ ] Understand when `--dangerously-skip-permissions` is appropriate vs dangerous
- [ ] Implemented the two-phase governance workflow (sandbox audit → human review → interactive fix)
