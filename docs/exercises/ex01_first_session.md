# Exercise 1: First Session

> **Duration:** 15 min | **Module:** 1 — SDLC Productivity

---

## Objective

Launch agy-cli, explore a codebase, and create an AGENTS.md that makes every future session smarter.

---

## Setup

You need a Git repository to work with. Use the sample app in this repo or bring your own:

```bash
# Option A: Use this workshop repository (you're already here)
# No need to cd — just start agy from the repo root

# Option B: Use any of your own Git repos
cd /path/to/your/project
```

---

## Part 1: First Interactive Session (5 min)

```bash
agy
```

At the prompt, ask:

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

**Notice:** agy read your files without you having to specify them. It indexed the git repo automatically.

---

## Part 2: Deep Dive (5 min)

Pick one file from agy's suggestions and go deeper:

```text
> Explain [filename] in detail. Walk me through what each function does and how they connect.
```

```text
> If I wanted to add [a simple feature], where would I start?
```

---

## Part 3: Create AGENTS.md (5 min)

Now codify what you've learned so every future session starts with context:

```text
> Based on our conversation, generate an AGENTS.md file for this project. Include: project purpose, tech stack, key conventions, and anything I should tell an AI assistant before asking it to modify this code.
```

Review what agy generates. Edit it if anything is wrong. Then write it:

```text
> Write that AGENTS.md to the project root.
```

Start a new session and verify it works:

```bash
agy --print "What do you know about this project?" --print-timeout 30s
```

---

## Completion Criteria

- [ ] agy launched and responded in interactive mode
- [ ] Explored at least 3 follow-up questions
- [ ] AGENTS.md exists at the project root
- [ ] `agy --print "What do you know about this project?"` returns accurate info
