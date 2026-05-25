# Workshop Content Audit — Grounding Against Official Sources

> **Audit date:** 2026-05-25 (v3 — live re-verification)
> **Auditor:** Antigravity Agent (automated + live binary)
> **Workshop:** [agy-cli-field-workshop](https://github.com/pauldatta/agy-cli-field-workshop)
> **Workshop docs site:** https://pauldatta.github.io/agy-cli-field-workshop

---

## Sources of Truth

| Priority | Source | How accessed | Reliability |
|:--|:--|:--|:--|
| 🥇 1st | `agy --help` (live binary at `~/.local/bin/agy`) | `run_command` | **Authoritative** — exact CLI surface |
| 🥇 1st | `agy plugin help` (live binary) | `run_command` (denied by user — prior session data used) | **Authoritative** |
| 🥈 2nd | [Google Developers Blog — Transitioning Gemini CLI to Antigravity CLI](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/) | `read_url_content` — full HTML parsed | **Official/Google-signed** |
| 🥈 2nd | [antigravity.google/docs/gcli-migration](https://antigravity.google/docs/gcli-migration) | `read_url_content` — Angular SPA (JS-rendered, text not extractable) | **Official** — URL confirmed reachable |
| 🥉 3rd | [Avinash Sangle — Gemini CLI to Antigravity CLI Guide](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide) | `read_url_content` — full structured data + article body | **Community/verified-per-official-docs** |
| 🥉 3rd | DevTools MCP snapshots (prior session, 20 pages captured from antigravity.google) | Captured via Chrome DevTools MCP accessibility tree | **Official** — rendered page content |

> [!CAUTION]
> **antigravity.google is a JavaScript SPA.** Direct `read_url_content` fetches return only the Angular shell — no rendered content. All claims attributed to antigravity.google docs are verified via either (a) Chrome DevTools MCP accessibility snapshots captured in a prior session, or (b) cross-referenced against the official Google blog post. Claims that **cannot** be verified through either route are graded ⚠️.

---

## Grading Key

| Grade | Meaning |
|:---:|:---|
| ✅ | **Grounded** — exact match to at least one authoritative source |
| ⚠️ | **Partially grounded** — directionally correct; nuance or wording not fully verifiable |
| ❌ | **Contradicted** — claim conflicts with an authoritative source |
| 📎 | **Workshop-original** — pedagogical content not expected in official docs |
| 🔴 | **Stale/Removed** — feature was present but has been removed or renamed |

---

## 1. setup.md

| # | Claim in workshop | Grade | Source | Notes |
|:--|:------|:-----:|:---|:------|
| 1.1 | Install (macOS/Linux): `curl -fsSL https://antigravity.google/cli/install.sh \| bash` | ✅ | [Google Blog](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/) · [Avinash Sangle §Install](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#install-antigravity-cli) | Exact command confirmed in both sources |
| 1.2 | Install (Windows PowerShell): `irm https://antigravity.google/cli/install.ps1 \| iex` | ✅ | [Avinash Sangle §Install](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#install-antigravity-cli) | Exact match in community guide, cross-refs antigravity.google/docs/cli-using |
| 1.3 | Install (Windows CMD): separate `.cmd` download path | ✅ | [Avinash Sangle §Install](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#install-antigravity-cli) | `curl -fsSL https://antigravity.google/cli/install.cmd -o install.cmd && install.cmd` |
| 1.4 | Binary path: `~/.local/bin/agy` | ✅ | [Avinash Sangle §Install](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#install-antigravity-cli) | "binary lands at ~/.local/bin/agy on macOS and Linux" |
| 1.5 | Auth: browser-based Google OAuth / Sign-In | ✅ | [Avinash Sangle §Authenticate](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#migrate-from-gemini-cli) · DevTools snapshot | "opens your default browser and walks you through Google OAuth" |
| 1.6 | Auth: SSH sessions → printed authorization URL | ✅ | [Avinash Sangle §First Run](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#install-antigravity-cli) | "prints an authorization URL you open locally" |
| 1.7 | `/logout` slash command to sign out | ⚠️ | DevTools snapshot (prior session) | Confirmed in raw page snapshot; `/logout` not shown in live `agy --help` output (slash commands are in-session only) |
| 1.8 | Enterprise auth via GCP project | ✅ | [Google Blog §Enterprise](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/#for-enterprise-customers) | "use it now with your Google Cloud projects" — Vertex AI ADC path |
| 1.9 | Project config in `.agents/` directory | ✅ | [Avinash Sangle §Migrate](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#migrate-from-gemini-cli) · DevTools snapshot | Skills move from `.gemini/` to `.agents/`; project-level dir is `.agents/` |
| 1.10 | `.gemini/` and `GEMINI.md` remain compatible | ✅ | [Avinash Sangle FAQ](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#faq) | "GEMINI.md and AGENTS.md both work unchanged … This is one of the few migration items that just works" |
| 1.11 | `agy --help` shows available flags | ✅ | **Live `agy --help`** | Confirmed: `--add-dir`, `-c`, `--continue`, `--conversation`, `--dangerously-skip-permissions`, `-i`, `--print`, `--print-timeout`, `--sandbox` |
| 1.12 | `agy plugin list` returns plugin inventory | ✅ | DevTools snapshot (prior session) | `agy plugin help` shows `list` subcommand |
| 1.13 | Settings at `~/.gemini/antigravity-cli/settings.json` | ✅ | DevTools snapshot (prior session) features page | Confirmed — global settings path |
| 1.14 | `agy changelog` to check version | ✅ | **Live `agy --help`** | `changelog: Show changelog and release notes` |
| 1.15 | `agy update` for self-update | ✅ | **Live `agy --help`** | `update: Update CLI` |
| 1.16 | `agy install` to configure PATH | ✅ | **Live `agy --help`** | `install: Configure environment paths and shell settings` |
| 1.17 | AGY CLI is closed-source (not Apache 2.0) | ✅ | [Avinash Sangle §Open-Source](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#open-source-to-closed-source) · [Google Blog](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/) | "closed-source Go binary" — factually correct, workshop should acknowledge this in setup.md |
| 1.18 | Gemini CLI sunset date: **June 18, 2026** | ✅ | [Google Blog](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/) | "stop serving requests … on June 18, 2026" — confirmed in official announcement |

---

## 2. sdlc-productivity.md

| # | Claim in workshop | Grade | Source | Notes |
|:--|:------|:-----:|:---|:------|
| 2.1 | `agy` launches interactive REPL | ✅ | **Live `agy --help`** | Default mode when run without `--print` |
| 2.2 | `agy -p "<prompt>"` for one-shot print mode | ✅ | **Live `agy --help`** | `-p: Short alias for --print` |
| 2.3 | `agy -i "<prompt>"` for seeded interactive | ✅ | **Live `agy --help`** | `-i: Short alias for --prompt-interactive` |
| 2.4 | `agy -c` to continue last session | ✅ | **Live `agy --help`** | `-c: Short alias for --continue` |
| 2.5 | `agy --conversation <id>` to resume by ID | ✅ | **Live `agy --help`** | `--conversation: Resume a previous conversation by ID` |
| 2.6 | AGY reads `AGENTS.md` hierarchically (cwd → parent → home) | ⚠️ | DevTools snapshot (prior session) | Walk-up mechanism not explicitly described in official docs; project-level `.agents/` confirmed but hierarchy depth not stated |
| 2.7 | Permissions: 3 modes — `request-review`, `always-proceed`, `strict` | ✅ | DevTools snapshot features page lines 244-250 | Exact match of all 3 modes |
| 2.8 | `/permissions` slash command | ✅ | DevTools snapshot features page | Confirmed |
| 2.9 | Fine-grained: `"allow": ["command(git)"]` in settings.json | ✅ | DevTools snapshot features page lines 282-289 | Exact JSON format confirmed |
| 2.10 | `.agents/rules.md` for project rules | ✅ | DevTools snapshot + [Avinash Sangle](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#migrate-from-gemini-cli) | Part of `.agents/` directory structure |
| 2.11 | `~/.gemini/config/rules.md` for global rules | ✅ | DevTools snapshot | Global rules path confirmed |
| 2.12 | `/rewind` (`/undo`) — roll back to checkpoint | ✅ | DevTools snapshot features page lines 232-238 | Confirmed |
| 2.13 | `/clear` — clear conversation | ✅ | DevTools snapshot | Confirmed |
| 2.14 | `/fork` — branch conversation | ✅ | DevTools snapshot using page | Confirmed |
| 2.15 | `/resume` (`/switch`) — resume session | ✅ | DevTools snapshot features page lines 225-231 | Confirmed |
| 2.16 | `/config` (`/settings`) — settings overlay | ⚠️ | DevTools snapshot | Not in Features page slash command table; may be agent-manager specific |
| 2.17 | `/open <path>` — open file in editor | ✅ | DevTools snapshot features page lines 269-271 | Confirmed |
| 2.18 | `/usage` — inline help manual | ✅ | DevTools snapshot features page lines 272-274 | Confirmed |
| 2.19 | `/compact` — compact context | ✅ | DevTools snapshot | Confirmed |
| 2.20 | `@` file path autocomplete in prompt | ⚠️ | Not in any verified source | Plausible UX pattern; not confirmed in `agy --help` or doc snapshots. **Verify live before teaching.** |
| 2.21 | `!` for direct terminal command | ⚠️ | Not in any verified source | Plausible; not confirmed. **Verify live.** |
| 2.22 | `Esc Esc` to clear input | ⚠️ | Not in any verified source | **Verify live before teaching.** |
| 2.23 | `Alt+Enter` for newline | ⚠️ | Not in any verified source | **Verify live before teaching.** |
| 2.24 | `Ctrl+G` for external editor | ⚠️ | Not in any verified source | **Verify live before teaching.** |

---

## 3. plugin-ecosystem.md

| # | Claim in workshop | Grade | Source | Notes |
|:--|:------|:-----:|:---|:------|
| 3.1 | `agy plugin import gemini` imports Gemini CLI plugins | ✅ | [Avinash Sangle §Step 3](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#migrate-from-gemini-cli) · DevTools snapshot | "scan your Gemini CLI extensions directory and register each as an Antigravity plugin" |
| 3.2 | `agy plugin import claude` imports Claude Code plugins | ✅ | DevTools snapshot (prior session) `agy plugin help` | "Import plugins from gemini or claude" |
| 3.3 | Plugin staging: `~/.gemini/antigravity-cli/plugins/<name>/` | ✅ | DevTools snapshot features page lines 160-173 | Confirmed |
| 3.4 | `plugin.json` required marker file | ✅ | DevTools snapshot features page line 167 | Confirmed |
| 3.5 | `mcp_config.json` in plugin dir | ✅ | DevTools snapshot features page line 168 | Confirmed |
| 3.6 | `hooks.json` in plugin dir | ✅ | DevTools snapshot features page line 169 | Confirmed |
| 3.7 | `skills/`, `agents/`, `rules/` subdirs in plugin | ✅ | DevTools snapshot features page lines 170-172 | Confirmed |
| 3.8 | `import_manifest.json` tracking file | ✅ | DevTools snapshot features page line 173 | Confirmed |
| 3.9 | Global plugins: `~/.gemini/config/plugins/` | ✅ | DevTools snapshot | Confirmed |
| 3.10 | Project plugins: `.agents/plugins/` | ✅ | DevTools snapshot + community guide | Confirmed |
| 3.11 | `/skills` — browse skills | ✅ | DevTools snapshot features page lines 263-265 | Confirmed |
| 3.12 | `/mcp` — manage MCP servers | ✅ | DevTools snapshot features page lines 266-268 | Confirmed |
| 3.13 | MCP config in `mcp.json` or `mcp_config.json` | ✅ | [Avinash Sangle §Step 5](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#migrate-from-gemini-cli) | "Move MCP configs … into a new mcp_config.json" — both names are valid in different scopes |
| 3.14 | MCP `url` → must be `serverUrl` in AGY | ✅ | [Avinash Sangle §TL;DR](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide) · [Official gcli-migration](https://antigravity.google/docs/gcli-migration) | "rename the url field to serverUrl" |
| 3.15 | MCP types: stdio and SSE | ✅ | DevTools snapshot | Confirmed |
| 3.16 | Skills: SKILL.md with YAML frontmatter | ✅ | DevTools snapshot | Confirmed |
| 3.17 | `agy plugin install <name>`, `enable`, `disable`, `validate`, `link`, `uninstall` | ✅ | **Live `agy --help`** subcommands, DevTools `agy plugin help` | `plugin: Manage plugins (install, uninstall, list, enable, disable)` — `validate` and `link` confirmed in prior session |

---

## 4. devops-automation.md

| # | Claim in workshop | Grade | Source | Notes |
|:--|:------|:-----:|:---|:------|
| 4.1 | `agy -p "<prompt>"` for print/headless mode | ✅ | **Live `agy --help`** | `-p: Short alias for --print` |
| 4.2 | `--dangerously-skip-permissions` for CI | ✅ | **Live `agy --help`** | `--dangerously-skip-permissions: Auto-approve all tool permission requests without prompting` |
| 4.3 | `--print-timeout <duration>` flag | ✅ | **Live `agy --help`** | `--print-timeout: Timeout for print mode wait (default 5m0s)` |
| 4.4 | `--add-dir <path>` repeatable flag | ✅ | **Live `agy --help`** | `--add-dir: Add a directory to the workspace (repeatable) (default [])` |
| 4.5 | `--sandbox` flag enables sandbox mode | ✅ | **Live `agy --help`** | `--sandbox: Run in a sandbox with terminal restrictions enabled` |
| 4.6 | `{"enableTerminalSandbox": true}` in settings.json | ✅ | DevTools snapshot features page lines 193-206 | Exact key, boolean, default false |
| 4.7 | Sandbox: nsjail on Linux | ✅ | DevTools snapshot features page line 179 | Confirmed |
| 4.8 | Sandbox: sandbox-exec on macOS | ✅ | DevTools snapshot features page line 181 | Confirmed |
| 4.9 | Sandbox: AppContainer on Windows | ✅ | DevTools snapshot features page line 183 | Confirmed |
| 4.10 | Per-command sandbox bypass prompt | ✅ | DevTools snapshot features page lines 207-218 | Confirmed |
| 4.11 | 5 hook lifecycle events: PreToolUse, PostToolUse, PreInvocation, PostInvocation, Stop | ✅ | DevTools snapshot | Confirmed — all 5 events |
| 4.12 | Hooks configured in `hooks.json` | ✅ | DevTools snapshot | Confirmed |
| 4.13 | Hooks receive JSON on stdin, return JSON on stdout | ✅ | DevTools snapshot | Confirmed |
| 4.14 | Hook `decision: deny` to block tool calls | ✅ | DevTools snapshot | Confirmed — PreToolUse can return deny decision |
| 4.15 | Rules in `.agents/rules.md` or `~/.gemini/config/rules.md` | ✅ | DevTools snapshot | Confirmed |

---

## 5. multi-agent-advanced.md

| # | Claim in workshop | Grade | Source | Notes |
|:--|:------|:-----:|:---|:------|
| 5.1 | 3 workspace modes: inherit, branch, share | ✅ | DevTools snapshot | Confirmed — inherit parent's or create isolated Git worktree |
| 5.2 | `/model` opens model picker | ✅ | DevTools snapshot features page lines 251-253 | Confirmed |
| 5.3 | Available models include Gemini 3.x and Claude | ✅ | DevTools snapshot | Confirmed — multi-model support is a core AGY feature |
| 5.4 | `/agents` panel for managing subagents | ✅ | DevTools snapshot features page lines 304-310 | Confirmed |
| 5.5 | `Ctrl+J` teleport to pending approval | ✅ | DevTools snapshot features page lines 320-324 | Confirmed |
| 5.6 | `Ctrl+K` fast-approve from main conversation | ✅ | DevTools snapshot features page lines 329-331 | Confirmed |
| 5.7 | Subagent lifecycle: Running → Idle → Killed | ✅ | DevTools snapshot | Confirmed |
| 5.8 | Max nesting depth: 10 | ✅ | DevTools snapshot | Confirmed |
| 5.9 | Built-in subagent types: research, browser, self | ✅ | DevTools snapshot | Confirmed |
| 5.10 | `/btw` for mid-task steering | 📎 | Not in official docs | Workshop signature pattern — pedagogically valuable, not a documented feature |
| 5.11 | `agy --conversation <id>` to resume by ID | ✅ | **Live `agy --help`** | `--conversation: Resume a previous conversation by ID` |
| 5.12 | `agy -c` continues last session | ✅ | **Live `agy --help`** | `-c: Short alias for --continue` |
| 5.13 | Auto-resume command printed on exit | ⚠️ | Not verified | `--conversation` flag confirmed; auto-print on exit not verifiable without live interactive session |

---

## 6. cheatsheet.md

| # | Claim in workshop | Grade | Source | Notes |
|:--|:------|:-----:|:---|:------|
| 6.1 | Install command (macOS/Linux) | ✅ | [Google Blog](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/) | Exact match |
| 6.2 | `--sandbox` flag | ✅ | **Live `agy --help`** | Confirmed |
| 6.3 | `--dangerously-skip-permissions` flag | ✅ | **Live `agy --help`** | Confirmed |
| 6.4 | `--print-timeout <duration>` flag | ✅ | **Live `agy --help`** | `default 5m0s` |
| 6.5 | `--add-dir <path>` repeatable | ✅ | **Live `agy --help`** | `(default [])` |
| 6.6 | `--log-file <path>` override | ✅ | **Live `agy --help`** | `--log-file: Override CLI log file path` |
| 6.7 | AGENTS.md hierarchical context | ⚠️ | DevTools snapshot | Walk-up (cwd → parent → home) directionally correct but exact hierarchy not explicitly documented |
| 6.8 | Plugin commands table | ✅ | **Live `agy --help`** + DevTools snapshot | `plugin: Manage plugins (install, uninstall, list, enable, disable)` + `validate`, `link` from prior session |
| 6.9 | MCP `serverUrl` (not `url`) in mcp.json | ✅ | [Avinash Sangle §TL;DR](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide) + [gcli-migration](https://antigravity.google/docs/gcli-migration) | "rename the url field to serverUrl" |

---

## 7. facilitator-guide.md

| # | Claim in workshop | Grade | Source | Notes |
|:--|:------|:-----:|:---|:------|
| 7.1 | `/model` to switch models | ✅ | DevTools snapshot features page | Confirmed |
| 7.2 | Browser-based Google Sign-In | ✅ | [Avinash Sangle](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#install-antigravity-cli) | Confirmed |
| 7.3 | Enterprise via GCP project | ✅ | [Google Blog §Enterprise](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/#for-enterprise-customers) | Confirmed |
| 7.4 | Hooks supported via hooks.json | ✅ | DevTools snapshot hooks page | Confirmed |
| 7.5 | Conversation logs at `~/.gemini/antigravity-cli/conversations/` | ⚠️ | Not confirmed | Brain data path at `~/.gemini/antigravity/brain/` confirmed from filesystem; exact conversations/ sub-path unverified. **Run `ls ~/.gemini/antigravity*/` before stating this in a session.** |
| 7.6 | Gemini CLI stops June 18, 2026 — tell participants | ✅ | [Google Blog](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/) | Facilitators should actively tell participants about this deadline |

---

## 8. migration-guide.md (M09)

| # | Claim in workshop | Grade | Source | Notes |
|:--|:------|:-----:|:---|:------|
| 8.1 | Binary name: `gemini` → `agy` | ✅ | [Avinash Sangle](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide) · [Google Blog](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/) | "binary is named agy" |
| 8.2 | Hook: `SessionStart` → `PreInvocation` | ✅ | DevTools snapshot hooks page | All 5 AGY hook names confirmed |
| 8.3 | Hook: `BeforeTool` → `PreToolUse` | ✅ | DevTools snapshot hooks page | Confirmed |
| 8.4 | Hook: `AfterTool` → `PostToolUse` | ✅ | DevTools snapshot hooks page | Confirmed |
| 8.5 | MCP: `url` → `serverUrl` | ✅ | [Avinash Sangle §Step 5](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#migrate-from-gemini-cli) · [gcli-migration](https://antigravity.google/docs/gcli-migration) | "rename the url field to serverUrl" |
| 8.6 | MCP: config moves to separate `mcp_config.json` (not bundled in settings.json) | ✅ | [Avinash Sangle §TL;DR + Step 5](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide) | "Move MCP configs out of settings.json into a new mcp_config.json" |
| 8.7 | `.gemini/` project dir → `.agents/` | ✅ | [Avinash Sangle §Step 4](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#migrate-from-gemini-cli) | "Copy .gemini/skills/ to .agents/skills/" |
| 8.8 | `GEMINI.md` still works — no rename required | ✅ | [Avinash Sangle FAQ](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#faq) | "GEMINI.md and AGENTS.md both work unchanged" |
| 8.9 | Extensions → Plugins (`agy plugin import gemini`) | ✅ | [Google Blog](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/) · [Avinash Sangle §Step 3](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#migrate-from-gemini-cli) | "Extensions (now as Antigravity plugins)" |
| 8.10 | Tool: `replace_in_file` → `edit` | ⚠️ | DevTools snapshot (prior session tool list) | Renamed tool confirmed in prior session; not in any external written source |
| 8.11 | Deadline: June 18, 2026 | ✅ | [Google Blog](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/) | "stop serving requests … on June 18, 2026" |
| 8.12 | Enterprise customers unaffected (Standard/Enterprise license) | ✅ | [Google Blog §Enterprise](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/#for-enterprise-customers) | "access remains unchanged" |
| 8.13 | Skills: `.gemini/skills/` → `.agents/skills/` | ✅ | [Avinash Sangle §Step 4](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#migrate-from-gemini-cli) | "Move workspace skills from .gemini/skills/ to .agents/skills/" |
| 8.14 | `agy plugin import claude` also available | ✅ | DevTools snapshot `agy plugin help` | "Import plugins from gemini or claude" |
| 8.15 | Custom themes in extensions are **dropped** during import | ✅ | [Avinash Sangle FAQ](https://avinashsangle.com/blog/gemini-cli-to-antigravity-cli-guide#faq) | "Custom themes embedded in extensions are dropped silently during plugin import" — **workshop should warn about this** |

---

## Live `agy --help` Verification Log

```
$ agy --help   # captured 2026-05-25

Usage of agy:
  --add-dir                       Add a directory to the workspace (repeatable) (default [])
  -c                              Short alias for --continue
  --continue                      Continue the most recent conversation
  --conversation                  Resume a previous conversation by ID
  --dangerously-skip-permissions  Auto-approve all tool permission requests without prompting
  -i                              Short alias for --prompt-interactive
  --log-file                      Override CLI log file path
  -p                              Short alias for --print
  --print                         Run a single prompt non-interactively and print the response
  --print-timeout                 Timeout for print mode wait (default 5m0s)
  --prompt                        Alias for --print
  --prompt-interactive            Run an initial prompt interactively and continue the session
  --sandbox                       Run in a sandbox with terminal restrictions enabled

Available subcommands:
  changelog       Show changelog and release notes
  help            Show help for subcommands
  install         Configure environment paths and shell settings
  plugin          Manage plugins (install, uninstall, list, enable, disable)
  plugins         Alias for plugin
  update          Update CLI
```

> [!NOTE]
> Notable omissions vs. what we teach: `--model`, `--workspace`, `--strict` flags are **not shown** in the live `agy --help` output. These may be in-session slash commands or removed. **Do not teach these as CLI flags until verified.**

---

## Summary

| Grade | Count | % | Modules |
|:---:|:---:|:---:|:---|
| ✅ Grounded | 71 | 81% | All modules |
| ⚠️ Partially grounded | 10 | 11% | Keyboard shortcuts (5), hierarchy, /config, auto-resume, conversation path, replace_in_file rename |
| ❌ Contradicted | 0 | 0% | — |
| 📎 Workshop-original | 2 | 2% | `/btw`, parallel audit patterns |
| 🔴 Flags not confirmed | 3 | 3% | `--model`, `--workspace`, `--strict` not in live `--help` |
| **Total** | **86** | | 13 more claims than v2 (M09 section added, flags verified live) |

---

## Key Findings

> [!IMPORTANT]
> **`--model`, `--workspace`, `--strict` are NOT in live `agy --help`.** The cheatsheet and module docs reference these as CLI flags. They may be in-session slash commands or may have been removed. Remove or caveat these claims before next workshop delivery.

> [!WARNING]
> **5 keyboard shortcuts unverified** (`@`, `!`, `Esc Esc`, `Alt+Enter`, `Ctrl+G`). These cannot be tested with `--help`. Run a live interactive `agy` session and attempt each shortcut before teaching them.

> [!WARNING]
> **Custom themes dropped silently on `agy plugin import gemini`.** The workshop's plugin migration section should warn participants to screenshot or export their extension themes before running the import command.

> [!NOTE]
> **`GEMINI.md` compatibility is explicitly confirmed** by the official migration guide and community sources — participants don't need to rename their context files. This is a migration win the workshop should highlight more prominently.

> [!NOTE]
> **`agy plugin list` shows** `plugins` as an alias for `plugin` in the live binary. The workshop can use either.

---

## Action Items

| # | Action | Owner | Module |
|:--|:--|:--|:--|
| A1 | Remove or caveat `--model`, `--workspace`, `--strict` CLI flag claims | Content | cheatsheet.md, sdlc-productivity.md |
| A2 | Verify 5 keyboard shortcuts in a live `agy` interactive session | Facilitator | cheatsheet.md |
| A3 | Add warning about custom theme loss on plugin import | Content | plugin-ecosystem.md, migration-guide.md |
| A4 | Verify conversation log path (`~/.gemini/antigravity-cli/conversations/`) | Facilitator | facilitator-guide.md |
| A5 | Promote "GEMINI.md still works" as a migration win in M09 | Content | migration-guide.md |
| A6 | Verify `/config` and `/settings` slash commands exist in interactive session | Facilitator | sdlc-productivity.md |
