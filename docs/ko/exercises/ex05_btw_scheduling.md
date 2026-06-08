# 실습 5: /btw 및 스케줄링

> **소요 시간:** 20분 | **모듈:** 4 — 멀티 에이전트 및 고급

---

## 목표

`/btw`를 사용하여 진행 중인 장기 작업의 방향을 조정하고, 반복적인 자동화된 분석을 예약합니다.

---

## 파트 1: /btw 작업 중 스티어링 (10분)

agy를 실행하고 상당한 규모의 작업을 시작합니다:

```bash
agy
```

```text
> I want to refactor the error handling across this entire project to use a consistent pattern. Start by analyzing all error handling in the codebase, then propose and implement a unified approach. This will touch multiple files — start with the analysis phase.
```

agy가 작업을 시작할 때(분석 단계 중), 제약 조건을 주입합니다:

```text
/btw Only touch files in the backend/ directory for now. Leave frontend untouched.
```

그런 다음 다른 참고 사항을 추가합니다:

```text
/btw Use the Result<T, E> pattern if the language supports it. Otherwise use a custom Error class hierarchy.
```

관찰:

- 작업을 다시 시작하지 않고 계속 진행합니다.
- agy는 두 개의 `/btw` 참고 사항을 모두 작업 방식에 통합합니다.
- 최종 계획에 주입한 제약 조건이 반영됩니다.

**핵심 인사이트:** `/btw`를 사용하면 취소하고 다시 시작하는 비용 없이 방향을 수정할 수 있습니다. 이는 스프린트 도중 개발자의 어깨를 두드리며 이야기하는 것과 같습니다.

---

## 파트 2: 세션 이어하기 (5분)

세션을 종료합니다(Ctrl+C를 누르거나 터미널을 닫습니다).

가장 최근 세션을 재개합니다:

```bash
agy -c
```

```text
> Remind me what we decided about the error handling refactor. What was the approach?
```

agy는 전체 컨텍스트를 유지합니다. 이제 작업을 계속합니다:

```text
> Let's implement step 1 of the plan we discussed.
```

---

## 파트 3: 정기 보고서 예약 (5분)

```bash
agy
```

```text
> Schedule a daily dependency check every weekday morning at 8am. It should:
> 1. Check for outdated dependencies with security advisories
> 2. List any new CVEs affecting our current dependency versions
> 3. Save the report to reports/deps-YYYY-MM-DD.md
>
> Create the reports/ directory if it doesn't exist.
```

일정이 수락되었는지 확인합니다. 다음과 같이 질문하세요:

```text
> What scheduled tasks are currently active?
```

---

## 완료 기준

- [ ] 장기 실행 작업을 시작하고 실행 중에 `/btw`를 두 번 이상 사용했습니다.
- [ ] `/btw` 메시지가 출력에 포함되었는지 확인했습니다.
- [ ] `agy -c`를 사용하여 세션을 재개하고 이전 컨텍스트를 검색했습니다.
- [ ] 예약된 반복 작업을 생성했습니다.
