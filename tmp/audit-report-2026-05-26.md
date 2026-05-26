# Workshop Quality Audit Report — 2026-05-26

**Date:** May 26, 2026  
**Auditor:** Antigravity Agent  
**Target Repository:** `agy-cli-field-workshop`

---

## 📊 Quality Dashboard

| ID | Test Name | Status | Notes |
| :-- | :-- | :-- | :-- |
| **T-01** | Markdown Lint — English | ✅ PASSED | Checked `docs/*.md` and root markdown files (0 errors). |
| **T-02** | Markdown Lint — Translated | ✅ PASSED | Verified all translated markdown files (0 errors). |
| **T-03** | Code Block Validation | ✅ PASSED | Checked all code block language tags. |
| **T-04** | MkDocs Strict Build | ⚠️ PASSED WITH WARNINGS | Build succeeded, but contains minor link anchor warnings. |
| **T-05** | Required Files | ✅ PASSED | All core files exist. |
| **T-06** | JSON Config Syntax | ✅ PASSED | All json config syntax is valid. |
| **T-07** | Shell Script Syntax | ✅ PASSED | Checked shell syntax for scripts in `scripts/` and `samples/hooks/`. |
| **T-08** | Agent Frontmatter | ✅ PASSED | Frontmatter validated for all agents in `samples/agents/`. |
| **T-09** | Stale Binary References | ✅ PASSED | No bare `gemini` command invocations found in docs. |
| **T-10** | Stale Hook Event Names | ✅ PASSED | Verified use of AGY event names (`PreInvocation`, etc.). |
| **T-11** | Drift Detection | ✅ PASSED | Local drift checks completed with 0 errors (7 warnings). |
| **T-12** | Translation Coverage | ⚠️ ADVISORY GAP | `assets` and `exercises` are incorrectly marked as missing languages. |
| **T-13** | Translation Drift | ⚠️ STALE TRANSLATIONS | 21 translated files are stale relative to English source updates. |
| **T-14** | Live Smoke Test | 🔧 LOCAL ONLY | Requires local GCP credentials (`GOOGLE_CLOUD_PROJECT`). |

---

## 🔍 Detailed Findings

### 1. Link Anchor Discrepancy (Test T-04)
During `.venv/bin/mkdocs build --strict`, the build succeeded, but logs recorded a broken link anchor warning:
> Doc file `plugin-ecosystem.md` contains a link `sdlc-productivity.md#17-extend-with-plugins`, but the doc `sdlc-productivity.md` does not contain an anchor `#17-extend-with-plugins`.

* **Root Cause:** In `sdlc-productivity.md`, the heading is `## 1.7 — Extend with Plugins <span class="duration-badge">15 min</span>`. Python-Markdown's `toc` extension slugifies this as `#17-extend-with-plugins-15-min`. Because `plugin-ecosystem.md` links to `#17-extend-with-plugins` (omitting the `-15-min` suffix), it resolves to a dead anchor.
* **Resolution:** Modify `docs/plugin-ecosystem.md` to point to `#17-extend-with-plugins-15-min` (and then regenerate translations).

### 2. Local Drift Warnings (Test T-11)
`make test-drift` ran successfully with 0 errors, but generated 7 warnings for unreferenced assets:
* **Unreferenced Agents:** `doc-writer`, `migration-validator`, and `pr-reviewer` exist in `samples/agents/` but are not referenced in the documentation.
* **Unreferenced Hooks:** `git-context-injector`, `secret-scanner`, `session-context`, and `test-nudge` exist in `samples/hooks/` but are not referenced in the documentation.

### 3. Translation Drift & Coverage (Tests T-12, T-13)
* **Coverage False Positives:** The coverage check flags `assets` and `exercises` as "missing languages" because the check script simply scans directories under `docs/`.
* **Out-of-Date Translations:** There are **21 stale translated files** across the Spanish (`id` - Bahasa Indonesia), Korean (`ko`), and Chinese (`zh`) subdirectories, indicating updates to English documentation that have not yet been translated.

### 4. Upstream Drift Check Behavior
When running the upstream drift check (`bash scripts/detect-drift.sh --upstream`), it reports 21 warnings indicating that many CLI flags (e.g. `--add-dir`, `--sandbox`) and slash commands (e.g. `/model`, `/agents`) were "not found" in the upstream reference.
* **Root Cause:** The script downloads the upstream documentation using `curl` against `https://antigravity.google/docs/cli-overview`. However, `antigravity.google` is an Angular SPA. Raw `curl` only fetches the initial loader shell and does not execute the JavaScript needed to render the documentation pages.
* **Correction:** To perform this validation accurately, a browser-based tool like Chrome DevTools MCP is required to let the SPA render before searching the DOM.

---

## 🛠️ Recommended Action Items

1. **Fix Broken Anchor Link:**
   Update the link on line 3 of `docs/plugin-ecosystem.md` to:
   `[Module 1 — Section 1.7](sdlc-productivity.md#17-extend-with-plugins-15-min)`
2. **Refresh Translations:**
   Once the GCP credentials (`GOOGLE_CLOUD_PROJECT`) are configured, run:
   `make translate-all`
3. **Update Translation Check Script:**
   Improve `check-translations` in the `Makefile` to filter directories, avoiding `assets` and `exercises` false positives:
   ```diff
   - LANGS=$(find docs -mindepth 1 -maxdepth 1 -type d 2>/dev/null | xargs -I{} basename {} | sort);
   + LANGS=$(find docs -mindepth 1 -maxdepth 1 -type d | xargs -I{} basename {} | grep -E '^[a-z]{2}(-[A-Z]{2})?$' | sort);
   ```
