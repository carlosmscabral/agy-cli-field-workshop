# 모듈 2: 플러그인 생태계 <span class="duration-badge">45분</span>

> **agy-cli의 가장 뛰어난 기능입니다.** 다른 어떤 AI 코딩 CLI도 Gemini CLI와 Claude Code의 플러그인을 단일 인터페이스로 연결할 수 없습니다. 이 모듈에서는 가져오기, 설치, 활성화, 비활성화 및 검증과 같은 전체 플러그인 수명 주기를 다룹니다.

---

## 2.0 — 플러그인이 중요한 이유 <span class="duration-badge">5 min</span>

agy-cli의 플러그인 시스템은 독특한 기능을 제공합니다. 재설치나 재구성 없이 **Gemini CLI 또는 Claude Code에 이미 설치한 플러그인을 가져올 수 있습니다**. 확장 프로그램에 대한 기존 투자가 그대로 이어집니다.

```bash
# See what plugins are currently active in agy
agy plugin list
```text

출력은 각 플러그인의 이름, 소스, 가져온 날짜 및 구성 요소(스킬, 명령어, mcpServers, 에이전트)를 보여주는 JSON입니다.

```bash
# More readable
agy plugin list | python3 -m json.tool
```text

> 📖 공식 문서: [플러그인](https://www.antigravity.google/docs/plugins) · [MCP](https://www.antigravity.google/docs/mcp) · [스킬](https://www.antigravity.google/docs/skills)

---

## 2.1 — Gemini CLI에서 가져오기 <span class="duration-badge">10분</span>

> **패턴: 교차 도구 플러그인 브릿지(Cross-Tool Plugin Bridge)** — 전체 Gemini CLI 플러그인 설정을 agy로 가져옵니다.

### 모든 Gemini CLI 플러그인 가져오기

```bash
agy plugin import gemini
```text

agy는 로컬 Gemini CLI 설치를 스캔하여 설치된 모든 플러그인을 찾고, 해당 구성 요소(스킬, 명령어, MCP 서버, 에이전트)를 `~/.gemini/antigravity-cli/`에 있는 agy의 설정으로 스테이징합니다.

출력은 다음과 같습니다:

```text
  [ok]    code-review
          ✔ skills      : 3 processed
          ✔ commands    : 2 processed
          - mcpServers  : skipped (not found)
  [ok]    gemini-deep-research
          ✔ commands    : 1 processed
          ✔ mcpServers  : 1 processed
  [skip]  superpowers (already imported)
```text

!!! tip "--force를 사용하여 다시 가져오기"
    이미 가져온 플러그인은 기본적으로 건너뜁니다. 플러그인 업데이트 후 강제로 다시 가져오려면 다음을 실행하세요:
    ```bash
    agy plugin import gemini --force
    ```

### What Gets Imported

| Component | What it means |
| :-- | :-- |
| `skills` | SKILL.md files with YAML frontmatter — injected into agy's context |
| `commands` | Slash commands available inside agy sessions |
| `mcpServers` | MCP tool servers (GitHub, gcloud, Workspace, etc.) — stdio or SSE |
| `agents` | Custom subagent definitions |
| `hooks` | Staged but not auto-executed (agy handles lifecycle differently) |
| `rules` | Rules files (`rules.md`, `rules/*.md`) injected as RULE blocks |

---

## 2.2 — Importing from Claude Code <span class="duration-badge">5 min</span>

> **Pattern: Unified Tool Surface** — if you use Claude Code alongside agy, import its plugins too.

```bash
agy plugin import claude
```text

Same mechanic — agy discovers your Claude Code extension installations and bridges compatible components.

!!! info "Component compatibility"
    Not all Claude Code extension components map 1:1 to agy's model. agy imports what's compatible and silently skips what isn't.

---

## 2.3 — Managing Plugins Per-Project <span class="duration-badge">10 min</span>

> **Pattern: Project-Scoped Plugin Config** — not every plugin is appropriate for every codebase.

### Enable / Disable

```bash
# 이 세션/프로젝트에 대해 플러그인 비활성화
agy plugin disable gemini-deep-research

# 다시 활성화
agy plugin enable gemini-deep-research

# 현재 상태 확인
agy plugin list
```text

### Plugin Locations

Plugins can be installed at two levels:

| Scope | Path |
| :-- | :-- |
| **Global** | `~/.gemini/config/plugins/` |
| **Project** | `.agents/plugins/` |

### Install a Specific Plugin

```bash
# 이름으로 설치 (구성된 소스에서)
agy plugin install <plugin-name>

# 특정 버전 설치
agy plugin install <plugin-name>@<version>
```text

---

## 2.4 — Validating a Plugin <span class="duration-badge">10 min</span>

> **Pattern: Plugin-as-Code** — treat plugin definitions like source code. Validate before shipping.

### Validate an Existing Plugin Directory

```bash
# 플러그인 디렉토리 유효성 검사
agy plugin validate ./path/to/my-plugin

# 또는 현재 디렉토리 유효성 검사
agy plugin validate .
```text

This checks that the plugin's `plugin.json` manifest is well-formed and all referenced components exist.

### Build a Minimal Custom Plugin

A valid agy plugin needs a `plugin.json` manifest. Here's the official structure:

```text
my-plugin/
├── plugin.json          ← 매니페스트 (필수)
├── mcp_config.json      ← MCP 서버 정의 (선택 사항)
├── hooks.json           ← 훅 이벤트 핸들러 (선택 사항)
├── skills/              ← YAML 프런트매터가 있는 SKILL.md 파일
│   └── my-skill/
│       └── SKILL.md
├── agents/              ← 서브에이전트 정의 (선택 사항)
└── rules/               ← 규칙 파일 (선택 사항)
    └── my-rules.md
```text

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "내 사용자 지정 agy 플러그인",
  "components": ["skills"]
}
```text

```bash
# 유효성 검사
agy plugin validate ./my-plugin

