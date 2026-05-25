# 모듈 1: SDLC 생산성 향상 <span class="duration-badge">50분</span>

> **첫 번째 실제 agy-cli 세션입니다.** 이 모듈에서는 핵심적인 일상 워크플로우를 다룹니다: 코드 이해, 리팩토링, 테스트 생성 및 변경 사항 검토 — 이 모든 것을 터미널에서 수행합니다.

---
## 1.0 — 첫 번째 대화형 세션 <span class="duration-badge">5분</span>

워크숍 프로젝트 디렉토리에서 agy-cli를 실행하세요:

```bash
cd agy-cli-field-workshop
agy
```

대화형 프롬프트에 진입하게 됩니다. 다음을 시도해 보세요:

```
> What files are in this project and what does each one do?
```

agy가 작업 공간을 어떻게 읽는지 관찰해 보세요. git 저장소를 색인화하고, 파일 내용을 읽으며, 컨텍스트와 함께 응답합니다. 이는 **자동**으로 이루어집니다. 구성이나 먼저 작성해야 할 프롬프트가 필요 없습니다.

!!! tip ".agents/ 폴더"
    첫 번째 세션이 끝난 후 `.agents/`를 확인해 보세요. agy가 작업 공간을 추적하는 프로젝트 구성 파일을 생성했습니다. 이를 통해 향후 실행 시 무엇을 색인화할지 알 수 있습니다.

---
## 1.1 — 코드 이해 <span class="duration-badge">10분</span>

> **패턴: 수정 전 설명** — 코드를 변경하기 전에 먼저 이해하세요.

### 실습: 익숙하지 않은 코드베이스 파악하기

```bash
# Start with --prompt-interactive: give agy an initial task, then continue conversationally
agy -i "Give me a high-level architecture overview of this project. What are the main components and how do they connect?"
```

그런 다음 대화형으로 후속 질문을 이어가세요:

```
> Which file handles the entry point?
> What external dependencies does this project have?
> Are there any obvious code smells or tech debt?
```

!!! tip "시드 세션에 -i 사용하기"
    `agy -i "<task>"`(`--prompt-interactive`의 약어)는 프롬프트로 시작하지만 대화형 상태를 유지합니다. 방향을 설정한 다음 후속 질문으로 방향을 조정할 수 있으므로 목적이 있는 탐색에 매우 유용합니다.

---
## 1.2 — 리팩터링 <span class="duration-badge">10분</span>

> **패턴: 제안, 검토, 적용** — 읽지 않은 변경 사항은 절대 적용하지 마세요.

### 실습: 타겟 리팩터링

```bash
agy
```

```
> I want to refactor the error handling in this project. First, show me all the places where errors are currently caught or returned — don't change anything yet.
```

결과를 검토하세요. 그런 다음:

```
> Now propose a refactored version of [specific function] using a consistent error handling pattern. Show me the diff before applying.
```

제안된 변경 사항을 읽은 후에만 적용하세요.

### 권한 모델

agy에는 도구 승인 처리 방식을 제어하는 **3단계 권한 모델**이 있습니다:

| 레벨 | 동작 |
|---|---|
| `request-review` | **기본값.** agy가 파일을 쓰거나 명령을 실행하기 전에 승인을 요청합니다 |
| `always-proceed` | 모든 도구 호출을 자동 승인합니다 — 신뢰할 수 있는 스크립트 및 CI에 유용합니다 |
| `strict` | 명시적으로 허용되지 않는 한 모든 도구 사용을 거부합니다 — 최대 제어 |

`/permissions` 슬래시 명령을 사용하여 현재 레벨을 보거나 변경하세요. 세분화된 규칙을 설정할 수도 있습니다:

```json
{
  "permissions": {
    "allow": ["command(git)", "read_file"],
    "deny": ["command(rm -rf)"]
  }
}
```

