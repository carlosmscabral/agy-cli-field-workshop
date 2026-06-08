# 练习 2：插件桥接

> **时长：** 20 分钟 | **模块：** 2 — 插件生态系统

---

## 目标

将您现有的插件库导入 Antigravity CLI，选择性地启用/禁用插件，并验证一个示例自定义插件。

---

## 第 1 部分：导入插件 (7 分钟)

```bash
# Check what's currently in agy
agy plugin list

# Import everything from Gemini CLI
agy plugin import gemini
```

仔细阅读输出内容：

- 导入了哪些插件？
- 每个插件提供了哪些组件（技能、命令、mcpServers、代理）？
- 有没有被跳过的？为什么？

```bash
# See the updated list
agy plugin list | python3 -m json.tool
```

**问题：** 现在有哪些以前没有的可用插件？

---

## 第 2 部分：测试导入的插件 (5 分钟)

启动 agy 并尝试运行来自其中一个导入的插件的命令：

```bash
agy
```

如果导入了 `code-review`：

```text
> /code-review Review the main entry point of this project.
```

如果导入了 `gemini-deep-research`：

```text
> Use the deep research capability to find best practices for error handling in Node.js APIs.
```

---

## 第 3 部分：禁用与重新启用 (3 分钟)

```bash
# Disable a plugin you just imported
agy plugin disable <plugin-name>

# Confirm it's disabled
agy plugin list | python3 -m json.tool

# Re-enable it
agy plugin enable <plugin-name>
```

---

## 第 4 部分：验证示例插件（5 分钟）

研讨会仓库包含一个示例插件：

```bash
ls samples/plugins/workshop-helpers/

# Validate its structure
agy plugin validate samples/plugins/workshop-helpers/
```

然后故意破坏它，看看验证会捕获到什么：

```bash
# Edit the manifest to remove a required field (use any text editor)
# Then re-validate
agy plugin validate samples/plugins/workshop-helpers/
```

完成后恢复清单文件。

---

## 完成标准

- [ ] `agy plugin import` 成功运行并至少导入了一个插件
- [ ] 测试了来自已导入插件的至少一个命令
- [ ] 成功禁用并重新启用了一个插件
- [ ] `agy plugin validate` 在示例插件上返回了有效结果
