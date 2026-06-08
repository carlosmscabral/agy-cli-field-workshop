# 실습 6: 샌드박스 및 거버넌스

> **소요 시간:** 15분 | **모듈:** 4 — 멀티 에이전트 및 고급

---

## 목표

안전한 코드 감사를 위해 `--sandbox` 모드에서 agy를 실행하고, `--dangerously-skip-permissions` 플래그를 이해하며, 엔터프라이즈 환경을 위한 거버넌스에 적합한 워크플로우를 모델링합니다.

---

## Part 1: 샌드박스 모드 — 안전한 감사 (7분)

터미널 제한이 활성화된 상태에서 보안 감사를 실행합니다:

```bash
agy --sandbox \
    --print "Scan this entire codebase for: (1) hardcoded secrets or API keys, (2) SQL injection risks, (3) insecure direct object references, (4) any .env files or credentials committed to the repo. Output findings as markdown with severity levels." \
    --print-timeout 5m > audit-sandbox.md

cat audit-sandbox.md
```

이 실행의 주요 속성:

- `--sandbox`는 터미널 명령 실행을 제한합니다 — agy는 파일을 읽을 수 있지만 임의의 셸 명령을 실행할 수는 없습니다.
- `--print`는 대화형 세션이 없음을 의미합니다 — 완전히 자동화됨
- 감사 추적을 위해 출력이 파일로 캡처됩니다.

**이 패턴을 사용해야 하는 경우:**

- 완전히 신뢰하지 않는 코드 감사
- 규제가 있는 환경에서의 규정 준수 스캔
- 부작용이 허용되지 않는 프로덕션 코드베이스에서 실행

---

## 파트 2: 자동 승인 모드 — 위험성 이해하기 (5분)

`--dangerously-skip-permissions`는 모든 도구 승인 프롬프트를 우회합니다. agy는 묻지 않고 파일 쓰기 및 셸 명령을 실행합니다.

**안전한 데모:** 실제 명령 실행 없이 자동 승인을 보여주려면 `--sandbox`와 함께 실행하세요:

```bash
agy --sandbox --dangerously-skip-permissions \
    --print "List all TODO comments in this codebase and generate a prioritized backlog." \
    --print-timeout 3m
```

`--sandbox`가 없으면 이 플래그는 agy가 프롬프트 없이 파일을 쓰고, 테스트를 실행하고, 명령을 실행하도록 허용합니다. **다음의 경우에만 사용하세요:**

- 사람이 없는 CI/CD 환경
- 읽기 전용 감사를 위해 `--sandbox`와 함께 사용
- 쓰기가 허용되는 일회성 환경

!!! warning "프로덕션 환경에서는 절대 사용 금지"
    라이브 코드베이스의 대화형 세션에서 `--sandbox` 없이 `--dangerously-skip-permissions`를 사용하는 것은 매우 위험한 행위(footgun)입니다. 덮어쓴 파일은 되돌릴 수 없습니다.

---

## 파트 3: 거버넌스 워크플로우 (3분)

2단계 거버넌스 워크플로우를 모델링합니다:

### 1단계: 안전한 분석 (부작용 없음)

```bash
agy --sandbox \
    --print "Analyze all database operations in this codebase. Flag any that lack transaction safety or input validation." \
    --print-timeout 3m > phase1-analysis.md
```

### 2단계: 사람의 검토 후 대화형 세션 승인

```bash
cat phase1-analysis.md  # human reviews findings

# If approved, continue with interactive session for remediation
agy -i "Based on the findings in phase1-analysis.md, fix the top 3 database safety issues."
```

이 패턴은 엔터프라이즈급 모델입니다: **신뢰 없이 읽고, 검토 후에만 쓰기**.

---

## 완료 기준

- [ ] `agy --sandbox --print "..."` 명령을 실행하여 감사 파일을 생성했습니다.
- [ ] `--dangerously-skip-permissions` 플래그가 언제 적절하고 언제 위험한지 이해했습니다.
- [ ] 2단계 거버넌스 워크플로우(샌드박스 감사 → 사람의 검토 → 대화형 수정)를 구현했습니다.
