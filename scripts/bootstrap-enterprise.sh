#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Antigravity CLI Workshop — Enterprise Bootstrap Script
# ═══════════════════════════════════════════════════════════
# Automates local-first onboarding using Vertex AI & GCP Cloud Shell.
# Coordinates Application Default Credentials (ADC) auth & sample workspace.

set -euo pipefail

# Color palette
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 Starting Antigravity CLI Enterprise Bootstrap...${NC}"
echo -e "================═════════════════════════════════════"

# Step 1: Check Google Cloud SDK installation
echo -e "\n${BLUE}[1/5] Checking Google Cloud SDK...${NC}"
if ! command -v gcloud &> /dev/null; then
  echo -e "${RED}❌ gcloud CLI is not installed.${NC}"
  echo -e "Please install it from: https://cloud.google.com/sdk/docs/install"
  exit 1
fi
gcloud_version=$(gcloud --version | head -n 1)
echo -e "  ✅ gcloud CLI found: ${GREEN}${gcloud_version}${NC}"

# Step 2: Validate GCP Project settings
echo -e "\n${BLUE}[2/5] Validating GCP Project Config...${NC}"
active_project=$(gcloud config get-value project 2>/dev/null || echo "")

if [ -z "${GOOGLE_CLOUD_PROJECT:-}" ]; then
  if [ -n "$active_project" ]; then
    export GOOGLE_CLOUD_PROJECT="$active_project"
    echo -e "  ✅ GOOGLE_CLOUD_PROJECT set from active gcloud config: ${GREEN}${GOOGLE_CLOUD_PROJECT}${NC}"
  else
    echo -e "${YELLOW}⚠️  GOOGLE_CLOUD_PROJECT environment variable is not set and no active gcloud project found.${NC}"
    read -r -p "Please enter your GCP Project ID: " input_project
    if [ -z "$input_project" ]; then
      echo -e "${RED}❌ Project ID is required. Exiting.${NC}"
      exit 1
    fi
    export GOOGLE_CLOUD_PROJECT="$input_project"
    gcloud config set project "$GOOGLE_CLOUD_PROJECT"
  fi
else
  echo -e "  ✅ GOOGLE_CLOUD_PROJECT is already set: ${GREEN}${GOOGLE_CLOUD_PROJECT}${NC}"
fi

# Step 3: Trigger Keyless Application Default Credentials (ADC) login
echo -e "\n${BLUE}[3/5] Authenticating with Vertex AI (Application Default Credentials)...${NC}"
echo -e "${YELLOW}  Opening browser window to authenticate with Google Cloud...${NC}"
gcloud auth application-default login --no-launch-browser || gcloud auth application-default login

echo -e "  ✅ Application Default Credentials configured successfully!"

# Step 4: Clone the attendee hands-on sandbox repository
echo -e "\n${BLUE}[4/5] Preparing Sandbox Workspace...${NC}"
SANDBOX_DIR="../agy-sample-app"

if [ -d "$SANDBOX_DIR" ]; then
  echo -e "  ⚠️  Sandbox directory '${SANDBOX_DIR}' already exists."
  read -r -p "Do you want to overwrite it? (y/N): " overwrite
  if [[ "$overwrite" =~ ^[Yy]$ ]]; then
    rm -rf "$SANDBOX_DIR"
    echo -e "  Cloning clean sample application..."
    git clone https://github.com/carlosmscabral/agy-sample-app.git "$SANDBOX_DIR"
  else
    echo -e "  Keeping existing sandbox app."
  fi
else
  echo -e "  Cloning clean sample application..."
  git clone https://github.com/carlosmscabral/agy-sample-app.git "$SANDBOX_DIR"
fi

# Step 5: Set up Sandbox Virtual Environment and SDK dependencies
echo -e "\n${BLUE}[5/5] Setting up Python SDK Dependencies...${NC}"
cd "$SANDBOX_DIR"

echo -e "  Creating virtual environment (.venv)..."
python3 -m venv .venv

echo -e "  Installing google-antigravity pip package..."
.venv/bin/pip install --upgrade pip
.venv/bin/pip install google-antigravity

# Create workspace .agents directory to ensure local customization works
mkdir -p .agents

echo -e "\n================═════════════════════════════════════"
echo -e "${GREEN}🎉 Enterprise Bootstrap Completed Successfully!${NC}"
echo -e "================═════════════════════════════════════\n"
echo -e "To start your first Antigravity CLI session, run:"
echo -e "  ${CYAN}cd ${SANDBOX_DIR}${NC}"
echo -e "  ${CYAN}source .venv/bin/activate${NC}"
echo -e "  ${CYAN}export GOOGLE_CLOUD_PROJECT=${GOOGLE_CLOUD_PROJECT}${NC}"
echo -e "  ${CYAN}agy${NC}"
echo -e "\nHappy agent hacking! 🤖"
