# Facilitator Guide

> Internal guide for workshop facilitators. Do not share with participants.

---

## Overview

This is a **4-module, ~3.5-hour hands-on workshop** for agy-cli (Antigravity CLI). It is designed for developer audiences: engineers, tech leads, and solution architects evaluating or adopting agy-cli.

---

## Delivery Formats

| Format | Modules | Duration |
|---|---|---|
| ⚡ Lightning | Module 1 + Module 2 highlights | 1.5 hrs |
| 📋 Standard | Modules 1 + 2 + 3 | 2.5 hrs |
| 📦 Full | All four modules | 3.5 hrs |
| 🏗️ Extended | All modules + open lab | 5 hrs |

---

## Pre-Workshop Checklist

- [ ] Participants have agy-cli installed and authenticated *(see [setup.md](setup.md))*
- [ ] Auth details distributed (session-specific — confirm with agy-cli team)
- [ ] Participants have Git and a suitable demo codebase
- [ ] Facilitator has run through all exercises end-to-end on the current agy-cli version
- [ ] Screen sharing / projection tested

!!! warning "Auth is the #1 failure point"
    Always run a pre-workshop auth check 30 minutes before the session. Run:
    ```bash
    agy --print "Say READY" --print-timeout 30s
    ```
    If participants can't get a response, stop and debug before starting.

---

## Module-by-Module Delivery Notes

### Module 1 — SDLC Productivity (50 min)

**Key message:** agy replaces the mental overhead of navigating an unfamiliar codebase. It's not autocomplete — it's a senior engineer you can ask anything.

- **Demo first, exercise second.** Live-demo section 1.1 (code understanding) on your own codebase before asking participants to try theirs.
- **Common friction:** participants try to write perfect prompts. Encourage natural language. "Tell me how the auth works" is better than "Please explain the authentication architecture of this codebase."
- **The AGENTS.md moment:** section 1.5 is a high-value demo. Create an AGENTS.md live on screen and show how the next session is immediately smarter.

### Module 2 — Plugin Ecosystem (45 min)

**Key message:** `agy plugin import gemini` in one command brings over everything you've built in Gemini CLI. Your extension investment carries over.

- **Live demo `agy plugin import gemini`** — let the audience see the real output. It's visually compelling.
- **Validate exercise:** the plugin validate section works best with the sample plugin in `samples/plugins/workshop-helpers/`.
- **Marketplace placeholder:** if asked about `plugin install`, say it's coming and redirect to `plugin import` as the current path.

### Module 3 — DevOps & Automation (40 min)

**Key message:** `--print` is the escape hatch. Once you can pipe agy output, you can automate anything.

- **Best demo:** `git diff --cached | agy -p "Review for bugs."` — every developer immediately sees the value.
- **CI/CD section:** don't write the full workflow live. Show the GitHub Actions YAML and explain the `--dangerously-skip-permissions` pattern.
- **Skip the sandbox deep dive** unless the audience is security/compliance-focused.

### Module 4 — Multi-Agent & Advanced (45 min)

**Key message:** subagents + /btw is the qualitative leap. This is where agy becomes an orchestrator, not just a chatbot.

- **Subagent demo is the wow moment.** Spawn two agents live, show both running simultaneously.
- **/btw demo:** start a long-ish task (refactor a file), then use /btw mid-task. Show participants the cursor keeps moving while the injected note is incorporated.
- **Scheduling:** describe the pattern conceptually, don't demo live (latency makes it awkward in a workshop).

---

## Common Participant Questions

| Question | Answer |
|---|---|
| "What model does agy use?" | Use `/model` to see and switch. See [Models docs](https://www.antigravity.google/docs/models). |
| "How is this different from Gemini CLI?" | agy bridges plugins from both Gemini CLI and Claude, has native subagent orchestration, and /btw mid-task steering. Different product. |
| "Can I use my own API key?" | agy uses browser-based Google Sign-In. Enterprise users connect a GCP project. See [Enterprise docs](https://www.antigravity.google/docs/enterprise). |
| "Is the code sent to Google?" | See the [FAQ](https://www.antigravity.google/docs/faq) for data handling details. |
| "What about hooks?" | agy-cli supports hooks via `hooks.json`. See [Hooks docs](https://www.antigravity.google/docs/hooks). |
| "Where are conversation logs stored?" | `~/.gemini/antigravity-cli/conversations/` |

---

## Troubleshooting During Workshop

| Symptom | Fix |
|---|---|
| `agy: command not found` | Check PATH. Run `which agy` or `which agy-cli`. |
| Auth error / 401 | Session credentials may have expired. Redistribute auth. |
| `agy plugin list` errors | Check that `~/.gemini/antigravity-cli/` exists |
| Slow responses | Check network. First run after idle may be slower due to workspace indexing. |
| Subagent doesn't spawn | Confirm the participant is in interactive mode (not `--print`) |

---

## Post-Workshop

1. Collect feedback using the standard workshop feedback form
2. Note any agy-cli bugs or unexpected behaviors observed — report to the agy-cli team
3. Any exercises that required workarounds should be flagged for doc updates in `CONTRIBUTING.md`
