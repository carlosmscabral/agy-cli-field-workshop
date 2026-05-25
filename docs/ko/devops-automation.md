# 모듈 3: DevOps 및 자동화 <span class="duration-badge">40분</span>

> **사람의 개입이 없는 agy.** 이 모듈에서는 비대화형 `--print` 파이프라인, CI/CD 통합, 다중 리포지토리 워크스페이스 및 거버넌스에 민감한 환경을 위한 샌드박스 실행을 다룹니다.

---

## 3.0 — Print 모드: 비대화형 핵심 기능 <span class="duration-badge">5분</span>

`--print`(약칭: `-p`)는 agy의 헤드리스 모드입니다. 단일 프롬프트를 실행하고 응답을 출력한 후 종료합니다. 대화형 세션도, 추가 프롬프트도 없습니다.

```bash
# Basic usage
agy --print "Summarize the top-level README of this project."

# Set a timeout (default: 5 minutes)
agy --print "Generate a full test suite for auth.js" --print-timeout 10m

# Short form
agy -p "What does this project do?"
```text

출력은 stdout으로 전달됩니다. 파이프, 리디렉션, 저장이 가능합니다.

```bash
# Pipe into a file
agy -p "Generate API documentation for all endpoints" > docs/api.md

# Pipe into another command
agy -p "List all TODO comments in this codebase as JSON" | jq '.[] | .file'
```text

---

## 3.1 — 셸 파이프라인 <span class="duration-badge">10분</span>

> **패턴: Unix 명령어로 사용되는 agy** — 표준 셸 도구와 함께 구성합니다.

### 패턴: 코드를 agy로 파이프하기

```bash
# Review a specific file
cat src/auth.js | agy -p "Review this file for security vulnerabilities."

# Review staged changes before commit
git diff --cached | agy -p "Review these changes. Flag bugs, security issues, or missing tests."

# Analyze a log file
tail -n 200 app.log | agy -p "Identify patterns in these errors. Group by root cause."
```text

### 패턴: agy 호출 체이닝

```bash
# Step 1: Generate a plan
agy -p "Create a migration plan for moving this project from CommonJS to ESM. Output as JSON with steps array." > migration-plan.json

# Step 2: Execute step by step
cat migration-plan.json | agy -p "Execute step 1 of this migration plan."
```text

### 패턴: 일괄 처리

```bash
# Process multiple files
for f in src/**/*.js; do
  echo "Reviewing $f..."
  agy -p "Add JSDoc comments to all exported functions in this file." --add-dir "$(dirname $f)" > /tmp/review.md
  cat /tmp/review.md
done
```text

---

## 3.2 — --add-dir을 사용한 다중 디렉터리 작업 공간 <span class="duration-badge">10분</span>

> **패턴: 교차 저장소 컨텍스트** — agy가 여러 코드베이스를 동시에 볼 수 있도록 합니다.

기본적으로 agy는 현재 디렉터리가 포함된 git 저장소를 인덱싱합니다. `--add-dir`은 이를 추가 디렉터리로 확장합니다.

```bash
# Give agy access to both your app and its shared library
agy --add-dir ../shared-lib "How does the app use shared-lib? Identify any API mismatches."

# Add multiple directories
agy --add-dir ../api --add-dir ../frontend "Generate an integration test that covers the API-to-frontend data flow."

# Use in print mode
agy -p "Compare the error handling patterns in app/ vs api/" --add-dir ../api
```text

### 실제 사용 사례: 모노레포 리뷰

```bash
# From the root of a monorepo, review cross-package dependencies
agy --add-dir packages/core --add-dir packages/api --add-dir packages/ui \
    -p "Map the dependency graph between these three packages and flag any circular dependencies."
```text

!!! tip "반복 가능한 플래그"
    `--add-dir`은 반복해서 사용할 수 있습니다. 필요한 만큼 디렉터리를 추가하세요. agy는 기본 git 저장소와 함께 추가된 모든 디렉터리를 인덱싱합니다.

---

## 3.3 — CI/CD 통합 <span class="duration-badge">10 min</span>

> **패턴: 파이프라인의 agy** — 모든 PR에 대한 자동화된 코드 리뷰 및 분석.

### GitHub Actions 예제

```yaml
# .github/workflows/agy-review.yml
name: agy Code Review
on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Install agy-cli
        run: |
          curl -fsSL https://antigravity.google/cli/install.sh | bash

      - name: Review PR changes
        run: |
          git diff origin/main...HEAD | \
          agy --dangerously-skip-permissions \
              --print "Review these changes for: (1) correctness, (2) security, (3) missing tests. Output as markdown." \
              --print-timeout 5m > review.md

      - name: Post review as comment
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const review = fs.readFileSync('review.md', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: review
            });
```text

!!! warning "CI에서의 --dangerously-skip-permissions"
    CI에서는 항상 `--dangerously-skip-permissions`를 사용하세요 — '승인'을 클릭할 사람이 없기 때문입니다. agy가 접근할 수 있는 항목을 제한하려면 샌드박스 모드와 함께 사용하세요.

