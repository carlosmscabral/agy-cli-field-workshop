# Exercise 1: First Session

> **Duration:** 20 min | **Module:** 1 — Antigravity CLI Fundamentals

---

## Objective

Launch `agy`, explore a sandbox codebase (using `@` to focus on files), understand the **Tool Permissions** model that governs what the agent may do, and codify project context in an `AGENTS.md` that every future session loads automatically.

---

## Setup

For this exercise, we will operate within the dedicated sandbox workspace `agy-sample-app` that you cloned during setup (or that the `scripts/bootstrap-enterprise.sh` script prepared for you).

**Set up the sample app environment.** The sample app owns its own virtualenv — there is no shared workshop venv. Create it and install the app's dependencies (this is what runs the app and its tests throughout Modules 1–2):

```bash
# Navigate to the sandbox project directory
cd ../agy-sample-app

# Create and activate the sample app's own virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install the sample app's dependencies
pip install -r requirements.txt
```

> [!NOTE]
> If you ran `scripts/bootstrap-enterprise.sh`, this `.venv` already exists — just activate it with `source .venv/bin/activate`.

Now launch your Antigravity CLI interactive shell:

```bash
agy
```

---

## Part 1: First Interactive Session (4 min)

At the `agy` prompt, ask:

```text
What does this project do? Give me a one-paragraph summary.
```

Then follow up:

```text
What are the top 3 files I should read to understand the core logic?
```

```text
Are there any obvious code quality issues or tech debt?
```

> [!NOTE]
> `agy` read and indexed your codebase automatically using standard Git repository scanning — you didn't upload or paste any files.

---

## Part 2: Tool Permissions — What the Agent May Do (5 min)

Before you let the agent change anything, understand how `agy` decides when to ask you first. This is the **permission mode**. Set it from the settings overlay — run `/config` and open **Tool Permissions** — or change it directly with the `/permissions` slash command:

```text
/permissions
```

There are four modes:

| Mode | Behavior |
| :-- | :-- |
| **request-review** | **Default.** The agent asks you to approve each file write or shell command before it runs. |
| **always-proceed** | The agent auto-approves and runs every tool call without prompting — fastest, least oversight. |
| **proceed-in-sandbox** | The agent auto-proceeds, but runs terminal commands inside the **sandbox** (restricted) — autonomy with a safety net. |
| **strict** | The agent may read and reason, but **cannot** write files or run commands — effectively read-only. |

### Persisting your decisions (the allow-list)

When `request-review` prompts you and you choose to **always allow** a specific action, `agy` records it in an **allow-list** in your `settings.json`, so you aren't asked again:

```json
{
  "permissions": {
    "mode": "request-review",
    "allow": [
      "command(git status)",
      "read_file"
    ]
  }
}
```

Your global settings live at `~/.gemini/antigravity-cli/settings.json`; a workspace can override them with its own `.agents/settings.json`. Keeping `request-review` as the default while building a targeted `allow` list is the enterprise sweet spot — the agent moves fast on the operations you've blessed and still stops for anything new.

> [!TIP]
> For a hands-on look at `strict` and the two-phase governance workflow, see the **Sandbox & Governance** exercise later in this module.

---

## Part 3: Deep Dive — Focus on a File with `@` (5 min)

Pick one of the files `agy` suggested and go deeper. Use the **`@` symbol** to focus the agent on a specific file: type `@` and `agy` autocompletes file paths — selecting one attaches that file as the focus of your question (no pasting paths, and the agent centers on exactly that file):

```text
Explain @app/main.py in detail — walk me through what each function does and how they connect.
```

Then explore where you'd extend it:

```text
If I wanted to add a simple health check endpoint, where would I start?
```

> [!NOTE]
> `@` works for any path in the workspace. It's the precise way to point the agent at a file, function, or folder instead of describing it in prose.

---

## Part 4: Codify Context in AGENTS.md (6 min)

Now capture what you've learned so **every future session starts with full context**. Ask the agent to generate *and write* the file — approving that write is `request-review` (Part 2) in action:

```text
Based on our conversation, generate an AGENTS.md for this project — purpose, tech stack, key conventions, and anything an AI assistant should know before modifying this code — and write it to the project root.
```

Review the proposed content, then approve the write.

### Verify it loads — in an interactive session

`agy` reads `AGENTS.md` from the workspace **at session launch** — but only for interactive sessions. Exit the current one:

```text
Press ctrl+d to exit agy.
```

Start a **fresh** session (a brand-new conversation, no prior history) and ask what it knows — it should answer from your `AGENTS.md` alone:

```bash
agy
```

```text
What do you know about this project and its conventions?
```

Because this is a new conversation with no chat history, an accurate answer proves the context came from `AGENTS.md`.

> [!WARNING]
> **Do not verify with `agy -p` (print mode).** Print mode runs *without* loading workspace context (`AGENTS.md`, rules, skills), so it won't reflect your file. Use an interactive session.

### Resuming instead of starting fresh

When you want to *continue* a previous conversation rather than start clean, resume it:

```bash
# Resume your most recent conversation
agy -c
```

Or pick from your past sessions with the in-session picker:

```text
/resume
```

> [!NOTE]
> `agy -c` (alias for `--continue`) reopens your most recent conversation; `/resume` (alias `/switch`) lists past sessions to choose from. Use these for continuity; use a **fresh** `agy` session (above) when you specifically want to confirm `AGENTS.md` is doing the work.

---

## Completion Criteria

- [ ] `agy` launched and answered questions about the sandbox in interactive mode
- [ ] You can name the four permission modes and set one via `/permissions` (or `/config` → Tool Permissions)
- [ ] Used `@` to focus the agent on a specific file
- [ ] `AGENTS.md` exists at the project root of `agy-sample-app`
- [ ] A **fresh** interactive `agy` session correctly describes the project from `AGENTS.md` (verified interactively, not with `agy -p`)
- [ ] You know how to resume a session with `agy -c` and `/resume`
