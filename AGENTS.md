# AGENTS.md — AGY CLI Field Workshop

This file is auto-loaded by `agy` on every session. It defines the quality
contract for this repository. **Follow every rule here before committing.**

---

## Project Overview

- **What:** Antigravity CLI Field Workshop — MkDocs site with exercises and
  SDK documentation for enterprise teams adopting `agy` CLI and
  `google-antigravity` Python SDK.
- **Languages:** English source in `docs/*.md`. Translations in
  `docs/{ko,zh,id}/*.md` (generated — do not hand-edit).
- **SDK:** `google-antigravity` pip package (NOT `google-adk`). All SDK docs
  must reference `Agent`, `LocalAgentConfig`, `policy.*`, `hooks.*` — never
  `LlmAgent`, `SequentialAgent`, `FunctionTool`, or `adk web/run/deploy`.
- **Grounding:** `research/sdk-grounding.md` is the authoritative SDK reference.
  Verify every SDK code sample against it before committing.
- **⚠️ Exercises dual-copy:** `exercises/*.md` (repo root) and `docs/exercises/*.md`
  are **separate files, not symlinks**. MkDocs and the translation pipeline both
  read from `docs/exercises/`. Always edit `docs/exercises/` first, then copy back
  to `exercises/` if you want the standalone version in sync. Editing only
  `exercises/` will **not** update the site or translations.

---

## Mandatory Pre-Commit Checks

Run ALL of these locally before every commit. CI runs the same checks.

### 1 — Markdown Lint (zero tolerance)

```bash
# Check English source
npx markdownlint-cli2 "docs/*.md" "README.md"

# Check translated files
npx markdownlint-cli2 "docs/id/**/*.md" "docs/ko/**/*.md" "docs/zh/**/*.md"

# Auto-fix what markdownlint can fix automatically
npx markdownlint-cli2 --fix "docs/**/*.md"
```

**After auto-fix, always re-run the check** — some errors (MD022, MD001) require
manual correction.

### 2 — Table Separator Normalization

CI requires `| :-- |` style (space on both sides, left-align dash). After any
table edit or translation, normalize:

```bash
# Normalize all table separators in translated files
find docs/id docs/ko docs/zh -name "*.md" | while read f; do
  perl -i -pe '
    if (/^\|[-:| ]+\|$/) {
      s/\|\s*:?-+:?\s*/| :-- /g; s/ $//; s/\| :-- $/|/;
    }
  ' "$f"
done
```

### 3 — Code Block Validation

```bash
# Validates bash, yaml, json blocks for syntax correctness
bash scripts/validate-code-blocks.sh docs/

# Must output: ALL PASSED
```

**Rules for code block language tags:**

| Content type | Tag to use |
| :-- | :-- |
| Real shell commands (`gcloud`, `git`, `pip`) | `bash` |
| CLI prompts / user input (`> ask the agent to...`) | `text` |
| AGY CLI conversation turns | `text` |
| `agy plugin validate` output / terminal output | `text` |
| Config file snippets (settings.json, mcp.json) | `json` |
| Workflow definitions | `yaml` |
| Code samples | `python`, `go`, etc. |

**Never tag prompt text, markdown tables, or CLI output as `bash`** — the
validator will fail.

### 4 — MkDocs Strict Build

```bash
.venv/bin/mkdocs build --strict

# Must output: Documentation built in X.XXs (no warnings)
```

Common causes of failure:

- Broken relative links in translated files (e.g. `legacy-modernization.md`
  only exists at the English level — translated files must use `../legacy-modernization.md`)
- Missing blank line before first `##` heading after a `<div>` block (MD022)
- New pages added to `docs/` but not added to `mkdocs.yml` nav

### 5 — Full CI Simulation (run before any PR)

```bash
make test
```

This runs structure checks, JSON validation, shell syntax, agent frontmatter,
stale reference checks, mkdocs build, code block validation, and drift detection.

---

## Recurring Lint Patterns to Avoid

These are the errors that have repeatedly broken CI. Know them by heart.

### MD022 — Blank line required above headings

```markdown
<!-- WRONG — heading immediately after closing tag -->
</div>
## My Heading

<!-- CORRECT — blank line between -->
</div>

## My Heading
```

**This fires in translated files** when the translator removes the blank line.
Fix with:

```bash
perl -i -0pe 's/(\S)\n(##\s)/$1\n\n$2/g' docs/{id,ko,zh}/affected-file.md
```

### MD040 — All fenced code blocks must have a language tag

