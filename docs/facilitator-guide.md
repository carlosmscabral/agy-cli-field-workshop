# Facilitator Guide

> Internal guide for workshop facilitators. Do not share with participants.

---

## Overview

This is a **single-track, ≈2-hour hands-on workshop** for Antigravity CLI (`agy`), built around one real codebase — the `agy-sample-app` FastAPI billing API. It follows an end-to-end software story across five beats: **Discovery → Planning & Build → Coding Standards → Governed Access → Fixes & Security.** Audience: engineers, tech leads, and solution architects evaluating or adopting `agy`.

---

## Delivery Formats

| Format | Beats | Duration |
| :-- | :-- | :-- |
| ⚡ Lightning | Beats 1, 2, 5 (Discovery, Artifacts, Subagents) | ~1 hr |
| 📋 Standard | All 5 beats | ~2 hrs |

---

## Pre-Workshop Checklist

- [ ] **Enterprise pre-work done:** participants installed `agy` (standalone binary), authenticated with `gcloud` + ADC + the Vertex env (`GOOGLE_CLOUD_PROJECT` / `GOOGLE_CLOUD_LOCATION` / `GOOGLE_GENAI_USE_VERTEXAI=True`), installed `uv`, and cloned the sample app (`agy-sample-app`) *(see [setup.md](setup.md))*
- [ ] The admin has granted attendees `roles/aiplatform.user` on the workshop project
- [ ] **Sample app venv ready:** `cd ../agy-sample-app && python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt` (installs the app's real deps incl. `pydantic[email]`, so its tests run in the right environment)
- [ ] Facilitator has run all five beats end-to-end on the current `agy` version
- [ ] Screen sharing / projection tested

!!! warning "Auth is the #1 failure point"
    Run a pre-workshop auth check 30 minutes before the session:
    ```bash
    agy --print "Say READY" --print-timeout 30s
    ```
    If participants can't get a response, stop and debug before starting.

---

## Delivery Flow (every beat)

Each beat runs in **three parts**:

1. **① Facilitator presents** — walk the relevant concept from the [Overview](overview.md) and run the live demo on the projector against `agy-sample-app`. ≈5 min.
2. **② Participants work solo** — attendees do the beat's exercise on their own; you circulate and unblock. ≈15–20 min.
3. **③ Facilitator wraps up** — walk the solution (live or pre-done) and answer questions before moving to the next beat.

Do the beats **in order** — each builds on the state the previous one left in `agy-sample-app` (e.g. Beat 2 adds `/health`; Beat 5 refactors code Beat 3 touched). Pre-run every beat beforehand so you have a finished result to show.

---

## Beat-by-Beat Delivery Notes

### Beat 1 — First Session (Discovery)

**Key message:** `agy` replaces the mental overhead of navigating an unfamiliar codebase — it's a senior engineer you can ask anything, not autocomplete.

- **Demo first.** Ask the sample app "what does this project do?" and "what are the top files to read?" live before participants try.
- **Encourage natural language** — "tell me how auth works" beats a carefully engineered prompt.
- **The `AGENTS.md` moment** is high-value: create it live, start a *fresh interactive* session, and show it's immediately smarter. Emphasize: verify in a fresh interactive session, **not** `agy --print` (print mode skips workspace context).
- **Tool Permissions:** show `/config` → Tool Permissions and the four modes; note the allow-list persists globally in `~/.gemini/antigravity-cli/settings.json` (a workspace `.agents/settings.json` is deliberately ignored — a security boundary).

### Beat 2 — Artifacts (Plan, Review & Build)

**Key message:** review structured milestones, not raw tool calls. This is agy's co-steering differentiator.

- Demo `/planning` → the Implementation Plan artifact → the Artifact Review panel (`/artifact` or `ctrl+r`) → an inline comment (`c` → type → `esc` → `y`) → Task List → Walkthrough.
- The concrete outcome is the `GET /health` endpoint that the sample app deliberately lacks. Verify with `!python3 -m pytest -q` or `curl`.

### Beat 3 — Skills & Rules (Coding Standards)

**Key message:** codify team conventions once; every session applies them.

- Live-create a Custom Skill in `.agents/skills/…/SKILL.md`; run `/skills` to show it loaded.
- Stress the **Rule format**: `.agents/rules/<name>.md` with `trigger` frontmatter (`always_on`). A bare `.agents/rules.md` or a file without frontmatter is silently ignored.
- Show the rule take effect on new code (the `format_currency` helper) via `/diff`.

### Beat 4 — Governed Access with MCP

**Key message:** MCP's value is *governance*, not raw capability — the agent can already shell/`curl`. Demo the SQLite billing-db server, then set `strict` mode (`/config` → Tool Permissions) so shell is denied and the agent must answer through the MCP query tool.

- **Gotcha:** if `/mcp` doesn't list the server, a broken server in *another* config (often a stale global `~/.gemini/config/mcp_config.json`) can suppress the whole list — check for an errored server.

### Beat 5 — Subagents (Fixes & Refactor)

**Key message:** subagents turn `agy` into an orchestrator. This is the wow moment — spawn two review agents live and show both running in `/agents`.

- Demo native parallel subagents (security + test-coverage) and the `ctrl+j` / `ctrl+k` approval keys.
- Then the payoff: **spawn a subagent in inherit mode** to refactor `app/billing.py` (dedupe currency formatters, fix the bare `except:`) and move the hard-coded key to the environment. Approve its edits with `ctrl+k`; verify with `/diff` + `pytest`.
- **Framing gotcha (the #1 issue):** a "security auditor / scan for hard-coded secrets & vulnerabilities" prompt makes the model **refuse**. Frame it as a *senior engineer suggesting hardening improvements* — it surfaces the same hard-coded key without declining. (Custom `.agents/agents/` subagent files are intentionally **not** taught here — they aren't surfaced reliably on current builds, so the beat uses spawned/native subagents.)

---

## Common Participant Questions

| Question | Answer |
| :-- | :-- |
| "What model does agy use?" | Use `/model` to see and switch. See [Models docs](https://www.antigravity.google/docs/models). |
| "How is this different from older assistants?" | Workspace-level isolation, customizable Skills/Rules (`.agents/`), governed MCP access, and native subagent orchestration. |
| "How does enterprise auth work?" | Vertex AI on your own GCP project — `gcloud auth application-default login` (ADC) + `GOOGLE_GENAI_USE_VERTEXAI=True`. See [Enterprise docs](https://www.antigravity.google/docs/enterprise). |
| "Is the code sent to Google?" | See the [FAQ](https://www.antigravity.google/docs/faq) for data handling details. |
| "Where do permissions live?" | Globally in `~/.gemini/antigravity-cli/settings.json`. A workspace `.agents/settings.json` is deliberately not read (security). |
| "What about hooks?" | Defined in a `hooks.json` file in a customization root (`.agents/hooks.json`, `~/.gemini/config/hooks.json`, or a plugin) — not under a `settings.json` key. See [Hooks docs](https://www.antigravity.google/docs/hooks). |
| "Where are conversation logs stored?" | `~/.gemini/antigravity/conversations/` |

---

## Troubleshooting During Workshop

| Symptom | Fix |
| :-- | :-- |
| `agy: command not found` | Check PATH. Run `which agy`. |
| Auth error / 401 / Vertex 403 | Run `gcloud auth application-default login`; confirm `GOOGLE_CLOUD_PROJECT` set and `roles/aiplatform.user` granted. |
| `agy plugin list` errors | Check that `~/.gemini/antigravity/` exists. |
| Slow responses | Check network. First run after idle is slower due to workspace indexing. |
| Subagent doesn't spawn | Confirm the participant is in interactive mode (not `--print`). |
| Security review refused (`"cannot fulfill…vulnerabilities"`) | Reframe as a constructive hardening review, not a "scan for secrets/vulnerabilities." |
| MCP server missing from `/mcp` | A broken server in another config can hide the list — fix/remove the errored one. |
| `ModuleNotFoundError` in the sample app | Activate its venv: `source .venv/bin/activate`. |

---

## Post-Workshop

1. Collect feedback using the standard workshop feedback form.
2. Note any `agy` bugs or unexpected behaviors — report to the agy-cli team.
3. Flag any beat that required a workaround for a doc update in `CONTRIBUTING.md`.
