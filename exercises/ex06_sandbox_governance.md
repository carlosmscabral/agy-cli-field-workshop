# Exercise 6: Sandbox & Governance

> **Duration:** 15 min | **Module:** 4 — Multi-Agent & Advanced

---

## Objective

Run agy in `--sandbox` mode for safe code audits, understand the `--dangerously-skip-permissions` flag, and model a governance-appropriate workflow for enterprise environments.

---

## Part 1: Sandbox Mode — Safe Audit (7 min)

Run a security audit with terminal restrictions enabled:

```bash
agy --sandbox \
    --print "Scan this entire codebase for: (1) hardcoded secrets or API keys, (2) SQL injection risks, (3) insecure direct object references, (4) any .env files or credentials committed to the repo. Output findings as markdown with severity levels." \
    --print-timeout 5m > audit-sandbox.md

cat audit-sandbox.md
```

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
    --print "Analyze all database operations in this codebase. Flag any that lack transaction safety or input validation." \
    --print-timeout 3m > phase1-analysis.md
```

### Phase 2: Human reviews, then approves interactive session

```bash
cat phase1-analysis.md  # human reviews findings

# If approved, continue with interactive session for remediation
agy -i "Based on the findings in phase1-analysis.md, fix the top 3 database safety issues."
```

This pattern is the enterprise-grade model: **read without trust, write only after review**.

---

## Completion Criteria

- [ ] `agy --sandbox --print "..."` ran and produced an audit file
- [ ] Understand when `--dangerously-skip-permissions` is appropriate vs dangerous
- [ ] Implemented the two-phase governance workflow (sandbox audit → human review → interactive fix)
