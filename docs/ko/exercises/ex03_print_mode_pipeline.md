# 실습 3: --print 모드 파이프라인

> **소요 시간:** 20분 | **모듈:** 3 — DevOps 및 자동화

---

## 목표

`agy --print`를 사용하여 다단계 셸 파이프라인을 구축합니다. 스테이징된 변경 사항을 검토하고, 문서를 생성하며, GitHub Actions 워크플로우의 초안을 작성합니다.

---

## 파트 1: 스테이징된 변경 사항 검토 (5분)

프로젝트의 파일에 작은 코드 변경을 수행합니다:

```bash
# Make any small edit
echo "// TODO: refactor this" >> src/index.js   # or equivalent

# Stage it
git add src/index.js
```

이제 헤드리스 검토를 실행합니다:

```bash
git diff --cached | agy -p "Review these staged changes. Flag any issues. Output as markdown." \
  --print-timeout 60s
```

**참고:** 대화형 세션이 필요하지 않습니다. agy가 stdin을 입력으로 받아 stdout으로 출력했습니다.

---

## 파트 2: API 문서 생성 (5분)

함수 또는 라우트가 있는 소스 파일을 선택하세요:

```bash
# Generate docs for a specific file
cat src/routes/api.js | \
  agy -p "Generate OpenAPI-style documentation for all routes in this file. Output as YAML." \
  --print-timeout 90s > docs/api-generated.yaml

# Verify the output
cat docs/api-generated.yaml
```

---

## 파트 3: 다중 디렉터리 분석 (5분)

사용 가능한 다른 저장소나 디렉터리가 있는 경우:

```bash
# Analyze two directories simultaneously
agy --add-dir ../another-project \
    -p "Compare the error handling approaches in both projects. Which is more consistent?" \
    --print-timeout 90s
```

저장소가 하나만 있는 경우, 두 개의 하위 디렉터리를 사용하세요:

```bash
agy --add-dir ./backend --add-dir ./frontend \
    -p "Are there any API contracts defined in the backend that aren't implemented in the frontend?" \
    --print-timeout 2m
```

---

## 파트 4: CI/CD 워크플로우 초안 작성 (5분)

```bash
agy -p "Write a GitHub Actions workflow that: (1) checks out the repo, (2) runs agy in print mode to review changed files, (3) posts the review as a PR comment. Use --dangerously-skip-permissions for CI. Output as a complete .yml file." \
  --print-timeout 2m > .github/workflows/agy-review.yml

cat .github/workflows/agy-review.yml
```

---

## 완료 기준

- [ ] `git diff --cached | agy -p "..."` 명령이 실행되어 리뷰 출력을 생성함
- [ ] 생성된 API 문서가 파일에 작성됨
- [ ] 최소 하나 이상의 추가 디렉터리와 함께 `--add-dir`이 사용됨
- [ ] GitHub Actions 워크플로 YAML이 생성되고 저장됨
