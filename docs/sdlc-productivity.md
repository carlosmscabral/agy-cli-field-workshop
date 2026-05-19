# Module 1: SDLC Productivity <span class="duration-badge">50 min</span>

> **Your first real agy-cli session.** This module covers the core daily-driver workflows: understanding code, refactoring, generating tests, and reviewing changes — all from the terminal.

---

## 1.0 — First Interactive Session <span class="duration-badge">5 min</span>

Launch agy-cli in your workshop project directory:

```bash
cd agy-cli-field-workshop
agy
```

You'll land in the interactive prompt. Try:

```
> What files are in this project and what does each one do?
```

Observe how agy reads your workspace — it indexes the git repo, reads file contents, and responds with context. This is **automatic**: no config, no prompts to write first.

!!! tip "The .antigravitycli/ folder"
    After your first session, check `.antigravitycli/` — agy created a project config JSON tracking your workspace. This is how it knows what to index on future runs.

---

## 1.1 — Code Understanding <span class="duration-badge">10 min</span>

> **Pattern: Explain Before You Touch** — understand the code before changing it.

### Exercise: Map an Unfamiliar Codebase

```bash
# Start with --prompt-interactive: give agy an initial task, then continue conversationally
agy -i "Give me a high-level architecture overview of this project. What are the main components and how do they connect?"
```

Then follow up interactively:

```
> Which file handles the entry point?
> What external dependencies does this project have?
> Are there any obvious code smells or tech debt?
```

!!! tip "Use -i for seeded sessions"
    `agy -i "<task>"` (short for `--prompt-interactive`) starts with a prompt but stays interactive. Great for oriented exploration — you set the direction, then steer with follow-ups.

---

## 1.2 — Refactoring <span class="duration-badge">10 min</span>

> **Pattern: Propose, Review, Apply** — never apply changes you haven't read.

### Exercise: Targeted Refactor

```bash
agy
```

```
> I want to refactor the error handling in this project. First, show me all the places where errors are currently caught or returned — don't change anything yet.
```

Review the findings. Then:

```
> Now propose a refactored version of [specific function] using a consistent error handling pattern. Show me the diff before applying.
```

Only apply after you've read the proposed change.

!!! warning "Review before applying"
    agy will ask permission before writing files. Read every diff. The `--dangerously-skip-permissions` flag bypasses this — never use it interactively on a codebase you care about.

---

## 1.3 — Test Generation <span class="duration-badge">10 min</span>

> **Pattern: Test What Exists** — generate tests for real code, not hypotheticals.

### Exercise: Generate Unit Tests

```bash
agy
```

```
> Look at [specific function or file]. Generate a comprehensive unit test suite for it. Include happy path, edge cases, and error conditions. Use the testing framework already in this project.
```

Then:

```
> Run the tests and fix any that fail.
```

!!! tip "Let agy run the tests"
    agy can execute shell commands. It will run your test suite and iterate on failures without you having to copy-paste error messages. Watch it self-correct.

---

## 1.4 — Code Review <span class="duration-badge">10 min</span>

> **Pattern: Pre-Commit Review** — use agy as a senior reviewer before every push.

### Exercise: Review Your Changes

```bash
# Stage some changes (or use an existing branch)
git add -p

# Start agy and review what's staged
agy
```

```
> Review my staged changes for: (1) correctness, (2) security issues, (3) missing test coverage, (4) anything that would block a PR. Be direct — don't soften findings.
```

### Headless Variant (for scripting)

```bash
# Review changes non-interactively — useful in pre-commit hooks or CI
git diff --cached | agy --print "Review these changes. Flag any bugs, security issues, or missing tests. Output as markdown."
```

---

## 1.5 — Project Context with AGENTS.md <span class="duration-badge">5 min</span>

> **Pattern: Persistent Context** — tell agy once, it remembers every session.

agy reads context files at session start. Create one at the project root:

```bash
cat > AGENTS.md << 'EOF'
# Project Context

This is a [your project description]. Key conventions:

- Language: [your language/framework]
- Testing: [your test framework]
- Style: [your coding conventions]
- DO NOT: [things agy should never do]

## Architecture
[Brief architecture summary]
EOF
```

Now start a new session:

```bash
agy --print "What do you know about this project?"
```

agy will incorporate your AGENTS.md into every subsequent session automatically.

!!! info "Context hierarchy"
    agy reads AGENTS.md from: current directory → parent directories → home directory. More specific context overrides broader context.

---

## Module 1 Exercises

<div class="exercise-card" markdown>

#### :material-file-document: Exercise 1: First Session

**File:** `exercises/ex01_first_session.md`
**Duration:** 15 min
**Objective:** Launch agy, explore a codebase, generate a AGENTS.md.

</div>

---

## Next Module

→ **[Module 2: Plugin Ecosystem](plugin-ecosystem.md)** — import Gemini CLI and Claude plugins into agy in one command.
