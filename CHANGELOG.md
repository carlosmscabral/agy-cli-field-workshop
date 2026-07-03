# Changelog

Content-specific changes to workshop materials — CLI breakages, deprecated commands, and doc corrections. For general repo changes see the commit history.

---

## 2026-07-03

### 🚑 Workshop Audit & Remediation

**Affects:** all modules, both setup tracks, exercises, samples, scripts, CI, nav

Full correctness/completeness audit against the live `agy` v1.0.16 and `agents-cli` v0.1.3 binaries and the in-repo grounding. Key fixes:

**Blocking**

- **Created the missing sandbox repo.** `github.com/carlosmscabral/agy-sample-app` did not exist (404) yet all of Module 1 and both setup tracks cloned/`cd`'d into it — the workshop was un-startable. Published a real FastAPI subscription-billing sample and wired `bootstrap-enterprise.sh` into setup.
- **Enterprise Vertex auth.** `GOOGLE_GENAI_USE_VERTEXAI=True` was set nowhere → the SDK/ADK silently fell back to AI-Studio mode. Added the canonical `gcloud auth application-default login` + `GOOGLE_CLOUD_PROJECT`/`GOOGLE_CLOUD_LOCATION`/`GOOGLE_GENAI_USE_VERTEXAI=True` block to both tracks, ex10, and the bootstrap script; documented the `agy` CLI enterprise sign-in for corporate workstations.
- **IAM least-privilege corrected** in `setup-enterprise-admin.md`: `storage.objectViewer`→`storage.admin` (source-deploy staging), `run.developer`→`run.admin` (for `--allow-unauthenticated`), added `cloudbuild.builds.editor`, granted the runtime service account `aiplatform.user`; added BigQuery/Dataplex roles + APIs for the optional ex14; consolidated the API-enable list.
- **ex09 prompt was refused by the model.** Its "scan for vulnerabilities/secrets" phrasing is declined by `agy`; reframed as a constructive maintainability/hardening review (surfaces the same issues) and added a note on prompt framing.

**Correctness**

- **ex10 / agents-cli.md eval** used non-existent `eval generate|grade|dataset synthesize|analyze`; rewritten to the real `eval run` + `eval compare` and pinned to agents-cli 0.1.3.
- **ex11** rewritten from the fictional `agentapi`/`sidecar.json` scheme to the real SDK **triggers** API (`every()`, `on_file_change()`).
- ex13 broken setup (`mkdir -p scripts`), ex12 missing `mkdir -p`, `agy` version `2.0.4`→`1.0.16`, cheatsheet `--model` (is a real flag), `/diff`→`!git diff`, MCP config filename standardized to `mcp_config.json`, permissions/hooks config schema canonicalized, PowerShell verifier `Join-Path` bug, verifier model IDs, leaked `PROJECT_ID="vibe-cabral"`, firewall typo `*.g_service_account_com`.

**New coverage (was missing)**

- **Artifacts** — the flagship AGY differentiator (Implementation Plan / Task List / Walkthrough, `/artifact`, `/plan` planning mode, `ctrl+r` review panel, inline-comment co-steering): new **Exercise 15**, a concept section in Module 1, cheatsheet + grounding entries.
- **MCP fundamentals** — new **Exercise 16** (connect `agy` to tools via `.agents/mcp_config.json` + `/mcp`), promoted into Module 1.

**Restructure** — 4-module order with the SDK moved to the advanced capstone:

1. Antigravity CLI Fundamentals · 2. Legacy Modernization & Advanced CLI · 3. ADK with agents-cli · 4. Advanced: Antigravity SDK. Nav, index, module headers, `Next` links, and the facilitator guide rewired accordingly.

**Infra** — removed dead i18n plumbing (Makefile pipeline, translation targets, `mkdocs-static-i18n`); made `validate-code-blocks.sh`/`detect-drift.sh` recurse into `docs/exercises/` (previously unvalidated); removed the drifting duplicate top-level `exercises/` tree; consolidated markdownlint config; fixed `install-deps`/`.venv`; README exercise count.

---

## 2026-06-09

### ✅ Exercise 12 — Eval Judge Model & Standalone Lab Guide

**Affects:** ex12, translations (ko, zh, id)

- Renamed "Vertex AI Eval Service" → "GenAI Evaluation Service" (Agent Platform branding)
- Clarified judge model config: built-in metrics use server-side autorater; custom metrics require fully-qualified resource paths
- Added standalone 90 min lab guide (`exercises/ex12_lab_guide_gdoc.md`, gitignored)
- Re-synced ko, zh, id translations

---

## 2026-06-07

### ✅ Module 5 Added — ADK Agents with agents-cli

**Affects:** All navigation (mkdocs.yml, README, facilitator guide, index), new module + exercise

The workshop is now a **5-module, ~7-hour curriculum**. Module 5 teaches the `agents-cli` lifecycle for building production ADK agents.

**New files:**

- `docs/agents-cli.md` — Module 5: Building ADK Agents with agents-cli (75 min)
- `exercises/ex12_agents_cli_lifecycle.md` — Exercise 12: Meeting Notes Summarizer agent (scaffold → build → eval → deploy)
- `docs/assets/agents-cli-hero.png` — Module 5 hero image (Nano Banana Pro 2)
- `docs/assets/banner.png` — Updated workshop banner with 5 modules (Nano Banana Pro 2)
- `docs/ko/agents-cli.md` — Korean translation
- `docs/zh/agents-cli.md` — Chinese (Simplified) translation
- `docs/id/agents-cli.md` — Indonesian translation

**Modified files:**

- `mkdocs.yml` — Added Module 5 and Exercise 12 to nav
- `README.md` — Updated to 5-module structure, fixed repo structure map, fixed delivery durations
- `docs/facilitator-guide.md` — Updated to 5-module, added Module 5 delivery notes, fixed Module 3 SDK references (`google-antigravity` not `google-adk`, removed `SequentialAgent`/`BaseAgent`)
- `docs/index.md` — Added Module 5 card, updated timeline, fixed Module 3 description

### ✅ Audit Remediation (audit-report-2026-06-07)

**Affects:** ex12, facilitator-guide, README

Fixed all critical and medium findings from the June 7 quality audit:

- **ex12 import mismatch** — Added `uv sync` step and note explaining `google-adk` ≠ `google-antigravity`
- **Facilitator guide Module 3** — Corrected SDK references, removed nonexistent `SequentialAgent`/`BaseAgent` classes
- **Duration contradictions** — Aligned delivery format tables across README, facilitator guide, and index
- **README repo structure** — Updated to reflect actual file layout (12 exercises, correct module mapping)

### 🧹 Cleanup

- Removed `tmp/` from git tracking (was accidentally committed)
- Added `tmp/` and `nanobanana-output/` to `.gitignore`

---

## 2026-05-25

### ✅ M09 — Migration Guide Added (Gemini CLI → AGY CLI)

**Affects:** All modules (cross-cutting), new M09 module, `mkdocs.yml` nav

The workshop now includes a dedicated migration guide for participants moving from Gemini CLI to Antigravity CLI.

**What was added:**

- `docs/migration-guide.md` — Full M09 module covering installation, plugin migration, MCP config migration, hook event name changes, and a decision framework
- Korean, Chinese (Simplified), and Indonesian translations via `gemini-3.1-pro-preview` on Vertex AI
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
| :-- | :-- | :-- |
| `docs/setup.md` | Step 2: Authentication | Full auth flow documentation |
| `docs/plugin-ecosystem.md` | Section 2.3 | Plugin marketplace URL |
