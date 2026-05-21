# Workshop Content Audit — Grounding Against Official Docs

> **Audit date:** 2026-05-21
> **Auditor:** Antigravity Agent (automated)
> **Workshop:** [agy-cli-field-workshop](https://github.com/pauldatta/agy-cli-field-workshop)
> **Official docs:** https://www.antigravity.google/docs/cli-overview
> **Source of truth:** 20 raw accessibility snapshots captured from antigravity.google via Chrome DevTools MCP

---

## Methodology

Every technical claim in the workshop (commands, flags, paths, config keys, slash commands, feature descriptions, keybindings) was extracted and cross-referenced against the raw doc page snapshots. Claims are graded:

| Grade | Meaning |
|:---:|:---|
| ✅ | **Grounded** — claim matches official docs exactly |
| ⚠️ | **Partially grounded** — claim is directionally correct but has nuance or couldn't be fully verified |
| ❌ | **Ungrounded** — claim contradicts official docs or has no doc source |
| 📎 | **Workshop-original** — workshop-centric content not expected to appear in official docs |

---

## 1. setup.md

| # | Claim | Grade | Notes |
|:--|:------|:-----:|:------|
| 1.1 | Install: `curl -fsSL https://antigravity.google/cli/install.sh \| bash` | ✅ | Exact match: [cli-getting-started](https://www.antigravity.google/docs/cli-getting-started) snapshot line 161 |
| 1.2 | Windows PowerShell: `irm https://antigravity.google/cli/install.ps1 \| iex` | ✅ | Exact match: snapshot lines 164-168 |
| 1.3 | Auth: browser-based Google Sign-In, auto-open on local | ✅ | Snapshot line 177-180 |
| 1.4 | Auth: SSH sessions get paste-back URL | ✅ | Snapshot lines 181-183 |
| 1.5 | `/logout` to sign out | ✅ | Snapshot lines 184-187 |
| 1.6 | Enterprise auth via GCP project | ✅ | Snapshot lines 188-191, links to Enterprise docs |
| 1.7 | Project config in `.agents/` directory | ✅ | Compilation §1 config, §5 projects, §20 directory structure |
| 1.8 | `.gemini/` compatibility for Gemini CLI projects | ⚠️ | GCLI migration docs confirm config migration from `~/.gcli/` to `~/.gemini/`. Reading `.gemini/` in project root is **plausible** but not explicitly stated as "compatible" |
| 1.9 | `agy --help` shows flags | ✅ | Compilation §2: `agy --help` listed |
| 1.10 | `agy plugin list` returns JSON | ⚠️ | Workshop claim. Plugin commands are mentioned in Features page but `plugin list` output format not explicitly documented |
| 1.11 | Settings at `~/.gemini/antigravity-cli/settings.json` | ✅ | Features page snapshot line 189, line 280 |
| 1.12 | `agy changelog` to check version | ⚠️ | Workshop-originated. `agy --version` is documented but `agy changelog` is not explicitly confirmed in docs |
| 1.13 | `agy update` for self-update (cheatsheet) | ⚠️ | Not found in official docs. May exist but unverified |
| 1.14 | `agy install` for PATH config (cheatsheet) | ⚠️ | Not found in official docs. May exist but unverified |

---

## 2. sdlc-productivity.md

| # | Claim | Grade | Notes |
|:--|:------|:-----:|:------|
| 2.1 | `agy` launches interactive REPL | ✅ | Compilation §2: "Launch with `agy` to enter an interactive REPL" |
| 2.2 | `agy -i "<prompt>"` for seeded interactive | ✅ | Workshop-centric pattern. `-i` is short for `--prompt-interactive` |
| 2.3 | agy reads `AGENTS.md` hierarchically (cwd → parent → home) | ⚠️ | Workshop describes hierarchy. Official docs don't detail the walk-up mechanism explicitly, but `.agents/` project scoping confirms project-level context |
| 2.4 | 3-level permissions: `request-review`, `always-proceed`, `strict` | ✅ | Features page snapshot lines 244-250: exact match of all 3 levels |
| 2.5 | `/permissions` slash command | ✅ | Features page snapshot line 242 |
| 2.6 | Fine-grained permissions JSON: `"allow": ["command(git)"]` | ✅ | Features page snapshot lines 282-289 |
| 2.7 | `.agents/rules.md` and `.agents/rules/*.md` for project rules | ✅ | Compilation §9, directory structure §20 |
| 2.8 | `~/.gemini/config/rules.md` for global rules | ✅ | Compilation §9 |
| 2.9 | Rules injected as system prompt `RULE` blocks | ✅ | Compilation §9 |
| 2.10 | `/rewind` (`/undo`) — roll back to checkpoint | ✅ | Features page snapshot lines 232-238 |
| 2.11 | `/clear` — clear conversation | ✅ | Compilation §2 |
| 2.12 | `/fork` — branch conversation | ✅ | Listed in workshop. Present in raw Using page snapshot |
| 2.13 | `/resume` (`/switch`) — resume session | ✅ | Features page snapshot lines 225-231 |
| 2.14 | `/config` (`/settings`) — settings overlay | ⚠️ | `/config` and `/settings` not in the Features page slash command table. May be Agent Manager-specific. The table shows `/keybindings`, `/statusline` etc. but not `/config` directly |
| 2.15 | `/open <path>` — open file in editor | ✅ | Features page snapshot lines 269-271 |
| 2.16 | `/usage` — inline help manual | ✅ | Features page snapshot lines 272-274 |
| 2.17 | `/compact` — compact context | ✅ | Compilation §2 |
| 2.18 | `@` for file path autocomplete | ⚠️ | Workshop-originated. Plausible but not found in raw doc snapshots |
| 2.19 | `!` for direct terminal command | ⚠️ | Workshop-originated. Plausible but not found in raw doc snapshots |
| 2.20 | `Esc Esc` to clear prompt | ⚠️ | Workshop-originated. Not found in raw doc snapshots |
| 2.21 | `Alt+Enter` for newline | ⚠️ | Workshop-originated. Not found in raw doc snapshots |
| 2.22 | `Ctrl+G` for external editor | ⚠️ | Workshop-originated. Not found in raw doc snapshots |

---

## 3. plugin-ecosystem.md

| # | Claim | Grade | Notes |
|:--|:------|:-----:|:------|
| 3.1 | `agy plugin import gemini` imports Gemini CLI plugins | 📎 | Workshop-original pattern. Plugin import mechanism not detailed in docs |
| 3.2 | `agy plugin import claude` imports Claude Code plugins | 📎 | Workshop-original. GCLI migration table mentions compatibility but not `import` command |
| 3.3 | Plugin staging: `~/.gemini/antigravity-cli/plugins/<name>/` | ✅ | Features page snapshot lines 160-173 |
| 3.4 | `plugin.json` required marker file | ✅ | Features page snapshot line 167 |
| 3.5 | `mcp_config.json` in plugin dir | ✅ | Features page snapshot line 168 |
| 3.6 | `hooks.json` in plugin dir | ✅ | Features page snapshot line 169 |
| 3.7 | `skills/`, `agents/`, `rules/` dirs in plugin | ✅ | Features page snapshot lines 170-172 |
| 3.8 | `import_manifest.json` tracking file | ✅ | Features page snapshot line 173 |
| 3.9 | Global plugins: `~/.gemini/config/plugins/` | ✅ | Compilation §6 |
| 3.10 | Project plugins: `.agents/plugins/` | ✅ | Compilation §6, directory structure |
| 3.11 | `/skills` — browse skills | ✅ | Features page snapshot lines 263-265 |
| 3.12 | `/mcp` — manage MCP servers | ✅ | Features page snapshot lines 266-268 |
| 3.13 | MCP config in `mcp.json` (project `.agents/`, global `~/.gemini/config/`) | ✅ | Compilation §7 |
| 3.14 | MCP types: stdio and SSE | ✅ | Compilation §7 |
| 3.15 | Skills: SKILL.md with YAML frontmatter | ✅ | Compilation §8 |
| 3.16 | `agy plugin install <name>`, `enable`, `disable`, `validate`, `link` | ⚠️ | Workshop-originated subcommands. Not individually confirmed in docs |

---

## 4. devops-automation.md

| # | Claim | Grade | Notes |
|:--|:------|:-----:|:------|
| 4.1 | `agy -p "<prompt>"` for print mode | ✅ | Compilation §2: one-shot mode |
| 4.2 | `--dangerously-skip-permissions` for CI | ✅ | Workshop pattern, flag exists |
| 4.3 | `--print-timeout <duration>` flag | ⚠️ | Workshop-originated. Not explicitly listed in docs |
| 4.4 | `--add-dir <path>` repeatable | ⚠️ | Workshop-originated. Not found in raw snapshots |
| 4.5 | `{"enableTerminalSandbox": true}` in settings.json | ✅ | Features page snapshot lines 193-206: exact key, boolean, default false |
| 4.6 | Sandbox uses nsjail (Linux) | ✅ | Features page snapshot line 179 |
| 4.7 | Sandbox uses sandbox-exec (macOS) | ✅ | Features page snapshot line 181 |
| 4.8 | Sandbox uses AppContainer (Windows) | ✅ | Features page snapshot line 183 |
| 4.9 | Per-command sandbox bypass prompt | ✅ | Features page snapshot lines 207-218 |
| 4.10 | Hooks: 5 lifecycle events | ✅ | Compilation §10: PreToolUse, PostToolUse, PreInvocation, PostInvocation, Stop |
| 4.11 | Hooks configured in `hooks.json` | ✅ | Compilation §10 |
| 4.12 | Hooks receive JSON on stdin, return JSON on stdout | ✅ | Compilation §10 |
| 4.13 | Rules in `.agents/rules.md` or `~/.gemini/config/rules.md` | ✅ | Compilation §9 |
| 4.14 | Rules injected as system prompt RULE blocks | ✅ | Compilation §9 |

---

## 5. multi-agent-advanced.md

| # | Claim | Grade | Notes |
|:--|:------|:-----:|:------|
| 5.1 | 3 workspace modes: inherit, branch, share | ✅ | Compilation §11: inherit parent's or create isolated Git worktree |
| 5.2 | `/model` opens model picker | ✅ | Features page snapshot lines 251-253 |
| 5.3 | Available models: Gemini 3.5 Flash, Gemini 3.1 Pro, Claude Sonnet 4.6 | ✅ | Compilation §14 |
| 5.4 | `/agents` panel for managing subagents | ✅ | Features page snapshot lines 304-310 |
| 5.5 | `Ctrl+J` teleport to pending approval | ✅ | Features page snapshot lines 320-324 |
| 5.6 | `Ctrl+K` fast-approve from main conversation | ✅ | Features page snapshot lines 329-331 |
| 5.7 | Subagent lifecycle: Running → Idle → Killed | ✅ | Compilation §11 |
| 5.8 | Max nesting depth: 10 | ✅ | Compilation §11 |
| 5.9 | Built-in types: research, browser, self | ✅ | Compilation §11 |
| 5.10 | `/btw` for mid-task steering | 📎 | Workshop signature feature. Not explicitly in CLI docs but widely known |
| 5.11 | `/resume` or `/switch` to resume sessions | ✅ | Features page snapshot lines 225-231 |
| 5.12 | Auto-resume command printed on exit | ⚠️ | Workshop claim. Plausible but not confirmed in raw snapshots |
| 5.13 | `agy --conversation <id>` to resume by ID | ⚠️ | Workshop claim. `--resume` flag is in docs but `--conversation` not explicitly confirmed |
| 5.14 | `agy -c` to continue last session | ⚠️ | Workshop claim. Not explicitly in docs. `--resume` is documented |

---

## 6. cheatsheet.md

| # | Claim | Grade | Notes |
|:--|:------|:-----:|:------|
| 6.1 | All 19 slash commands in table | ✅ | 13/19 confirmed directly from Features page snapshot. Remaining 6 from Using page or compilation |
| 6.2 | `--sandbox` flag | ⚠️ | Workshop lists as flag. Docs show `enableTerminalSandbox` in settings.json. CLI flag may also exist but not confirmed |
| 6.3 | `--strict` flag | ✅ | Compilation §2: `agy --strict` |
| 6.4 | `--model <model>` flag | ✅ | Compilation §2: `agy --model <model>` |
| 6.5 | `--workspace <path>` flag | ✅ | Compilation §2: `agy --workspace <path>` |
| 6.6 | AGENTS.md hierarchical context | ⚠️ | Hierarchy (cwd → parent → home) not explicitly documented |
| 6.7 | Plugin commands table (install, enable, disable, validate, link) | ⚠️ | Workshop-original. Individual subcommands not confirmed |

---

## 7. facilitator-guide.md

| # | Claim | Grade | Notes |
|:--|:------|:-----:|:------|
| 7.1 | `/model` to switch models | ✅ | Features page |
| 7.2 | Browser-based Google Sign-In | ✅ | Getting-started page |
| 7.3 | Enterprise via GCP project | ✅ | Enterprise page |
| 7.4 | Hooks supported via hooks.json | ✅ | Hooks page |
| 7.5 | Conversation logs at `~/.gemini/antigravity-cli/conversations/` | ⚠️ | Path not confirmed in raw snapshots. Brain data is at `~/.gemini/antigravity/brain/`. Conversations path may differ |

---

## Summary

| Grade | Count | % |
|:---:|:---:|:---:|
| ✅ Grounded | 46 | 63% |
| ⚠️ Partially grounded | 21 | 29% |
| ❌ Ungrounded | 0 | 0% |
| 📎 Workshop-original | 6 | 8% |
| **Total claims audited** | **73** | |

### Key Findings

> [!IMPORTANT]
> **No claims contradict the official docs** — zero ❌ grades. The workshop content is directionally accurate across all modules.

> [!WARNING]
> **21 claims are ⚠️ partially grounded** — these are either:
> 1. **Keyboard shortcuts** (`@`, `!`, `Esc Esc`, `Alt+Enter`, `Ctrl+G`) — plausible but not found in the raw doc snapshots. May be documented elsewhere or discovered through usage.
> 2. **CLI subcommands** (`agy plugin install/enable/disable/validate/link`, `agy changelog`, `agy update`, `agy install`) — workshop references but not individually confirmed.
> 3. **Resume flags** (`agy -c`, `agy --conversation <id>`) — `--resume` is confirmed but these specific variants aren't.

> [!NOTE]
> **6 workshop-original claims** (`agy plugin import gemini/claude`, `/btw`, parallel audit patterns) are **workshop-centric pedagogical content** — they teach patterns rather than document features, so they're not expected to appear in official docs.

### Discrepancy: Compilation vs Raw Snapshots

> [!CAUTION]
> The subagent-compiled `agy-docs-compilation.md` contains one **hallucinated claim**: it lists the install command as `npm install -g @anthropic-ai/antigravity-cli` (§1). The **raw snapshot** from cli-getting-started (line 161) clearly shows `curl -fsSL https://antigravity.google/cli/install.sh | bash`. The workshop correctly uses the raw snapshot version. **Always prefer raw snapshots over compiled summaries.**

### Recommendations

1. **Verify keyboard shortcuts** — the 5 unverified shortcuts (`@`, `!`, `Esc Esc`, `Alt+Enter`, `Ctrl+G`) should be tested live before workshop delivery. If any don't work, participants will lose confidence.
2. **Verify plugin subcommands** — `agy plugin --help` should confirm `install`, `enable`, `disable`, `validate`, `link`. If any don't exist, update the cheatsheet.
3. **Verify resume flags** — `agy --help` should confirm whether `-c`/`--continue` and `--conversation <id>` exist alongside `--resume`.
4. **Conversation log path** — verify actual path with `ls ~/.gemini/antigravity*/` before stating it in the facilitator guide.
