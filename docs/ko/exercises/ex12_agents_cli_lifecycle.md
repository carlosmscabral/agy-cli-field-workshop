# 실습 12: agents-cli를 사용한 ADK 에이전트 수명 주기

> **소요 시간:** 45분 | **모듈:** 5 — agents-cli를 사용하여 ADK 에이전트 구축하기

---

## 목표

전체 개발 수명 주기에 따라 `agents-cli`를 사용하여 ADK 에이전트를 스캐폴딩, 빌드, 평가 및 반복합니다. 원시 회의 기록을 받아 구조화된 실행 항목을 생성하는 **회의록 요약기** 에이전트를 구축하게 됩니다.

---

## 사전 요구 사항

- `agents-cli` 설치됨 (`uvx google-agents-cli setup`)
- `uv` 설치됨 ([설치 가이드](https://docs.astral.sh/uv/getting-started/installation/))
- Google Cloud 프로젝트 또는 [AI Studio API 키](https://aistudio.google.com/apikey)
- Antigravity CLI (agy) 설치 및 작동 확인

---

## 파트 1: 에이전트 스캐폴딩 (10분)

### 1단계: 프로젝트 생성

Antigravity CLI 세션을 열고 스캐폴딩합니다:

```bash
agents-cli scaffold create meeting-notes \
  --agent adk \
  --prototype \
  --agent-guidance-filename GEMINI.md
```

!!! info "왜 `--prototype`을 사용하나요?"
    prototype 플래그는 CI/CD 및 Terraform을 건너뜁니다. 먼저 에이전트를 작동시키는 데 집중한 다음, 나중에 `scaffold enhance`를 사용하여 배포를 추가할 수 있습니다.

### 2단계: 스캐폴딩된 구조 탐색

```bash
cd meeting-notes
# If you don't have tree installed, you can use find:
find . -maxdepth 3 -not -path '*/.*'
```

다음과 같은 구조가 표시되어야 합니다:

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

### 3단계: 종속성 설치

스캐폴드는 올바른 ADK 종속성이 포함된 `pyproject.toml`을 생성합니다. 이를 설치합니다:

```bash
uv sync
```

!!! note "google-adk ≠ google-antigravity"
    모듈 3은 `google-antigravity`(agy 내에서 에이전트를 구축하기 위한 Antigravity SDK)를 사용합니다. 모듈 5는 `google-adk`(Google Cloud에 배포되는 독립 실행형 ADK 에이전트를 구축하기 위한 Agent Development Kit)를 사용합니다. 이들은 서로 다른 API를 가진 다른 패키지입니다. `agents-cli scaffold`는 항상 자동으로 `google-adk`를 설정합니다.

### 4단계: 환경 설정

```bash
# If using AI Studio:
echo 'GOOGLE_API_KEY=your-key-here' >> .env

# If using Google Cloud:
echo 'GOOGLE_CLOUD_PROJECT=your-project-id' >> .env
echo 'GOOGLE_CLOUD_LOCATION=us-east1' >> .env
```

---

## 파트 2: 에이전트 구축 (15분)

### 1단계: 도구 정의

`app/tools.py`를 편집하여 트랜스크립트 추출 도구를 추가합니다:

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

### 2단계: 에이전트 구성

`app/agent.py`를 편집합니다:

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

### 3단계: 스모크 테스트

```bash
agents-cli run "Summarize this meeting: Alice and Bob discussed the Q3 launch. \
Alice will prepare the marketing deck by Friday. Bob will review the API docs by \
next Monday. They decided to use Cloud Run for deployment and skip the staging \
environment for the MVP."
```

확인:

- [ ] 에이전트가 `extract_action_items`를 호출합니다.
- [ ] 에이전트가 구조화된 데이터로 `format_summary`를 호출합니다.
- [ ] 출력에 담당자와 기한이 지정된 실행 항목이 포함되어 있습니다.
- [ ] 주요 결정 사항이 나열되어 있습니다.

---

## 파트 3: 평가 케이스 작성 (10분)

### 1단계: 평가 데이터셋 생성

`tests/eval/datasets/basic-dataset.json` 파일을 편집합니다:

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

### 2단계: 지표 구성

`tests/eval/eval_config.yaml` 파일을 편집합니다:

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

### 3단계: 평가 실행

```bash
# Generate traces (runs agent on each eval case)
agents-cli eval generate

# Grade the traces
agents-cli eval grade
```

출력을 검토합니다. 임계값 미만인 지표 점수가 있다면 파트 4로 진행합니다.

---

## 파트 4: 평가-수정 루프 (10분)

여기서부터 본격적인 작업이 시작됩니다. 실패한 각 지표에 대해 다음을 수행합니다:

### 1단계: 결과 확인

```bash
# Open the HTML report (easiest to read)
open artifacts/grade_results/results_*.html

# Or check the JSON programmatically
cat artifacts/grade_results/results_*.json | python -m json.tool | head -50
```

### 2단계: 진단 및 수정

일반적인 수정 사항:

| 증상 | 수정 사항 |
| :-- | :-- |
| 에이전트가 `extract_action_items`를 건너뜀 | 지침 강화: "반드시 extract_action_items를 먼저 호출해야 합니다" |
| 담당자 누락 | 지침에 추가: "모든 실행 항목에는 담당자가 있어야 합니다 — 불분명한 경우 'Unassigned'를 사용하세요" |
| 환각(Hallucinated) 실행 항목 | 추가: "대화록에 명시적으로 언급되지 않은 실행 항목은 절대 추가하지 마세요" |
| 낮은 tool_use_quality | 도구 독스트링(docstring) 개선 — 매개변수에 대해 더 구체적으로 작성 |

### 3단계: 재평가 및 비교

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

모든 지표를 통과할 때까지 반복합니다.

---

## 추가 목표

### 배포 추가

```bash
# Add Cloud Run deployment
agents-cli scaffold enhance . --deployment-target cloud_run

# Deploy
agents-cli deploy
```

### CI/CD 추가

```bash
agents-cli scaffold enhance . --cicd-runner github_actions
```

### 더 많은 평가 케이스 합성

```bash
# Auto-generate multi-turn eval scenarios
agents-cli eval dataset synthesize \
  -n 5 \
  --instruction "User provides meeting transcripts of varying complexity" \
  --max-turns 3
```

### agy가 전체 흐름을 주도하도록 하기

agy 세션을 열고 다음과 같이 말합니다:

```text
> Use agents-cli to improve my meeting-notes agent.
  The eval scores for meeting_summary_quality are low.
  Analyze the failures and fix them.
```

agy가 평가 스킬을 로드하고, `eval analyze`를 실행하며, 실패 클러스터를 식별하고, 반복적으로 에이전트를 수정하는 과정을 지켜보세요.

---

## 완료 기준

- [ ] `agents-cli scaffold create`로 프로젝트 스캐폴딩 완료
- [ ] 두 개의 도구 정의됨: `extract_action_items` 및 `format_summary`
- [ ] 에이전트 지침에 명확한 워크플로와 규칙이 포함됨
- [ ] `agents-cli run`으로 스모크 테스트 통과
- [ ] `basic-dataset.json`에 3개의 평가 케이스 작성됨
- [ ] 사용자 정의 `meeting_summary_quality` 지표 정의됨
- [ ] `agents-cli eval generate` + `eval grade`가 성공적으로 실행됨
- [ ] `eval compare`에서 개선 사항을 보여주는 평가-수정 반복이 최소 1회 완료됨

---

## 핵심 요약

1. **`agents-cli scaffold create`**는 전체 프로젝트 구조를 부트스트랩합니다 — 수동으로 설정하지 마세요.
2. **`agents-cli eval`은 선택 사항이 아닙니다** — 이것이 데모와 프로덕션 에이전트의 차이를 만듭니다.
3. **pytest ≠ eval** — pytest는 코드의 정확성을 테스트하고, eval은 에이전트의 동작을 테스트합니다.
4. **eval-fix 루프는 반복적입니다** — 5~10회 이상의 반복을 예상하세요. 이는 정상적인 과정입니다.
5. **agents-cli 스킬**은 코딩 에이전트(agy)를 ADK 개발 전문가로 자동으로 만들어 줍니다.
