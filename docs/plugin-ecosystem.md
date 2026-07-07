# Reference: Workspace Customization

> **Deep reference for agy-cli's workspace customization system** — skills, rules, MCP servers, hooks, subagents, and plugins. The workshop beats introduce these in context ([Skills & Rules](exercises/ex03_skills_rules.md), [MCP](exercises/ex04_mcp_governed_access.md), [Subagents](exercises/ex05_subagents.md)); this page is the full file-format detail for teams building and maintaining them.

---

## 2.0 — Why Customization Matters <span class="duration-badge">5 min</span>

An AI development assistant is only as good as the context and standards it operates with. Out of the box, `agy-cli` is an expert in general coding, but it doesn't know about:

* Your team's custom internal APIs, helper libraries, or design patterns.
* Your specific architectural rules (e.g., "Always catch and wrap SQL errors").
* Your internal styling standards or regulatory compliance rules.

By extending `agy-cli` with **Skills**, **Rules**, and **Workspace-Scoped configs**, you embed your organization's expertise directly into the terminal, ensuring the agent's code suggestions are immediately production-ready.

```bash
# Browse all active discovered skills in agy
# (Run this inside an agy session, or via slash commands)
/skills
```

---

## 2.1 — Creating and Structuring Custom Skills <span class="duration-badge">10 min</span>

> **Pattern: Domain-Specific Expertise** — Write modular instruction blocks that load dynamically depending on the task.

A **Skill** is a self-contained directory that tells the agent how to handle certain classes of problems.

### File Structure

Skills are organized under standard customization roots:

* **Workspace-Scoped**: `.agents/skills/<skill_name>/`
* **Global-Scoped**: `~/.gemini/config/skills/<skill_name>/`

```text
.agents/skills/database-handler/
├── SKILL.md                 # ← Required: metadata & instructions
├── examples/                # Optional: reference code snippets
│   └── query_wrapper.py
└── references/              # Optional: additional offline docs
    └── schema_guide.md
```

### The SKILL.md Schema

Each skill **must** start with a valid YAML frontmatter block containing a `name` and a `description`. `agy-cli` uses semantic embedding matching on the `description` field to determine when a skill should be activated:

```markdown
---
name: database-handler
description: Guide for writing transactional queries and handling database migrations. Triggers on SQL, database, transactional, or query questions.
---

# Database Handler Guidelines

Always follow these rules when writing SQL or database manipulation methods:

1. Always use parameterized queries or bindings. Never concatenate user input directly.
2. Ensure every transaction block is wrapped in a try/except, and calls `.rollback()` on exception.
3. Database migrations must be placed under `migrations/` and run sequentially.
```

---

## 2.2 — Defining Project Rules (`.agents/rules/`) <span class="duration-badge">10 min</span>

> **Pattern: Strict Boundaries** — Set project-wide, unconditional standards that the agent must obey.

While **Skills** are matched semantically (only triggering on related questions), **Rules** are loaded unconditionally as part of the agent's system prompt instructions on every single turn.

Each rule is a Markdown file placed **directly under a `rules/` folder** (subfolders are not crawled):

* **Workspace rules**: `.agents/rules/<name>.md`
* **Global rules**: `~/.gemini/config/rules/<name>.md`

> A bare `.agents/rules.md`, or a rule file without frontmatter, is **not** loaded — rules live under `.agents/rules/` and must declare a `trigger`.

### Rules Formatting

Each rule needs **YAML frontmatter** with a `trigger` (`always_on`, `model_decision`, `glob`, or `manual`). An `always_on` rule is injected into the system prompt on every turn:

```markdown
---
trigger: always_on
description: Corporate engineering standards
---

# Corporate Engineering Rules

- All source files must contain the standard SPDX copyright header.
- Never use print statements for logging in production code. Always use `logging.getLogger(__name__)`.
- Enforce strict typing on all function signatures. Do not accept bare `Any` types.
- The use of deprecated libraries (e.g., `requests` instead of `httpx` for async endpoints) is strictly forbidden.
```

---

## 2.3 — Configuration & Permissions (`settings.json`) <span class="duration-badge">5 min</span>

Behavior and permissions are managed in your **global** settings file at `~/.gemini/antigravity-cli/settings.json`:

```json
{
  "enableTerminalSandbox": true,
  "permissions": {
    "mode": "request-review",
    "allow": [
      "read_file",
      "command(git)",
      "command(pytest)"
    ],
    "deny": [
      "command(rm -rf)",
      "command(curl)",
      "read_url"
    ]
  }
}
```

> [!IMPORTANT]
> Antigravity does **not** read a per-workspace `.agents/settings.json` — this is a deliberate security boundary. Otherwise an untrusted repo you clone could ship a `.agents/settings.json` that auto-approves destructive commands, disables the sandbox, or weakens other guardrails. Permissions live only in your global, user-owned file. (MCP servers, hooks, rules, and skills *are* workspace-scoped via `.agents/` — permissions are the deliberate exception.)