> 📖 전체 세부 정보: [권한 문서](https://www.antigravity.google/docs/permissions) · [엄격 모드 문서](https://www.antigravity.google/docs/strict-mode)

---
## 1.3 — 테스트 생성 <span class="duration-badge">10분</span>

> **패턴: 존재하는 것 테스트하기** — 가상의 코드가 아닌 실제 코드에 대한 테스트를 생성합니다.

### 실습: 단위 테스트 생성

```bash
agy
```

```
> Look at [specific function or file]. Generate a comprehensive unit test suite for it. Include happy path, edge cases, and error conditions. Use the testing framework already in this project.
```

그런 다음:

```
> Run the tests and fix any that fail.
```

!!! tip "agy가 테스트를 실행하도록 하기"
    agy는 셸 명령을 실행할 수 있습니다. 오류 메시지를 복사하여 붙여넣을 필요 없이 테스트 스위트를 실행하고 실패 시 반복 작업을 수행합니다. 스스로 수정하는 과정을 지켜보세요.

---
## 1.4 — 코드 리뷰 <span class="duration-badge">10분</span>

> **패턴: 커밋 전 리뷰** — 모든 푸시 전에 agy를 시니어 리뷰어로 사용하세요.

### 연습: 변경 사항 리뷰하기

```bash
# Stage some changes (or use an existing branch)
git add -p

# Start agy and review what's staged
agy
```

```
> Review my staged changes for: (1) correctness, (2) security issues, (3) missing test coverage, (4) anything that would block a PR. Be direct — don't soften findings.
```

### 헤드리스 변형 (스크립팅용)

```bash
# Review changes non-interactively — useful in pre-commit hooks or CI
git diff --cached | agy --print "Review these changes. Flag any bugs, security issues, or missing tests. Output as markdown."
```

---
## 1.5 — AGENTS.md를 사용한 프로젝트 컨텍스트 <span class="duration-badge">5 min</span>

> **패턴: 영구 컨텍스트** — agy에게 한 번만 알려주면 모든 세션에서 기억합니다.

agy는 세션 시작 시 컨텍스트 파일을 읽습니다. 프로젝트 루트에 하나를 생성하세요:

```bash
cat > AGENTS.md << 'EOF'
# Project Context

This is a [your project description]. Key conventions:

- Language: [your language/framework]
- Testing: [your test framework]
- Style: [your coding conventions]
- DO NOT: [things agy should never do]

## Architecture
[Brief architecture summary]
EOF
```

이제 새 세션을 시작하세요:

```bash
agy --print "What do you know about this project?"
```

agy는 이후의 모든 세션에 AGENTS.md를 자동으로 포함시킵니다.

!!! info "컨텍스트 계층 구조"
    agy는 현재 디렉토리 → 상위 디렉토리 → 홈 디렉토리 순으로 AGENTS.md를 읽습니다. 더 구체적인 컨텍스트가 더 넓은 범위의 컨텍스트를 재정의합니다.

### 추가 컨텍스트 소스

AGENTS.md 외에도 agy는 다음을 로드합니다:

- **`.agents/rules.md`** (또는 `.agents/rules/*.md`) — 시스템 프롬프트 지시문으로 주입되는 프로젝트 수준의 규칙입니다. "마이그레이션 파일을 절대 삭제하지 마세요" 또는 "항상 TypeScript 엄격 모드를 사용하세요"와 같은 필수 요구 사항에 사용하세요.
- **`.gemini/`** — Gemini CLI 호환성을 위해 agy는 `.agents/`와 함께 `.gemini/` 디렉토리를 읽습니다.
- **`~/.gemini/config/rules.md`** — 모든 세션에 적용되는 전역 규칙입니다.

> 📖 전체 세부 정보: [규칙 및 워크플로우 문서](https://www.antigravity.google/docs/rules-workflows)

---
## 1.6 — 대화형 탐색 <span class="duration-badge">5분</span>

> **패턴: 터미널 유창성** — agy 세션을 빠르게 만드는 단축키를 알아두세요.

> 📖 전체 참조: [AGY CLI 사용하기](https://www.antigravity.google/docs/cli-using)

### 주요 슬래시 명령어

| 명령어 | 기능 |
|---|---|
| `/rewind` (또는 `/undo`) | 대화 기록을 이전 체크포인트로 롤백합니다 |
| `/resume` (또는 `/switch`) | 대화 선택기를 열어 세션을 재개하거나 전환합니다 |
| `/rename <name>` | 활성 대화 스레드의 이름을 변경합니다 |
| `/config` (또는 `/settings`) | 전체 화면 설정 오버레이를 엽니다 |
| `/permissions` | 에이전트 자율성 수준을 설정합니다 (`request-review`, `always-proceed`, `strict`) |
| `/model` | 추론 모델을 선택합니다 (세션 간 유지됨) |
| `/tasks` | 백그라운드 작업을 모니터링하거나 로그를 보거나 종료합니다 |
| `/agents` | 서브에이전트 작업을 보고, 관리하고, 승인합니다 |
| `/open <path>` | 선호하는 외부 편집기에서 파일을 엽니다 |
| `/usage` | 인라인 대화형 도움말 매뉴얼을 엽니다 |
| `/skills` | 로컬 및 글로벌 에이전트 스킬을 찾아봅니다 |
| `/mcp` | MCP 서버를 구성하고 관리합니다 |

> 📖 전체 슬래시 명령어 참조: [CLI 기능](https://antigravity.google/docs/cli-features)

### 빠른 팁

| 단축키 | 기능 |
|---|---|
| `@` | 파일 경로 자동 완성 — `@`를 입력하여 경로 제안을 트리거합니다 |
| `!` | agy를 종료하지 않고 터미널 명령어를 직접 실행합니다 |
| `esc esc` | 현재 프롬프트 입력을 지웁니다 (스트리밍이 활성화되지 않은 경우) |
| `?` | 도움말을 얻고 모든 슬래시 명령어를 나열합니다 |
| `alt+enter` / `ctrl+j` / `shift+enter` | 프롬프트에 줄바꿈을 삽입합니다 (여러 줄 입력) |
| `ctrl+g` | 기본 셸 편집기 내에서 프롬프트를 편집합니다 |
| `ctrl+l` | TUI 화면을 지웁니다 |
| `ctrl+d` | CLI를 종료합니다 |

> 📖 전체 키바인딩 참조: [AGY CLI 사용하기](https://antigravity.google/docs/cli-using)

---
## 모듈 1 연습 문제

<div class="exercise-card" markdown>

#### :material-file-document: 연습 문제 1: 첫 번째 세션

**파일:** `exercises/ex01_first_session.md`
**소요 시간:** 15분
**목표:** agy를 실행하고, 코드베이스를 탐색하며, AGENTS.md를 생성합니다.

</div>

---
## 다음 모듈

→ **[모듈 2: 플러그인 생태계](../plugin-ecosystem.md)** — 단일 명령으로 Gemini CLI 및 Claude 플러그인을 agy로 가져옵니다.
