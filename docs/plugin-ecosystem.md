# Reference: Plugin Ecosystem

> **Deep reference for agy-cli's plugin system.** The essential commands are covered in [Module 1 — Section 1.7](sdlc-productivity.md#17-extend-with-plugins). This page has the full lifecycle detail for teams building and maintaining custom plugins.

---

## 2.0 — Why Plugins Matter <span class="duration-badge">5 min</span>

agy-cli's plugin system does something unique: it can **import plugins you've already installed in Gemini CLI or Claude Code** — without reinstalling or reconfiguring. Your existing investment in extensions carries over.

```bash
# See what plugins are currently active in agy
agy plugin list
```bash

The output is JSON showing each plugin's name, source, import date, and components (skills, commands, mcpServers, agents).

```bash
# More readable
agy plugin list | python3 -m json.tool
```bash

> 📖 Official docs: [Plugins](https://www.antigravity.google/docs/plugins) · [MCP](https://www.antigravity.google/docs/mcp) · [Skills](https://www.antigravity.google/docs/skills)

---

## 2.1 — Importing from Gemini CLI <span class="duration-badge">10 min</span>

> **Pattern: Cross-Tool Plugin Bridge** — pull your entire Gemini CLI plugin setup into agy.

### Import All Gemini CLI Plugins

```bash
agy plugin import gemini
```bash

agy scans your local Gemini CLI installation, discovers all installed plugins, and stages their components (skills, commands, MCP servers, agents) into agy's config at `~/.gemini/antigravity-cli/`.

Output looks like:
```bash
  [ok]    code-review
          ✔ skills      : 3 processed
          ✔ commands    : 2 processed
          - mcpServers  : skipped (not found)
  [ok]    gemini-deep-research
          ✔ commands    : 1 processed
          ✔ mcpServers  : 1 processed
  [skip]  superpowers (already imported)
```yaml

!!! tip "Re-import with --force"
    Already imported plugins are skipped by default. To force re-import after a plugin update:
    ```bash
    agy plugin import gemini --force
    ```

### What Gets Imported

| Component | What it means |
|---|---|
| `skills` | SKILL.md files with YAML frontmatter — injected into agy's context |
| `commands` | Slash commands available inside agy sessions |
| `mcpServers` | MCP tool servers (GitHub, gcloud, Workspace, etc.) — stdio or SSE |
| `agents` | Custom subagent definitions |
| `hooks` | Staged but not auto-executed (agy handles lifecycle differently) |
| `rules` | Rules files (`rules.md`, `rules/*.md`) injected as RULE blocks |

---

## 2.2 — Importing from Claude Code <span class="duration-badge">5 min</span>

> **Pattern: Unified Tool Surface** — if you use Claude Code alongside agy, import its plugins too.

```bash
agy plugin import claude
```yaml

Same mechanic — agy discovers your Claude Code extension installations and bridges compatible components.

!!! info "Component compatibility"
    Not all Claude Code extension components map 1:1 to agy's model. agy imports what's compatible and silently skips what isn't.

---

## 2.3 — Managing Plugins Per-Project <span class="duration-badge">10 min</span>

> **Pattern: Project-Scoped Plugin Config** — not every plugin is appropriate for every codebase.

### Enable / Disable

```bash
# Disable a plugin for this session/project
agy plugin disable gemini-deep-research

# Re-enable it
agy plugin enable gemini-deep-research

# Check current state
agy plugin list
```bash

### Plugin Locations

Plugins can be installed at two levels:

| Scope | Path |
|---|---|
| **Global** | `~/.gemini/config/plugins/` |
| **Project** | `.agents/plugins/` |

### Install a Specific Plugin

```bash
# Install by name (from configured source)
agy plugin install <plugin-name>

# Install a specific version
agy plugin install <plugin-name>@<version>
```bash

---

## 2.4 — Validating a Plugin <span class="duration-badge">10 min</span>

> **Pattern: Plugin-as-Code** — treat plugin definitions like source code. Validate before shipping.

### Validate an Existing Plugin Directory

```bash
# Validate a plugin directory
agy plugin validate ./path/to/my-plugin

# Or validate the current directory
agy plugin validate .
```bash

This checks that the plugin's `plugin.json` manifest is well-formed and all referenced components exist.

### Build a Minimal Custom Plugin

A valid agy plugin needs a `plugin.json` manifest. Here's the official structure:

```bash
my-plugin/
├── plugin.json          ← manifest (required)
├── mcp_config.json      ← MCP server definitions (optional)
├── hooks.json           ← hook event handlers (optional)
├── skills/              ← SKILL.md files with YAML frontmatter
│   └── my-skill/
│       └── SKILL.md
├── agents/              ← subagent definitions (optional)
└── rules/               ← rules files (optional)
    └── my-rules.md
```bash

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "My custom agy plugin",
  "components": ["skills"]
}
```bash

```bash
# Validate it
agy plugin validate ./my-plugin

# If valid, you'll see: ✔ Plugin manifest is valid
```bash

### Interacting with Plugin Components

Use slash commands to inspect active plugin components in a session:

| Command | What it shows |
|---|---|
| `/skills` | All loaded skills (from plugins, project, global) |
| `/mcp` | Active MCP servers and their status |

### Exercise: Validate the Workshop Plugin

The workshop repo includes a sample plugin at `samples/plugins/workshop-helpers/`. Validate it:

```bash
agy plugin validate samples/plugins/workshop-helpers/
```yaml

---

## 2.5 — Plugin Architecture Overview

```mermaid
graph LR
    GC["Gemini CLI\nPlugins"] -->|agy plugin import gemini| S["Plugin Staging\n~/.gemini/antigravity-cli/plugins/"]
    CC["Claude Code\nExtensions"] -->|agy plugin import claude| S
    S -->|agy plugin enable/disable| A[agy session]
    A --> SK[Skills]
    A --> MCP[MCP Servers]
    A --> AG[Agents]
    A --> RU[Rules]
    A --> HK[Hooks]
```bash

Plugin staging directory structure:

```bash
~/.gemini/antigravity-cli/plugins/<name>/
├── plugin.json
├── mcp_config.json
├── hooks.json
├── skills/
├── agents/
└── rules/
```yaml

---

## Module 2 Exercises

<div class="exercise-card" markdown>

### :material-file-document: Exercise 2: Plugin Bridge

**File:** `exercises/ex02_plugin_bridge.md`
**Duration:** 20 min
**Objective:** Import plugins from Gemini CLI, enable/disable selectively, validate a custom plugin.

</div>

---

## Back to Workshop

→ **[Module 1: SDLC Productivity](sdlc-productivity.md)** — plugins are introduced in Section 1.7

→ **[Cheatsheet](cheatsheet.md)** — all plugin commands in one place