### Key Workspace Keys

| Key | Type | Description |
| :-- | :-- | :-- |
| `permissions.mode` | `string` | Sets autonomy level (`always-proceed`, `request-review`, `strict`). |
| `enableTerminalSandbox` | `bool` | Runs command tool execution in a restricted container/sandbox. |
| `permissions.allow` | `array` | Explicitly lists allowed commands or file/URL paths. |
| `permissions.deny` | `array` | Explicitly lists forbidden commands or file/URL paths. |

---

## 2.4 — Registering Local MCP Servers (`mcp_config.json`) <span class="duration-badge">10 min</span>

You can expose custom developer tools (e.g., issue trackers, database browsers, or compliance scanners) via **Model Context Protocol (MCP)**. Register workspace-specific servers in `.agents/mcp_config.json` (or globally in `~/.gemini/config/mcp_config.json`, or inside a plugin):

```json
{
  "mcpServers": {
    "jira-compliance": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-jira"],
      "env": {
        "JIRA_API_TOKEN": "secret_token_value"
      }
    }
  }
}
```

Once registered, the tools provided by the MCP server will appear directly in your `/mcp` TUI panel and will be callable by `agy` during sessions.

---

## 2.5 — Plugin Lifecycle <span class="duration-badge">10 min</span>

> **Pattern: Package and Share** — a **plugin** bundles skills, rules, subagents, MCP servers, and hooks into a single installable unit so a whole team can adopt the same customizations at once.

Where a Skill or a rule file customizes a single workspace, a **plugin** packages those same components (plus MCP servers and hooks) so they can be installed, versioned, enabled, and disabled as a unit. Plugins are managed with the `agy plugin` subcommand (aliased `agy plugins`).

### Plugin Directory Layout

A plugin is just a directory with a `plugin.json` marker file at its root. Everything else is optional and mirrors the workspace customization roots you already know:

```text
~/.gemini/config/plugins/<plugin_name>/
├── plugin.json          # ← Required marker file (name, version, metadata)
├── mcp_config.json      # Optional: MCP server definitions
├── hooks.json           # Optional: event hooks (PreInvocation, PreToolUse, PostToolUse)
├── skills/              # Optional: skill instruction sets (SKILL.md dirs)
├── agents/              # Optional: subagent definitions
├── rules/              # Optional: rule files
└── import_manifest.json # Auto-generated when a plugin is imported
```

> **Note:** hooks are always defined in a `hooks.json` file placed in a customization root — `.agents/hooks.json` (workspace), `~/.gemini/config/hooks.json` (global), or inside a plugin. They are **not** configured under a `settings.json` key.

### Managing Plugins

```bash
# List installed plugins and their enabled/disabled state
agy plugin list

# Install / remove a plugin
agy plugin install <name>
agy plugin uninstall <name>

# Toggle a plugin without uninstalling it
agy plugin enable <name>
agy plugin disable <name>

# Validate a plugin's structure and manifest before shipping it
agy plugin validate <name>

# Import existing Gemini CLI (or Claude) extensions as plugins
agy plugin import gemini
```

### Typical Workflow

1. Scaffold a directory with a `plugin.json` and drop your `skills/`, `rules/`, `agents/`, `mcp_config.json`, and `hooks.json` into it.
2. Run `agy plugin validate <name>` to confirm the manifest and component layout are correct.
3. `agy plugin install <name>` to register it, then `agy plugin list` to confirm it is enabled.
4. Use `agy plugin disable <name>` / `enable <name>` to toggle it per project without losing the install.

> 📖 Full details: [Plugins docs](https://antigravity.google/docs/plugins) · [cli-features — Plugins](https://antigravity.google/docs/cli-features)

---

## Sample Files in This Repo

Copy-ready examples live under `samples/` — drop them into a workspace `.agents/` (or a plugin) and adapt:

* **Subagents** (`samples/agents/`): `security-scanner.md`, `pr-reviewer.md`, and `doc-writer.md` — each a `.agents/agents/<name>.md` definition (`model` + `tools.allow` + system-prompt body). *Note: workspace subagent files are documented but not surfaced by all `agy` builds — confirm in `/agents` before relying on them. [Beat 5](exercises/ex05_subagents.md) uses spawned (native) subagents instead.*
* **Hooks** (`samples/hooks/`): `session-context.sh` (PreInvocation), `secret-scanner.sh` and `git-context-injector.sh` (PreToolUse), and `test-nudge.sh` (PostToolUse) — wired together in `samples/configs/hooks.json`.
* **Configs** (`samples/configs/`): `settings.json` (permissions), `mcp_config.json` (MCP server), and `hooks.json` (hook registrations).
