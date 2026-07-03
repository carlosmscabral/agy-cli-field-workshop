# Exercise 1: First Session

> **Duration:** 15 min | **Module:** 1 — Antigravity CLI Fundamentals

---

## Objective

Launch `agy` CLI, explore a sandbox codebase, and create an `AGENTS.md` file that makes every future session smarter.

---

## Setup

For this exercise, we will operate within the dedicated sandbox workspace `agy-sample-app` that you cloned during setup (or that the `scripts/bootstrap-enterprise.sh` script prepared for you).

```bash
# Navigate to the sandbox project directory
cd ../agy-sample-app

# Launch your Antigravity CLI interactive shell
agy
```

---

## Part 1: First Interactive Session (5 min)

At the `agy` prompt, ask:

```text
> What does this project do? Give me a one-paragraph summary.
```

Then follow up:

```text
> What are the top 3 files I should read to understand the core logic?
```

```text
> Are there any obvious code quality issues or tech debt?
```

> [!NOTE]
> `agy` read and indexed your codebase files automatically behind the scenes using standard Git repository scanning, without you having to explicitly upload or copy-paste files.

---

## Part 2: Deep Dive (5 min)

Pick one file from `agy`'s suggestions and go deeper:

```text
> Explain [filename] in detail. Walk me through what each function does and how they connect.
```

```text
> If I wanted to add a simple feature like a health check endpoint, where would I start?
```

---

## Part 3: Create AGENTS.md (5 min)

Now codify what you've learned so every future session starts with full context:

```text
> Based on our conversation, generate an AGENTS.md file for this project. Include: project purpose, tech stack, key conventions, and anything I should tell an AI assistant before asking it to modify this code.
```

Review what `agy` generates. Edit it if anything is wrong. Then ask `agy` to write it:

```text
> Write that AGENTS.md to the project root.
```

Start a new session and verify it loads the rules:

```bash
agy --print "What do you know about this project?" --print-timeout 30s
```

---

## Completion Criteria

- [ ] `agy` launched and responded in interactive mode
- [ ] Explored at least 3 follow-up questions
- [ ] `AGENTS.md` exists at the project root of `agy-sample-app`
- [ ] `agy --print "What do you know about this project?"` returns accurate info
