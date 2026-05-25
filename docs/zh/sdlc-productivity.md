# 模块 1：SDLC 生产力提升 <span class="duration-badge">50 分钟</span>

> **你的第一次真正的 agy-cli 会话。** 本模块涵盖了核心的日常工作流：理解代码、重构、生成测试以及审查更改——所有这些都在终端中完成。

---

## 1.0 — 首次交互式会话 <span class="duration-badge">5 分钟</span>

在您的研讨会项目目录中启动 agy-cli：

```bash
cd agy-cli-field-workshop
agy
```

您将进入交互式提示符。尝试输入：

```
> What files are in this project and what does each one do?
```

观察 agy 如何读取您的工作区 —— 它会索引 git 仓库，读取文件内容，并结合上下文进行响应。这是**自动**的：无需配置，也无需预先编写提示词。

!!! tip ".agents/ 文件夹"
    在您的首次会话之后，检查 `.agents/` —— agy 创建了跟踪您工作区的项目配置文件。这就是它在未来运行中知道要索引什么内容的方式。

---

## 1.1 — 代码理解 <span class="duration-badge">10 min</span>

> **模式：修改前先解释** — 在修改代码之前先理解它。

### 练习：梳理陌生的代码库

```bash
# Start with --prompt-interactive: give agy an initial task, then continue conversationally
agy -i "Give me a high-level architecture overview of this project. What are the main components and how do they connect?"
```

然后进行交互式跟进：

```
> Which file handles the entry point?
> What external dependencies does this project have?
> Are there any obvious code smells or tech debt?
```

!!! tip "使用 -i 进行预设会话"
    `agy -i "<task>"`（`--prompt-interactive` 的简写）以提示词开始，但保持交互状态。非常适合定向探索——你设定方向，然后通过跟进进行引导。

---

## 1.2 — 重构 <span class="duration-badge">10 分钟</span>

> **模式：提议、审查、应用** — 永远不要应用你没有阅读过的更改。

### 练习：针对性重构

```bash
agy
```

```
> I want to refactor the error handling in this project. First, show me all the places where errors are currently caught or returned — don't change anything yet.
```

审查发现的问题。然后：

```
> Now propose a refactored version of [specific function] using a consistent error handling pattern. Show me the diff before applying.
```

只有在阅读了提议的更改后才进行应用。

### 权限模型

agy 具有一个**三级权限模型**，用于控制其处理工具审批的方式：

| 级别 | 行为 |
|---|---|
| `request-review` | **默认。** agy 在写入文件或运行命令之前会请求批准 |
| `always-proceed` | 自动批准所有工具调用 — 适用于受信任的脚本和 CI |
| `strict` | 拒绝所有工具使用，除非明确允许 — 最大限度的控制 |

使用 `/permissions` 斜杠命令查看或更改当前级别。你还可以设置细粒度的规则：

```json
{
  "permissions": {
    "allow": ["command(git)", "read_file"],
    "deny": ["command(rm -rf)"]
  }
}
```

