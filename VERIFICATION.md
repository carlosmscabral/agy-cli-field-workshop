# Verification Playbook

> **Purpose:** How to refresh and maintain the workshop's ground truth against official Antigravity CLI documentation.

---

## Overview

The workshop's accuracy depends on a **grounded audit trail** in [`AUDIT.md`](AUDIT.md). Every factual claim in the workshop docs maps to a specific source and evidence marker (e.g., `uid 5_209` from the Chrome DevTools accessibility tree). This playbook explains how to keep that audit current.

## Architecture

```text
┌────────────────────────┐
│  antigravity.google/*  │  ← Official docs (Angular SPA)
│  agy --help (live)     │  ← CLI binary
│  Google Developers Blog│  ← Announcements
└──────────┬─────────────┘
           │ (manual refresh)
           ▼
┌────────────────────────┐
│     AUDIT.md           │  ← Verified ground truth
│  90+ grounded claims   │     with source URLs + uid refs
└──────────┬─────────────┘
           │ (automated)
           ▼
┌────────────────────────┐
│  detect-drift.sh       │  ← Drift detection
│  --upstream flag        │     validates docs against AUDIT.md
└──────────┬─────────────┘
           │
           ▼
┌────────────────────────┐
│  Workshop docs (docs/) │  ← What attendees read
└────────────────────────┘
```

## When to Refresh

| Trigger | Action |
| :-- | :-- |
| New AGY CLI release | Run the full refresh procedure below |
| `detect-drift.sh --upstream` warns about stale AUDIT.md (>30 days) | Run the full refresh procedure |
| New workshop module added | Add claims + sources to AUDIT.md for new content |
| Upstream URL returns non-200 | Check if docs moved; update URLs in AUDIT.md |

## Refresh Procedure

### Step 1: Capture the Live Binary

```bash
# Record current CLI help output
agy --help > tmp/agy-help-$(date +%Y-%m-%d).txt

# Record version
agy --version >> tmp/agy-help-$(date +%Y-%m-%d).txt
```

Compare against the flags documented in AUDIT.md Section 2 ("CLI Flags"). Add any new flags, remove any deprecated ones.

### Step 2: Capture Official Documentation

The official docs at `antigravity.google` are an **Angular SPA** — `curl` only fetches the loader shell. You must use a browser-based tool to capture rendered content.

#### Option A: Chrome DevTools MCP (recommended)

```text
# In an agy session with Chrome DevTools MCP configured:
1. Navigate to each doc page (see AUDIT.md "Official Documentation Index")
2. Take an accessibility snapshot (captures all rendered text as uid nodes)
3. Compare uid-referenced claims in AUDIT.md against current snapshot
4. Update any changed claims with new uid references
```

#### Option B: Manual browser inspection

```text
1. Open each URL from AUDIT.md "Official Documentation Index" in Chrome
2. Use DevTools (F12) → Accessibility tab to inspect the rendered tree
3. Cross-reference each AUDIT.md claim against the current page content
4. Screenshot any changed sections for the audit trail
```

### Step 3: Update AUDIT.md

1. Update the `Audit date:` field in the frontmatter
2. For each changed claim:
   - Update the "Official Source" column with the new uid or evidence
   - If a feature was removed, mark the claim with ~~strikethrough~~ and note the removal
   - If a feature was added, add a new row with full source attribution
3. Update the summary count at the bottom

### Step 4: Update Workshop Docs

For any claims that changed in AUDIT.md:

1. Find the corresponding content in `docs/*.md`
2. Update the workshop text to match the new ground truth
3. Run `make precommit` to validate

### Step 5: Validate

```bash
# Run upstream drift check (validates docs against updated AUDIT.md)
bash scripts/detect-drift.sh --upstream

# Run full pre-commit suite
make precommit

# If translations exist, regenerate affected languages
make translate-all
```

## Drift Detection Details

The `--upstream` flag on `detect-drift.sh` performs these checks:

| Check | What it does |
| :-- | :-- |
| CLI flags vs AUDIT.md | Every `agy --flag` in docs must appear in AUDIT.md |
| Slash commands vs AUDIT.md | Every `/command` in docs must appear in AUDIT.md |
| Source URL reachability | Every `antigravity.google` URL in AUDIT.md must return HTTP 200 |
| AUDIT.md freshness | Warns at 30 days, errors at 90 days since last audit date |

## Official Documentation Index

These are the canonical source pages. Keep this list in sync with AUDIT.md Section "Official Documentation Index":

| Page | URL |
| :-- | :-- |
| CLI Overview | <https://antigravity.google/docs/cli-overview> |
| Getting Started | <https://antigravity.google/docs/cli-getting-started> |
| Using Antigravity CLI | <https://antigravity.google/docs/cli-using> |
| Features | <https://antigravity.google/docs/cli-features> |
| Migration from Gemini CLI | <https://antigravity.google/docs/gcli-migration> |
| Permissions | <https://antigravity.google/docs/permissions> |
| Strict Mode | <https://antigravity.google/docs/strict-mode> |
| Plugins | <https://antigravity.google/docs/plugins> |
| MCP | <https://antigravity.google/docs/mcp> |
| Skills | <https://antigravity.google/docs/skills> |
| Rules & Workflows | <https://antigravity.google/docs/rules-workflows> |
| Hooks | <https://antigravity.google/docs/hooks> |
| Subagents | <https://antigravity.google/docs/subagents> |
| Enterprise | <https://antigravity.google/docs/enterprise> |
