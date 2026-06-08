# 연습 문제 11: 다중 에이전트 파이프라인

> **소요 시간:** 45분 | **모듈:** 3 — AGY 에이전트 구축

---

## 목표

**작성 후 감사 파이프라인**을 구축합니다 — 테크니컬 라이터 에이전트가 개인정보 처리방침 문서를 작성하면, 컴플라이언스 분석가 에이전트가 GDPR 규정 위반 여부를 감사합니다. 이들을 순차적으로 연결하고, 병렬 변형을 추가하며, 세션 재개를 구현하고, Cloud Run에 배포합니다.

---

## 설정

```bash
# Create project directory
mkdir -p ~/agy-pipeline/skills/gdpr-expertise ~/agy-pipeline/tools

# Set up Python environment
cd ~/agy-pipeline
python3 -m venv .venv
source .venv/bin/activate
pip install google-antigravity pydantic
```

```bash
export GEMINI_API_KEY="your-api-key-here"
```

---

## 파트 1: 테크니컬 라이터 에이전트 구축 (10분)

라이터가 사용할 GDPR 스킬을 생성합니다. `skills/gdpr-expertise/SKILL.md`를 생성합니다:

```text
---
name: gdpr-expertise
description: GDPR compliance requirements for technical documentation
---

## GDPR Documentation Requirements

When writing privacy-related documentation, ensure coverage of:

### Data Subject Rights (Articles 12-23)
- Right to access (Art. 15)
- Right to rectification (Art. 16)
- Right to erasure / "right to be forgotten" (Art. 17)
- Right to restrict processing (Art. 18)
- Right to data portability (Art. 20)
- Right to object (Art. 21)

### Lawful Basis for Processing (Article 6)
- Consent, contract, legal obligation, vital interests, public task, legitimate interests
- Each processing activity must cite its lawful basis

### Data Protection by Design (Article 25)
- Privacy by default
- Data minimisation
- Purpose limitation
- Storage limitation

### International Transfers (Chapter V)
- Adequacy decisions
- Standard contractual clauses (SCCs)
- Binding corporate rules

### Data Breach Notification (Articles 33-34)
- 72-hour notification to supervisory authority
- Communication to data subjects for high-risk breaches

### Data Protection Impact Assessment (Article 35)
- Required for high-risk processing
- Must be conducted before processing begins
```

`writer_agent.py`를 생성합니다:

```python
from google.antigravity import LocalAgentConfig
from google.antigravity.hooks import policy

writer_config = LocalAgentConfig(
    model="gemini-3.5-flash",
    skills_paths=["skills/"],
    system_instructions="""You are a Technical Writer specialising in privacy documentation.

Your job: produce a comprehensive privacy policy document for a SaaS application.

Requirements:
- Use the GDPR expertise skill for compliance requirements
- Structure the document with clear sections and headers
- Include specific data categories, retention periods, and legal bases
- Write in plain language accessible to non-lawyers
- Include placeholders marked [COMPANY_NAME] and [DPO_EMAIL] for customisation

Output a complete, ready-to-review privacy policy document.
""",
    tools=[],
    policies=[policy.allow_all()],
)
```

> **핵심 개념:** `skills_paths=["skills/"]`는 SDK가 해당 디렉터리 아래의 모든 `SKILL.md` 파일을 자동 검색하도록 지시합니다. 라이터 에이전트에는 GDPR 스킬이 자동으로 주입됩니다.

---

## 파트 2: 컴플라이언스 분석가 에이전트 구축 (10분)

`analyst_agent.py`를 생성합니다:

