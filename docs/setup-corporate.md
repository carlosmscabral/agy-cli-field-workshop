# Track B — Corporate Dev Track Setup

This track is designed for teams running the workshop on **customer-managed corporate physical machines** (such as company laptops running macOS, Windows, or Linux).

> [!IMPORTANT]
> **IT Admin Setup Must Be Completed First!**
> Before any developer can configure their workstation, your company's **IT Administrator** must complete the project provisioning, API activation, and IAM permissions.
>
> - **IT Admins**: Go to [Role 1: IT Admin Provisioning](setup-enterprise-admin.md) first.
> - **Developers**: Obtain the assigned **GCP Project ID** from your admin before starting Role 2.

It consists of **two roles**:

1. 🛠️ **IT Admin**: Configures the GCP project, enables Vertex AI APIs, whitelists domains, and provisions bulk IAM permissions *once* for the group.
2. 💻 **Developer**: Configures their local laptop virtual environment, corporate proxies, Google authentication, and runs the workstation verifier.

---

## 🛠️ Role 1: IT Administrator Provisioning (One-Time)

If you are the cloud or infrastructure administrator setting up the Google Cloud project, IAM roles, and network parameters for your team **before** the workshop begins, please complete this step once per team:

👉 **[Go to the IT Admin Provisioning Guide](setup-enterprise-admin.md)**

---

## 💻 Role 2: Developer Workstation Setup (Each Attendee)

As a developer/attendee, once your IT Administrator has provided you with the **GCP Project ID** and verified your IAM roles, complete the workstation setup steps below.

---

## Step 1: Install Core Prerequisites

Ensure the following core CLI tools are installed on your physical machine.

### 1.1 — Git

Required to clone the workshop repositories. Check with:

```bash
git --version
```

