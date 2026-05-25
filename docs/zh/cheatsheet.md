# agy-cli 速查表

> 本工作坊涵盖的所有内容的快速参考。
> 所有命令均已对照 [antigravity.google/docs](https://antigravity.google/docs/cli-overview) 进行验证。

---

## 安装与版本

```bash
curl -fsSL https://antigravity.google/cli/install.sh | bash
agy --help         # Show all flags and subcommands
agy changelog      # Show release notes
agy update         # Self-update
agy install        # Configure PATH and shell aliases
```bash

---

## 启动模式

| 模式 | 命令 | 何时使用 |
|---|---|---|
| **交互式** | `agy` | 默认 — 完整的对话会话 |
| **预设交互式** | `agy -i "<提示词>"` | 带着方向启动，随后继续对话 |
| **打印 (无头模式)** | `agy -p "<提示词>"` | 单次执行，通过管道输出到标准输出 |
| **继续上一次** | `agy -c` | 恢复最近一次的会话 |
| **按 ID 恢复** | `agy --conversation <id>` | 恢复特定的历史会话 |
| **会话内恢复** | `/resume` 或 `/switch` | 在不离开 agy 的情况下切换对话 |

---

## 关键标志

> 来源：[`agy --help`](https://antigravity.google/docs/cli-getting-started) · [CLI 使用](https://antigravity.google/docs/cli-using)

| 标志 | 简写 | 描述 |
|---|---|---|
| `--print "<提示词>"` | `-p` | 非交互式单一提示词 |
| `--prompt-interactive "<提示词>"` | `-i` | 带初始提示词的交互式会话 |
| `--continue` | `-c` | 恢复最近的会话 |
| `--conversation <id>` | — | 通过会话 ID 恢复 |
| `--add-dir <路径>` | — | 将目录添加到工作区（可重复） |
| `--sandbox` | — | 启用终端沙盒限制 |
| `--dangerously-skip-permissions` | — | 自动批准所有工具请求（仅限 CI） |
| `--print-timeout <时长>` | — | 打印模式的超时时间（默认：5分钟） |
| `--log-file <路径>` | — | 覆盖日志输出路径 |

> **注意：** 模型选择和严格模式是通过 `/model` 和 `/permissions` 斜杠命令设置的，而不是通过 CLI 标志。请参阅 [功能文档](https://antigravity.google/docs/cli-features)。

---

## 斜杠命令（交互模式）

> 来源：[CLI 功能 — 核心斜杠命令](https://antigravity.google/docs/cli-features) · [使用 Antigravity CLI](https://antigravity.google/docs/cli-using)

| 命令 | 类别 | 用途 |
|---|---|---|
| `/resume` (`/switch`) | 对话 | 打开对话选择器以恢复或切换会话 |
| `/rewind` (`/undo`) | 对话 | 将对话历史回滚到上一个检查点 |
| `/rename <name>` | 对话 | 重命名当前活动的对话线程 |
| `/permissions` | 配置 | 设置自治级别：`request-review`、`always-proceed`、`strict` |
| `/model` | 配置 | 选择默认推理模型（跨会话持久保存） |
| `/config` (`/settings`) | 配置 | 打开全屏设置覆盖层 |
| `/keybindings` | 配置 | 打开交互式键盘快捷键编辑器 |
| `/statusline` | 配置 | 自定义实时 CLI 状态栏指示器 |
| `/tasks` | 监控 | 监控、查看日志或终止后台任务 |
| `/skills` | 监控 | 浏览本地和全局代理技能 |
| `/mcp` | 监控 | 配置和管理 MCP 服务器 |
| `/agents` | 监控 | 查看、管理和批准子代理操作 |
| `/open <path>` | 实用工具 | 在首选的外部编辑器中打开文件 |
| `/usage` | 实用工具 | 打开内联交互式帮助手册 |
| `/logout` | 账户 | 登出并清除缓存的凭据 |

---

## 快速提示

> 来源：[使用 Antigravity CLI — 快速提示与快捷键](https://antigravity.google/docs/cli-using)

| 快捷键 / 提示 | 操作 |
|---|---|
| `@` | 文件路径自动补全（输入 `@` 触发路径建议） |
| `!` | 直接从提示词运行终端命令 |
| `esc esc` | 清空提示词框（当没有活动的流式传输时） |
| `?` | 获取帮助并列出所有斜杠命令 |
| `alt+enter` / `ctrl+j` / `shift+enter` | 插入换行符而不提交 |
| `ctrl+g` | 在默认的 shell 编辑器中编辑提示词 |
| `ctrl+l` | 清空 TUI 屏幕 |
| `ctrl+d` | 退出 CLI 会话 |
| `ctrl+z` | 将 CLI 挂起到终端后台 |
| `ctrl+j` （在 `/agents` 中） | 跳转到下一个待处理的子代理审批 |
| `ctrl+k` | 从主对话中快速批准待处理的子代理权限 |

---

## 插件命令

```bash
# List all active plugins (JSON)
agy plugin list

# Import from Gemini CLI
agy plugin import gemini

# Import from Claude Code
agy plugin import claude

# Force re-import (after plugin updates)
agy plugin import gemini --force

# Install a plugin
agy plugin install <name>
agy plugin install <name>@<version>

# Enable / disable
agy plugin enable <name>
agy plugin disable <name>

# Validate a plugin directory
agy plugin validate ./my-plugin

# Generate marketplace link
agy plugin link <marketplace> <target>
```yaml

---

## 工作区与上下文

```bash
# Project config directory:
.agents/                    # settings.json, mcp.json, hooks.json, rules.md, skills/, plugins/

# Global config directory:
~/.gemini/config/           # settings.json, mcp.json, hooks.json, rules.md, skills/, plugins/

# User settings:
~/.gemini/antigravity-cli/settings.json

# Context file (hierarchical: cwd → parent → home):
AGENTS.md

# agy also reads:
.gemini/                    # Gemini CLI config (compatible)
```bash

### AGENTS.md 模式

```markdown
# Project Context

Brief description of what this project is.

## Conventions
- Language: TypeScript, Node 20
- Testing: Jest + Supertest
- DO NOT run database migrations without explicit approval
```yaml

---

## 实用模式

```bash
# Review staged changes before commit
git diff --cached | agy -p "Review for bugs, security issues, missing tests."

# Generate docs for a file
cat src/api.ts | agy -p "Generate OpenAPI documentation for all exported functions."

# Analyze logs
tail -n 500 app.log | agy -p "Group these errors by root cause. Output as JSON."

# Multi-dir cross-repo analysis
agy --add-dir ../api --add-dir ../frontend \
    -p "Map data flow from frontend form submission to database write."

# Full headless CI audit (safe)
agy --sandbox --dangerously-skip-permissions \
    -p "Audit for hardcoded secrets and insecure patterns." \
    --print-timeout 5m > audit.md

# Schedule a recurring task (in interactive mode)
# > Schedule a daily code quality report at 9am weekdays.
```yaml

---

## 多代理模式

```text
# Spawn parallel subagents (in interactive mode)
> Spawn a security auditor and a performance auditor in parallel (branch mode).

# Adversarial review
> Spawn an adversarial reviewer subagent — its job is to find reasons to NOT merge this PR.

# Steer mid-task
/btw Focus only on the authentication module, skip the frontend.

# Background task
> In the background, audit all dependencies for known CVEs. Notify me when done.
```yaml

---

## 打印模式管道示例

```bash
# Step 1: plan
agy -p "Create a refactoring plan for moving from callbacks to async/await. JSON output." \
  > plan.json

# Step 2: execute
cat plan.json | agy -p "Execute step 1 of this plan."

# Batch: process multiple files
for f in src/*.ts; do
  agy --add-dir "$(dirname $f)" \
      -p "Add JSDoc to all exported functions in $(basename $f)."
done
```bash

---

## 官方文档

| 主题 | 链接 |
|---|---|
| CLI 概览 | [antigravity.google/docs/cli-overview](https://antigravity.google/docs/cli-overview) |
| 快速入门 | [antigravity.google/docs/cli-getting-started](https://antigravity.google/docs/cli-getting-started) |
| 使用 Antigravity CLI（设置、技巧、快捷键） | [antigravity.google/docs/cli-using](https://antigravity.google/docs/cli-using) |
| 功能特性（插件、沙盒、斜杠命令、子代理） | [antigravity.google/docs/cli-features](https://antigravity.google/docs/cli-features) |
| 从 Gemini CLI 迁移 | [antigravity.google/docs/gcli-migration](https://antigravity.google/docs/gcli-migration) |
| 权限 | [antigravity.google/docs/permissions](https://antigravity.google/docs/permissions) |
| 严格模式 | [antigravity.google/docs/strict-mode](https://antigravity.google/docs/strict-mode) |
| 插件 | [antigravity.google/docs/plugins](https://antigravity.google/docs/plugins) |
| MCP | [antigravity.google/docs/mcp](https://antigravity.google/docs/mcp) |
| 技能 | [antigravity.google/docs/skills](https://antigravity.google/docs/skills) |
| 规则 | [antigravity.google/docs/rules-workflows](https://antigravity.google/docs/rules-workflows) |
| 钩子 | [antigravity.google/docs/hooks](https://antigravity.google/docs/hooks) |
| 子代理 | [antigravity.google/docs/subagents](https://antigravity.google/docs/subagents) |
| 企业级 | [antigravity.google/docs/enterprise](https://antigravity.google/docs/enterprise) |