> 📖 完整详情：[权限文档](https://www.antigravity.google/docs/permissions) · [严格模式文档](https://www.antigravity.google/docs/strict-mode)

---

## 1.3 — 测试生成 <span class="duration-badge">10 分钟</span>

> **模式：测试现有代码** — 为真实代码生成测试，而不是假设的代码。

### 练习：生成单元测试

```bash
agy
```

```
> Look at [specific function or file]. Generate a comprehensive unit test suite for it. Include happy path, edge cases, and error conditions. Use the testing framework already in this project.
```

然后：

```
> Run the tests and fix any that fail.
```

!!! tip "让 agy 运行测试"
    agy 可以执行 shell 命令。它将运行你的测试套件并在失败时进行迭代，而无需你复制粘贴错误消息。观察它的自我修正过程。

---

## 1.4 — 代码审查 <span class="duration-badge">10 min</span>

> **模式：提交前审查** — 在每次推送之前，使用 agy 作为高级审查员。

### 练习：审查你的更改

```bash
# Stage some changes (or use an existing branch)
git add -p

# Start agy and review what's staged
agy
```

```
> Review my staged changes for: (1) correctness, (2) security issues, (3) missing test coverage, (4) anything that would block a PR. Be direct — don't soften findings.
```

### 无头变体（用于脚本编写）

```bash
# Review changes non-interactively — useful in pre-commit hooks or CI
git diff --cached | agy --print "Review these changes. Flag any bugs, security issues, or missing tests. Output as markdown."
```

---

## 1.5 — 使用 AGENTS.md 设置项目上下文 <span class="duration-badge">5 分钟</span>

> **模式：持久化上下文** — 告诉 agy 一次，它会在每个会话中记住。

agy 在会话开始时读取上下文文件。在项目根目录下创建一个：

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

现在启动一个新会话：

```bash
agy --print "What do you know about this project?"
```

agy 会自动将你的 AGENTS.md 整合到随后的每个会话中。

!!! info "上下文层级"
    agy 按照以下顺序读取 AGENTS.md：当前目录 → 父目录 → 主目录。更具体的上下文会覆盖更广泛的上下文。

### 其他上下文来源

除了 AGENTS.md 之外，agy 还会加载：

- **`.agents/rules.md`**（或 `.agents/rules/*.md`）— 作为系统提示词指令注入的项目级规则。将这些用于硬性要求，例如“永远不要删除迁移文件”或“始终使用 TypeScript 严格模式”。
- **`.gemini/`** — 为了与 Gemini CLI 兼容，agy 会与 `.agents/` 一起读取 `.gemini/` 目录。
- **`~/.gemini/config/rules.md`** — 应用于所有会话的全局规则。

> 📖 完整详情：[规则与工作流文档](https://www.antigravity.google/docs/rules-workflows)

---

## 1.6 — 交互式导航 <span class="duration-badge">5 分钟</span>

> **模式：终端熟练度** — 了解让 agy 会话变得更快的快捷键。

> 📖 完整参考：[使用 Antigravity CLI](https://www.antigravity.google/docs/cli-using)

### 关键斜杠命令

| 命令 | 功能说明 |
|---|---|
| `/rewind`（或 `/undo`） | 将对话历史回滚到上一个检查点 |
| `/resume`（或 `/switch`） | 打开对话选择器以恢复或切换会话 |
| `/rename <name>` | 重命名当前活动的对话线程 |
| `/config`（或 `/settings`） | 打开全屏设置覆盖层 |
| `/permissions` | 设置代理自治级别（`request-review`、`always-proceed`、`strict`） |
| `/model` | 选择推理模型（跨会话持久化） |
| `/tasks` | 监控、查看日志或终止后台任务 |
| `/agents` | 查看、管理和批准子代理操作 |
| `/open <path>` | 在您首选的外部编辑器中打开文件 |
| `/usage` | 打开内联交互式帮助手册 |
| `/skills` | 浏览本地和全局代理技能 |
| `/mcp` | 配置和管理 MCP 服务器 |

> 📖 完整斜杠命令参考：[CLI 功能](https://antigravity.google/docs/cli-features)

### 快速提示

| 快捷键 | 功能说明 |
|---|---|
| `@` | 文件路径自动补全 — 键入 `@` 触发路径建议 |
| `!` | 直接运行终端命令而无需离开 agy |
| `esc esc` | 清除当前的提示词输入（当没有活动的流式传输时） |
| `?` | 获取帮助并列出所有斜杠命令 |
| `alt+enter` / `ctrl+j` / `shift+enter` | 在您的提示词中插入换行符（多行输入） |
| `ctrl+g` | 在您的默认 shell 编辑器中编辑提示词 |
| `ctrl+l` | 清除 TUI 屏幕 |
| `ctrl+d` | 退出 CLI |

> 📖 完整快捷键参考：[使用 Antigravity CLI](https://antigravity.google/docs/cli-using)

---

## 模块 1 练习

<div class="exercise-card" markdown>

#### :material-file-document: 练习 1：首次会话

**文件：** `exercises/ex01_first_session.md`
**时长：** 15 分钟
**目标：** 启动 agy，探索代码库，生成一个 AGENTS.md。

</div>

---

## 下一模块

→ **[模块 2：插件生态系统](../plugin-ecosystem.md)** — 只需一条命令即可将 Gemini CLI 和 Claude 插件导入到 agy 中。
