# Module 3: Building AGY Agents with the SDK

<div class="module-header" markdown>
**Duration:** ~90 minutes  
**Goal:** Build a production-ready AGY agent from scratch using the Google ADK — tools, orchestration, skills, session state, and deployment to Cloud Run.  
**Exercises:** [Exercise 10: Your First Agent](../exercises/ex10_first_agent.md) · [Exercise 11: Multi-Agent Pipeline](../exercises/ex11_multi_agent_pipeline.md)
</div>

> 📖 Sources: [ADK Docs](https://google.github.io/adk-docs/) · [google-adk PyPI](https://pypi.org/project/google-adk/) · [Subagents](https://antigravity.google/docs/subagents) · [Skills](https://antigravity.google/docs/skills)

---

## Why Build an Agent Instead of Just Using the CLI?

The CLI is a **general-purpose assistant**. An agent you build with the SDK is a **specialist** — it has a narrow job, domain-specific tools, a carefully engineered system prompt, and it can be deployed as a service that your whole team calls.

| | Antigravity CLI | AGY SDK Agent |
|:--|:--|:--|
| **Who uses it** | Individual developer | Team / API consumers |
| **Customization** | AGENTS.md + plugins | Full code control |
| **Tools** | Built-in CLI tools | Any Python function you write |
| **Deployment** | Local interactive session | Cloud Run service, callable via API |
| **Multi-agent** | Subagents in CLI session | `SequentialAgent`, `ParallelAgent`, `LlmAgent` |

---

## 3.1 — SDK Setup <span class="duration-badge">10 min</span>

### Prerequisites

- Python 3.11+
- GCP credentials: `gcloud auth application-default login`

### Install

```bash
python -m venv .venv
source .venv/bin/activate
pip install google-adk
```

### Authenticate with Vertex AI

```bash
gcloud auth application-default login
export GOOGLE_CLOUD_PROJECT="your-project-id"
export GOOGLE_CLOUD_LOCATION="global"
export GOOGLE_GENAI_USE_VERTEXAI="True"
```

> **Why Vertex AI?** Vertex AI gives you enterprise billing, audit logs, VPC-SC controls, and access to the full Gemini model lineup. For production agents, always use Vertex AI over API keys.

---

## 3.2 — Core Primitives: Agent, Tool, Skill <span class="duration-badge">20 min</span>

The ADK has three building blocks. Learn these and you can build anything.

### The Tool

A tool is a plain Python function. The agent decides when to call it based on the docstring — that's the contract.

```python
def get_file_contents(file_path: str) -> str:
    """Read and return the contents of a file at the given path.

    Args:
        file_path: Absolute or relative path to the file.

    Returns:
        The file contents as a string, or an error message if not found.
    """
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            return f.read()
    except FileNotFoundError:
        return f"Error: File not found at {file_path}"
```

> **Critical rules for tools:**
> - Use explicit type annotations — `str`, `int`, `bool`, `list[str]`. No `typing.Optional`.
> - Use a default value of `None` for optional parameters: `param: str = None`
> - The docstring is the tool's interface — the agent reads it to decide when and how to call the tool. Write it for the agent, not a human.
> - Keep tools narrow and focused. One job per tool.

### The Agent

An agent wraps a model, a system prompt, and a list of tools:

```python
from google.adk.agents import Agent

root_agent = Agent(
    name="code_reviewer",
    model="gemini-3.1-flash-lite-preview",
    instruction="""You are a code reviewer specializing in Python.
    When given a file path, read the file and provide a structured review covering:
    - Correctness and edge cases
    - Code style and readability
    - Security concerns
    - Suggested improvements

    Always read the file first before commenting. Be specific — cite line numbers.
    """,
    tools=[get_file_contents],
)
```

### Model Selection

Match the model to the job. Cost-conscious policy:

| Role | Model | Rationale |
|:--|:--|:--|
| Orchestration, routing, planning | `gemini-3.1-pro-preview` | Complex intent classification, multi-step reasoning |
| Document generation, code review | `gemini-3.1-flash-lite-preview` | High-throughput, cost-efficient with good prompting |
| Adversarial review, compliance | `gemini-3.1-pro-preview` | Needs deep reasoning to find non-obvious gaps |
| Zero-cost guards and checks | `BaseAgent` (no model) | Programmatic heuristics — no tokens consumed |

> **Never use** `gemini-1.5-flash`, `gemini-1.5-pro`. Deprecated.

### The Skill

Skills are SKILL.md files loaded at runtime to inject domain knowledge. This keeps your system prompt lean and makes expertise portable:

```python
from pathlib import Path
import re

def load_skill(skill_name: str) -> str:
    """Load a SKILL.md and strip YAML frontmatter."""
    skill_path = Path("skills") / skill_name / "SKILL.md"
    if skill_path.exists():
        content = skill_path.read_text(encoding="utf-8")
        return re.sub(r'^---\n.*?---\n', '', content, flags=re.DOTALL).strip()
    return ""

review_guidelines = load_skill("python-review")

root_agent = Agent(
    name="code_reviewer",
    model="gemini-3.1-flash-lite-preview",
    instruction=f"""You are a code reviewer.

## Review Guidelines
{review_guidelines}
""",
    tools=[get_file_contents],
)
```

> **Why skills instead of hardcoding?** Changing review guidelines means editing `SKILL.md`, not touching agent code. Different teams can swap skill packs. New frameworks get a new skill — the agent code doesn't change.

---

## 3.3 — Session State: Passing Context Through Pipelines <span class="duration-badge">10 min</span>

In multi-agent pipelines, agents communicate through **session state** — not conversation history. This is critical for token efficiency and reliability.

### Why Session State?

Sub-agents in a pipeline use `include_contents="none"` — they don't see the conversation. They only see what's written to session state. This:

- Eliminates token bloat from multi-turn history
- Makes each step deterministic (reads from explicit keys, not implicit context)
- Lets you inspect the pipeline's data at every step

### Writing to State (Tool Pattern)

```python
from google.adk.tools import FunctionTool

def seed_pipeline_context(
    topic: str,
    audience: str,
    depth: str,
    tool_context,  # injected by ADK
) -> dict:
    """Seeds structured context into session state for downstream sub-agents.

    Args:
        topic: The main subject to process.
        audience: Target audience (e.g. 'senior engineers', 'end users').
        depth: Depth level: 'overview', 'detailed', or 'comprehensive'.

    Returns:
        Confirmation dict with the seeded keys.
    """
    tool_context.state["topic"] = topic
    tool_context.state["audience"] = audience
    tool_context.state["depth"] = depth
    return {"status": "context_seeded", "keys": ["topic", "audience", "depth"]}
```

### Reading from State (Sub-Agent Pattern)

```python
from google.adk.agents import LlmAgent

section_writer = LlmAgent(
    name="section_writer",
    model="gemini-3.1-flash-lite-preview",
    include_contents="none",  # No conversation history — state only
    instruction="""Write a detailed section based on the context provided.

Topic: {topic}
Audience: {audience}
Depth: {depth}
Outline: {document_outline}
""",
    output_key="written_section",  # Writes result back to state
)
```

> ADK substitutes `{key}` placeholders in the instruction from session state automatically.

---

## 3.4 — Multi-Agent Orchestration <span class="duration-badge">20 min</span>

ADK gives you three orchestration primitives:

### SequentialAgent — Steps in Order

Run sub-agents one after another. Output of each step feeds the next via session state:

```python
from google.adk.agents import SequentialAgent

pipeline = SequentialAgent(
    name="review_pipeline",
    sub_agents=[
        file_reader,      # Step 1: Read the code
        issue_detector,   # Step 2: Find issues
        fix_suggester,    # Step 3: Suggest fixes
        report_writer,    # Step 4: Format the report
    ],
)
```

### ParallelAgent — Independent Work Simultaneously

Run sub-agents at the same time. Use when steps don't depend on each other:

```python
from google.adk.agents import ParallelAgent

parallel_analysis = ParallelAgent(
    name="parallel_review",
    sub_agents=[
        security_scanner,    # Looks for vulnerabilities
        style_checker,       # Checks code style
        test_coverage_check, # Maps test gaps
    ],
)
```

> **When to use parallel:** Any time you have N independent analyses that could run simultaneously. This cuts wall-clock time by 60–80% compared to sequential.

### LlmAgent — Conditional Routing

An LLM decides which sub-agent to invoke based on input:

```python
from google.adk.agents import LlmAgent

orchestrator = LlmAgent(
    name="review_orchestrator",
    model="gemini-3.1-pro-preview",
    instruction="""Classify the incoming request and route to the correct agent.
    
    - If the user wants code reviewed: route to code_reviewer
    - If the user wants compliance checked: route to compliance_analyst
    - If the user wants both: route to code_reviewer first, then compliance_analyst
    """,
    sub_agents=[code_reviewer, compliance_analyst],
)
```

> Use `gemini-3.1-pro-preview` for orchestrators. Routing mistakes are expensive — a cheaper model routing to the wrong agent wastes the entire pipeline's compute.

### Zero-Cost Guards (BaseAgent)

`BaseAgent` runs Python logic with no model call — no tokens, no latency:

```python
from google.adk.agents import BaseAgent
from google.adk.invocation_context import InvocationContext

class DriftDetector(BaseAgent):
    """Checks whether gathered research matches the original topic.
    Aborts the pipeline early if research drifted off-topic.
    Uses keyword overlap heuristic — zero token cost.
    """
    async def _run_async_impl(self, ctx: InvocationContext):
        topic_keywords = set(ctx.session.state.get("topic", "").lower().split())
        research = ctx.session.state.get("research_summary", "").lower()
        
        overlap = sum(1 for word in topic_keywords if word in research)
        overlap_ratio = overlap / max(len(topic_keywords), 1)
        
        if overlap_ratio < 0.3:
            ctx.session.state["drift_detected"] = True
            # Raising here aborts the pipeline
            raise ValueError(f"Research drifted: only {overlap_ratio:.0%} keyword overlap")
        
        ctx.session.state["drift_detected"] = False
```

> **The pattern:** Put zero-cost guards between expensive steps. A drift detector that catches a wrong-topic research run saves the entire generation pipeline's compute.

---

## 3.5 — Running and Testing Locally <span class="duration-badge">10 min</span>

### Interactive Testing with ADK Web

```bash
adk web .
```

Opens a browser UI. Select your agent, send messages, inspect session state at each step. The best way to iterate quickly.

### Non-Interactive Testing

```bash
# Run a single prompt through your agent
adk run . --prompt "Review the file at src/auth/login.py"

# Run evaluation suite against golden test cases
adk eval . --eval-set evals/review_agent.evalset.json
```

### Eval File Structure

```json
{
  "eval_set_id": "code_reviewer_evals",
  "eval_cases": [
    {
      "eval_id": "basic_review",
      "conversation": [
        {
          "role": "user",
          "parts": [{ "text": "Review src/auth/login.py" }]
        }
      ],
      "expected_tool_use": [
        { "tool_name": "get_file_contents", "tool_input": { "file_path": "src/auth/login.py" } }
      ],
      "reference": "The review should identify the hardcoded secret on line 12."
    }
  ]
}
```

> **Golden test philosophy:** Don't just test "does it produce output." Test "does it produce the right output for a known input." The eval set is your regression guard — run it before every deploy.

---

## 3.6 — Deployment to Cloud Run <span class="duration-badge">10 min</span>

```bash
# Deploy to Cloud Run
adk deploy cloud_run \
  --project gpu-launchpad-playground \
  --region us-central1 \
  --service-name paul-sdlc-code-reviewer \
  .
```

> **Naming convention:** Always prefix with `paul-sdlc-` when deploying to `gpu-launchpad-playground`.

### What Gets Deployed

ADK packages your agent directory into a container, deploys it as a Cloud Run service, and exposes an HTTP endpoint. The service accepts requests in the ADK session protocol.

### Calling the Deployed Agent

```bash
curl -X POST \
  "https://paul-sdlc-code-reviewer-xxx-uc.a.run.app/run" \
  -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"user_id": "workshop", "session_id": "session-1", "new_message": {"role": "user", "parts": [{"text": "Review src/auth/login.py"}]}}'
```

---

## 3.7 — Project Structure Conventions <span class="duration-badge">5 min</span>

Structure your agent project for maintainability and ADK compatibility:

```
my_agent/
├── agent.py                  # root_agent definition — ADK entry point
├── tools/
│   ├── __init__.py
│   ├── file_reader.py        # One tool per file
│   └── search_tool.py
├── skills/
│   └── domain-expertise/
│       └── SKILL.md          # Portable skill packs
├── sub_agents/               # For multi-agent pipelines
│   ├── researcher.py
│   └── writer.py
├── evals/
│   └── agent.evalset.json    # Golden test cases
├── tests/
│   ├── test_file_reader.py
│   └── test_search_tool.py
├── pyproject.toml            # Dependencies
└── README.md
```

> **ADK entry point rule:** ADK looks for `root_agent` in `agent.py` at the package root. This name is required — don't rename it.

---

## Hands-On Exercise

<div class="exercise-card" markdown>

### :material-code-braces: Exercise 10: Your First AGY Agent

**File:** `exercises/ex10_first_agent.md`  
**Duration:** 45 min  
**Build:** A **Code Review Agent** that reads files, identifies issues, and produces a structured review report.

**What you'll implement:**
1. Define 3 tools: `read_file`, `list_directory`, `write_report`
2. Write a system prompt with a review rubric (loaded from a SKILL.md)
3. Wire the agent with `Agent(name=..., model=..., tools=...)`
4. Test interactively with `adk web .`
5. Run the eval suite against 2 golden test cases

### :material-graph: Exercise 11: Multi-Agent Pipeline

**File:** `exercises/ex11_multi_agent_pipeline.md`  
**Duration:** 45 min  
**Build:** A **Write-then-Audit Pipeline** — a Technical Writer agent produces a document, then a Compliance Analyst agent evaluates it for GDPR gaps.

**What you'll implement:**
1. Build a `technical_writer` agent with a PRD skill
2. Build a `compliance_analyst` agent with a GDPR skill
3. Wire them sequentially: `SequentialAgent(sub_agents=[writer, analyst])`
4. Add a `ParallelAgent` for simultaneous web research + Drive context gathering
5. Add a zero-cost `BaseAgent` drift detector between research and generation
6. Deploy to Cloud Run as `paul-sdlc-<yourname>-pipeline`

</div>

---

## Summary: SDK Building Blocks

| Primitive | What It Does | When to Use |
|:--|:--|:--|
| `Agent` | Single LLM agent with tools and system prompt | The core building block |
| `LlmAgent` | Agent that routes to sub-agents based on LLM decision | Orchestrators, intent routers |
| `SequentialAgent` | Runs sub-agents in order, passing state between them | Linear pipelines |
| `ParallelAgent` | Runs sub-agents simultaneously | Independent analyses |
| `BaseAgent` | Pure Python logic, zero token cost | Guards, checks, state manipulation |
| `FunctionTool` | Wraps a Python function as a callable tool | Any external operation |
| `output_key` | Writes agent output to named session state key | Pipeline data passing |
| `include_contents="none"` | Sub-agent ignores conversation history | Token-efficient pipeline agents |
| Skills (`SKILL.md`) | Domain knowledge loaded at runtime | Portable expertise |
| `adk web .` | Interactive browser testing UI | Local development |
| `adk eval .` | Golden test evaluation | Regression testing |
| `adk deploy cloud_run` | Deploy to Cloud Run | Production serving |

---

## Next Step

→ Continue to **[Module 4: Multi-Agent & Advanced Patterns](multi-agent-advanced.md)**

→ Reference: **[Cheatsheet](cheatsheet.md)** — all commands in one place
