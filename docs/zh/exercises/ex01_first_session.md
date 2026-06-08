# 练习 1：首次会话

> **时长：** 15 分钟 | **模块：** 1 — SDLC 生产力提升

---

## 目标

启动 agy-cli，探索代码库，并创建一个 AGENTS.md，让未来的每次会话都变得更智能。

---

## 环境设置

您需要一个 Git 仓库来进行操作。请使用此仓库中的示例应用程序，或者使用您自己的：

```bash
# Option A: Use the workshop sample (minimal Node.js app)
cd samples/demo-app

# Option B: Use any of your own Git repos
cd /path/to/your/project
```

---

## 第 1 部分：首次交互式会话（5 分钟）

```bash
agy
```

在提示符下，询问：

```text
> What does this project do? Give me a one-paragraph summary.
```

然后继续提问：

```text
> What are the top 3 files I should read to understand the core logic?
```

```text
> Are there any obvious code quality issues or tech debt?
```

**注意：** agy 读取了您的文件，而无需您指定它们。它自动索引了 git 仓库。

---

## 第 2 部分：深入探讨 (5 分钟)

从 agy 的建议中选择一个文件并深入探讨：

```text
> Explain [filename] in detail. Walk me through what each function does and how they connect.
```

```text
> If I wanted to add [a simple feature], where would I start?
```

---

## 第 3 部分：创建 AGENTS.md（5 分钟）

现在将你学到的内容整理成文档，以便未来的每个会话都能带有上下文：

```text
> Based on our conversation, generate an AGENTS.md file for this project. Include: project purpose, tech stack, key conventions, and anything I should tell an AI assistant before asking it to modify this code.
```

检查 agy 生成的内容。如果有任何错误，请进行编辑。然后将其写入：

```text
> Write that AGENTS.md to the project root.
```

启动一个新会话并验证它是否有效：

```bash
agy --print "What do you know about this project?" --print-timeout 30s
```

---

## 完成标准

- [ ] agy 已启动并在交互模式下响应
- [ ] 探索了至少 3 个后续问题
- [ ] AGENTS.md 存在于项目根目录
- [ ] `agy --print "What do you know about this project?"` 返回准确的信息