### Pre-Commit 훅

```bash
#!/bin/bash
# .git/hooks/pre-commit
echo "🤖 Running agy pre-commit review..."
git diff --cached | agy --dangerously-skip-permissions \
    -p "Flag any obvious bugs or security issues in these staged changes. If none, output 'LGTM'." \
    --print-timeout 60s

# Optionally block commit if issues found
# (parse output for keywords)
```text

---

## 3.4 — 샌드박스 모드 <span class="duration-badge">5분</span>

> **패턴: 제한된 실행** — OS 수준의 터미널 격리 환경에서 agy를 실행합니다.

### 샌드박스 활성화

샌드박스는 `settings.json`(프로젝트의 `.agents/settings.json` 또는 사용자의 `~/.gemini/antigravity-cli/settings.json`)을 통해 구성됩니다:

```json
{
  "enableTerminalSandbox": true
}
```text

활성화되면 agy는 **네이티브 OS 격리**를 사용하여 터미널 명령 실행을 제한합니다:

| OS | 격리 기술 |
| :-- | :-- |
| **Linux** | nsjail |
| **macOS** | sandbox-exec |
| **Windows** | AppContainer |

### 명령별 우회

샌드박스가 활성화된 상태에서 명령이 샌드박스를 벗어나야 할 때 agy는 **승인을 요청하는 프롬프트**를 표시합니다. 명령별 우회 프롬프트가 표시되어 전체 샌드박스를 비활성화하지 않고도 선택적으로 실행할 수 있습니다.

### 사용 사례

- 신뢰할 수 없는 코드에서 agy 실행
- 부작용 없이 민감한 콘텐츠 감사
- 모든 실행에 승인이 필요한 거버넌스에 민감한 환경

### 권한과 결합하기

최대 제어를 위해 샌드박스 모드를 권한 모델과 결합하세요:

```json
{
  "enableTerminalSandbox": true,
  "permissions": {
    "allow": ["read_file", "command(git)"],
    "deny": ["command(rm)", "unsandboxed"]
  }
}
```text

> 📖 전체 세부 정보: [권한 문서](https://www.antigravity.google/docs/permissions)

---

## 3.5 — 훅 & 규칙 <span class="duration-badge">5분</span>

> **패턴: 가드레일 & 자동화** — 표준을 강제하고 주요 수명 주기 지점에서 작업을 트리거합니다.

### 훅

훅을 사용하면 5가지 수명 주기 이벤트에서 사용자 지정 로직을 실행할 수 있습니다:

| 이벤트 | 실행 시점 |
| :-- | :-- |
| `PreToolUse` | agy가 도구(파일 읽기, 명령어 실행 등)를 호출하기 전 |
| `PostToolUse` | 도구 호출이 완료된 후 |
| `PreInvocation` | agy가 프롬프트 처리를 시작하기 전 |
| `PostInvocation` | agy가 응답을 완료한 후 |
| `Stop` | 세션이 종료될 때 |

훅은 `hooks.json`(프로젝트의 경우 `.agents/`, 전역의 경우 `~/.gemini/config/`)에서 구성합니다. 훅 스크립트는 표준 입력(stdin)으로 JSON을 받고 표준 출력(stdout)으로 JSON을 반환합니다.

> 📖 전체 세부 정보: [훅 문서](https://www.antigravity.google/docs/hooks)

### 규칙

규칙은 agy의 시스템 프롬프트에 `RULE` 블록으로 주입되는 마크다운 파일로, agy가 반드시 따라야 하는 엄격한 제약 조건입니다.

| 범위 | 위치 |
| :-- | :-- |
| **프로젝트** | `.agents/rules.md` 또는 `.agents/rules/*.md` |
| **전역** | `~/.gemini/config/rules.md` 또는 `~/.gemini/config/rules/*.md` |

예시 `.agents/rules.md`:

```markdown
- Never delete migration files
- Always use TypeScript strict mode
- Run `npm test` after any code change
- Do not modify files in the vendor/ directory
```text

> 📖 전체 세부 정보: [규칙 & 워크플로 문서](https://www.antigravity.google/docs/rules-workflows)

---

## 모듈 3 연습 문제

<div class="exercise-card" markdown>

#### :material-file-document: 연습 문제 3: --print 파이프라인

**파일:** `exercises/ex03_print_mode_pipeline.md`
**소요 시간:** 20분
**목표:** agy --print를 사용하여 다단계 셸 파이프라인을 구축합니다. 스테이징된 변경 사항을 검토하고, 문서를 생성하며, GitHub Actions 워크플로우를 연결합니다.

</div>

---

## 다음 모듈

→ **[모듈 4: 멀티 에이전트 및 고급](../multi-agent-advanced.md)** — 서브에이전트, /btw 작업 중 스티어링, 스케줄링.
