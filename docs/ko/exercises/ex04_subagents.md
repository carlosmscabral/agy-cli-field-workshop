# 연습 문제 4: 서브에이전트

> **소요 시간:** 20분 | **모듈:** 4 — 멀티 에이전트 및 고급

---

## 목표

코드베이스에서 병렬 서브에이전트를 생성하고, 적대적 리뷰어 패턴을 연습하며, 격리된 실행을 관찰합니다.

---

## 파트 1: 병렬 감사 (10분)

대화형으로 agy를 실행합니다:

```bash
agy
```

병렬 감사 팀을 파견합니다:

```text
> Spawn two subagents in parallel using branch workspace mode:
> 1. A security auditor — scan for: hardcoded credentials, injection vulnerabilities, exposed sensitive data, and insecure dependencies
> 2. A test coverage auditor — identify: untested public functions, missing edge cases, and integration test gaps
>
> Report back when both complete with a combined findings summary.
```

실행되는 동안 다음과 같이 질문합니다:

```text
> What's the status of the subagents?
```

완료되면:

```text
> Show me the combined findings from both audits. What are the top 3 things to fix?
```

---

## 파트 2: 적대적 리뷰어 (7분)

최근 PR, 브랜치 또는 변경 사항 세트를 선택하세요:

```bash
git checkout -b feature/my-test-branch
# (make a few changes)
git add -A
```

다시 agy로 돌아가서:

```text
> I have changes on the current branch. Spawn an adversarial reviewer subagent.
> Its only job: find reasons why these changes should NOT be merged.
> It should challenge assumptions, look for edge cases, and be skeptical of everything.
> Be harsh — this is an adversarial review, not a supportive one.
```

적대적 분석 결과를 읽어보세요. 목표는 철저한 코드 리뷰에서 발견할 수 있는 문제점을 식별하는 것입니다.

---

## 파트 3: 서브에이전트 작업 재개하기 (3분)

```text
> One of the subagent findings mentioned [specific issue]. Let's fix it. Create a subagent in inherit mode to implement the fix.
```

브랜치 모드와의 차이점에 유의하세요: `inherit`은 서브에이전트가 메인 세션과 동일한 디렉토리에서 작업함을 의미하며, 이는 충돌이 없는 타겟팅된 수정에 적합합니다.

---

## 완료 기준

- [ ] 최소 2개의 병렬 서브에이전트를 성공적으로 생성함
- [ ] 두 서브에이전트가 모두 실행되어 발견 사항을 반환함
- [ ] 적대적 리뷰어가 중요한 발견 사항을 반환함
- [ ] 최소 두 가지 다른 작업 공간 모드(branch vs inherit)를 사용함
