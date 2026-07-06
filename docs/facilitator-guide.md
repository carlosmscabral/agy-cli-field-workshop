# Facilitator Guide

> Internal guide for workshop facilitators. Do not share with participants.

---

## Overview

This is a **4-module, ≈7-hour hands-on workshop** for Antigravity CLI. It is designed for developer audiences: engineers, tech leads, and solution architects evaluating or adopting Antigravity CLI.

---

## Delivery Formats

| Format | Modules | Duration |
| :-- | :-- | :-- |
| ⚡ Lightning | Module 1 + Module 2 highlights | 1.5 hrs |
| 📋 Half-day | Modules 1 + 2 | 2.5 hrs |
| 📦 Full day | Modules 1–3 | ≈5.5 hrs |
| 🏗️ Extended | All 4 modules + open lab | 7 hrs |

---

## Pre-Workshop Checklist

- [ ] **Pre-work is repo-agnostic:** participants have installed `agy` (standalone binary — no venv), set up `gcloud` + ADC + the Vertex env (`GOOGLE_CLOUD_PROJECT`/`GOOGLE_CLOUD_LOCATION`/`GOOGLE_GENAI_USE_VERTEXAI=True`), installed `uv`, and cloned both repos. **No shared workshop venv** *(see [setup.md](setup.md))*
- [ ] Auth details distributed (session-specific — confirm with agy-cli team)
- [ ] Participants have Git and a suitable demo codebase
- [ ] Facilitator has run through all exercises end-to-end on the current agy-cli version
- [ ] Screen sharing / projection tested
- [ ] For Modules 1/2: the sample app uses its **own** `.venv` (`cd ../agy-sample-app && python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt`) — this installs the app's real deps (incl. `pydantic[email]`), so its tests run in the right environment
- [ ] For Module 2: confirm participants can run `dotnet` or `mvn` (or use the provided container)
- [ ] For Module 3: confirm `uv` and `agents-cli` are installed (`uvx google-agents-cli setup`); `agents-cli scaffold` + `uv sync` manage the ADK project's env
- [ ] For Module 4: each SDK exercise creates its **own** project-local `.venv` with `pip install google-antigravity`; confirm `gcloud auth application-default login` works

!!! warning "Auth is the #1 failure point"
    Always run a pre-workshop auth check 30 minutes before the session:
    ```bash
    agy --print "Say READY" --print-timeout 30s
    ```
    If participants can't get a response, stop and debug before starting.

---

## Delivery Flow (every module)

Each module runs in **three beats**:

1. **① Facilitator presents** — walk through the module's numbered concept sections and run the live demos on the projector (your own codebase or the sample app). ≈10–20 min.
2. **② Participants work solo** — attendees do the module's **Core** exercises on their own; you circulate and unblock. **Optional** exercises are stretch goals for anyone who finishes early.
3. **③ Facilitator wraps up** — walk through each exercise's solution (live, or a pre-done result) and answer questions before moving on.

Exercises are tagged **Core** (everyone does) or **Optional** (stretch) in each module doc's "Exercises" section. Pre-run every exercise beforehand so you have a finished result to show in the wrap-up.

---

## Module-by-Module Delivery Notes

### Module 1 — Antigravity CLI Fundamentals (90 min)

**Key message:** agy replaces the mental overhead of navigating an unfamiliar codebase. It's not autocomplete — it's a senior engineer you can ask anything.

- **Demo first, exercise second.** Live-demo section 1.1 (code understanding) on your own codebase before asking participants to try theirs.
- **Common friction:** participants try to write perfect prompts. Encourage natural language. "Tell me how the auth works" is better than "Please explain the authentication architecture of this codebase."
- **The AGENTS.md moment:** section 1.5 is a high-value demo. Create an AGENTS.md live on screen and show how the next session is immediately smarter.
- **Custom Skills live-demo (section 1.7):** create a simple custom skill in `.agents/skills/code-reviewer/SKILL.md` live. Run `agy` and type `/skills` to show it loaded the skill. This demonstrates how teams can codify custom styles and expert knowledge without modifying source code.
- **Artifacts workflow (section 1.4a):** demo the plan → task list → walkthrough loop and the Artifact Review panel (`ctrl+r`). This is the co-steering story — reviewing milestones, not tool calls. Core exercise (ex15).
- **MCP (section 1.8):** frame MCP as *governed access*, not raw capability (the agent can already shell/`curl`). Demo the SQLite billing-db server, then set `strict` mode (`/config` → Tool Permissions) so shell is denied and the agent must use the MCP query tool — the enterprise "grant a scoped capability, not shell + secrets" story. Core exercise (ex16).
- **Core exercises:** First Session (ex01), Artifacts (ex15), Custom Skills (ex02), MCP (ex16). **Sandbox & Governance (ex09) is Optional** — a stretch lab; demo `agy --sandbox` briefly if time allows.

### Module 2 — Legacy Modernization & Advanced CLI (90 min)

**Key message:** strict mode + self-onboarding turns a week-long migration into a structured afternoon. The agent writes its own context, then executes it. The second half of the module layers on the advanced CLI features — subagents, mid-task steering, and non-interactive automation.

**Live demo script (recommended):**

1. Clone the .NET or Java target repo (pre-done for time)
2. Enter strict mode: `/config` → Tool Permissions → `strict`
3. Run the investigation prompt — show participants the agent reading the whole codebase
4. Let the agent generate an AGENTS.md — read it aloud to show it captured real context
5. `ctrl+g` — open the generated plan in the editor, make one visible edit to show human control
6. Switch to `request-review`, execute Phase 1 only
7. Show `/rewind` — revert the phase if anything goes wrong
8. Total demo: ≈15 min, then participants do it themselves

