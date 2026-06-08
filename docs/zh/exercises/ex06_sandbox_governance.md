# 练习 6：沙盒与治理

> **时长：** 15 分钟 | **模块：** 4 — 多代理与高级

---

## 目标

在 `--sandbox` 模式下运行 agy 以进行安全的代码审计，了解 `--dangerously-skip-permissions` 标志，并为企业级环境构建符合治理要求的工作流模型。

---

## 第 1 部分：沙盒模式 — 安全审计 (7 分钟)

在启用终端限制的情况下运行安全审计：

```bash
agy --sandbox \
    --print "Scan this entire codebase for: (1) hardcoded secrets or API keys, (2) SQL injection risks, (3) insecure direct object references, (4) any .env files or credentials committed to the repo. Output findings as markdown with severity levels." \
    --print-timeout 5m > audit-sandbox.md

cat audit-sandbox.md
```

此次运行的关键属性：

- `--sandbox` 限制终端命令执行 — agy 可以读取文件，但不能运行任意 shell 命令
- `--print` 意味着没有交互式会话 — 完全自动化
- 输出被捕获到文件中以用于审计跟踪

**何时使用此模式：**

- 审计你不完全信任的代码
- 在受监管的环境中进行合规性扫描
- 在无法接受副作用的生产代码库上运行

---

## 第 2 部分：自动批准模式 — 了解风险 (5 分钟)

`--dangerously-skip-permissions` 会绕过所有工具批准提示。agy 会在不询问的情况下执行文件写入和 shell 命令。

**安全演示：** 结合 `--sandbox` 运行它，以展示自动批准而无需实际执行命令：

```bash
agy --sandbox --dangerously-skip-permissions \
    --print "List all TODO comments in this codebase and generate a prioritized backlog." \
    --print-timeout 3m
```

如果不使用 `--sandbox`，此标志将允许 agy 在没有提示的情况下写入文件、运行测试和执行命令。**仅在以下情况使用它：**

- 在没有人员参与的 CI/CD 环境中
- 与 `--sandbox` 结合使用以进行只读审计
- 在允许写入的一次性环境中

!!! warning "切勿在生产环境中使用"
    在实时代码库的交互式会话中，不带 `--sandbox` 使用 `--dangerously-skip-permissions` 无异于搬起石头砸自己的脚。被覆盖的文件无法撤销。

---

## 第 3 部分：治理工作流 (3 分钟)

模拟一个两阶段的治理工作流：

### 阶段 1：安全分析（无副作用）

```bash
agy --sandbox \
    --print "Analyze all database operations in this codebase. Flag any that lack transaction safety or input validation." \
    --print-timeout 3m > phase1-analysis.md
```

### 阶段 2：人工审查，然后批准交互式会话

```bash
cat phase1-analysis.md  # human reviews findings

# If approved, continue with interactive session for remediation
agy -i "Based on the findings in phase1-analysis.md, fix the top 3 database safety issues."
```

这种模式是企业级模型：**无信任读取，仅在审查后写入**。

---

## 完成标准

- [ ] 运行了 `agy --sandbox --print "..."` 并生成了审计文件
- [ ] 了解何时使用 `--dangerously-skip-permissions` 是合适的，何时是危险的
- [ ] 实现了两阶段治理工作流（沙盒审计 → 人工审查 → 交互式修复）
