# 실습 1: 첫 번째 세션

> **소요 시간:** 15분 | **모듈:** 1 — SDLC 생산성 향상

---

## 목표

agy-cli를 실행하고 코드베이스를 탐색하며, 향후 모든 세션을 더 스마트하게 만드는 AGENTS.md를 생성합니다.

---

## 설정

작업할 Git 저장소가 필요합니다. 이 저장소의 샘플 앱을 사용하거나 본인의 저장소를 가져오세요:

```bash
# Option A: Use the workshop sample (minimal Node.js app)
cd samples/demo-app

# Option B: Use any of your own Git repos
cd /path/to/your/project
```

---

## 파트 1: 첫 번째 대화형 세션 (5분)

```bash
agy
```

프롬프트에서 다음과 같이 질문하세요:

```text
> What does this project do? Give me a one-paragraph summary.
```

그런 다음 후속 질문을 하세요:

```text
> What are the top 3 files I should read to understand the core logic?
```

```text
> Are there any obvious code quality issues or tech debt?
```

**참고:** agy는 여러분이 파일을 지정하지 않아도 파일을 읽었습니다. 자동으로 git 저장소를 인덱싱했습니다.

---

## 파트 2: 심층 분석 (5분)

agy의 제안 중 파일 하나를 선택하여 더 깊이 파고들어 보세요:

```text
> Explain [filename] in detail. Walk me through what each function does and how they connect.
```

```text
> If I wanted to add [a simple feature], where would I start?
```

---

## 파트 3: AGENTS.md 생성 (5분)

이제 배운 내용을 명문화하여 향후 모든 세션이 컨텍스트를 가지고 시작할 수 있도록 하세요:

```text
> Based on our conversation, generate an AGENTS.md file for this project. Include: project purpose, tech stack, key conventions, and anything I should tell an AI assistant before asking it to modify this code.
```

agy가 생성한 내용을 검토하세요. 잘못된 부분이 있다면 수정합니다. 그런 다음 작성하세요:

```text
> Write that AGENTS.md to the project root.
```

새 세션을 시작하고 제대로 작동하는지 확인하세요:

```bash
agy --print "What do you know about this project?" --print-timeout 30s
```

---

## 완료 기준

- [ ] 대화형 모드에서 agy가 실행되고 응답함
- [ ] 최소 3개의 후속 질문을 탐색함
- [ ] 프로젝트 루트에 AGENTS.md가 존재함
- [ ] `agy --print "What do you know about this project?"` 명령이 정확한 정보를 반환함
