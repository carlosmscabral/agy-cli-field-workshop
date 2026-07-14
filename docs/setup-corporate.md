# Track A — Enterprise / Corporate Dev Track Setup

This track is designed for teams running the workshop on **customer-managed corporate physical machines** (such as company laptops running macOS, Windows, or Linux).

> [!IMPORTANT]
> **IT Admin Setup Must Be Completed First!**
> Before any developer can configure their workstation, your company's **IT Administrator** must complete the project provisioning, API activation, and IAM permissions.
>
> - **IT Admins**: Go to [Role 1: IT Admin Provisioning](setup-enterprise-admin.md) first.
> - **Developers**: Obtain the assigned **GCP Project ID** from your admin before starting Role 2.

It consists of **two roles**:

1. 🛠️ **IT Admin**: Configures the GCP project, enables Vertex AI APIs, whitelists domains, and provisions bulk IAM permissions *once* for the group.
2. 💻 **Developer**: Configures their local laptop virtual environment, Google authentication, and runs the workstation verifier (plus optional corporate proxy/SSL setup only if the network requires it).

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

Required to clone the sample app. Check with:

```bash
git --version
```

- **macOS**: Install via Homebrew (`brew install git`) or Xcode Command Line Tools (`xcode-select --install`).
- **Windows**: Install via [Git for Windows](https://git-scm.com/download/win).
- **Linux**: Install via package manager (e.g., `sudo apt install git`).

### 1.2 — Python 3.10 to 3.12

Required to run the sample app and its tests. Check with:

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

## Step 2: Clone the Sample App

You only need **one** repository — the sample application. The workshop material itself lives on this site (nothing to clone), and `agy` runs *inside* the sample app. Clone it into your working directory:

```bash
git clone https://github.com/carlosmscabral/agy-sample-app.git
cd agy-sample-app
```

> [!TIP]
> **One-command bootstrap (optional).** Instead of the clone above (and Step 5 auth), run this one-liner from your working directory — it clones `agy-sample-app` into the current folder, runs the ADC login, exports the canonical Vertex environment, and creates the sample app's `.venv`:
>
> ```bash
> bash <(curl -fsSL https://raw.githubusercontent.com/carlosmscabral/agy-cli-field-workshop/main/scripts/bootstrap-enterprise.sh)
> ```
>
> It runs interactively (it may prompt for your GCP project ID). You still need `uv` (Step 3) and `agy` (Step 6).

---

## Step 3: Install uv (Python Package Manager)

Install [`uv`](https://docs.astral.sh/uv/), the fast Python package manager — it provides `uvx`, used by the MCP beat (Beat 4). It's a standalone binary — no virtual environment required to install it.

### Install uv on macOS / Linux

```bash
# Install uv, then re-source your shell and verify
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
uv --version
```

### Install uv on Windows

```powershell
# Install uv, then verify
irm https://astral.sh/uv/install.ps1 | iex
uv --version
```

> [!NOTE]
> **The sample app owns its environment — there is no shared workshop venv.** The sample app (`agy-sample-app`) creates its own `.venv` and installs from its `requirements.txt` (Beat 1 sets this up). This keeps the project's dependencies isolated and avoids `ModuleNotFoundError` from running it in the wrong environment.

---

## Step 4: Google Cloud Authentication & Vertex AI Environment

The workshop runs against **your company's GCP project on Vertex AI**. This one canonical setup authorizes the `agy` CLI — no personal/API-key path is needed.

```bash
# 1. Log in to Application Default Credentials (triggers browser auth)
gcloud auth application-default login

# 2. Set your active workshop project (replace with the project ID from your IT Admin)
gcloud config set project "your-workshop-project-id"

# 3. Export the canonical Vertex AI environment (add these to your shell profile
#    so every new terminal targets Vertex)
export GOOGLE_CLOUD_PROJECT="your-workshop-project-id"
export GOOGLE_CLOUD_LOCATION="global"          # or a region, e.g. us-central1
export GOOGLE_GENAI_USE_VERTEXAI=True           # routes model calls through Vertex AI
```

> [!IMPORTANT]
> **`GOOGLE_GENAI_USE_VERTEXAI=True` is required for the enterprise path.** Without it, the underlying `google-genai` stack defaults to the AI-Studio (API-key) backend and ignores your ADC/project — model calls will fail on a customer machine that has no `GOOGLE_API_KEY`.

---

## Step 5: Install the Antigravity CLI (agy)

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
> `agy` uses the project from `GOOGLE_CLOUD_PROJECT` (set in Step 4) to select which GCP project handles inference. Type `/logout` inside `agy` to clear cached credentials.

---

## Step 6: Run the Workstation Verification Script

To guarantee zero blockers, we provide an automated verifier that tests local binaries, package isolation, local credentials, and Vertex AI IAM permissions.

Run the verifier corresponding to your host OS:

Run it straight from the repo — no clone needed:

### Run Verification on macOS / Linux

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/carlosmscabral/agy-cli-field-workshop/main/scripts/verify-workstation.sh)
```

### Run Verification on Windows

```powershell
irm https://raw.githubusercontent.com/carlosmscabral/agy-cli-field-workshop/main/scripts/verify-workstation.ps1 | iex
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

[4/5] Checking Antigravity CLI (agy) & Tooling
  ✅ PASS: agy CLI is installed and in user PATH (version 1.0.16)
  ✅ PASS: uv is installed (0.5.11)

[5/5] Checking Firewall Outbound Connection & Vertex AI IAM Permissions
  🌐 Testing outbound network connectivity to Vertex AI...
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

## Step 7: Run the Quick TUI Smoke Test

Verify interactive sign-in works by triggering `agy`:

```bash
# Start an interactive agy print command
agy --print "Say 'Workstation Ready!' in exactly three words." --print-timeout 30s
```

Expected output: `Workstation Ready!`

---

## Next Step

Once your smoke test succeeds, you are ready to start:
👉 Go to **[The Workshop — An End-to-End Software Story](overview.md)**

---

## Optional: Corporate Proxies, Private Mirrors, & SSL Certs

> [!NOTE]
> **Only needed if your network restricts outbound package traffic.** Skip this entirely if the verification script (Step 6) passed. Many corporate environments route traffic through SSL-decrypting firewalls or require private package registries (like Sonatype Nexus or JFrog Artifactory). The settings below apply to **every `pip install` you run inside a project's venv** throughout the workshop. If verification failed with SSL or network errors, apply the relevant fix below and re-run Step 6.

### Trusting Corporate Root Certificates

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

### Redirecting to a Corporate Pip Mirror

If direct access to `pypi.org` is blocked, configure pip to use your corporate mirror. Create or update your pip configuration file:

- **macOS/Linux**: `~/.pip/pip.conf`
- **Windows**: `%APPDATA%\pip\pip.ini`

```ini
[global]
index-url = https://artifactory.yourcompany.com/api/pip/pypi/simple
trusted-host = artifactory.yourcompany.com
```
