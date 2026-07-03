# Contributing to Antigravity CLI Field Workshop

Thanks for your interest in improving this workshop! Every contribution — from typo fixes to new exercises — helps enterprise developers get up and running with Antigravity CLI faster.

## Getting Started with AGY CLI

This repo is built to be navigated with `agy` itself. Before contributing, let AGY CLI read the project context:

```bash
# Clone and enter the repo
git clone https://github.com/carlosmscabral/agy-cli-field-workshop.git
cd agy-cli-field-workshop

# Start AGY CLI — it auto-reads AGENTS.md for project context
agy
```

### Key Context Files

| File | Purpose | How AGY CLI uses it |
| :-- | :-- | :-- |
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

# "I want to validate migration guide accuracy"
agy "Run the migration-validator agent against the migration guide examples"
```

## How to Contribute

### Report Issues or Share Feedback

Use [GitHub Issues](https://github.com/carlosmscabral/agy-cli-field-workshop/issues/new/choose) to:

| Template | When to use |
| :-- | :-- |
| **Bug Report** | Setup fails, broken links, incorrect commands, stale `gemini` references |
| **Content Improvement** | Suggest new exercises, better explanations, additional use cases |
| **Workshop Feedback** | Share your experience after attending a session |

All issues are automatically triaged with type, area, and priority labels.

### Submit Changes

1. **Fork** the repository
2. **Create a branch** from `main` (`git checkout -b fix/broken-command-m02`)
3. **Make your changes** — see [Content Guidelines](#content-guidelines) below
4. **Run quality checks locally** (see [Quality Checklist](#quality-checklist)):

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

---

## Quality Checklist

> See [`AGENTS.md`](AGENTS.md) for the machine-readable version of these rules
> that AGY CLI loads automatically.

Run these before every commit:

```bash
# 1. Markdown lint
npx markdownlint-cli2 "docs/**/*.md" "README.md"

# 2. Code block syntax validation
bash scripts/validate-code-blocks.sh docs/
# Expected: ALL PASSED

# 3. MkDocs strict build (catches broken links, nav mismatches)
.venv/bin/mkdocs build --strict
# Expected: Documentation built in X.XXs (no warnings)

# 4. Full CI simulation
make test
```

### Common errors and how to fix them

| Error | Fix |
| :-- | :-- |
| `MD022` — no blank line above heading | Add blank line between `</div>` and `## Heading` |
| `MD040` — untagged code fence | Add language tag: `` ```text `` for prompts/output |
| `MD060` — table separator style | Run the table normalizer (see `AGENTS.md`) |
| `MD001` — heading level skipped | Don't jump from `##` to `####` — use `###` |
| Code block: Invalid bash syntax | Prompt text tagged as `bash` — retag as `` ```text `` |
| Code block: Invalid YAML | YAML snippet with `${{ }}` (GH Actions template) — retag as `` ```text `` |
| MkDocs warning: link not found | Check the relative link path and that the target page is in `mkdocs.yml` nav |

## Code of Conduct

Be respectful and constructive. This is a learning resource — we welcome contributors of all experience levels.

## Questions?

For questions that aren't bugs or feature requests, open a **Bug Report** issue and select "Other" as the area.
