# Pre-Work: Cloud Shell & Qwiklabs Onboarding

This onboarding track is designed for attendees running the workshop in a Google-provided **Cloud Shell or Qwiklabs sandbox environment**.

In this setup, you are typically granted **Owner** permissions over a temporary GCP project, and all standard tools (Python, Git, gcloud SDK, and Docker) are pre-installed in your virtual browser terminal.

---

## Step 1: Open Cloud Shell

1. Go to the [Google Cloud Console](https://console.cloud.google.com).
2. In the top-right toolbar, click the **Activate Cloud Shell** button (SSH terminal icon).
3. Wait for the Cloud Shell provisioner to launch.

---

## Step 2: Initialize Project & Enable Vertex AI

Because you are the owner of the sandbox project, you can enable APIs directly. Run the following commands to configure your active project and enable the required Vertex AI APIs:

```bash
# Get the active project ID and set it
export PROJECT_ID=$(gcloud config get-value project)
gcloud config set project "$PROJECT_ID"

# Enable Vertex AI, Cloud Run, Artifact Registry, and Cloud Build
gcloud services enable aiplatform.googleapis.com \
                       run.googleapis.com \
                       artifactregistry.googleapis.com \
                       cloudbuild.googleapis.com
```

---

## Step 3: Clone the Workshop & Sandbox Repositories

Create a clean directory structure and clone the workshop repository and the developer sandbox application:

```bash
# Clone the Workshop Repository
git clone https://github.com/carlosmscabral/agy-cli-field-workshop.git
cd agy-cli-field-workshop

# Clone the Sandbox Application (into the parent directory)
git clone https://github.com/carlosmscabral/agy-sample-app.git ../agy-sample-app
```

---

## Step 4: Install the Antigravity CLI (agy)

Install the `agy` tool inside your Cloud Shell environment:

```bash
curl -fsSL https://antigravity.google/cli/install.sh | bash
```

Verify that the CLI is accessible and set up in your terminal `PATH`:

```bash
# Reload shell or source bashrc
source ~/.bashrc

# Verify installation
agy --version
```

---

## Step 5: Virtual Environment & Packages

Initialize an isolated virtual environment and install the required workshop dependencies (including `google-antigravity`):

```bash
# Create and activate virtual environment inside the workshop directory
python3 -m venv .venv
source .venv/bin/activate

# Upgrade pip and install standard packages
pip install --upgrade pip
pip install google-antigravity uvicorn fastapi pytest
```

---

## Step 6: Docker Verification

Docker and Docker Compose (v2) are **fully pre-installed and running** out of the box inside Google Cloud Shell.

Verify that Docker is active and responsive:

```bash
# Check docker version
docker --version

# Check docker compose version
docker compose version

# Verify the Docker daemon is responsive
docker info
```

---

## Step 7: Google Sign-In (Authentication)

Authenticate the `agy` CLI using your Google user credentials:

```bash
# Run agy to trigger authentication
agy
```

> [!NOTE]
> Since Cloud Shell is a remote virtual environment, the CLI will output a sign-in URL. Copy the URL, paste it into your local browser, sign in with your Google Account, copy the authorization code, and paste it back into your Cloud Shell terminal.

---

## Step 8: Run the Quick Smoke Test

Verify everything is fully functional by running a quick print-mode test:

```bash
agy --print "Say 'Cloud Shell Ready!' in exactly three words." --print-timeout 30s
```

Expected output: `Cloud Shell Ready!`

---

## Next Step

Once your smoke test succeeds, you are ready to start:
👉 Go to **[Module 1: SDLC Productivity](sdlc-productivity.md)**
