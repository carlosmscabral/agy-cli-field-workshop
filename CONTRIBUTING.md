# Contributing to AGY CLI Field Workshop

Thanks for your interest in improving this workshop! Every contribution — from typo fixes to new exercises — helps enterprise developers get up and running with Antigravity CLI faster.

## Getting Started with AGY CLI

This repo is built to be navigated with `agy` itself. Before contributing, let AGY CLI read the project context:

```bash
# Clone and enter the repo
git clone https://github.com/pauldatta/agy-cli-field-workshop.git
cd agy-cli-field-workshop

# Start AGY CLI — it auto-reads AGENTS.md for project context
agy
```

### Key Context Files

| File | Purpose | How AGY CLI uses it |
|---|---|---|
| `AGENTS.md` | Project rules, testing infrastructure, quality standards | Auto-loaded on every session |
| `AUDIT.md` | Claims-based audit table grounded against live `agy` binary | Ask: `Read AUDIT.md and check if any ⚠️ claims have been resolved` |
| `samples/agents/*.md` | Subagent definitions for code review, docs, migration validation | Reference when building new agents |
| `samples/hooks/*.sh` | Hook scripts for PreInvocation/PreToolUse/PostToolUse | Reference when teaching hooks module |

### Example Contributor Workflows

```bash
# "I want to fix a broken code example"
# AGY CLI already knows the project from AGENTS.md
agy "Find all bash code blocks in docs/devops-automation.md and check if they're syntactically valid"

# "I want to check if new agy CLI flags need to be documented"
agy "Read AUDIT.md and check which ⚠️ claims could now be verified with agy --help"

# "I want to add a new language translation"
# Launch a research subagent to check what's already translated
agy "What docs exist under docs/ko/ and what's missing compared to docs/?"

# "I want to validate migration guide accuracy"
agy "Run the migration-validator agent against the migration guide examples"
```

## How to Contribute

### Report Issues or Share Feedback

Use [GitHub Issues](https://github.com/pauldatta/agy-cli-field-workshop/issues/new/choose) to:

| Template | When to use |
|:---------|:------------|
| **Bug Report** | Setup fails, broken links, incorrect commands, stale `gemini` references |
| **Content Improvement** | Suggest new exercises, better explanations, additional use cases |
| **Workshop Feedback** | Share your experience after attending a session |

All issues are automatically triaged with type, area, and priority labels.

### Submit Changes

1. **Fork** the repository
2. **Create a branch** from `main` (`git checkout -b fix/broken-command-m02`)
3. **Make your changes** — see [Content Guidelines](#content-guidelines) below
4. **Test locally**:
   ```bash
   make test          # Structure, code blocks, drift (~5s)
   make serve         # Preview the MkDocs site
   ```
5. **Submit a PR** — reference any related issue numbers

### Content Guidelines

- **Voice:** Instructional, concise, encouraging. Write for enterprise developers who may be new to AI-assisted coding.
- **Code samples:** Must be copy-pasteable and tested. Use fenced code blocks with language tags (`bash`, `json`, `yaml`).
- **Binary:** Always use `agy` — never `gemini`. If documenting the migration from Gemini CLI, make the context explicit.
- **Hook event names:** Use AGY CLI names exclusively:
  - `PreInvocation` (not `SessionStart`)
  - `PreToolUse` (not `BeforeTool`)
  - `PostToolUse` (not `AfterTool`)
- **Tool names:** AGY uses `edit` (not `replace_in_file`), `write_file`, `read_file`, `glob`, `grep_search`.
- **Models:** Use `gemini-3.1-flash-lite-preview` or `gemini-3-flash-preview` for cost-efficient agents. Use `gemini-3.1-pro-preview` for orchestrators and heavy reasoning. Never reference deprecated models (`gemini-1.5-flash`, `gemini-1.5-pro`).
- **Config paths:** AGY uses `~/.gemini/antigravity-cli/settings.json` and project-level `.agents/` (not `.gemini/`).
- **MCP config:** AGY uses `serverUrl` (not `url`); SSE and stdio types; `mcp.json` at project root.
- **Module structure:** Each use case follows: context → demo → hands-on exercise → recap.
- **Grounding:** All technical claims must be verifiable against the live `agy` binary (`agy --help`, `agy plugin help`) or official docs at `antigravity.google/docs`. See [`AUDIT.md`](AUDIT.md) for the full claims table.

### Translations (i18n)

The workshop supports multiple languages via an automated Gemini-powered pipeline:

| Language | Code | Status |
|---|---|---|
| English | `en` | Source of truth |
| Korean | `ko` | Active |
| Indonesian | `id` | Active |
| Chinese (Simplified) | `zh` | Active |

**If you change English source files:**
- Note in your PR which docs changed — translation owners will regenerate
- Never edit `docs/{lang}/*.md` directly — these are generated files
- Translation owners run (from the `gemini-cli-field-workshop` shared pipeline):
  ```bash
  GOOGLE_CLOUD_PROJECT=gpu-launchpad-playground GOOGLE_CLOUD_LOCATION=global \
    python tools/i18n/translate.py docs/<filename>.md --lang ko --model gemini-3.1-pro-preview
  ```

**To add a new language:** Open a Content Improvement issue first to discuss glossary coverage.

## Code of Conduct

Be respectful and constructive. This is a learning resource — we welcome contributors of all experience levels.

## Questions?

For questions that aren't bugs or feature requests, open a **Bug Report** issue and select "Other" as the area.
