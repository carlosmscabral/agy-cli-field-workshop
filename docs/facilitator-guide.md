# Facilitator Guide

> Internal guide for workshop facilitators. Do not share with participants.

---

## Overview

This is a **4-module, ~5.5-hour hands-on workshop** for Antigravity CLI. It is designed for developer audiences: engineers, tech leads, and solution architects evaluating or adopting Antigravity CLI.

!!! warning "Gemini CLI Sunset: June 18, 2026"
    Gemini CLI reaches end-of-life on **June 18, 2026**. When participants ask about migration, direct them to `agy plugin import gemini` — this is the primary migration path. All Gemini CLI plugins carry over in one command.

---

## Delivery Formats

| Format | Modules | Duration |
| :-- | :-- | :-- |
| ⚡ Lightning | Module 1 + Module 2 highlights | 1.5 hrs |
| 📋 Half-day | Modules 1 + 2 | 2.5 hrs |
| 📦 Full day | All four modules | ~5.5 hrs |
| 🏗️ Extended | All modules + open lab | 7 hrs |

---

## Pre-Workshop Checklist

- [ ] Participants have Antigravity CLI installed and authenticated *(see [setup.md](setup.md))*
- [ ] Auth details distributed (session-specific — confirm with agy-cli team)
- [ ] Participants have Git and a suitable demo codebase
- [ ] Facilitator has run through all exercises end-to-end on the current agy-cli version
- [ ] Screen sharing / projection tested
- [ ] For Module 2: confirm participants can run `dotnet` or `mvn` (or use the provided container)
- [ ] For Module 3: confirm `pip install google-adk` and `gcloud auth application-default login` work

!!! warning "Auth is the #1 failure point"
    Always run a pre-workshop auth check 30 minutes before the session:
    ```bash
    agy --print "Say READY" --print-timeout 30s
    ```
    If participants can't get a response, stop and debug before starting.

---

## Module-by-Module Delivery Notes

### Module 1 — SDLC Productivity (75 min)

**Key message:** agy replaces the mental overhead of navigating an unfamiliar codebase. It's not autocomplete — it's a senior engineer you can ask anything.

- **Demo first, exercise second.** Live-demo section 1.1 (code understanding) on your own codebase before asking participants to try theirs.
- **Common friction:** participants try to write perfect prompts. Encourage natural language. "Tell me how the auth works" is better than "Please explain the authentication architecture of this codebase."
- **The AGENTS.md moment:** section 1.5 is a high-value demo. Create an AGENTS.md live on screen and show how the next session is immediately smarter.
- **Plugin import demo (section 1.7):** run `agy plugin import gemini` live — the visual output is compelling. Note: **custom themes are silently dropped** during import and cannot be migrated. If a participant asks why their theme didn't carry over, this is expected behavior — there's no error, the component is simply skipped.

### Module 2 — Legacy Codebase Modernization (90 min)

**Key message:** strict mode + self-onboarding turns a week-long migration into a structured afternoon. The agent writes its own context, then executes it.

**Live demo script (recommended):**

1. Clone the .NET or Java target repo (pre-done for time)
2. Enter strict mode: `/permissions strict`
3. Run the investigation prompt — show participants the agent reading the whole codebase
4. Let the agent generate an AGENTS.md — read it aloud to show it captured real context
5. `ctrl+g` — open the generated plan in the editor, make one visible edit to show human control
6. Switch to `request-review`, execute Phase 1 only
7. Show `/rewind` — revert the phase if anything goes wrong
8. Total demo: ~15 min, then participants do it themselves

- **Common question:** "Can it do the whole migration?" — Yes, but the value is in reviewing and steering, not just watching it run. Encourage them to edit the plan.
- **Facilitator timing note:** Phase 0–1 together take ~20 min per participant. Let them work through Phase 2 while you circulate.

### Module 3 — Building AGY Agents with the SDK (90 min)

**Key message:** the CLI is for individuals. An SDK agent is a specialist service your whole team can call.

- **Setup gate:** ensure everyone has `google-adk` installed and Vertex AI auth working before starting. This is the most common blocker.
- **The `adk web .` moment:** once participants get their first agent running in the browser UI, the energy changes — they see it responding to their tools.
- **Model selection table:** emphasize Flash-lite for generation, Pro for orchestration. Cost-consciousness is a feature, not a compromise.
- **Exercise 11 (pipeline):** the `SequentialAgent` + `BaseAgent` guard pattern is the key architecture insight. Spend 5 min explaining zero-cost guards before they start.

### Module 4 — Multi-Agent & Advanced (60 min)

**Key message:** subagents + `/btw` is the qualitative leap. This is where agy becomes an orchestrator, not just a chatbot.

- **Subagent demo is the wow moment.** Spawn two agents live, show both running simultaneously.
- **/btw demo:** start a long-ish task (refactor a file), then use `/btw` mid-task. Show participants the cursor keeps moving while the injected note is incorporated.
- **Scheduling:** describe the pattern conceptually, don't demo live (latency makes it awkward in a workshop).

---

## Common Participant Questions

| Question | Answer |
| :-- | :-- |
| "What model does agy use?" | Use `/model` to see and switch. See [Models docs](https://www.antigravity.google/docs/models). |
| "How is this different from Gemini CLI?" | agy bridges plugins from Gemini CLI and Claude, has native subagent orchestration, and `/btw` mid-task steering. Gemini CLI reaches EOL June 18, 2026. |
| "Can I use my own API key?" | agy uses browser-based Google Sign-In. Enterprise users connect a GCP project. See [Enterprise docs](https://www.antigravity.google/docs/enterprise). |
| "Is the code sent to Google?" | See the [FAQ](https://www.antigravity.google/docs/faq) for data handling details. |
| "What about hooks?" | agy-cli supports hooks via `hooks.json`. See [Hooks docs](https://www.antigravity.google/docs/hooks). |
| "Where are conversation logs stored?" | `~/.gemini/antigravity-cli/conversations/` |
| "My Gemini CLI theme didn't import." | Expected — custom themes are silently dropped during `agy plugin import gemini`. Skills, MCP servers, and agents do carry over. |
| "Can I deploy SDK agents to Cloud Run?" | Yes — `adk deploy cloud_run`. See Module 3 section 3.6. |

---

## Troubleshooting During Workshop

| Symptom | Fix |
| :-- | :-- |
| `agy: command not found` | Check PATH. Run `which agy` or `which agy-cli`. |
| Auth error / 401 | Session credentials may have expired. Redistribute auth. |
| `agy plugin list` errors | Check that `~/.gemini/antigravity-cli/` exists |
| Slow responses | Check network. First run after idle may be slower due to workspace indexing. |
| Subagent doesn't spawn | Confirm the participant is in interactive mode (not `--print`) |
| `google-adk` import errors (M3) | Ensure venv is activated: `source .venv/bin/activate` |
| Vertex AI 403 (M3) | Run `gcloud auth application-default login` and confirm `GOOGLE_CLOUD_PROJECT` is set |

---

## Post-Workshop

1. Collect feedback using the standard workshop feedback form
2. Note any agy-cli bugs or unexpected behaviors observed — report to the agy-cli team
3. Any exercises that required workarounds should be flagged for doc updates in `CONTRIBUTING.md`
