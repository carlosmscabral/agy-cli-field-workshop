# Antigravity CLI Field Workshop

> **Hands-on field workshop for Antigravity CLI.**

🚀 **Live Workshop Site (GitHub Pages):** [carlosmscabral.github.io/agy-cli-field-workshop](https://carlosmscabral.github.io/agy-cli-field-workshop/)
📚 **Official Docs:** [antigravity.google/docs](https://www.antigravity.google/docs/cli-overview)

---

## Workshop Overview

A single, cohesive ≈2-hour track that teaches `agy` by taking **one real codebase** — the [`agy-sample-app`](https://github.com/carlosmscabral/agy-sample-app) FastAPI billing API — through the everyday arc of software work. It is designed for **real customer / enterprise delivery**, authenticating to **Google Cloud / Vertex AI** throughout.

| Beat | Exercise | Antigravity CLI concepts |
| :-- | :-- | :-- |
| **1. Discovery** | First Session | interactive session, `@`-focus, Tool Permissions, `AGENTS.md` |
| **2. Planning & Build** | Artifacts | `/planning`, Artifact Review panel, plan→review→verify (`GET /health`) |
| **3. Coding Standards** | Skills & Rules | `.agents/skills/`, `.agents/rules/` (`trigger` frontmatter), `/diff` |
| **4. Governed Access** | Governed Access with MCP | `.agents/mcp_config.json`, `/mcp`, `strict` mode |
| **5. Fixes & Security** | Subagents | native subagents, `/agents`, custom `.agents/agents/code-cleaner.md` |

Total: ≈2 hours · Lightning (Beats 1, 2, 5): ≈1 hour.

---

## Quick Start (participants)

```bash
# 1. Install agy (if not already installed)
curl -fsSL https://antigravity.google/cli/install.sh | bash

# 2. Clone the workshop repo
git clone https://github.com/carlosmscabral/agy-cli-field-workshop.git
cd agy-cli-field-workshop

# 3. Validate your environment
make check-env
```

Then complete the **enterprise setup** in **[docs/setup.md](docs/setup.md)** and follow the beats on the **[live workshop site](https://carlosmscabral.github.io/agy-cli-field-workshop/)**.

> **Pre-work:** the enterprise path — GCP + Vertex AI (ADC) — documented under [`docs/setup.md`](docs/setup.md) (IT-Admin provisioning + developer workstation). The hands-on beats run against the sample app, [`carlosmscabral/agy-sample-app`](https://github.com/carlosmscabral/agy-sample-app), cloned alongside this repo.
>
> **Previewing the docs locally is optional** (maintainers / offline use): `make install-deps && make serve`, then open <http://localhost:8000>.

---

## Repository Structure

```text
├── docs/                          # Workshop documentation (MkDocs Material)
│   ├── index.md                   # Home page
│   ├── overview.md                # The Workshop — the end-to-end story
│   ├── setup.md                   # Pre-work: enterprise setup intro
│   ├── setup-enterprise-admin.md  # IT Admin provisioning (IAM/API)
│   ├── setup-corporate.md         # Developer workstation setup
│   ├── cheatsheet.md              # Reference
│   ├── plugin-ecosystem.md        # Reference: workspace customization
│   ├── facilitator-guide.md
│   └── exercises/                 # ex01–ex05 (the five beats)
├── samples/                       # Sample configs, subagents, hooks, plugin
├── scripts/
│   ├── check-env.sh               # Pre-workshop validator
│   ├── verify-workstation.sh      # Workstation verifier (Bash + PowerShell)
│   ├── bootstrap-enterprise.sh    # One-command sandbox + Vertex bootstrap
│   ├── validate-code-blocks.sh    # Doc code-block validation (recursive)
│   └── detect-drift.sh            # Ground-truth drift detection
├── research/                      # Verified grounding reference (agy CLI)
├── AUDIT.md                       # Ground truth for upstream claims + test register
├── VERIFICATION.md                # Maintenance playbook
├── Makefile
└── mkdocs.yml
```

---

## Delivery Formats

| Format | Beats | Duration |
| :-- | :-- | :-- |
| ⚡ Lightning | Beats 1, 2, 5 | ~1 hr |
| 📋 Standard | All 5 beats | ~2 hrs |

See the [Facilitator Guide](docs/facilitator-guide.md) for delivery instructions.

---

## Prerequisites

- `agy` installed and authenticated against your GCP project / Vertex AI (see [Environment Setup](docs/setup.md))
- A GCP project with the Vertex AI API enabled and `roles/aiplatform.user` granted to attendees
- `uv` installed (provides `uvx`, used by the MCP beat) and Python 3.10–3.12 for the sample app
- Familiarity with a terminal, Git, and basic coding workflows

---

*Built with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/).*
