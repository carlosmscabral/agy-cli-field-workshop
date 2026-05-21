# agy-cli Field Workshop

> **Hands-on field workshop for Antigravity CLI (agy-cli).**

📚 **Official Docs:** [antigravity.google/docs](https://www.antigravity.google/docs/cli-overview)

---

## Workshop Overview

This workshop teaches engineers how to use agy-cli as a daily-driver AI coding assistant and automation tool. It covers four modules, from first interactive session to multi-agent orchestration.

| Module | Topic | Duration |
|---|---|---|
| **1. SDLC Productivity** | First session, code understanding, refactoring, test generation, review | 50 min |
| **2. Plugin Ecosystem** | Import from Gemini CLI & Claude, enable/disable, validate custom plugins | 45 min |
| **3. DevOps & Automation** | `--print` pipelines, CI/CD, multi-dir workspaces, sandbox mode | 40 min |
| **4. Multi-Agent & Advanced** | Subagents, `/btw` mid-task steering, scheduling, session resumption | 45 min |

**Total: ~3.5 hours (half-day)**

---

## Quick Start

```bash
# Install agy-cli (if not already installed)
curl -fsSL https://antigravity.google/cli/install.sh | bash

# Clone the workshop repo
git clone https://github.com/pauldatta/agy-cli-field-workshop.git
cd agy-cli-field-workshop

# Validate your environment
chmod +x scripts/check-env.sh
make check-env

# Serve the docs locally
make install-deps
make serve
```

Open [http://localhost:8000](http://localhost:8000) for the workshop site.

---

## Repository Structure

```
├── docs/                    # Workshop documentation (MkDocs Material)
│   ├── index.md             # Home page
│   ├── setup.md             # Environment setup
│   ├── sdlc-productivity.md # Module 1
│   ├── plugin-ecosystem.md  # Module 2
│   ├── devops-automation.md # Module 3
│   ├── multi-agent-advanced.md # Module 4
│   ├── cheatsheet.md
│   └── facilitator-guide.md
├── exercises/               # Hands-on exercises (6 total)
├── demos/                   # VHS tape scripts for terminal GIFs
├── samples/                 # Sample configs and scripts
├── scripts/
│   └── check-env.sh         # Pre-workshop validator
├── Makefile
└── mkdocs.yml
```

---

## Delivery Formats

| Format | Modules | Duration |
|---|---|---|
| ⚡ Lightning | 1 + 2 highlights | 1.5 hrs |
| 📋 Standard | 1 + 2 + 3 | 2.5 hrs |
| 📦 Full | All four modules | 3.5 hrs |
| 🏗️ Extended | All modules + open lab | 5 hrs |

See [Facilitator Guide](docs/facilitator-guide.md) for delivery instructions.

---

## Prerequisites

- agy-cli installed and authenticated (see [Environment Setup](docs/setup.md))
- Familiarity with terminal, Git, and basic coding workflows

---

*Built with [MkDocs Material](https://squidfundamentals.github.io/mkdocs-material/).*
