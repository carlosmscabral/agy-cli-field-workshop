# Enterprise Admin & Provisioning Guide

This guide is designed for enterprise cloud administrators, IT infrastructure managers, and workshop facilitators. It explains how to provision Google Cloud Platform (GCP) resources and configure local employee workstations for the Antigravity CLI Field Workshop.

---

## Overview

The workshop is designed to run locally on attendee workstations (e.g., standard corporate laptops) using Vertex AI API for language model inference and optional Google Cloud Run for service deployments (Module 3 and 5).

To ensure a smooth delivery on local machines, administrators must complete two core phases:

1. **GCP Project & API Setup**: Create a dedicated sandbox project, enable Vertex AI, and grant IAM roles.
2. **Local Workstation Provisioning**: Install prerequisites (Python 3.10+, Google Cloud SDK, Git) and verify network egress.

---

## Phase 1: Google Cloud Project Setup

We recommend setting up a single, dedicated GCP project for the workshop, or individual sandbox projects for each attendee.

### 1.1 — Create a GCP Project

Create a new project specifically for the workshop:

```bash
gcloud projects create agy-workshop-sandbox-99 --name="Antigravity Workshop Sandbox"
```

### 1.2 — Enable Required APIs

Enable the Vertex AI, Cloud Run, Artifact Registry, and Cloud Build APIs. These are required for CLI inference, SDK testing, and service deployment:

```bash
gcloud services enable aiplatform.googleapis.com \
                       run.googleapis.com \
                       artifactregistry.googleapis.com \
                       cloudbuild.googleapis.com \
                       --project="agy-workshop-sandbox-99"
```

### 1.3 — Configure IAM Roles for Attendees

Grant each attendee (employee) the following minimum permissions in the workshop project. To simplify administration, we recommend adding all workshop attendees to a dedicated Google Group (e.g., `agy-workshop-attendees@yourcompany.com`) and binding the roles to the group in bulk.

| IAM Role | Role Identifier | Why it's needed |
| :-- | :-- | :-- |
| **Vertex AI User** | `roles/aiplatform.user` | Essential. Allows `agy` CLI and the Python SDK to invoke Gemini models. |
| **Cloud Run Developer** | `roles/run.developer` | Allows attendees to deploy SDK agents to Google Cloud Run in Modules 3 & 5. |
| **Artifact Registry Writer** | `roles/artifactregistry.writer` | Allows container images to be pushed to Artifact Registry during deployments. |
| **Storage Object Viewer** | `roles/storage.objectViewer` | Allows Cloud Build to pull build sources from Google Cloud Storage. |
| **Service Account User** | `roles/iam.serviceAccountUser` | Allows attendees to run services as the default Compute Engine service account. |

To assign these roles in bulk to a Google Group via `gcloud`, run the following script:

```bash
# Define project and attendee group
export PROJECT_ID="agy-workshop-sandbox-99"
export ATTENDEE_GROUP="group:agy-workshop-attendees@yourcompany.com"

# Bind each required role
for role in \
  roles/aiplatform.user \
  roles/run.developer \
  roles/artifactregistry.writer \
  roles/storage.objectViewer \
  roles/iam.serviceAccountUser; do
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
      --member="$ATTENDEE_GROUP" \
      --role="$role"
done
```

Alternatively, to grant these roles to individual employees individually, run:

```bash
gcloud projects add-iam-policy-binding "agy-workshop-sandbox-99" \
    --member="user:employee.name@yourcompany.com" \
    --role="roles/aiplatform.user"
```

---

## Phase 2: Workstation (Local Machine) Requirements

Attendees will run `agy` CLI sessions and develop Python SDK code directly on their customer-managed machines. Ensure employee machines are prepared with the following tools.

### 2.1 — Prerequisites & Installations

#### 1. Git & SSH/HTTPS Access

Attendees must be able to clone the workshop and sample repositories:

- `git clone https://github.com/carlosmscabral/agy-cli-field-workshop.git`
- `git clone https://github.com/carlosmscabral/agy-sample-app.git`

#### 2. Python 3.10+ & venv

Attendees must have Python 3.10, 3.11, or 3.12 installed locally.

