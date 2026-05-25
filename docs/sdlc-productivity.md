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

!!! tip "The .agents/ folder"
    After your first session, check `.agents/` — agy created project config files tracking your workspace. This is how it knows what to index on future runs.

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

### Permissions Model

agy has a **3-level permissions model** that controls how it handles tool approvals:

| Level | Behavior |
|---|---|
| `request-review` | **Default.** agy asks for approval before writing files or running commands |
| `always-proceed` | Auto-approve all tool calls — useful for trusted scripts and CI |
| `strict` | Deny all tool use unless explicitly allowed — maximum control |

Use the `/permissions` slash command to view or change the current level. You can also set fine-grained rules:

```json
{
  "permissions": {
    "allow": ["command(git)", "read_file"],
    "deny": ["command(rm -rf)"]
  }
}
```

> 📖 Full details: [Permissions docs](https://www.antigravity.google/docs/permissions) · [Strict Mode docs](https://www.antigravity.google/docs/strict-mode)

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

### Additional Context Sources

Beyond AGENTS.md, agy also loads:

- **`.agents/rules.md`** (or `.agents/rules/*.md`) — project-level rules injected as system prompt directives. Use these for hard requirements like "never delete migration files" or "always use TypeScript strict mode."
- **`.gemini/`** — for Gemini CLI compatibility, agy reads `.gemini/` directories alongside `.agents/`.
- **`~/.gemini/config/rules.md`** — global rules applied to all sessions.

> 📖 Full details: [Rules & Workflows docs](https://www.antigravity.google/docs/rules-workflows)

---

## 1.6 — Interactive Navigation <span class="duration-badge">5 min</span>

> **Pattern: Terminal Fluency** — know the shortcuts that make agy sessions fast.

> 📖 Full reference: [Using AGY CLI](https://www.antigravity.google/docs/cli-using)

### Key Slash Commands

| Command | What it does |
|---|---|
| `/rewind` (or `/undo`) | Roll back conversation history to a previous checkpoint |
| `/resume` (or `/switch`) | Open conversation picker to resume or switch sessions |
| `/rename <name>` | Rename the active conversation thread |
| `/config` (or `/settings`) | Open full-screen settings overlay |
| `/permissions` | Set agent autonomy level (`request-review`, `always-proceed`, `strict`) |
| `/model` | Select reasoning model (persists across sessions) |
| `/tasks` | Monitor, view logs for, or terminate background tasks |
| `/agents` | View, manage, and approve subagent actions |
| `/open <path>` | Open a file in your preferred external editor |
| `/usage` | Open the inline interactive help manual |
| `/skills` | Browse local and global agent skills |
| `/mcp` | Configure and manage MCP servers |

> 📖 Full slash command reference: [CLI Features](https://antigravity.google/docs/cli-features)

### Quick Tips

| Shortcut | What it does |
|---|---|
| `@` | File path autocomplete — type `@` to trigger path suggestions |
| `!` | Run terminal commands directly without leaving agy |
| `esc esc` | Clear the current prompt input (when no streaming is active) |
| `?` | Get help and list all slash commands |
| `alt+enter` / `ctrl+j` / `shift+enter` | Insert a newline in your prompt (multi-line input) |
| `ctrl+g` | Edit prompt inside your default shell editor |
| `ctrl+l` | Clear TUI screen |
| `ctrl+d` | Exit the CLI |

> 📖 Full keybindings reference: [Using AGY CLI](https://antigravity.google/docs/cli-using)

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
