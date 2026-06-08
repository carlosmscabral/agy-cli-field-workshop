# 练习 5：/btw 与调度

> **时长：** 20 分钟 | **模块：** 4 — 多代理与高级功能

---

## 目标

使用 `/btw` 在中途引导长时间运行的任务，并安排定期的自动化分析。

---

## 第 1 部分：/btw 任务中途引导（10 分钟）

启动 agy 并开始一项实质性任务：

```bash
agy
```

```text
> I want to refactor the error handling across this entire project to use a consistent pattern. Start by analyzing all error handling in the codebase, then propose and implement a unified approach. This will touch multiple files — start with the analysis phase.
```

当 agy 开始工作时（在分析阶段），注入一个约束条件：

```text
/btw Only touch files in the backend/ directory for now. Leave frontend untouched.
```

然后添加另一条注释：

```text
/btw Use the Result<T, E> pattern if the language supports it. Otherwise use a custom Error class hierarchy.
```

观察：

- 任务继续进行而无需重新启动
- agy 将两条 `/btw` 注释都纳入其工作方法中
- 最终计划反映了您注入的约束条件

**核心洞察：** `/btw` 允许您在不产生取消和重新启动成本的情况下纠正方向。这相当于在冲刺（sprint）中途拍拍开发人员的肩膀。

---

## 第 2 部分：会话延续 (5 分钟)

结束会话（按 Ctrl+C 或关闭终端）。

恢复最近的会话：

```bash
agy -c
```

```text
> Remind me what we decided about the error handling refactor. What was the approach?
```

agy 将拥有完整的上下文。现在继续工作：

```text
> Let's implement step 1 of the plan we discussed.
```

---

## 第 3 部分：安排定期报告 (5 分钟)

```bash
agy
```

```text
> Schedule a daily dependency check every weekday morning at 8am. It should:
> 1. Check for outdated dependencies with security advisories
> 2. List any new CVEs affecting our current dependency versions
> 3. Save the report to reports/deps-YYYY-MM-DD.md
>
> Create the reports/ directory if it doesn't exist.
```

确认该计划已被接受。提问：

```text
> What scheduled tasks are currently active?
```

---

## 完成标准

- [ ] 启动了一个长时间运行的任务，并在执行期间至少使用了两次 `/btw`
- [ ] 确认 `/btw` 消息已合并到输出中
- [ ] 使用 `agy -c` 恢复了会话并检索了先前的上下文
- [ ] 创建了一个计划的定期任务
