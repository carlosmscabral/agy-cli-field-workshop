# 模块 3：DevOps 与自动化 <span class="duration-badge">40 分钟</span>

> **无需人工干预的 agy。** 本模块涵盖非交互式 `--print` 流水线、CI/CD 集成、多仓库工作区以及针对治理敏感环境的沙盒执行。

---

## 3.0 — 打印模式：非交互式核心 <span class="duration-badge">5 分钟</span>

`--print`（简写：`-p`）是 agy 的无头模式。它运行单个提示词，打印响应，然后退出。没有交互式会话，没有输入提示。

```bash
# Basic usage
agy --print "Summarize the top-level README of this project."

# Set a timeout (default: 5 minutes)
agy --print "Generate a full test suite for auth.js" --print-timeout 10m

# Short form
agy -p "What does this project do?"
```text

输出直接进入标准输出 (stdout) —— 可以对其进行管道传输、重定向或存储。

```bash
# Pipe into a file
agy -p "Generate API documentation for all endpoints" > docs/api.md

# Pipe into another command
agy -p "List all TODO comments in this codebase as JSON" | jq '.[] | .file'
```text

---

## 3.1 — Shell 管道 <span class="duration-badge">10 min</span>

> **模式：将 agy 作为 Unix 命令** — 将其与标准 shell 工具组合使用。

### 模式：将代码通过管道传递给 agy

```bash
# Review a specific file
cat src/auth.js | agy -p "Review this file for security vulnerabilities."

# Review staged changes before commit
git diff --cached | agy -p "Review these changes. Flag bugs, security issues, or missing tests."

# Analyze a log file
tail -n 200 app.log | agy -p "Identify patterns in these errors. Group by root cause."
```text

### 模式：链式调用 agy

```bash
# Step 1: Generate a plan
agy -p "Create a migration plan for moving this project from CommonJS to ESM. Output as JSON with steps array." > migration-plan.json

# Step 2: Execute step by step
cat migration-plan.json | agy -p "Execute step 1 of this migration plan."
```text

### 模式：批处理

```bash
# Process multiple files
for f in src/**/*.js; do
  echo "Reviewing $f..."
  agy -p "Add JSDoc comments to all exported functions in this file." --add-dir "$(dirname $f)" > /tmp/review.md
  cat /tmp/review.md
done
```text

---

## 3.2 — 使用 --add-dir 的多目录工作区 <span class="duration-badge">10 分钟</span>

> **模式：跨仓库上下文** — 让 agy 同时具备对多个代码库的可见性。

默认情况下，agy 会索引包含您当前目录的 git 仓库。`--add-dir` 将此范围扩展到其他附加目录。

```bash
# Give agy access to both your app and its shared library
agy --add-dir ../shared-lib "How does the app use shared-lib? Identify any API mismatches."

# Add multiple directories
agy --add-dir ../api --add-dir ../frontend "Generate an integration test that covers the API-to-frontend data flow."

# Use in print mode
agy -p "Compare the error handling patterns in app/ vs api/" --add-dir ../api
```text

### 真实世界的使用场景：Monorepo 审查

```bash
# From the root of a monorepo, review cross-package dependencies
agy --add-dir packages/core --add-dir packages/api --add-dir packages/ui \
    -p "Map the dependency graph between these three packages and flag any circular dependencies."
```text

!!! tip "可重复使用的标志"
    `--add-dir` 是可重复的 — 您可以根据需要添加任意数量的目录。agy 会将它们与主 git 仓库一起进行索引。

---

## 3.3 — CI/CD 集成 <span class="duration-badge">10 分钟</span>

> **模式：流水线中的 agy** — 在每个 PR 上进行自动化的代码审查和分析。

### GitHub Actions 示例

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

!!! warning "CI 中的 --dangerously-skip-permissions"
    在 CI 中始终使用 `--dangerously-skip-permissions` — 因为没有人工来点击“批准”。将其与沙盒模式结合使用，以限制 agy 可以访问的内容。

### Pre-Commit 钩子

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

## 3.4 — 沙盒模式 <span class="duration-badge">5 min</span>

> **模式：受限执行** — 在操作系统级别的终端隔离下运行 agy。

### 启用沙盒

沙盒通过 `settings.json`（项目级 `.agents/settings.json` 或用户级 `~/.gemini/antigravity-cli/settings.json`）进行配置：

```json
{
  "enableTerminalSandbox": true
}
```text

启用后，agy 使用**原生操作系统隔离**来限制终端命令的执行：

| 操作系统 | 隔离技术 |
| :-- | :-- |
| **Linux** | nsjail |
| **macOS** | sandbox-exec |
| **Windows** | AppContainer |

### 逐命令绕过

在启用沙盒的情况下，当命令需要突破沙盒时，agy 将**提示要求批准**。您将看到一个逐命令绕过提示 — 允许选择性执行，而无需禁用整个沙盒。

### 使用场景

- 在不受信任的代码上运行 agy
- 在无副作用的情况下审计敏感内容
- 任何执行都需要批准的治理敏感环境

### 与权限结合使用

为了获得最大程度的控制，请将沙盒模式与权限模型结合使用：

```json
{
  "enableTerminalSandbox": true,
  "permissions": {
    "allow": ["read_file", "command(git)"],
    "deny": ["command(rm)", "unsandboxed"]
  }
}
```text

> 📖 完整详情：[权限文档](https://www.antigravity.google/docs/permissions)

---

## 3.5 — 钩子与规则 <span class="duration-badge">5 分钟</span>

> **模式：护栏与自动化** — 在关键生命周期点强制执行标准并触发操作。

### 钩子

钩子允许您在 5 个生命周期事件中运行自定义逻辑：

| 事件 | 触发时机 |
| :-- | :-- |
| `PreToolUse` | 在 agy 调用任何工具（读取文件、运行命令等）之前 |
| `PostToolUse` | 在工具调用完成之后 |
| `PreInvocation` | 在 agy 开始处理提示词之前 |
| `PostInvocation` | 在 agy 完成响应之后 |
| `Stop` | 在会话结束时 |

在 `hooks.json` 中配置钩子（项目级别位于 `.agents/` 中，全局级别位于 `~/.gemini/config/` 中）。钩子脚本通过标准输入（stdin）接收 JSON，并通过标准输出（stdout）返回 JSON。

> 📖 完整详情：[钩子文档](https://www.antigravity.google/docs/hooks)

### 规则

规则是注入到 agy 系统提示词中的 markdown 文件，作为 `RULE` 块存在 —— 这是 agy 必须遵循的硬性约束。

| 作用域 | 位置 |
| :-- | :-- |
| **项目** | `.agents/rules.md` 或 `.agents/rules/*.md` |
| **全局** | `~/.gemini/config/rules.md` 或 `~/.gemini/config/rules/*.md` |

示例 `.agents/rules.md`：

```markdown
- Never delete migration files
- Always use TypeScript strict mode
- Run `npm test` after any code change
- Do not modify files in the vendor/ directory
```text

> 📖 完整详情：[规则与工作流文档](https://www.antigravity.google/docs/rules-workflows)

---

## 模块 3 练习

<div class="exercise-card" markdown>

#### :material-file-document: 练习 3：--print 管道

**文件：** `exercises/ex03_print_mode_pipeline.md`
**时长：** 20 分钟
**目标：** 使用 agy --print 构建多步 shell 管道。审查已暂存的更改，生成文档，并配置 GitHub Actions 工作流。

</div>

---

## 下一模块

→ **[模块 4：多代理与高级](../multi-agent-advanced.md)** — 子代理、/btw 任务中途引导、调度。
