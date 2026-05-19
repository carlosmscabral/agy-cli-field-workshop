# agy-cli Cheatsheet

> Quick reference for everything covered in this workshop.

---

## Installation & Version

```bash
agy --help         # Show all flags and subcommands
agy changelog      # Show release notes
agy update         # Self-update
agy install        # Configure PATH and shell aliases
```

---

## Launch Modes

| Mode | Command | When to use |
|---|---|---|
| **Interactive** | `agy` | Default — full conversational session |
| **Seeded interactive** | `agy -i "<prompt>"` | Start with direction, continue conversationally |
| **Print (headless)** | `agy -p "<prompt>"` | Single shot, pipe to stdout |
| **Continue last** | `agy -c` | Resume most recent session |
| **Resume by ID** | `agy --conversation <id>` | Resume a specific past session |

---

## Key Flags

| Flag | Short | Description |
|---|---|---|
| `--print "<prompt>"` | `-p` | Non-interactive single prompt |
| `--prompt-interactive "<prompt>"` | `-i` | Seeded interactive session |
| `--continue` | `-c` | Resume most recent conversation |
| `--conversation <id>` | — | Resume by conversation ID |
| `--add-dir <path>` | — | Add directory to workspace (repeatable) |
| `--sandbox` | — | Enable terminal restrictions |
| `--dangerously-skip-permissions` | — | Auto-approve all tool requests (CI only) |
| `--print-timeout <duration>` | — | Timeout for print mode (default: 5m) |
| `--log-file <path>` | — | Override log output path |

---

## Plugin Commands

```bash
# List all active plugins (JSON)
agy plugin list

# Import from Gemini CLI
agy plugin import gemini

# Import from Claude Code
agy plugin import claude

# Force re-import (after plugin updates)
agy plugin import gemini --force

# Install a plugin
agy plugin install <name>
agy plugin install <name>@<version>

# Enable / disable
agy plugin enable <name>
agy plugin disable <name>

# Validate a plugin directory
agy plugin validate ./my-plugin

# Generate marketplace link
agy plugin link <marketplace> <target>
```

---

## Workspace & Context

```bash
# Project config auto-created on first run at:
.antigravitycli/<uuid>.json

# agy also reads:
.gemini/          # Gemini CLI config (compatible)
AGENTS.md         # Project context file (read at session start)
```

### AGENTS.md Pattern

```markdown
# Project Context

Brief description of what this project is.

## Conventions
- Language: TypeScript, Node 20
- Testing: Jest + Supertest
- DO NOT run database migrations without explicit approval
```

---

## Slash Commands (Interactive Mode)

| Command | Description |
|---|---|
| `/btw <message>` | Inject a note mid-task without interrupting |
| *(see plugin commands)* | Plugins add additional slash commands |

---

## Useful Patterns

```bash
# Review staged changes before commit
git diff --cached | agy -p "Review for bugs, security issues, missing tests."

# Generate docs for a file
cat src/api.ts | agy -p "Generate OpenAPI documentation for all exported functions."

# Analyze logs
tail -n 500 app.log | agy -p "Group these errors by root cause. Output as JSON."

# Multi-dir cross-repo analysis
agy --add-dir ../api --add-dir ../frontend \
    -p "Map data flow from frontend form submission to database write."

# Full headless CI audit (safe)
agy --sandbox --dangerously-skip-permissions \
    -p "Audit for hardcoded secrets and insecure patterns." \
    --print-timeout 5m > audit.md

# Schedule a recurring task (in interactive mode)
# > Schedule a daily code quality report at 9am weekdays.
```

---

## Multi-Agent Patterns

```
# Spawn parallel subagents (in interactive mode)
> Spawn a security auditor and a performance auditor in parallel (branch mode).

# Adversarial review
> Spawn an adversarial reviewer subagent — its job is to find reasons to NOT merge this PR.

# Steer mid-task
/btw Focus only on the authentication module, skip the frontend.

# Background task
> In the background, audit all dependencies for known CVEs. Notify me when done.
```

---

## Print Mode Pipeline Examples

```bash
# Step 1: plan
agy -p "Create a refactoring plan for moving from callbacks to async/await. JSON output." \
  > plan.json

# Step 2: execute
cat plan.json | agy -p "Execute step 1 of this plan."

# Batch: process multiple files
for f in src/*.ts; do
  agy --add-dir "$(dirname $f)" \
      -p "Add JSDoc to all exported functions in $(basename $f)."
done
```