# 유효한 경우 다음이 표시됩니다: ✔ Plugin manifest is valid
```text

### Interacting with Plugin Components

Use slash commands to inspect active plugin components in a session:

| Command | What it shows |
| :-- | :-- |
| `/skills` | All loaded skills (from plugins, project, global) |
| `/mcp` | Active MCP servers and their status |

### Exercise: Validate the Workshop Plugin

The workshop repo includes a sample plugin at `samples/plugins/workshop-helpers/`. Validate it:

```bash
agy plugin validate samples/plugins/workshop-helpers/
```text

---

## 2.5 — Plugin Architecture Overview

```mermaid
graph LR
    GC["Gemini CLI\n플러그인"] -->|agy plugin import gemini| S["플러그인 스테이징\n~/.gemini/antigravity-cli/plugins/"]
    CC["Claude Code\n확장 프로그램"] -->|agy plugin import claude| S
    S -->|agy plugin enable/disable| A[agy 세션]
    A --> SK[스킬]
    A --> MCP[MCP 서버]
    A --> AG[에이전트]
    A --> RU[규칙]
    A --> HK[훅]
```text

Plugin staging directory structure:

```text
~/.gemini/antigravity-cli/plugins/<name>/
├── plugin.json
├── mcp_config.json
├── hooks.json
├── skills/
├── agents/
└── rules/
```text

---

## 모듈 2 실습

<div class="exercise-card" markdown>

#### :material-file-document: 실습 2: 플러그인 브릿지

**파일:** `exercises/ex02_plugin_bridge.md`
**소요 시간:** 20분
**목표:** Gemini CLI에서 플러그인을 가져오고, 선택적으로 활성화/비활성화하며, 사용자 지정 플러그인을 검증합니다.

</div>

---

## 다음 모듈

→ **[모듈 3: DevOps 및 자동화](../devops-automation.md)** — 비대화형 파이프라인, CI/CD, 다중 디렉터리 작업 공간.
