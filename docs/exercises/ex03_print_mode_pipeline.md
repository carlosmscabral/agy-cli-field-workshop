# Exercise 3: --print Mode Pipeline

> **Duration:** 20 min | **Module:** 3 — DevOps & Automation

---

## Objective

Build a multi-step shell pipeline using `agy --print`. Review staged changes, generate documentation, and draft a GitHub Actions workflow.

---

## Part 1: Review Staged Changes (5 min)

Make a small code change to a file in your project:

```bash
# Make any small edit
echo "// TODO: refactor this" >> src/index.js   # or equivalent

# Stage it
git add src/index.js
```text

Now run a headless review:

```bash
git diff --cached | agy -p "Review these staged changes. Flag any issues. Output as markdown." \
  --print-timeout 60s
```text

**Notice:** no interactive session needed. agy consumed stdin and printed to stdout.

---

## Part 2: Generate API Documentation (5 min)

Pick a source file with functions or routes:

```bash
# Generate docs for a specific file
cat src/routes/api.js | \
  agy -p "Generate OpenAPI-style documentation for all routes in this file. Output as YAML." \
  --print-timeout 90s > docs/api-generated.yaml

# Verify the output
cat docs/api-generated.yaml
```text

---

## Part 3: Multi-Directory Analysis (5 min)

If you have another repo or directory available:

```bash
# Analyze two directories simultaneously
agy --add-dir ../another-project \
    -p "Compare the error handling approaches in both projects. Which is more consistent?" \
    --print-timeout 90s
```text

If you only have one repo, use two subdirectories:

```bash
agy --add-dir ./backend --add-dir ./frontend \
    -p "Are there any API contracts defined in the backend that aren't implemented in the frontend?" \
    --print-timeout 2m
```text

---

## Part 4: Draft a CI/CD Workflow (5 min)

```bash
agy -p "Write a GitHub Actions workflow that: (1) checks out the repo, (2) runs agy in print mode to review changed files, (3) posts the review as a PR comment. Use --dangerously-skip-permissions for CI. Output as a complete .yml file." \
  --print-timeout 2m > .github/workflows/agy-review.yml

cat .github/workflows/agy-review.yml
```text

---

## Completion Criteria

- [ ] `git diff --cached | agy -p "..."` ran and produced review output
- [ ] Generated API documentation written to a file
- [ ] `--add-dir` used with at least one additional directory
- [ ] GitHub Actions workflow YAML generated and saved