> [!IMPORTANT]
> If employee workstations are locked down without root/administrator rights, they can install Python in user-space using [pyenv](https://github.com/pyenv/pyenv) (macOS/Linux) or the official Python installer (Windows) with system-path checkboxes enabled.

All exercises and package installations **must run inside a Python Virtual Environment** to bypass administrative locks and prevent global package pollution:

```bash
# Create and activate an isolated virtual environment
python3 -m venv .venv
source .venv/bin/activate
```

#### 3. Google Cloud SDK (gcloud CLI)

The `gcloud` CLI is required for local authentication via Application Default Credentials (ADC):

- Install instructions: [cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install)
- Attendees must run `gcloud components install` to ensure components are updated.

---

## Phase 3: Enterprise Network, Proxies & Packages

Many corporate environments employ SSL-decrypting firewalls, deep packet inspection, private package mirrors, or locked package registries. This phase details how to bypass these obstacles so employees can install local Python packages (beyond AGY) successfully.

### 3.1 — Firewall Egress Rules

Ensure outbound HTTPS (port 443) traffic is allowed to the following domains on the corporate network or VPN:

- **Vertex AI API**: `*.aiplatform.googleapis.com` (e.g., `us-central1-aiplatform.googleapis.com`)
- **Python Package Index**: `pypi.org` and `files.pythonhosted.org`
- **GitHub**: `github.com` (for cloning repositories)
- **Antigravity CLI**: `antigravity.google`

### 3.2 — Configuring Custom Package Mirrors (pip)

If your enterprise blocks direct access to `pypi.org` and requires a private repository mirror (such as JFrog Artifactory, Sonatype Nexus, or GCP Artifact Registry), configure the workstations to redirect `pip` requests.

#### macOS/Linux (~/.pip/pip.conf) or Windows (%APPDATA%\pip\pip.ini)

Create or update the configuration file with your corporate registry:

```ini
[global]
index-url = https://artifactory.yourcompany.com/api/pip/pypi/simple
trusted-host = artifactory.yourcompany.com
```

Alternatively, attendees can install packages using the command line flag:

```bash
pip install google-antigravity --index-url https://artifactory.yourcompany.com/api/pip/pypi/simple
```

### 3.3 — Handling Corporate SSL-Decrypting Proxies

If your enterprise proxy intercepts HTTPS traffic and decrypts SSL, `pip` or Python's `urllib` may throw `SSL: CERTIFICATE_VERIFY_FAILED` errors. Resolve this by:

1. **Setting the CA Bundle**: Direct `pip` and python to trust your corporate Root Certificate:

```bash
# macOS/Linux
export PIP_CERT="/etc/ssl/certs/corporate-ca-bundle.pem"
export REQUESTS_CA_BUNDLE="/etc/ssl/certs/corporate-ca-bundle.pem"

# Windows PowerShell
$env:PIP_CERT="C:\Certificates\corporate-ca-bundle.pem"
$env:REQUESTS_CA_BUNDLE="C:\Certificates\corporate-ca-bundle.pem"
```

1. **Using Trusted Hosts (Fallback Only)**: If importing certificates is restricted, bypass verification for trusted hosts during installation (not recommended for production):

```bash
pip install google-antigravity --trusted-host pypi.org --trusted-host files.pythonhosted.org
```

### 3.4 — Local Credentials Storage (ADC)

The `gcloud auth application-default login` command stores keyless Application Default Credentials (ADC) locally as JSON files. Ensure the local user profiles have write permissions to:

- **Mac/Linux**: `~/.config/gcloud/application_default_credentials.json`
- **Windows**: `%APPDATA%\gcloud\application_default_credentials.json`

---

## Phase 4: Pre-Work Local Verification Script

To guarantee zero setup blockers on day-one of the workshop, have each attendee run the pre-work validation script on their customer machine.

This repository includes a highly robust verification script located at `scripts/verify-workstation.sh`. It automatically:

1. Verifies core binaries (`git`, `python3`, `gcloud`, `agy`).
2. Tests Python 3.10+ compliance.
3. Tests isolated virtual environment (`venv`) creation.
4. Performs a dry-run package installation to check for proxy/SSL blockages.
5. Checks local Application Default Credentials (ADC) status.
6. **Performs a real outbound call to Vertex AI** using the local credentials to verify project authorization, IAM permissions (`roles/aiplatform.user`), and network firewall whitelisting.

### Running the Verification Script

Ensure the user is authenticated and has selected their project first:

```bash
# 1. Log in to GCP Application Default Credentials
gcloud auth application-default login

# 2. Configure the workshop project ID
gcloud config set project "agy-workshop-sandbox-99"

# 3. Run the workstation verifier
./scripts/verify-workstation.sh
```

### Expected Output (Success)

```text
═════════════════════════════════════════════════════════════════════════
   🚀 Antigravity CLI Field Workshop — Workstation Verification
═════════════════════════════════════════════════════════════════════════

[1/5] Checking Workstation Operating System & Core Utilities
  💻 Operating System: Darwin
  ✅ PASS: Git is installed (version 2.39.3)
  ✅ PASS: jq is installed

[2/5] Checking Python 3 Runtime & Package Isolation
  ✅ PASS: Python version is compliant (3.11.2)
  📦 Checking package manager (pip) and corporate proxies...
  🧪 Testing virtual environment and local pip installations...
  ✅ PASS: Isolated virtual environments can install pip packages

[3/5] Checking Google Cloud SDK & Authentication Setup
  ✅ PASS: Google Cloud SDK is installed (version 412.0.0)
  ✅ PASS: Application Default Credentials (ADC) are configured locally
  ✅ PASS: Active Google Cloud project configured: agy-workshop-sandbox-99

[4/5] Checking Antigravity CLI (agy) Installation
  ✅ PASS: agy CLI is installed and in user PATH (version 2.0.4)

[5/5] Checking Firewall Outbound Connection & Vertex AI IAM Permissions
  🌐 Testing outbound network connectivity to Vertex AI us-central1...
  ✅ PASS: Vertex AI Gemini Model access is healthy & verified

═════════════════════════════════════════════════════════════════════════
   📋 Verification Summary
      - 8 passed
      - 0 warnings
      - 0 failures
═════════════════════════════════════════════════════════════════════════

🎉 CONGRATULATIONS! Your local workstation is perfectly prepared for the workshop!
```

Have employees send a screenshot of their successful verification summary to the facilitator before the workshop begins to guarantee a flawless start.