```python
import pydantic
from google.antigravity import LocalAgentConfig
from google.antigravity.hooks import policy


class GDPRGap(pydantic.BaseModel):
    article: str          # e.g. "Article 17"
    requirement: str      # What GDPR requires
    gap: str              # What's missing or incomplete
    severity: str         # 'critical', 'major', 'minor'
    recommendation: str   # How to fix it


class ComplianceReport(pydantic.BaseModel):
    overall_score: int           # 0-100
    overall_assessment: str      # 'compliant', 'needs-work', 'non-compliant'
    gaps: list[GDPRGap]
    strengths: list[str]
    summary: str


analyst_config = LocalAgentConfig(
    model="gemini-3.5-flash",
    response_schema=ComplianceReport,
    system_instructions="""You are a GDPR Compliance Analyst.

Your job: audit a privacy policy document for GDPR compliance gaps.

Evaluation criteria:
1. Coverage of all Data Subject Rights (Articles 12-23)
2. Lawful basis specified for each processing activity (Article 6)
3. Data Protection by Design principles (Article 25)
4. International transfer safeguards (Chapter V)
5. Breach notification procedures (Articles 33-34)
6. DPIA provisions (Article 35)
7. DPO contact information (Article 37)
8. Clear, plain language (Article 12)

Severity classification:
- critical: Missing mandatory GDPR requirement, regulatory risk
- major: Incomplete coverage, ambiguous language on key rights
- minor: Style improvements, additional detail recommended

Be thorough and cite specific GDPR articles for every gap found.
Return your findings as structured output.
""",
    tools=[],
    policies=[policy.allow_all()],
)
```

---

## 파트 3: 순차적 파이프라인 연결하기 (10분)

`main.py`를 생성합니다:

```python
import asyncio
import json

from google.antigravity import Agent

from writer_agent import writer_config
from analyst_agent import analyst_config


async def sequential_pipeline():
    """Run writer → analyst in sequence. Output of writer feeds into analyst."""

    print("=" * 60)
    print("PHASE 1: Technical Writer — drafting privacy policy")
    print("=" * 60)

    # Step 1 — Writer produces the document
    async with Agent(writer_config) as writer:
        response = await writer.chat(
            "Write a comprehensive privacy policy for a B2B SaaS application "
            "that processes employee HR data, uses cloud infrastructure in the EU "
            "and US, and integrates with third-party payroll providers."
        )
        privacy_policy = await response.text()
        writer_conv_id = writer.conversation_id  # save for session resume

    print(privacy_policy[:500] + "...\n")

    print("=" * 60)
    print("PHASE 2: Compliance Analyst — auditing for GDPR gaps")
    print("=" * 60)

    # Step 2 — Analyst audits the writer's output
    async with Agent(analyst_config) as analyst:
        response = await analyst.chat(
            f"Audit the following privacy policy for GDPR compliance gaps:\n\n"
            f"{privacy_policy}"
        )
        report = await response.structured_output()

    # Print the structured report
    print(f"\nOverall Score: {report['overall_score']}/100")
    print(f"Assessment: {report['overall_assessment']}")
    print(f"\nStrengths ({len(report['strengths'])}):")
    for s in report["strengths"]:
        print(f"  ✅ {s}")

    print(f"\nGaps ({len(report['gaps'])}):")
    for gap in report["gaps"]:
        icon = {"critical": "🔴", "major": "🟡", "minor": "🔵"}.get(gap["severity"], "⚪")
        print(f"  {icon} [{gap['severity']}] {gap['article']}: {gap['gap']}")
        print(f"     → {gap['recommendation']}")

    print(f"\nSummary: {report['summary']}")

    return privacy_policy, report, writer_conv_id


if __name__ == "__main__":
    asyncio.run(sequential_pipeline())
```

### 실행하기

```bash
python main.py
```

---

## 파트 4: 병렬 변형 추가 (5분)

작성자와 법률 검토자를 `asyncio.gather`를 사용하여 동시에 실행하는 병렬 분석 함수를 `main.py`에 추가합니다:

```python
from analyst_agent import analyst_config


async def parallel_pipeline():
    """Run writer and a parallel legal pre-check simultaneously."""

    # Create a second analyst config for a different perspective
    legal_config = analyst_config.model_copy(
        update={
            "system_instructions": """You are an EU Data Protection Lawyer.
Review the prompt describing a SaaS application and produce a pre-check
compliance report listing what a privacy policy MUST contain for this
specific use case. Return structured output.""",
        }
    )

    prompt = (
        "B2B SaaS application processing employee HR data, "
        "cloud infrastructure in EU and US, "
        "third-party payroll provider integrations."
    )

    print("Running writer + legal pre-check in parallel...\n")

    async with (
        Agent(writer_config) as writer,
        Agent(legal_config) as lawyer,
    ):
        writer_task = writer.chat(f"Write a privacy policy for: {prompt}")
        lawyer_task = lawyer.chat(f"What must a privacy policy contain for: {prompt}")

        results = await asyncio.gather(writer_task, lawyer_task)
        texts = await asyncio.gather(*[r.text() for r in results])

    privacy_policy, legal_checklist = texts
    print(f"Writer produced {len(privacy_policy)} chars")
    print(f"Lawyer produced {len(legal_checklist)} chars")

    # Now run the compliance analyst on the writer's output
    async with Agent(analyst_config) as analyst:
        response = await analyst.chat(
            f"Audit this privacy policy:\n\n{privacy_policy}\n\n"
            f"Also consider this legal pre-check:\n\n{legal_checklist}"
        )
        report = await response.structured_output()

    print(f"\nFinal Score: {report['overall_score']}/100")
    return report
```

