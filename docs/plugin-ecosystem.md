# Reference: Custom Skills and the Workspace Ecosystem

> **Deep reference for agy-cli's customization and skill system.** The essential commands are covered in [Module 1 — Section 1.7](sdlc-productivity.md#17-extend-with-custom-skills-15-min). This page has the full lifecycle detail for teams building and maintaining custom skills, rules, and local workspace-scoped configs.

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

## 2.2 — Defining Project Rules (`rules.md`) <span class="duration-badge">10 min</span>

> **Pattern: Strict Boundaries** — Set project-wide, unconditional standards that the agent must obey.

While **Skills** are matched semantically (only triggering on related questions), **Rules** are loaded unconditionally as part of the agent's system prompt instructions on every single turn.

Create a rules file inside your workspace root:

* **Workspace rules**: `.agents/rules.md` (or `.agents/rules/*.md`)
* **Global rules**: `~/.gemini/config/rules.md` (or `~/.gemini/config/rules/*.md`)

### Rules Formatting

Rules are authored as clean Markdown files containing style guidelines, engineering practices, or forbidden patterns:

```markdown
# Corporate Engineering Rules

- All source files must contain the standard SPDX copyright header.
- Never use print statements for logging in production code. Always use `logging.getLogger(__name__)`.
- Enforce strict typing on all function signatures. Do not accept bare `Any` types.
- The use of deprecated libraries (e.g., `requests` instead of `httpx` for async endpoints) is strictly forbidden.
```

---

## 2.3 — Workspace Configuration & Permissions (`settings.json`) <span class="duration-badge">5 min</span>

Each project can have a `.agents/settings.json` file to manage fine-grained behavior and permissions for that workspace:

```json
{
  "toolPermission": "request-review",
  "enableTerminalSandbox": true,
  "permissions": {
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

### Key Workspace Keys

| Key | Type | Description |
| :-- | :-- | :-- |
| `toolPermission` | `string` | Sets autonomy level (`always-proceed`, `request-review`, `strict`). |
| `enableTerminalSandbox` | `bool` | Runs command tool execution in a restricted container/sandbox. |
| `permissions.allow` | `array` | Explicitly lists allowed commands or file/URL paths. |
| `permissions.deny` | `array` | Explicitly lists forbidden commands or file/URL paths. |

---

## 2.4 — Registering Local MCP Servers (`mcp_config.json`) <span class="duration-badge">10 min</span>

You can expose custom developer tools (e.g., issue trackers, database browsers, or compliance scanners) via **Model Context Protocol (MCP)**. Register workspace-specific servers in `.agents/mcp_config.json`:

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
