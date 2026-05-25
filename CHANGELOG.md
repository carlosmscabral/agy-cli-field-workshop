# Changelog

Content-specific changes to workshop materials — CLI breakages, deprecated commands, and doc corrections. For general repo changes see the commit history.

---

## 2026-05-25

### ✅ M09 — Migration Guide Added (Gemini CLI → AGY CLI)

**Affects:** All modules (cross-cutting), new M09 module, `mkdocs.yml` nav

The workshop now includes a dedicated migration guide for participants moving from Gemini CLI to Antigravity CLI.

**What was added:**
- `docs/migration-guide.md` — Full M09 module covering installation, plugin migration, MCP config migration, hook event name changes, and a decision framework
- Korean, Chinese (Simplified), and Indonesian translations via `gemini-3.1-pro-preview` on Vertex AI (`gpu-launchpad-playground/global`)
- `mkdocs.yml` nav updated with `⚠️ Migration Guide: Gemini CLI → AGY CLI` under Resources
- Glossaries updated with AGY migration terminology (all three languages)

**Key migration differences documented:**
- `gemini` binary → `agy`
- `SessionStart` → `PreInvocation`, `BeforeTool` → `PreToolUse`, `AfterTool` → `PostToolUse`
- `settings.json` MCP block → standalone `mcp.json` with `serverUrl` (not `url`)
- `.gemini/` project dir → `.agents/` project dir
- `GEMINI.md` → `AGENTS.md`

---

### ✅ Workshop Quality Infrastructure Added

**Affects:** CI, scripts, samples, contributing workflow

Ported and AGY-adapted quality infrastructure from the gemini-cli-field-workshop reference:

**New files:**
- `scripts/validate-code-blocks.sh` — Validates JSON/YAML/bash code blocks in docs
- `scripts/detect-drift.sh` — Detects doc↔code drift, stale `gemini` binary refs, and stale Gemini CLI hook names
- `.github/workflows/workshop-structural.yml` — PR quality gate with AGY-specific checks
- `.github/ISSUE_TEMPLATE/bug_report.yml` — Bug report template
- `.github/ISSUE_TEMPLATE/content_improvement.yml` — Improvement suggestion template
- `.github/ISSUE_TEMPLATE/workshop_feedback.yml` — Post-session feedback template (includes migration context field)
- `CONTRIBUTING.md` — Full contributor guide with AGY-specific content guidelines

**New sample files:**
- `samples/configs/settings.json` — AGY settings with PreInvocation/PreToolUse/PostToolUse hooks
- `samples/configs/mcp.json` — Project MCP config (stdio + SSE, `serverUrl` format)
- `samples/configs/mcp_config.json` — Plugin-level MCP config
- `samples/agents/pr-reviewer.md` — Code review subagent
- `samples/agents/doc-writer.md` — Documentation generation subagent
- `samples/agents/security-scanner.md` — Security audit subagent
- `samples/agents/migration-validator.md` — AGY-specific migration validation subagent
- `samples/hooks/session-context.sh` — PreInvocation hook
- `samples/hooks/secret-scanner.sh` — PreToolUse hook
- `samples/hooks/git-context-injector.sh` — PreToolUse hook
- `samples/hooks/test-nudge.sh` — PostToolUse hook

---

## Unreleased

### Placeholders (pending post-Google I/O clarity)

| File | Section | Placeholder |
|---|---|---|
| `docs/setup.md` | Step 2: Authentication | Full auth flow documentation |
| `docs/plugin-ecosystem.md` | Section 2.3 | Plugin marketplace URL |
