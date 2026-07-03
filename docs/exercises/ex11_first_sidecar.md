# Exercise 11: Your First Sidecar (SDK Triggers)

> **Duration:** 20 min | **Module:** 4 — Advanced: Building Agents with the Antigravity SDK

---

## Objective

Build a scheduled **daily standup sidecar** — a long-running Python process built with the Antigravity SDK that periodically wakes itself up and asks an agent to summarise your recent git activity. You'll use the SDK's **triggers** system (`every()` and `on_file_change()`) to drive an agent without any human typing a prompt.

---

## Background

A "sidecar" here is just a persistent Python program that hosts an `Agent` and lets **triggers** — not a human — start each turn. The Antigravity SDK ships two ready-made trigger factories:

- `every(seconds, handler)` — fire on a fixed interval (polling/schedule).
- `on_file_change(path, handler)` — fire when a watched path changes.

Each handler receives a `TriggerContext` and calls `await ctx.send(...)` to inject a message into the agent's conversation. This is the grounded, supported way to schedule agent work — there is no separate scheduler binary to install.

> [!NOTE]
> **Prerequisites:** `google-antigravity` installed in your virtualenv and your Vertex AI environment configured (`GOOGLE_CLOUD_PROJECT`, `GOOGLE_CLOUD_LOCATION`, `GOOGLE_GENAI_USE_VERTEXAI=True`). See the setup guide.

---

## Part 1: Create the Standup Sidecar (8 min)

Create a working directory and a script `standup_sidecar.py`:

```bash
mkdir -p ~/agy-sidecars && cd ~/agy-sidecars
```

```python
# standup_sidecar.py
import asyncio

from google.antigravity import Agent, LocalAgentConfig
from google.antigravity.hooks import policy
from google.antigravity.triggers import every, TriggerContext

# Fire once per day. Drop to 60 for a quick test (see the tip in Part 2).
STANDUP_INTERVAL_SECONDS = 24 * 60 * 60


async def run_standup(ctx: TriggerContext) -> None:
    """Injected on each interval — asks the agent to summarise recent git activity."""
    await ctx.send(
        "Summarise all git commits from the last 24 hours across my repos. "
        "Group by repo, list the most impactful changes first, and flag any "
        "commits that touch security-sensitive files."
    )


async def main() -> None:
    config = LocalAgentConfig(
        model="gemini-3.5-flash",
        system_instructions="You are a daily standup assistant that summarises git activity.",
        triggers=[every(STANDUP_INTERVAL_SECONDS, run_standup)],
        policies=[policy.allow_all()],  # required when the agent runs unattended
        workspaces=["."],
    )
    async with Agent(config) as agent:  # noqa: F841 — the context keeps triggers alive
        print("Standup sidecar running — fires every 24h. Press Ctrl-C to stop.")
        await asyncio.Event().wait()  # keep the process alive so triggers can fire


if __name__ == "__main__":
    asyncio.run(main())
```

**Key decisions:**

- `triggers=[every(...)]` — the SDK's built-in interval trigger drives each turn.
- `policies=[policy.allow_all()]` — an unattended sidecar can't stop to ask you for approval.
- `await asyncio.Event().wait()` — a standard idiom to keep the process alive; the agent keeps servicing triggers until you stop it.

---

## Part 2: Run and Verify (6 min)

Run the sidecar from your activated virtualenv:

```bash
python standup_sidecar.py
```

You should see the "Standup sidecar running" line and the process stays in the foreground.

> [!TIP]
> The daily interval won't fire during a 20-minute lab. To see it work now, temporarily set `STANDUP_INTERVAL_SECONDS = 60`, run again, and wait ≈60 seconds — the agent will produce a git summary on its own. **Remember to change it back.**

---

## Part 3: File-Watcher Sidecar (6 min)

Swap the schedule for a file watcher using `on_file_change()`. Create `watcher_sidecar.py`:

```python
# watcher_sidecar.py
import asyncio

from google.antigravity import Agent, LocalAgentConfig
from google.antigravity.hooks import policy
from google.antigravity.triggers import on_file_change, TriggerContext

WATCH_PATH = "./important-config.yaml"


async def on_change(ctx: TriggerContext, changes) -> None:
    paths = [c.path for c in changes]
    await ctx.send(
        f"These files just changed: {paths}. "
        "Review the changes and flag anything risky or misconfigured."
    )


async def main() -> None:
    config = LocalAgentConfig(
        model="gemini-3.5-flash",
        triggers=[on_file_change(WATCH_PATH, on_change)],
        policies=[policy.allow_all()],
        workspaces=["."],
    )
    async with Agent(config):  # keep the context open so the watcher stays active
        print(f"Watching {WATCH_PATH} for changes. Press Ctrl-C to stop.")
        await asyncio.Event().wait()


if __name__ == "__main__":
    asyncio.run(main())
```

Run it, then in another terminal `echo "# edit" >> important-config.yaml` and watch the agent react.

---

## Completion Criteria

- [ ] `standup_sidecar.py` runs and prints the "running" banner
- [ ] With a short test interval, the scheduled trigger fires and the agent produces a git summary unprompted
- [ ] `watcher_sidecar.py` reacts when the watched file changes
- [ ] You can explain how `every()` / `on_file_change()` + `TriggerContext.send()` drive an agent without human input