- **Common question:** "Can it do the whole migration?" — Yes, but the value is in reviewing and steering, not just watching it run. Encourage them to edit the plan.
- **Facilitator timing note:** Phase 0–1 together take ≈20 min per participant. Let them work through Phase 2 while you circulate.

**Advanced CLI half (subagents, `/btw`, automation):**

- **Key message:** subagents + `/btw` is the qualitative leap. This is where agy becomes an orchestrator, not just a chatbot.
- **Subagent demo is the wow moment.** Spawn two agents live, show both running simultaneously.
- **/btw demo:** start a long-ish task, then type a `/btw` note mid-task. Be accurate about the mechanism: the note is **queued** (not a live interrupt) and, under the `next-invocation` delivery strategy, picked up at the agent's next step to steer the remaining work; to hard-stop, press `Esc`/`ctrl+c`. Remind them `/btw` is a workshop convention (not a built-in command), and that the strongest no-stop co-steering is Artifacts inline comments.
- **Scheduling:** describe the pattern conceptually, don't demo live (latency makes it awkward in a workshop).

### Module 3 — ADK Agents with agents-cli (75 min)

**Key message:** agents-cli turns your coding agent into an ADK expert. The 7-phase lifecycle (scaffold → build → eval → deploy) is where agents go from demos to production.

- **Setup gate:** ensure `uv` and `agents-cli` are installed. Run `agents-cli info` to verify.
- **The eval loop is the teaching moment.** Spend time on Phase 4 (evaluation) — this is what differentiates a toy from a production agent. Let participants see scores fail, then iterate.
- **google-adk ≠ google-antigravity:** Module 4 uses `google-antigravity` (the Antigravity SDK). Module 3 (this module) uses `google-adk` (the ADK). They are different packages. `agents-cli scaffold` manages the right dependency automatically.
- **Exercise 10 pacing:** Parts 1–2 go fast (scaffold + build). Part 3–4 (eval + fix loop) is where time is spent. Emphasize that 5–10 iterations is normal.

### Module 4 — Advanced: Building Agents with the Antigravity SDK (90 min)

**Key message:** the CLI is for individuals. An SDK agent is a specialist service your whole team can call. This is the capstone module — the deepest point of the workshop.

- **Setup gate:** ensure everyone has `google-antigravity` installed and Vertex AI or AI Studio auth working before starting. This is the most common blocker.
- **Local run experience:** once participants get their first agent executing locally using `asyncio.run(main())` and printing tool call steps in the terminal, they see how `google-antigravity` connects plain Python functions as tools.
- **Model selection table:** emphasize Flash-lite for generation, Pro for orchestration. Cost-consciousness is a feature, not a compromise.
- **Exercise 6 (pipeline):** the `asyncio.gather` + `START_SUBAGENT` multi-agent pattern is the key architecture insight. Spend 5 min explaining how subagents compose before they start.

---

## Common Participant Questions

| Question | Answer |
| :-- | :-- |
| "What model does agy use?" | Use `/model` to see and switch. See [Models docs](https://www.antigravity.google/docs/models). |
| "How is this different from older assistants?" | `agy` provides workspace-level isolation, customizable Skills (`.agents/skills/`), native subagent orchestration, and `/btw` mid-task steering. |
| "Can I use my own API key / browser Sign-In / Enterprise GCP?" | `agy` uses browser-based Google Sign-In by default; for AI Studio you can set an API key. Enterprise users go through Vertex AI on their own GCP project — authenticate with `gcloud auth application-default login` (ADC) and set `GOOGLE_GENAI_USE_VERTEXAI=true`. See [Enterprise docs](https://www.antigravity.google/docs/enterprise). |
| "Is the code sent to Google?" | See the [FAQ](https://www.antigravity.google/docs/faq) for data handling details. |
| "What about hooks?" | `agy-cli` runs hooks defined in a `hooks.json` file in a customization root (`.agents/hooks.json` for a workspace, `~/.gemini/config/hooks.json` globally, or inside a plugin) — not under a `settings.json` key. See [Hooks docs](https://www.antigravity.google/docs/hooks). |
| "Where are conversation logs stored?" | `~/.gemini/antigravity/conversations/` |
| "Can I deploy SDK agents to Cloud Run?" | Yes — since Antigravity SDK agents are standard Python applications, you can containerize them and deploy using standard `gcloud run deploy`. See Module 4 section 4.9. |

---

## Troubleshooting During Workshop

| Symptom | Fix |
| :-- | :-- |
| `agy: command not found` | Check PATH. Run `which agy` or `which agy-cli`. |
| Auth error / 401 | Session credentials may have expired. Redistribute auth. |
| `agy plugin list` errors | Check that `~/.gemini/antigravity/` exists |
| Slow responses | Check network. First run after idle may be slower due to workspace indexing. |
| Subagent doesn't spawn | Confirm the participant is in interactive mode (not `--print`) |
| `google-antigravity` import errors (M4) | Ensure venv is activated: `source .venv/bin/activate` |
| Vertex AI 403 (M4) | Run `gcloud auth application-default login` and confirm `GOOGLE_CLOUD_PROJECT` is set |

---

## Post-Workshop

1. Collect feedback using the standard workshop feedback form
2. Note any agy-cli bugs or unexpected behaviors observed — report to the agy-cli team
3. Any exercises that required workarounds should be flagged for doc updates in `CONTRIBUTING.md`