- **macOS**: Install via Homebrew (`brew install git`) or Xcode Command Line Tools (`xcode-select --install`).
- **Windows**: Install via [Git for Windows](https://git-scm.com/download/win).
- **Linux**: Install via package manager (e.g., `sudo apt install git`).

### 1.2 — Python 3.10 to 3.12

Required to run virtual environments and the AGY Python SDK. Check with:

```bash
python3 --version
```

- **macOS/Linux**: Download from [python.org](https://www.python.org/downloads/) or manage via `pyenv`.
- **Windows**: Install via Microsoft Store or python.org (ensure you check **"Add Python to PATH"** during installation).

### 1.3 — Google Cloud SDK (gcloud CLI)

Required to authenticate with GCP APIs. Check with:

```bash
gcloud --version
```

- Follow the official install guide: [cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install).

### 1.4 — Docker & Docker Compose (v2)

Required to build containerized services and spin up sandbox databases. Check with:

```bash
docker --version
docker compose version
```

- Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) (macOS/Windows) or use [Rancher Desktop](https://rancherdesktop.io/) as an open-source alternative.
- Ensure the Docker daemon is launched and running.

---

## Step 2: Clone the Workshop & Sandbox Repositories

Clone both repositories into adjacent directories on your local workstation:

```bash
# 1. Clone the Workshop Repository
git clone https://github.com/carlosmscabral/agy-cli-field-workshop.git
cd agy-cli-field-workshop

# 2. Clone the Sandbox Application (into the parent directory)
git clone https://github.com/carlosmscabral/agy-sample-app.git ../agy-sample-app
```

> [!TIP]
> **One-command bootstrap (optional).** Once `gcloud` and `agy` are installed, `scripts/bootstrap-enterprise.sh` automates the rest — it clones the `agy-sample-app` sandbox, runs the ADC login, exports the canonical Vertex environment, and creates the sandbox virtualenv with `google-antigravity`. Run it from the workshop repo root: `bash scripts/bootstrap-enterprise.sh`. You can then skip Steps 3, 5, and 6 below.

---

## Step 3: Configure Virtual Environment & Package Isolation

To prevent package conflicts and permission blocks on locked workstations, **always use an isolated virtual environment** for all workshop dependencies.

Run these commands inside the `agy-cli-field-workshop` directory:

### Create Environment on macOS / Linux

```bash
# Create the virtual environment
python3 -m venv .venv

# Activate it
source .venv/bin/activate
```

### Create Environment on Windows

```powershell
# Create the virtual environment
python -m venv .venv

# Activate it
.\.venv\Scripts\Activate.ps1
```

---

## Step 4: Handle Corporate Proxies, Private Mirrors, & SSL Certs

Many corporate environments route traffic through SSL-decrypting firewalls or require private package registries (like Sonatype Nexus or JFrog Artifactory). If yours does not, **skip to Step 5**.

### 4.1 — Trusting Corporate Root Certificates

If `pip` throws `SSL: CERTIFICATE_VERIFY_FAILED` errors, point Python to your company's Root CA Certificate Bundle:

#### macOS / Linux (Bash)

```bash
export PIP_CERT="/path/to/corporate-ca-bundle.pem"
export REQUESTS_CA_BUNDLE="/path/to/corporate-ca-bundle.pem"
```

#### Windows (PowerShell)

```powershell
$env:PIP_CERT="C:\path\to\corporate-ca-bundle.pem"
$env:REQUESTS_CA_BUNDLE="C:\path\to\corporate-ca-bundle.pem"
```

### 4.2 — Redirecting to a Corporate Pip Mirror

If direct access to `pypi.org` is blocked, configure pip to use your corporate mirror. Create or update your pip configuration file:

- **macOS/Linux**: `~/.pip/pip.conf`
- **Windows**: `%APPDATA%\pip\pip.ini`

```ini
[global]
index-url = https://artifactory.yourcompany.com/api/pip/pypi/simple
trusted-host = artifactory.yourcompany.com
```

---

## Step 5: Install Workshop Python Packages

With your virtual environment active, run the following commands to install dependencies:

```bash
# Upgrade pip inside the environment
pip install --upgrade pip

# Install required workshop packages
pip install google-antigravity uvicorn fastapi pytest
```

---

## Step 6: Google Cloud Authentication & Vertex AI Environment

The workshop runs against **your company's GCP project on Vertex AI**. This one canonical setup authorizes the `agy` CLI, the Antigravity Python SDK, and `agents-cli` (ADK) — no personal/API-key path is needed.

```bash
# 1. Log in to Application Default Credentials (triggers browser auth)
gcloud auth application-default login

# 2. Set your active workshop project (replace with the project ID from your IT Admin)
gcloud config set project "your-workshop-project-id"

# 3. Export the canonical Vertex AI environment (add these to your shell profile
#    so every new terminal — and every SDK/agents-cli exercise — targets Vertex)
export GOOGLE_CLOUD_PROJECT="your-workshop-project-id"
export GOOGLE_CLOUD_LOCATION="global"          # or a region, e.g. us-central1
export GOOGLE_GENAI_USE_VERTEXAI=True           # routes google-genai / ADK calls through Vertex AI
```

> [!IMPORTANT]
> **`GOOGLE_GENAI_USE_VERTEXAI=True` is required for the enterprise path.** Without it, the underlying `google-genai`/ADK stack defaults to the AI-Studio (API-key) backend and ignores your ADC/project — the SDK (Module 4) and `agents-cli` (Module 3) exercises will fail on a customer machine that has no `GOOGLE_API_KEY`.

---

## Step 7: Install the Antigravity CLI (agy)

Install the `agy` binary locally:

### Install agy on macOS / Linux

```bash
# Run the installation script
curl -fsSL https://antigravity.google/cli/install.sh | bash

# Reload your shell profile or source bashrc
source ~/.bashrc
```

### Install agy on Windows

```powershell
# Run the installation script
irm https://antigravity.google/cli/install.ps1 | iex
```

Verify that the CLI is accessible:

```bash
agy --version
```

### Sign in to `agy` with your Google Cloud identity

Launch `agy` once to complete authentication. On an enterprise workstation, sign in with the **Google Cloud identity** that your IT Admin granted `roles/aiplatform.user` — `agy` then runs inference through your project on the Gemini Enterprise Agent Platform (billed at Agent Platform consumption pricing), not a personal Google account.

```bash
# Launch agy; it opens your browser to Google Sign-In.
# On a headless/SSH box it prints a secure authorization URL instead —
# open it in your local browser and paste the code back.
agy
```

> [!NOTE]
> `agy` uses the project from `GOOGLE_CLOUD_PROJECT` (set in Step 6) to select which GCP project handles inference. Type `/logout` inside `agy` to clear cached credentials.

---

## Step 8: Run the Workstation Verification Script

To guarantee zero blockers, we provide an automated verifier that tests local binaries, package isolation, local credentials, Docker daemon connection, and Vertex AI IAM permissions.

Run the verifier corresponding to your host OS:

### Run Verification on macOS / Linux

```bash
# Run the verification script
./scripts/verify-workstation.sh
```

### Run Verification on Windows

```powershell
# Run the verification script
.\scripts\verify-workstation.ps1
```

### Expected Successful Output

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
  ✅ PASS: Isolated virtual environments can install pip packages

[3/5] Checking Google Cloud SDK & Authentication Setup
  ✅ PASS: Google Cloud SDK is installed (version 412.0.0)
  ✅ PASS: Application Default Credentials (ADC) are configured locally
  ✅ PASS: Active Google Cloud project configured: your-workshop-project-id

[4/5] Checking Antigravity CLI (agy) & Docker Environment
  ✅ PASS: agy CLI is installed and in user PATH (version 1.0.16)
  ✅ PASS: Docker client & Compose are installed
  ✅ PASS: Docker Daemon is active & running

[5/5] Checking Firewall Outbound Connection & Vertex AI IAM Permissions
  🌐 Testing outbound network connectivity to Vertex AI us-central1...
  ✅ PASS: Vertex AI Gemini Model access is healthy & verified

═════════════════════════════════════════════════════════════════════════
   📋 Verification Summary
      - 10 passed
      - 0 warnings
      - 0 failures
═════════════════════════════════════════════════════════════════════════

🎉 CONGRATULATIONS! Your local workstation is perfectly prepared for the workshop!
```

---

## Step 9: Run the Quick TUI Smoke Test

Verify interactive sign-in works by triggering `agy`:

```bash
# Start an interactive agy print command
agy --print "Say 'Workstation Ready!' in exactly three words." --print-timeout 30s
```

Expected output: `Workstation Ready!`

---

## Next Step

Once your smoke test succeeds, you are ready to start:
👉 Go to **[Module 1: Antigravity CLI Fundamentals](sdlc-productivity.md)**
