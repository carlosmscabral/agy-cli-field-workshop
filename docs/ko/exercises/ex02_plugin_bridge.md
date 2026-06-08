# 실습 2: 플러그인 브릿지

> **소요 시간:** 20분 | **모듈:** 2 — 플러그인 생태계

---

## 목표

기존 플러그인 라이브러리를 Antigravity CLI로 가져오고, 플러그인을 선택적으로 활성화/비활성화하며, 샘플 사용자 지정 플러그인을 검증합니다.

---

## 파트 1: 플러그인 가져오기 (7분)

```bash
# Check what's currently in agy
agy plugin list

# Import everything from Gemini CLI
agy plugin import gemini
```

출력을 주의 깊게 읽어보세요:

- 어떤 플러그인을 가져왔나요?
- 각 플러그인이 어떤 구성 요소(스킬, 명령어, mcpServers, 에이전트)를 제공했나요?
- 건너뛴 것이 있나요? 이유는 무엇인가요?

```bash
# See the updated list
agy plugin list | python3 -m json.tool
```

**질문:** 이전에는 없었지만 지금은 사용할 수 있는 플러그인은 무엇인가요?

---

## 파트 2: 가져온 플러그인 테스트 (5분)

agy를 실행하고 가져온 플러그인 중 하나의 명령을 시도해 보세요:

```bash
agy
```

`code-review`를 가져온 경우:

```text
> /code-review Review the main entry point of this project.
```

`gemini-deep-research`를 가져온 경우:

```text
> Use the deep research capability to find best practices for error handling in Node.js APIs.
```

---

## 파트 3: 비활성화 및 재활성화 (3분)

```bash
# Disable a plugin you just imported
agy plugin disable <plugin-name>

# Confirm it's disabled
agy plugin list | python3 -m json.tool

# Re-enable it
agy plugin enable <plugin-name>
```

---

## 파트 4: 샘플 플러그인 유효성 검사 (5분)

워크숍 저장소에는 샘플 플러그인이 포함되어 있습니다:

```bash
ls samples/plugins/workshop-helpers/

# Validate its structure
agy plugin validate samples/plugins/workshop-helpers/
```

그런 다음 의도적으로 손상시켜 유효성 검사에서 무엇을 잡아내는지 확인합니다:

```bash
# Edit the manifest to remove a required field (use any text editor)
# Then re-validate
agy plugin validate samples/plugins/workshop-helpers/
```

완료되면 매니페스트를 복원합니다.

---

## 완료 기준

- [ ] `agy plugin import`가 성공적으로 실행되어 하나 이상의 플러그인을 가져왔습니다.
- [ ] 가져온 플러그인에서 하나 이상의 명령을 테스트했습니다.
- [ ] 플러그인을 성공적으로 비활성화하고 다시 활성화했습니다.
- [ ] 샘플 플러그인에서 `agy plugin validate`가 유효한 결과를 반환했습니다.
