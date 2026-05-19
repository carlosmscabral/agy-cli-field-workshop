# Exercise 4: Subagents

> **Duration:** 20 min | **Module:** 4 — Multi-Agent & Advanced

---

## Objective

Spawn parallel subagents on your codebase, practice the adversarial reviewer pattern, and observe isolated execution.

---

## Part 1: Parallel Audit (10 min)

Launch agy interactively:

```bash
agy
```

Dispatch a parallel audit team:

```
> Spawn two subagents in parallel using branch workspace mode:
> 1. A security auditor — scan for: hardcoded credentials, injection vulnerabilities, exposed sensitive data, and insecure dependencies
> 2. A test coverage auditor — identify: untested public functions, missing edge cases, and integration test gaps
>
> Report back when both complete with a combined findings summary.
```

While they run, ask:
```
> What's the status of the subagents?
```

When they finish:
```
> Show me the combined findings from both audits. What are the top 3 things to fix?
```

---

## Part 2: Adversarial Reviewer (7 min)

Pick a recent PR, branch, or any set of changes:

```bash
git checkout -b feature/my-test-branch
# (make a few changes)
git add -A
```

Back in agy:

```
> I have changes on the current branch. Spawn an adversarial reviewer subagent.
> Its only job: find reasons why these changes should NOT be merged.
> It should challenge assumptions, look for edge cases, and be skeptical of everything.
> Be harsh — this is an adversarial review, not a supportive one.
```

Read the adversarial findings. The goal is to identify what a thorough code review would catch.

---

## Part 3: Resume a Subagent's Work (3 min)

```
> One of the subagent findings mentioned [specific issue]. Let's fix it. Create a subagent in inherit mode to implement the fix.
```

Note the difference from branch mode: `inherit` means the subagent works in the same directory as your main session — appropriate for targeted, non-conflicting fixes.

---

## Completion Criteria

- [ ] Spawned at least 2 parallel subagents successfully
- [ ] Both subagents ran and returned findings
- [ ] Adversarial reviewer returned critical findings
- [ ] Used at least two different workspace modes (branch vs inherit)