> **병렬 처리를 사용해야 하는 경우:** N개의 독립적인 분석이 있을 때마다 사용합니다. 작성자와 법률 사전 검토를 동시에 실행하면 실제 소요 시간(wall-clock time)을 약 50% 단축할 수 있습니다.

---

## 파트 5: 세션 재개 추가 (5분)

분석가가 작성자의 이전 대화를 읽을 수 있도록 `main.py`에 resume 함수를 추가합니다:

```python
async def resume_and_refine(writer_conv_id: str, original_report: dict):
    """Resume the writer's session and ask it to fix the gaps found by the analyst."""

    # Resume the writer's conversation — it remembers the full context
    resume_config = writer_config.model_copy(
        update={
            "conversation_id": writer_conv_id,
        }
    )

    critical_gaps = [g for g in original_report["gaps"] if g["severity"] == "critical"]
    if not critical_gaps:
        print("No critical gaps found — no revision needed!")
        return

    gap_descriptions = "\n".join(
        f"- {g['article']}: {g['gap']} → {g['recommendation']}"
        for g in critical_gaps
    )

    print(f"\nResuming writer session to fix {len(critical_gaps)} critical gaps...")

    async with Agent(resume_config) as writer:
        response = await writer.chat(
            f"The compliance analyst found these critical GDPR gaps in your "
            f"privacy policy. Please revise the document to address them:\n\n"
            f"{gap_descriptions}"
        )
        revised_policy = await response.text()

    print("Revised policy generated. Running final audit...")

    # Re-audit the revised version
    async with Agent(analyst_config) as analyst:
        response = await analyst.chat(
            f"Audit this REVISED privacy policy for GDPR compliance:\n\n"
            f"{revised_policy}"
        )
        final_report = await response.structured_output()

    print(f"Revised Score: {final_report['overall_score']}/100 "
          f"(was {original_report['overall_score']}/100)")
```

`__main__` 블록을 업데이트합니다:

```python
if __name__ == "__main__":
    policy_text, report, conv_id = asyncio.run(sequential_pipeline())
    asyncio.run(resume_and_refine(conv_id, report))
```

---

## 파트 6: Cloud Run에 배포하기 (5분)

`requirements.txt` 생성하기:

```text
google-antigravity
pydantic
```

`Dockerfile` 생성하기:

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "main.py"]
```

배포하기:

```bash
gcloud run deploy my-pipeline \
  --source . \
  --project $GOOGLE_CLOUD_PROJECT \
  --region $GOOGLE_CLOUD_REGION \
  --allow-unauthenticated
```

> **팁:** 배포하기 전에 `GOOGLE_CLOUD_PROJECT` 및 `GOOGLE_CLOUD_REGION`(예: `us-central1`)을 설정하세요. 프로덕션 환경의 경우 `--allow-unauthenticated`를 제거하고 적절한 IAM 제어를 추가하세요.

---

## 완료 기준

- [ ] GDPR `SKILL.md`가 생성되고 `skills_paths`를 통해 작성자 에이전트에 로드됨
- [ ] `GDPRGap` 하위 모델을 포함하여 `ComplianceReport` Pydantic 스키마가 정의됨
- [ ] 순차적 파이프라인 실행: 작성자의 출력이 분석가의 입력으로 전달됨
- [ ] 분석가가 격차, 강점, 점수를 포함하는 구조화된 `ComplianceReport`를 반환함
- [ ] 병렬 변형이 `asyncio.gather`를 사용하여 작성자와 법률 사전 검토를 동시에 실행함
- [ ] 세션 재개 작동: 격차를 수정하기 위해 `conversation_id`를 통해 작성자 대화가 재개됨
- [ ] Cloud Run 배포를 위한 `Dockerfile` 및 `gcloud run deploy` 명령어가 준비됨
