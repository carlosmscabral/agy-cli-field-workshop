# Exercise 12: ADK Agent Lifecycle with agents-cli

> **Duration:** 45 min | **Module:** 5 — Building ADK Agents with agents-cli

---

## Objective

Use `agents-cli` to scaffold, build, evaluate, and iterate on an ADK agent — following the full development lifecycle. You'll build a **Meeting Notes Summarizer** agent that takes raw meeting transcripts and produces structured action items.

---

## Prerequisites

- `agents-cli` installed (`uvx google-agents-cli setup`)
- `uv` installed ([install guide](https://docs.astral.sh/uv/getting-started/installation/))
- A Google Cloud project or [AI Studio API key](https://aistudio.google.com/apikey)
- Antigravity CLI (agy) installed and working

---

## Part 1: Scaffold the Agent (10 min)

### Step 1: Create the Project

Open an Antigravity CLI session and scaffold:

```bash
agents-cli scaffold create meeting-notes \
  --agent adk \
  --prototype \
  --agent-guidance-filename GEMINI.md
```

!!! info "Why `--prototype`?"
    The prototype flag skips CI/CD and Terraform — you focus on getting the agent working first, then add deployment later with `scaffold enhance`.

### Step 2: Explore the Scaffolded Structure

```bash
cd meeting-notes
tree -L 2
```

You should see:

```text
meeting-notes/
├── app/
│   ├── __init__.py
│   ├── agent.py
│   └── tools.py
├── tests/
│   └── eval/
│       ├── datasets/
│       │   └── basic-dataset.json
│       └── eval_config.yaml
├── .env
├── agents-cli-manifest.yaml
├── pyproject.toml
├── GEMINI.md
└── Makefile
```

### Step 3: Install Dependencies

The scaffold creates a `pyproject.toml` with the correct ADK dependency. Install it:

```bash
uv sync
```

!!! note "google-adk ≠ google-antigravity"
    Module 3 uses `google-antigravity` (the Antigravity SDK for building agents within agy). Module 5 uses `google-adk` (the Agent Development Kit for building standalone ADK agents deployed to Google Cloud). They are different packages with different APIs. `agents-cli scaffold` always sets up `google-adk` automatically.

### Step 4: Configure Environment

```bash
# If using AI Studio:
echo 'GOOGLE_API_KEY=your-key-here' >> .env

# If using Google Cloud:
echo 'GOOGLE_CLOUD_PROJECT=your-project-id' >> .env
echo 'GOOGLE_CLOUD_LOCATION=us-east1' >> .env
```

---

## Part 2: Build the Agent (15 min)

### Step 1: Define the Tool

Edit `app/tools.py` to add a transcript extraction tool:

```python
def extract_action_items(transcript: str) -> dict:
    """Parse a meeting transcript and extract structured action items.

    Args:
        transcript: The raw meeting transcript text.

    Returns:
        A dict containing the parsed action items with assignees and deadlines.
    """
    # In a real agent, this might call a document API or parse structured formats.
    # For now, return the transcript for the LLM to process.
    return {
        "transcript_length": len(transcript),
        "raw_text": transcript[:5000],  # Cap at 5K chars for context window
        "status": "ready_for_analysis",
    }


def format_summary(
    title: str,
    attendees: list[str],
    action_items: list[dict],
    key_decisions: list[str],
) -> str:
    """Format the meeting summary into a structured markdown report.

    Args:
        title: Meeting title or topic.
        attendees: List of attendee names.
        action_items: List of dicts with 'task', 'assignee', and 'deadline' keys.
        key_decisions: List of key decisions made during the meeting.

    Returns:
        A formatted markdown string with the complete meeting summary.
    """
    lines = [f"# {title}", ""]
    lines.append(f"**Attendees:** {', '.join(attendees)}")
    lines.append("")
    lines.append("## Action Items")
    for i, item in enumerate(action_items, 1):
        assignee = item.get("assignee", "Unassigned")
        deadline = item.get("deadline", "TBD")
        lines.append(f"{i}. **{item['task']}** — {assignee} (due: {deadline})")
    lines.append("")
    lines.append("## Key Decisions")
    for decision in key_decisions:
        lines.append(f"- {decision}")
    return "\n".join(lines)
```

### Step 2: Configure the Agent

Edit `app/agent.py`:

```python
from google.adk import Agent
from app.tools import extract_action_items, format_summary

root_agent = Agent(
    name="meeting_notes",
    model="gemini-3.5-flash",
    instruction="""You are a meeting notes summarizer. Your job is to take raw
meeting transcripts and produce structured, actionable summaries.

Workflow:
1. Use `extract_action_items` to process the raw transcript
2. Identify: attendees, action items (with assignees + deadlines), key decisions
3. Use `format_summary` to produce the final structured output

Rules:
- Every action item MUST have an assignee and a deadline
- If a deadline is not mentioned, mark it as "TBD"
- If an assignee is not clear, mark it as "Unassigned"
- Key decisions must be concrete, not vague summaries
- Never fabricate attendees or actions not in the transcript
""",
    tools=[extract_action_items, format_summary],
)
```

### Step 3: Smoke Test

```bash
agents-cli run "Summarize this meeting: Alice and Bob discussed the Q3 launch. \
Alice will prepare the marketing deck by Friday. Bob will review the API docs by \
next Monday. They decided to use Cloud Run for deployment and skip the staging \
environment for the MVP."
```

Verify:

- [ ] Agent calls `extract_action_items`
- [ ] Agent calls `format_summary` with structured data
- [ ] Output has action items with assignees and deadlines
- [ ] Key decisions are listed

---

## Part 3: Write Eval Cases (10 min)

### Step 1: Create the Eval Dataset

Edit `tests/eval/datasets/basic-dataset.json`:

```json
{
  "eval_cases": [
    {
      "eval_case_id": "simple_meeting",
      "prompt": {
        "role": "user",
        "parts": [
          {
            "text": "Summarize this meeting transcript:\n\nMeeting: Sprint Planning\nDate: 2026-06-01\n\nAlice: Let's review the backlog. The auth migration is top priority.\nBob: I can take the auth migration. Should be done by end of week.\nCarol: I'll handle the API rate limiting. Need two weeks for that.\nAlice: Agreed. Let's also deprecate the v1 endpoints — Carol, can you add that to your scope?\nCarol: Sure, I'll bundle it with the rate limiting work.\nBob: One more thing — we decided to use Redis for session caching instead of Memcached.\nAlice: Confirmed. Meeting adjourned."
          }
        ]
      }
    },
    {
      "eval_case_id": "meeting_no_deadlines",
      "prompt": {
        "role": "user",
        "parts": [
          {
            "text": "Summarize this meeting:\n\nTeam standup. Dave mentioned he's blocked on the database schema review. Eve said she'll look at it when she gets a chance. Frank reported that the CI pipeline is green. No specific deadlines were discussed."
          }
        ]
      }
    },
    {
      "eval_case_id": "meeting_with_decisions",
      "prompt": {
        "role": "user",
        "parts": [
          {
            "text": "Meeting notes: Architecture Review\n\nParticipants: Grace, Heidi, Ivan\n\nGrace proposed moving from monolith to microservices. After discussion, the team decided to start with extracting the payment service first. Heidi will create the service boundary document by next Wednesday. Ivan will set up the new GKE cluster by Friday. They also decided to keep the monolith running in parallel for 3 months during migration. Grace will present the migration timeline to leadership next Monday."
          }
        ]
      }
    }
  ]
}
```

### Step 2: Configure Metrics

Edit `tests/eval/eval_config.yaml`:

```yaml
metrics_to_run:
  - multi_turn_task_success
  - multi_turn_tool_use_quality
  - final_response_quality
  - meeting_summary_quality

custom_metrics:
  - name: meeting_summary_quality
    prompt_template: |
      Evaluate the agent's meeting summary on these criteria (1-5 each):

      1. **Completeness**: Are all action items from the transcript captured?
      2. **Attribution**: Does every action item have an assignee?
      3. **Deadlines**: Are deadlines captured or correctly marked as TBD?
      4. **Decisions**: Are key decisions listed accurately?
      5. **No hallucination**: Does the summary contain ONLY information from the transcript?

      Transcript/Prompt: {prompt}
      Agent response: {response}
      Full trace: {agent_data}

      Return JSON: {"score": <1-5 average>, "explanation": "<detailed reasoning>"}
```

### Step 3: Run the Eval

```bash
# Generate traces (runs agent on each eval case)
agents-cli eval generate

# Grade the traces
agents-cli eval grade
```

Review the output. If any metric scores below threshold, proceed to Part 4.

---

## Part 4: The Eval-Fix Loop (10 min)

This is where the real work happens. For each failing metric:

### Step 1: Read the Results

```bash
# Open the HTML report (easiest to read)
open artifacts/grade_results/results_*.html

# Or check the JSON programmatically
cat artifacts/grade_results/results_*.json | python -m json.tool | head -50
```

### Step 2: Diagnose and Fix

Common fixes:

| Symptom | Fix |
| :-- | :-- |
| Agent skips `extract_action_items` | Strengthen the instruction: "You MUST call extract_action_items first" |
| Missing assignees | Add to instruction: "Every action item MUST have an assignee — use 'Unassigned' if unclear" |
| Hallucinated action items | Add: "NEVER add action items not explicitly stated in the transcript" |
| Low tool_use_quality | Improve tool docstrings — be more specific about parameters |

### Step 3: Re-Evaluate and Compare

```bash
# Save the previous results
cp artifacts/grade_results/results_*.json artifacts/grade_results/baseline.json

# Re-run
agents-cli eval generate
agents-cli eval grade

# Compare
agents-cli eval compare \
  artifacts/grade_results/baseline.json \
  artifacts/grade_results/results_*.json
```

Repeat until all metrics pass.

---

## Stretch Goals

### Add Deployment

```bash
# Add Cloud Run deployment
agents-cli scaffold enhance . --deployment-target cloud_run

# Deploy
agents-cli deploy
```

### Add CI/CD

```bash
agents-cli scaffold enhance . --cicd-runner github_actions
```

### Synthesize More Eval Cases

```bash
# Auto-generate multi-turn eval scenarios
agents-cli eval dataset synthesize \
  -n 5 \
  --instruction "User provides meeting transcripts of varying complexity" \
  --max-turns 3
```

### Let agy Drive the Whole Flow

Open an agy session and say:

```text
> Use agents-cli to improve my meeting-notes agent.
  The eval scores for meeting_summary_quality are low.
  Analyze the failures and fix them.
```

Watch agy load the eval skill, run `eval analyze`, identify failure clusters, and iteratively fix the agent.

---

## Completion Criteria

- [ ] Project scaffolded with `agents-cli scaffold create`
- [ ] Two tools defined: `extract_action_items` and `format_summary`
- [ ] Agent instruction includes clear workflow and rules
- [ ] Smoke test passes with `agents-cli run`
- [ ] Three eval cases written in `basic-dataset.json`
- [ ] Custom `meeting_summary_quality` metric defined
- [ ] `agents-cli eval generate` + `eval grade` runs successfully
- [ ] At least one eval-fix iteration completed with `eval compare` showing improvement

---

## Key Takeaways

1. **`agents-cli scaffold create`** bootstraps the entire project structure — don't set it up manually
2. **`agents-cli eval` is not optional** — it's the difference between a demo and a production agent
3. **pytest ≠ eval** — pytest tests code correctness; eval tests agent behavior
4. **The eval-fix loop is iterative** — expect 5–10+ rounds; this is normal
5. **agents-cli skills** make your coding agent (agy) an expert at ADK development automatically
