# 练习 4：子代理

> **时长：** 20 分钟 | **模块：** 4 — 多代理与高级

---

## 目标

在您的代码库上生成并行的子代理，练习对抗性审查者模式，并观察隔离执行。

---

## 第 1 部分：并行审计（10 分钟）

以交互方式启动 agy：

```bash
agy
```

派遣一个并行审计团队：

```text
> Spawn two subagents in parallel using branch workspace mode:
> 1. A security auditor — scan for: hardcoded credentials, injection vulnerabilities, exposed sensitive data, and insecure dependencies
> 2. A test coverage auditor — identify: untested public functions, missing edge cases, and integration test gaps
>
> Report back when both complete with a combined findings summary.
```

在它们运行期间，询问：

```text
> What's the status of the subagents?
```

当它们完成时：

```text
> Show me the combined findings from both audits. What are the top 3 things to fix?
```

---

## 第 2 部分：对抗性审查员 (7 分钟)

选择一个最近的 PR、分支或任何一组更改：

```bash
git checkout -b feature/my-test-branch
# (make a few changes)
git add -A
```

回到 agy 中：

```text
> I have changes on the current branch. Spawn an adversarial reviewer subagent.
> Its only job: find reasons why these changes should NOT be merged.
> It should challenge assumptions, look for edge cases, and be skeptical of everything.
> Be harsh — this is an adversarial review, not a supportive one.
```

阅读对抗性审查的发现。目标是找出彻底的代码审查会发现的问题。

---

## 第 3 部分：恢复子代理的工作 (3 分钟)

```text
> One of the subagent findings mentioned [specific issue]. Let's fix it. Create a subagent in inherit mode to implement the fix.
```

请注意与分支模式的区别：`inherit` 意味着子代理与您的主会话在同一个目录中工作——适用于有针对性的、无冲突的修复。

---

## 完成标准

- [ ] 成功生成了至少 2 个并行的子代理
- [ ] 两个子代理均已运行并返回了发现结果
- [ ] 对抗性审查者返回了关键发现结果
- [ ] 使用了至少两种不同的工作区模式（分支与继承）
