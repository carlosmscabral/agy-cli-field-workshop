---
title: ""
hide:
  - navigation
  - toc
---

<div class="hero-banner" markdown>
  <img src="assets/banner.png" alt="Antigravity CLI Field Workshop">
</div>

---

## One Project, One Story

This is a hands-on field workshop for the **Antigravity CLI (`agy`)**, built around a single real codebase — the `agy-sample-app` FastAPI billing API. You'll take it through the everyday arc of software work, learning a core `agy` capability at each step:

<div class="grid cards" markdown>

- :material-compass:{ .lg .middle } **1 · Discovery**

    ---

    Launch `agy`, explore the code with `@`, set Tool Permissions, and capture context in `AGENTS.md`.

    [:octicons-arrow-right-24: First Session](exercises/ex01_first_session.md)

- :material-lightbulb-on:{ .lg .middle } **2 · Planning & Build**

    ---

    Plan, review, and build the missing `GET /health` endpoint through the **Artifacts** workflow.

    [:octicons-arrow-right-24: Artifacts](exercises/ex02_artifacts.md)

- :material-puzzle:{ .lg .middle } **3 · Coding Standards**

    ---

    Codify conventions as a Custom **Skill** + an always-on **Rule**, and watch them shape new code.

    [:octicons-arrow-right-24: Skills & Rules](exercises/ex03_skills_rules.md)

- :material-transit-connection-variant:{ .lg .middle } **4 · Governed Access**

    ---

    Give the agent a governed channel to the billing data — an **MCP** server under `strict` permissions.

    [:octicons-arrow-right-24: Governed Access with MCP](exercises/ex04_mcp_governed_access.md)

- :material-account-group:{ .lg .middle } **5 · Fixes & Security**

    ---

    Run parallel review **subagents**, then spawn one to refactor the messy module and fix the hard-coded key.

    [:octicons-arrow-right-24: Subagents](exercises/ex05_subagents.md)

</div>

[:octicons-book-24: Read the workshop overview →](overview.md)

---

## Timeline (≈2 hours)

| Time | Content | Duration |
| :-- | :-- | :-- |
| `0:00` | Pre-work check + first run | 15 min |
| `0:15` | Overview & concept demos | 15 min |
| `0:30` | Beats 1–2 (Discovery, Artifacts) | 40 min |
| `1:10` | Beats 3–4 (Skills & Rules, MCP) | 40 min |
| `1:50` | Beat 5 (Subagents) | 25 min |
| `2:15` | Wrap-up & Q&A | 15 min |

---

## Before You Start

!!! warning "Pre-Work Required"
    Complete the [enterprise setup](setup.md) before the workshop: Antigravity CLI installed and authenticated against Vertex AI, plus the `agy-sample-app` sandbox cloned.

!!! info "Official Documentation"
    Full reference at [antigravity.google/docs](https://www.antigravity.google/docs/cli-overview).

!!! info "Prerequisite"
    Familiarity with a terminal, Git, and basic coding workflows. No prior AI coding assistant experience required.
