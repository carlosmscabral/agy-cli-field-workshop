# Environment Setup

> Complete this before starting any module. Takes ≈15 minutes.

Welcome to the **Antigravity CLI Field Workshop**! To participate in the hands-on coding modules and exercises, you must first set up your development environment.

We provide two onboarding pathways. **The primary path for real customer and enterprise deployments is Track A — Enterprise / Corporate on GCP + Vertex AI.** Track B (Cloud Shell Sandbox) is a zero-install option for quick trials and lab environments. Pick the one that matches your setup.

---

## Select Your Onboarding Track

<div class="grid cards" markdown>

- :material-laptop:{ .lg .middle } **Track A — Enterprise / Corporate (GCP + Vertex AI)** ⭐

    ---

    **Recommended — the primary path for real customer deployments.** Develop on a company-managed laptop (macOS, Windows, or Linux), authenticating to **your organization's GCP project via Vertex AI**.

    This track has **two roles**:
    1. **IT Admin**: provisions the GCP project, enables APIs, and sets IAM permissions (*once* for the group).
    2. **Developer**: sets up the local workstation, handles proxies, and validates the environment.

    [:octicons-arrow-right-24: Follow Track A Guide](setup-corporate.md)

- :material-cloud:{ .lg .middle } **Track B — Cloud Shell Sandbox**

    ---

    **A zero-install option for quick trials and lab environments.** Run the workshop inside a Google-provided, browser-based Cloud Shell (or Qwiklabs) with Owner on a temporary project.

  - All dependencies and tools are pre-configured.
  - APIs are enabled directly by you (as project Owner).
  - Docker & Docker Compose are pre-installed.

    [:octicons-arrow-right-24: Follow Track B Guide](setup-cloud-shell.md)

</div>

---

## General System Requirements

If you are running on your local workstation, verify your system meets these baseline requirements. (If you are running on Cloud Shell, these are already pre-configured for you).

| Component | Minimum | Notes |
| :-- | :-- | :-- |
| **Antigravity CLI (agy)** | Latest | Installed during the onboarding guides. |
| **Google Cloud SDK** | v410.0+ | Required for workstation-based ADC authentication. |
| **Python** | v3.10 to v3.12 | Required for virtual environments and SDK exercises. |
| **Docker** *(optional)* | v24.0+ | **Only** for the .NET modernization exercise (ex03). Skip if you're not running that lab. |
| **Docker Compose** *(optional)* | v2.20+ | **Only** for ex03 (running the sample's multi-container services). |
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
