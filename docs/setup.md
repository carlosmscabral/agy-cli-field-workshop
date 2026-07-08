# Environment Setup

> Complete this before the workshop. Takes ≈15 minutes.

Welcome to the **Antigravity CLI Field Workshop**! To run the hands-on beats, set up your enterprise development environment: a company-managed workstation authenticating to **your organization's GCP project via Vertex AI**.

Setup has **two roles**:

<div class="grid cards" markdown>

- :material-shield-account:{ .lg .middle } **IT Admin — Provisioning** (once, for the group)

    ---

    Provision the GCP project, enable APIs, and grant attendee IAM roles. Done once by a cloud/IT admin or facilitator before the session.

    [:octicons-arrow-right-24: IT Admin Provisioning](setup-enterprise-admin.md)

- :material-laptop:{ .lg .middle } **Developer — Workstation** (each attendee)

    ---

    Install the tooling, authenticate with ADC + Vertex AI, clone the sample app, and verify. Done by every attendee on their own laptop (macOS, Windows, or Linux).

    [:octicons-arrow-right-24: Workstation Setup](setup-corporate.md)

</div>

---

## General System Requirements

Verify your workstation meets these baselines (the onboarding guides install the rest):

| Component | Minimum | Notes |
| :-- | :-- | :-- |
| **Antigravity CLI (agy)** | Latest | Installed during the workstation guide. |
| **Google Cloud SDK** | v410.0+ | Required for ADC authentication to Vertex AI. |
| **Python** | v3.10 to v3.12 | Runs the sample app and its tests. |
| **uv** | Latest | Provides `uvx` (used by the MCP beat). Installed during setup. |
| **Git** | v2.30+ | For cloning the sample app. |
| **Terminal** | Any | bash, zsh, VS Code terminal, or PowerShell. |

---

## The Sample App — the one repo you clone

You only clone **one** repository: the **Sample Application ([`agy-sample-app`](https://github.com/carlosmscabral/agy-sample-app))** — a FastAPI billing API where you run `agy`, let agents make changes, and complete every beat. The workshop material itself lives on this site (nothing to clone), and you point `agy` at the sample app, not the curriculum.

The workstation guide clones it in one line (or run the [bootstrap one-liner](setup-corporate.md#step-2-clone-the-sample-app) to clone + auth + set up its venv in one command).

> [!NOTE]
> **The sample app owns its environment — there is no shared workshop virtualenv.** The sample app has its own `.venv` created from its `requirements.txt`; pre-work only installs repo-agnostic tooling (`agy`, `gcloud`/ADC/Vertex, and `uv`).

---

## Troubleshooting Support

If setup blocks you, check the troubleshooting section at the bottom of the [Workstation Setup](setup-corporate.md) guide, or ask your facilitator.
