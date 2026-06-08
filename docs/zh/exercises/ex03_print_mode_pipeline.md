# 练习 3：--print 模式流水线

> **时长：** 20 分钟 | **模块：** 3 — DevOps 与自动化

---

## 目标

使用 `agy --print` 构建多步 Shell 管道。审查暂存的更改，生成文档，并起草一个 GitHub Actions 工作流。

---

## 第 1 部分：审查暂存的更改（5 分钟）

对项目中的文件进行少量代码更改：

```bash
# Make any small edit
echo "// TODO: refactor this" >> src/index.js   # or equivalent

# Stage it
git add src/index.js
```

现在运行无头审查：

```bash
git diff --cached | agy -p "Review these staged changes. Flag any issues. Output as markdown." \
  --print-timeout 60s
```

**注意：** 不需要交互式会话。agy 读取了 stdin 并打印到 stdout。

---

## 第 2 部分：生成 API 文档 (5 分钟)

选择一个包含函数或路由的源文件：

```bash
# Generate docs for a specific file
cat src/routes/api.js | \
  agy -p "Generate OpenAPI-style documentation for all routes in this file. Output as YAML." \
  --print-timeout 90s > docs/api-generated.yaml

# Verify the output
cat docs/api-generated.yaml
```

---

## 第 3 部分：多目录分析（5 分钟）

如果您有另一个可用的代码库或目录：

```bash
# Analyze two directories simultaneously
agy --add-dir ../another-project \
    -p "Compare the error handling approaches in both projects. Which is more consistent?" \
    --print-timeout 90s
```

如果您只有一个代码库，请使用两个子目录：

```bash
agy --add-dir ./backend --add-dir ./frontend \
    -p "Are there any API contracts defined in the backend that aren't implemented in the frontend?" \
    --print-timeout 2m
```

---

## 第 4 部分：起草 CI/CD 工作流 (5 分钟)

```bash
agy -p "Write a GitHub Actions workflow that: (1) checks out the repo, (2) runs agy in print mode to review changed files, (3) posts the review as a PR comment. Use --dangerously-skip-permissions for CI. Output as a complete .yml file." \
  --print-timeout 2m > .github/workflows/agy-review.yml

cat .github/workflows/agy-review.yml
```

---

## 完成标准

- [ ] 运行了 `git diff --cached | agy -p "..."` 并生成了审查输出
- [ ] 生成的 API 文档已写入文件
- [ ] 使用了 `--add-dir` 并至少包含一个附加目录
- [ ] 已生成并保存 GitHub Actions 工作流 YAML 文件