Use ` ```text ` for anything that isn't real code. Never leave a fence untagged.

````markdown
<!-- WRONG — no language tag -->
```
some content
```

<!-- CORRECT — always tag the fence -->
```
some content
```
```

### MD060 — Table separator style must be consistent

The `.markdownlint-cli2.yaml` enforces `compact` style with spaces.
Every separator row must look exactly like this:

```text
| :-- | :-- | :-- |
```

Not `|---|`, not `|:---|`, not `| --- |`. Run the table normalizer after
any table edit.

### MD001 — Heading levels must not skip

```markdown
<!-- WRONG -->
## Section
#### Subsection   ← skipped h3

<!-- CORRECT -->
## Section
### Subsection
```

---

## Translation Workflow

### Running Translations

```bash
export GOOGLE_CLOUD_PROJECT=<your-gcp-project>

# All files, all languages in parallel
make translate L=ko P=8 & make translate L=zh P=8 & make translate L=id P=8 & wait

# Single file retranslation (after changing one English doc)
make translate-file FILE=docs/agy-sdk.md L=ko P=8
```

### Post-Translation Lint Fix

**Always run these after translation** — the model sometimes drops blank lines:

```bash
# 1. Auto-fix what markdownlint can
npx markdownlint-cli2 --fix "docs/id/**/*.md" "docs/ko/**/*.md" "docs/zh/**/*.md"

# 2. Normalize table separators
find docs/id docs/ko docs/zh -name "*.md" | while read f; do
  perl -i -pe '
    if (/^\|[-:| ]+\|$/) {
      s/\|\s*:?-+:?\s*/| :-- /g; s/ $//; s/\| :-- $/|/;
    }
    s/^```\n$/```text\n/;
  ' "$f"
done

# 3. Fix MD022 blank-lines-around-headings (translator drops these)
find docs/id docs/ko docs/zh -name "*.md" | while read f; do
  perl -i -0pe 's/(\S)\n(##\s)/$1\n\n$2/g' "$f"
done

# 4. Verify clean
npx markdownlint-cli2 "docs/id/**/*.md" "docs/ko/**/*.md" "docs/zh/**/*.md"
```

### Never hand-edit translated files

`docs/{ko,zh,id}/*.md` are generated. If you need to fix content in a translated
file, fix the English source and re-run `make translate-file`.

---

## SDK Documentation Rules

All content in `docs/agy-sdk.md` and SDK exercises must comply with
`research/sdk-grounding.md`. Key rules:

| Rule | Correct | Forbidden |
| :-- | :-- | :-- |
| Package import | `from google.antigravity import Agent, LocalAgentConfig` | `from google.adk.agents import ...` |
| Install command | `pip install google-antigravity` | `pip install google-adk` |
| Agent class | `Agent(config)` where config is `LocalAgentConfig` | `LlmAgent`, `SequentialAgent`, `ParallelAgent` |
| Tool wrapping | Plain Python function in `tools=[fn]` | `FunctionTool(fn)` |
| State access | `ctx.get_state("key")` / `ctx.set_state("key", val)` | `tool_context.state["key"]` |
| Policy | `policy.allow_all()`, `policy.deny("tool")` | No policy configured |
| Ask user policy | `policy.ask_user("tool", handler=fn)` | `policy.ask_user("tool")` — `handler=` is required |
| Parallel agents | `asyncio.gather(agent1.chat(...), agent2.chat(...))` | `ParallelAgent(sub_agents=[...])` |
| Local testing | `asyncio.run(main())` | `adk web .` |
| Deployment | Standard Cloud Run (`gcloud run deploy`) | `adk deploy cloud_run` |

---

## Naming Conventions

- Models: `gemini-3.5-flash` (default), `gemini-3.1-pro-preview` (orchestrators)
- Never use: `gemini-1.5-flash`, `gemini-1.5-pro` (deprecated)
- Binary references: always `agy`, never bare `gemini` in command positions

---

## CI Pipeline Summary

`.github/workflows/workshop-structural.yml` runs on every push to `main`:

| Job | What it checks | Fix command |
| :-- | :-- | :-- |
| File Structure | Required files exist, JSON valid, shell syntax | — |
| Stale references | No bare `gemini` commands, no old hook names | Find/replace |
| MkDocs nav | `mkdocs build --strict` — no broken links or warnings | Fix links, add to nav |
| Code Block Validation | `bash scripts/validate-code-blocks.sh docs/` | Retag prompt/output blocks as `text` |
| Drift Detection | `bash scripts/detect-drift.sh` | Update docs to match binary |
| Markdown Lint | `npx markdownlint-cli2 "docs/**/*.md" "README.md"` | See rules above |
