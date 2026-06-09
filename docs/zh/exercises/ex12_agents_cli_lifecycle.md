# 练习 12：使用 agents-cli 的 ADK 代理生命周期

> **时长：** 45 分钟 | **模块：** 5 — 使用 agents-cli 构建 ADK 代理

---

## 目标

使用 `agents-cli` 生成脚手架、构建、评估并迭代一个 ADK 代理 —— 遵循完整的开发生命周期。你将构建一个**会议纪要总结器**代理，该代理接收原始会议转录内容并生成结构化的行动项。

---

## 前置条件

- 已安装 `agents-cli`（`uvx google-agents-cli setup`）
- 已安装 `uv`（[安装指南](https://docs.astral.sh/uv/getting-started/installation/)）
- 一个 Google Cloud 项目或 [AI Studio API 密钥](https://aistudio.google.com/apikey)
- 已安装并正常运行 Antigravity CLI (agy)

---

## 第 1 部分：搭建代理脚手架 (10 分钟)

### 第 1 步：创建项目

打开一个 Antigravity CLI 会话并生成脚手架：

```bash
agents-cli scaffold create meeting-notes \
  --agent adk \
  --prototype \
  --agent-guidance-filename GEMINI.md
```

!!! info "为什么使用 `--prototype`？"
    prototype 标志会跳过 CI/CD 和 Terraform —— 你可以先专注于让代理运行起来，稍后再使用 `scaffold enhance` 添加部署。

### 第 2 步：探索生成的脚手架结构

```bash
cd meeting-notes
# If you don't have tree installed, you can use find:
find . -maxdepth 3 -not -path '*/.*'
```

你应该会看到类似这样的结构：

```text
meeting-notes/
├── app/
│   ├── app_utils/
│   │   ├── telemetry.py
│   │   └── typing.py
│   ├── __init__.py
│   ├── agent.py
│   ├── fast_api_app.py
│   └── tools.py
├── tests/
│   ├── eval/
│   │   ├── datasets/
│   │   │   └── basic-dataset.json
│   │   └── eval_config.yaml
│   ├── integration/
│   │   ├── test_agent.py
│   │   └── test_server_e2e.py
│   └── unit/
│       └── test_dummy.py
├── .env
├── Dockerfile
├── GEMINI.md
├── README.md
├── agents-cli-manifest.yaml
├── pyproject.toml
└── uv.lock
```

### 第 3 步：安装依赖

脚手架会创建一个包含正确 ADK 依赖的 `pyproject.toml`。安装它：

```bash
uv sync
```

!!! note "google-adk ≠ google-antigravity"
    模块 3 使用 `google-antigravity`（用于在 agy 中构建代理的 Antigravity SDK）。模块 5 使用 `google-adk`（用于构建部署到 Google Cloud 的独立 ADK 代理的 Agent Development Kit）。它们是具有不同 API 的不同包。`agents-cli scaffold` 总是会自动设置 `google-adk`。

### 第 4 步：配置环境

```bash
# If using AI Studio:
echo 'GOOGLE_API_KEY=your-key-here' >> .env

# If using Google Cloud:
echo 'GOOGLE_CLOUD_PROJECT=your-project-id' >> .env
echo 'GOOGLE_CLOUD_LOCATION=us-east1' >> .env
```

---

## 第 2 部分：构建代理（15 分钟）

### 第 1 步：定义工具

编辑 `app/tools.py` 以添加一个转录提取工具：

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

### 第 2 步：配置代理

编辑 `app/agent.py`：

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

### 第 3 步：冒烟测试

```bash
agents-cli run "Summarize this meeting: Alice and Bob discussed the Q3 launch. \
Alice will prepare the marketing deck by Friday. Bob will review the API docs by \
next Monday. They decided to use Cloud Run for deployment and skip the staging \
environment for the MVP."
```

验证：

- [ ] 代理调用 `extract_action_items`
- [ ] 代理使用结构化数据调用 `format_summary`
- [ ] 输出包含带有负责人和截止日期的行动项
- [ ] 列出了关键决策

---

## 第 3 部分：编写评估用例 (10 分钟)

### 第 1 步：创建评估数据集

编辑 `tests/eval/datasets/basic-dataset.json`：

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

### 第 2 步：配置指标

编辑 `tests/eval/eval_config.yaml`：

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

### 第 3 步：运行评估

```bash
# Generate traces (runs agent on each eval case)
agents-cli eval generate

# Grade the traces
agents-cli eval grade
```

查看输出结果。如果有任何指标得分低于阈值，请继续执行第 4 部分。

---

## 第 4 部分：评估-修复循环（10 分钟）

这是真正开始工作的地方。对于每个未通过的指标：

### 第 1 步：读取结果

```bash
# Open the HTML report (easiest to read)
open artifacts/grade_results/results_*.html

# Or check the JSON programmatically
cat artifacts/grade_results/results_*.json | python -m json.tool | head -50
```

### 第 2 步：诊断并修复

常见修复方法：

| 症状 | 修复方法 |
| :-- | :-- |
| 代理跳过 `extract_action_items` | 强化指令：“你必须首先调用 extract_action_items” |
| 缺少负责人 | 添加到指令中：“每个行动项必须有一个负责人——如果不清楚，请使用‘未分配’” |
| 产生幻觉的行动项 | 添加：“切勿添加未在记录中明确说明的行动项” |
| tool_use_quality 较低 | 改进工具文档字符串——对参数进行更具体的说明 |

### 第 3 步：重新评估并比较

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

重复此过程，直到所有指标都通过。

---

## 延伸目标

### 添加部署

```bash
# Add Cloud Run deployment
agents-cli scaffold enhance . --deployment-target cloud_run

# Deploy
agents-cli deploy
```

### 添加 CI/CD

```bash
agents-cli scaffold enhance . --cicd-runner github_actions
```

### 合成更多评估用例

```bash
# Auto-generate multi-turn eval scenarios
agents-cli eval dataset synthesize \
  -n 5 \
  --instruction "User provides meeting transcripts of varying complexity" \
  --max-turns 3
```

### 让 agy 驱动整个流程

打开一个 agy 会话并输入：

```text
> Use agents-cli to improve my meeting-notes agent.
  The eval scores for meeting_summary_quality are low.
  Analyze the failures and fix them.
```

观察 agy 加载 eval 技能，运行 `eval analyze`，识别失败集群，并迭代修复代理。

---

## 完成标准

- [ ] 使用 `agents-cli scaffold create` 搭建项目脚手架
- [ ] 定义了两个工具：`extract_action_items` 和 `format_summary`
- [ ] 代理指令包含清晰的工作流和规则
- [ ] 使用 `agents-cli run` 通过冒烟测试
- [ ] 在 `basic-dataset.json` 中编写了三个评估用例
- [ ] 定义了自定义的 `meeting_summary_quality` 指标
- [ ] `agents-cli eval generate` + `eval grade` 成功运行
- [ ] 至少完成了一次评估-修复迭代，且 `eval compare` 显示出改进

---

## 核心要点

1. **`agents-cli scaffold create`** 初始化整个项目结构 —— 不要手动设置
2. **`agents-cli eval` 是必不可少的** —— 这是演示版本和生产级代理之间的区别
3. **pytest ≠ eval** —— pytest 测试代码正确性；eval 测试代理行为
4. **评估-修复循环是迭代的** —— 预计需要 5–10 轮以上；这很正常
5. **agents-cli 技能** 会自动使你的编码代理 (agy) 成为 ADK 开发专家
