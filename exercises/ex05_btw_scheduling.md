# Exercise 5: /btw & Scheduling

> **Duration:** 20 min | **Module:** 4 — Multi-Agent & Advanced

---

## Objective

Use `/btw` to steer a long-running task mid-flight, and schedule a recurring automated analysis.

---

## Part 1: /btw Mid-Task Steering (10 min)

Launch agy and kick off a substantial task:

```bash
agy
```

```
> I want to refactor the error handling across this entire project to use a consistent pattern. Start by analyzing all error handling in the codebase, then propose and implement a unified approach. This will touch multiple files — start with the analysis phase.
```

As agy starts working (during the analysis phase), inject a constraint:

```
/btw Only touch files in the backend/ directory for now. Leave frontend untouched.
```

Then add another note:

```
/btw Use the Result<T, E> pattern if the language supports it. Otherwise use a custom Error class hierarchy.
```

Observe:
- The task continues without restarting
- agy incorporates both `/btw` notes into its working approach
- The final plan reflects your injected constraints

**Key insight:** `/btw` lets you course-correct without the cost of cancelling and restarting. This is the equivalent of tapping a developer on the shoulder mid-sprint.

---

## Part 2: Session Continuation (5 min)

End the session (Ctrl+C or close the terminal).

Resume the most recent session:

```bash
agy -c
```

```
> Remind me what we decided about the error handling refactor. What was the approach?
```

agy will have full context. Now continue the work:

```
> Let's implement step 1 of the plan we discussed.
```

---

## Part 3: Schedule a Recurring Report (5 min)

```bash
agy
```

```
> Schedule a daily dependency check every weekday morning at 8am. It should:
> 1. Check for outdated dependencies with security advisories
> 2. List any new CVEs affecting our current dependency versions
> 3. Save the report to reports/deps-YYYY-MM-DD.md
>
> Create the reports/ directory if it doesn't exist.
```

Confirm the schedule was accepted. Ask:

```
> What scheduled tasks are currently active?
```

---

## Completion Criteria

- [ ] Started a long-running task and used `/btw` at least twice during execution
- [ ] Confirmed that `/btw` messages were incorporated into the output
- [ ] Used `agy -c` to resume a session and retrieved prior context
- [ ] Created a scheduled recurring task
