# Antigravity CLI Field Workshop

> **Hands-on field workshop for Antigravity CLI.**

🚀 **Live Workshop Site (GitHub Pages):** [carlosmscabral.github.io/agy-cli-field-workshop](https://carlosmscabral.github.io/agy-cli-field-workshop/)
📚 **Official Docs:** [antigravity.google/docs](https://www.antigravity.google/docs/cli-overview)

---

## Workshop Overview

This workshop teaches engineers how to use `agy` as a daily-driver AI coding assistant and automation tool, and how to build agents on top of it. It is designed for **real customer / enterprise delivery**, authenticating to **Google Cloud / Vertex AI** throughout. It covers four modules, from first interactive session to building and deploying production agents.

| Module | Topic | Duration |
| :-- | :-- | :-- |
| **1. Antigravity CLI Fundamentals** | First session, the **Artifacts** plan-review-verify workflow, custom skills & rules, connecting tools via **MCP**, sandbox governance | 90 min |
| **2. Legacy Modernization & Advanced CLI ⭐** | Strict mode, agent self-onboarding, Java migration (optional .NET), then subagents, `/btw` mid-task steering, headless `--print` automation | 120 min |
| **3. ADK Agents with agents-cli** | Scaffold, build, evaluate, and deploy ADK agents via `agents-cli` (optional GCP Data Cloud lab) | 75 min |
| **4. Advanced: Building Agents with the Antigravity SDK** | The `google-antigravity` SDK on Vertex — tools, hooks, triggers, multi-agent orchestration, Cloud Run | 90 min |

Total: ≈7 hours (extended) · Full day: Modules 1–3 (≈5.5 hrs) · Half-day: Modules 1–2 (3.5 hrs) · Lightning: Module 1 (1.5 hrs)

There are **16 hands-on exercises** (`ex01`–`ex16`) mapped across the four modules.

---

## Quick Start

```bash
# Install agy (if not already installed)
curl -fsSL https://antigravity.google/cli/install.sh | bash

# Clone the workshop repo
git clone https://github.com/carlosmscabral/agy-cli-field-workshop.git
cd agy-cli-field-workshop

# Validate your environment
make check-env

# Serve the docs locally (creates a local .venv)
make install-deps
make serve
```

Open [http://localhost:8000](http://localhost:8000) for the workshop site.

> **Pre-work:** attendees pick a setup track — **Track A: Enterprise / Corporate (GCP + Vertex AI)** (the primary path) or **Track B: Cloud Shell Sandbox**. Both are documented under [`docs/setup.md`](docs/setup.md). The hands-on labs use a separate sample app, [`carlosmscabral/agy-sample-app`](https://github.com/carlosmscabral/agy-sample-app), cloned alongside this repo.

---

## Repository Structure

```text
├── docs/                        # Workshop documentation (MkDocs Material)
│   ├── index.md                 # Home page
│   ├── setup.md                 # Pre-work: track selector
│   ├── setup-enterprise-admin.md  # Track A — IT Admin provisioning (IAM/APIs)
│   ├── setup-corporate.md       # Track A — developer workstation
│   ├── setup-cloud-shell.md     # Track B — Cloud Shell sandbox
│   ├── sdlc-productivity.md     # Module 1 — Antigravity CLI Fundamentals
│   ├── legacy-modernization.md  # Module 2 — Legacy Modernization (+ advanced CLI)
│   ├── multi-agent-advanced.md  # Module 2 — Advanced CLI (subagents, /btw, --print)
│   ├── agents-cli.md            # Module 3 — ADK Agents with agents-cli
│   ├── agy-sdk.md               # Module 4 — Advanced: Antigravity SDK
│   ├── cheatsheet.md            # Reference
│   ├── plugin-ecosystem.md      # Reference
│   ├── devops-automation.md     # Reference
│   ├── facilitator-guide.md
│   └── exercises/               # Hands-on exercises (ex01–ex16, 16 total)
├── demos/                       # VHS tape scripts for terminal GIFs
├── samples/                     # Sample configs, agents, hooks, plugin
├── scripts/
│   ├── check-env.sh             # Pre-workshop validator
│   ├── verify-workstation.sh    # Workstation verifier (Bash + PowerShell)
│   ├── bootstrap-enterprise.sh  # One-command sandbox + Vertex bootstrap
│   ├── validate-code-blocks.sh  # Doc code-block validation (recursive)
│   └── detect-drift.sh          # Ground-truth drift detection
├── research/                    # Verified grounding references (agy CLI + SDK)
├── AUDIT.md                     # Ground truth for upstream claims + test register
├── VERIFICATION.md              # Maintenance playbook
├── Makefile
└── mkdocs.yml
```

---

## Delivery Formats

| Format | Modules | Duration |
| :-- | :-- | :-- |
| ⚡ Lightning | Module 1 | 1.5 hrs |
| 📋 Half-day | Modules 1 + 2 | 3.5 hrs |
| 📦 Full day | Modules 1–3 | ≈5.5 hrs |
| 🏗️ Extended | All 4 modules + open lab | 7 hrs |

See the [Facilitator Guide](docs/facilitator-guide.md) for delivery instructions.

---

## Prerequisites

- `agy` installed and authenticated against your GCP project / Vertex AI (see [Environment Setup](docs/setup.md))
- A GCP project with the Vertex AI API enabled and `roles/aiplatform.user` (Modules 3–4 add Cloud Run / Artifact Registry / Cloud Build roles — see the IT Admin guide)
- Familiarity with a terminal, Git, and basic coding workflows
- Docker is **optional** — only the optional .NET modernization exercise (ex03) uses it

---

*Built with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/).*
