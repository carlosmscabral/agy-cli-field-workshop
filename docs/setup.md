# Environment Setup

> Complete this before starting any module. Takes ~15 minutes.

Welcome to the **Antigravity CLI Field Workshop**! To participate in the hands-on coding modules and exercises, you must first set up your development environment.

We provide two distinct onboarding pathways depending on where you are running the workshop. Please select the track below that matches your setup.

---

## Select Your Onboarding Track

Choose the onboarding guide that corresponds to your workshop environment:

<div class="grid cards" markdown>

- :material-cloud:{ .lg .middle } **Track A — Cloud Shell & Qwiklabs**

    ---

    **Recommended for sandboxed environments.** Run the workshop inside a Google-provided, browser-based Cloud Shell.

  - APIs are enabled directly by you (as project Owner).
  - Google Cloud SDK and Python are pre-installed.
  - Docker & Docker Compose are pre-installed.

    [:octicons-arrow-right-24: Follow Track A Guide](setup-cloud-shell.md)

- :material-laptop:{ .lg .middle } **Track B — Corporate Workstation**

    ---

    **For local developer laptops.** Develop and run the workshop on your physical machine (macOS, Windows, or Linux).

  - Workspace uses project resources provisioned by your IT Administrator.
  - Requires local installation of gcloud, Python, and Docker.
  - Includes proxy, SSL certificate, and private registry support.

    [:octicons-arrow-right-24: Follow Track B Guide](setup-corporate.md)

</div>

---

## 🛠️ Are you the IT Administrator?

If you are the Cloud/IT Administrator responsible for setting up the GCP sandbox project, provisioning IAM permissions, and whitelisting firewalls for your team's local machines **before** the workshop starts, please follow the admin guide:

👉 **[Enterprise IT Admin & Provisioning Guide](setup-enterprise-admin.md)**

---

## General System Requirements

If you are running on your local workstation, verify your system meets these baseline requirements. (If you are running on Cloud Shell, these are already pre-configured for you).

| Component | Minimum | Notes |
| :-- | :-- | :-- |
| **Antigravity CLI (agy)** | Latest | Installed during the onboarding guides. |
| **Google Cloud SDK** | v410.0+ | Required for workstation-based ADC authentication. |
| **Python** | v3.10 to v3.12 | Required for virtual environments and SDK exercises. |
| **Docker** | v24.0+ | Required for building containerized applications locally. |
| **Docker Compose** | v2.20+ | Required for running multi-container target services. |
| **Git** | v2.30+ | Required for cloning the workshop and sample repos. |
| **Terminal** | Any | bash, zsh, VS Code terminal, or PowerShell. |

---

## Why Two Repositories?

Regardless of which track you choose, you will work with **two separate repositories** during this workshop to maintain clean configurations and prevent self-referencing issues:

1. **Workshop Repository (`agy-cli-field-workshop`)**: Contains the curriculum, guidebooks, verifiers, and step-by-step exercise instructions. This is the repository you are reading now.
2. **Sample Application Sandbox (`agy-sample-app`)**: A separate target codebase (a premium FastAPI application) where you will run `agy` sessions, let agents run commands, and write SDK-based tools or test files.

Both onboarding guides will walk you through cloning these repositories into adjacent directories.

---

## Troubleshooting Support

If you encounter any workspace setup blocks, consult the troubleshooting section at the bottom of your chosen track's guide page, or ask your workshop facilitator for assistance.
