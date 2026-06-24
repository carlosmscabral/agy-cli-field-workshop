#!/usr/bin/env bash
# Antigravity CLI Field Workshop — Workstation Verification Script
# This script is run by workshop attendees on their local customer machine 
# to verify environment readiness, corporate network egress, and GCP IAM permissions.

set -eo pipefail

# ANSI color codes for premium terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASS=0
FAIL=0
WARN=0

print_header() {
  echo -e "\n${BLUE}═════════════════════════════════════════════════════════════════════════${NC}"
  echo -e "   ${GREEN}🚀 Antigravity CLI Field Workshop — Workstation Verification${NC}"
  echo -e "${BLUE}═════════════════════════════════════════════════════════════════════════${NC}\n"
}

check_result() {
  local status="$1"
  local message="$2"
  local help_tip="${3:-}"

  if [ "$status" = "PASS" ]; then
    echo -e "  ${GREEN}✅ PASS:${NC} $message"
    PASS=$((PASS + 1))
  elif [ "$status" = "WARN" ]; then
    echo -e "  ${YELLOW}⚠️  WARN:${NC} $message"
    [ -n "$help_tip" ] && echo -e "           ${YELLOW}Tip:${NC} $help_tip"
    WARN=$((WARN + 1))
  else
    echo -e "  ${RED}❌ FAIL:${NC} $message"
    [ -n "$help_tip" ] && echo -e "           ${RED}Action required:${NC} $help_tip"
    FAIL=$((FAIL + 1))
  fi
}

print_header

# -----------------------------------------------------------------------------
# 1. System Environment Checks
# -----------------------------------------------------------------------------
echo -e "${BLUE}[1/5] Checking Workstation Operating System & Core Utilities${NC}"

# Check OS Type
OS_NAME=$(uname -s 2>/dev/null || echo "Windows")
echo -e "  💻 Operating System: ${GREEN}$OS_NAME${NC}"

# Git
if command -v git &>/dev/null; then
  GIT_VER=$(git --version | awk '{print $3}')
  check_result "PASS" "Git is installed (version $GIT_VER)"
else
  check_result "FAIL" "Git is not installed" "Install Git from https://git-scm.com/downloads"
fi

# jq (Optional but highly useful)
if command -v jq &>/dev/null; then
  check_result "PASS" "jq is installed"
else
  check_result "WARN" "jq is not installed (optional)" "Recommended for parsing JSON payloads in later SDK exercises"
fi

echo ""

# -----------------------------------------------------------------------------
# 2. Python & Package Installation Checks
# -----------------------------------------------------------------------------
echo -e "${BLUE}[2/5] Checking Python 3 Runtime & Package Isolation${NC}"

# Python version check (minimum 3.10)
if command -v python3 &>/dev/null; then
  PY_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
  PY_PATCH=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}")')
  
  # Compare versions (major >= 3, minor >= 10)
  MAJOR=$(echo "$PY_VER" | cut -d. -f1)
  MINOR=$(echo "$PY_VER" | cut -d. -f2)
  
  if [ "$MAJOR" -eq 3 ] && [ "$MINOR" -ge 10 ]; then
    check_result "PASS" "Python version is compliant ($PY_PATCH)"
  else
    check_result "FAIL" "Python version is $PY_PATCH (minimum 3.10+ required)" "Please install Python 3.10, 3.11, or 3.12."
  fi
else
  check_result "FAIL" "Python 3 is not installed" "Please install Python 3.10+."
fi

# Pip Mirror & Configuration Detection (Corporate Proxy Handling)
echo -e "  📦 Checking package manager (pip) and corporate proxies..."
if [ -n "${PIP_INDEX_URL:-}" ]; then
  echo -e "     - Found environment variable PIP_INDEX_URL: $PIP_INDEX_URL"
fi
if [ -f "$HOME/.pip/pip.conf" ]; then
  echo -e "     - Found local user pip.conf file at ~/.pip/pip.conf"
elif [ -f "$APPDATA/pip/pip.ini" ]; then
  echo -e "     - Found local user pip.ini file at %APPDATA%\\pip\\pip.ini"
fi

# Sandbox isolated package installation check (dry run pip install)
if command -v python3 &>/dev/null; then
  echo -e "  🧪 Testing virtual environment and local pip installations..."
  
  # Create a small temp directory for a test virtual environment
  TEMP_VENV_DIR=$(mktemp -d -t "agy_venv_verify_XXXXXX" 2>/dev/null || mktemp -d 2>/dev/null || echo "./.agy_venv_verify_temp")
  
  if python3 -m venv "$TEMP_VENV_DIR" &>/dev/null; then
    # Try upgrading pip or installing a small safe package inside the sandbox
    if "$TEMP_VENV_DIR/bin/pip" install --dry-run packaging &>/dev/null; then
      check_result "PASS" "Isolated virtual environments can install pip packages"
    else
      check_result "WARN" "Virtual environment cannot download packages via pip" "Your machine may be behind a decrypting corporate proxy or firewall. Ask your Network Admin to configure pip to use your internal mirror (e.g. Artifactory) or import corporate CA certificates using export PIP_CERT=/path/to/corporate-ca.crt"
    fi
    # Clean up temp virtual environment
    rm -rf "$TEMP_VENV_DIR"
  else
    check_result "FAIL" "Failed to create Python virtual environments (venv module missing)" "On Ubuntu/Debian, install with: sudo apt install python3-venv"
  fi
else
  check_result "FAIL" "Pip check skipped (Python 3 missing)"
fi

echo ""

# -----------------------------------------------------------------------------
# 3. Google Cloud SDK & Authentication Checks
# -----------------------------------------------------------------------------
echo -e "${BLUE}[3/5] Checking Google Cloud SDK & Authentication Setup${NC}"

# Check gcloud installation
if command -v gcloud &>/dev/null; then
  GCLOUD_VER=$(gcloud --version | head -n 1 | awk '{print $4}')
  check_result "PASS" "Google Cloud SDK is installed (version $GCLOUD_VER)"
else
  check_result "FAIL" "Google Cloud SDK (gcloud CLI) is not installed" "Please install gcloud from https://cloud.google.com/sdk/docs/install"
fi

# Check Application Default Credentials (ADC)
ADC_PATH=""
if [ "$OS_NAME" = "Darwin" ] || [ "$OS_NAME" = "Linux" ]; then
  ADC_PATH="$HOME/.config/gcloud/application_default_credentials.json"
else
  ADC_PATH="$APPDATA/gcloud/application_default_credentials.json"
fi

if [ -f "$ADC_PATH" ]; then
  check_result "PASS" "Application Default Credentials (ADC) are configured locally"
else
  check_result "FAIL" "Application Default Credentials (ADC) are missing" "Please authenticate your local workstation by running: gcloud auth application-default login"
fi

# Check active GCP Project ID
GCP_PROJECT=$(gcloud config get-value project 2>/dev/null || true)
if [ -n "$GCP_PROJECT" ] && [ "$GCP_PROJECT" != "(unset)" ]; then
  check_result "PASS" "Active Google Cloud project configured: ${GREEN}$GCP_PROJECT${NC}"
else
  check_result "WARN" "No active Google Cloud project configured in gcloud CLI" "Configure your project using: gcloud config set project <your-project-id>"
fi

echo ""

# -----------------------------------------------------------------------------
# 4. Antigravity CLI (agy) & Docker Environment Checks
# -----------------------------------------------------------------------------
echo -e "${BLUE}[4/5] Checking Antigravity CLI (agy) & Docker Environment${NC}"

# Check agy installation
if command -v agy &>/dev/null; then
  AGY_VERSION=$(agy --version 2>/dev/null || echo "Unknown")
  check_result "PASS" "agy CLI is installed and in user PATH (version $AGY_VERSION)"
else
  check_result "FAIL" "agy CLI is not installed or not in your system PATH" "Follow the instructions in setup.md to install agy"
fi

# Check Docker Client installation
if command -v docker &>/dev/null; then
  DOCKER_VER=$(docker --version | awk '{print $3}' | tr -d ',')
  check_result "PASS" "Docker client is installed (version $DOCKER_VER)"
else
  check_result "FAIL" "Docker client is not installed" "Please install Docker Desktop (or Rancher Desktop) on your workstation"
fi

# Check Docker Compose (v2 preferred)
if docker compose version &>/dev/null; then
  COMPOSE_VER=$(docker compose version | awk '{print $4}')
  check_result "PASS" "Docker Compose is installed ($COMPOSE_VER)"
elif command -v docker-compose &>/dev/null; then
  COMPOSE_VER=$(docker-compose --version | awk '{print $3}')
  check_result "PASS" "Docker Compose is installed (version $COMPOSE_VER)"
else
  check_result "FAIL" "Docker Compose is not installed" "Verify Docker Desktop is installed or install the docker-compose-plugin"
fi

# Check Docker Daemon running state
if command -v docker &>/dev/null; then
  if docker info &>/dev/null; then
    check_result "PASS" "Docker Daemon is active & running"
  else
    check_result "FAIL" "Docker Daemon is not running" "Start Docker Desktop or Rancher Desktop to activate the local container runtime"
  fi
fi

echo ""

# -----------------------------------------------------------------------------
# 5. Network & GCP IAM Permission Integration Checks
# -----------------------------------------------------------------------------
echo -e "${BLUE}[5/5] Checking Firewall Outbound Connection & Vertex AI IAM Permissions${NC}"

if [ -z "$GCP_PROJECT" ] || [ "$GCP_PROJECT" = "(unset)" ]; then
  check_result "FAIL" "GCP API connection check skipped" "Configure an active project first using: gcloud config set project <your-project-id>"
elif [ ! -f "$ADC_PATH" ]; then
  check_result "FAIL" "GCP API connection check skipped" "Ensure you have logged in via: gcloud auth application-default login"
else
  echo -e "  🌐 Testing outbound network connectivity to Vertex AI us-central1..."
  
  # Fetch ADC Access Token to verify credential viability
  ADC_TOKEN=$(gcloud auth application-default print-access-token 2>/dev/null || true)
  
  if [ -z "$ADC_TOKEN" ]; then
    check_result "FAIL" "Unable to obtain local Application Default Credentials token" "Re-run: gcloud auth application-default login"
  else
    # Run API connectivity & IAM check via a real Vertex AI Gemini API endpoint call
    # We target gemini-3.5-flash as mandated.
    # We check HTTP status code output.
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
      -X POST \
      -H "Authorization: Bearer $ADC_TOKEN" \
      -H "Content-Type: application/json" \
      "https://us-central1-aiplatform.googleapis.com/v1/projects/${GCP_PROJECT}/locations/us-central1/publishers/google/models/gemini-3.5-flash:generateContent" \
      -d '{"contents": [{"role": "user", "parts": [{"text": "Hello, is this API active?"}]}]}' \
      --max-time 10 || echo "000")

    if [ "$HTTP_STATUS" = "200" ]; then
      check_result "PASS" "Vertex AI Gemini Model access is healthy & verified"
    elif [ "$HTTP_STATUS" = "403" ]; then
      check_result "FAIL" "IAM Permission Denied (HTTP 403) accessing Vertex AI on project $GCP_PROJECT" "Verify your GCP user has been granted the 'Vertex AI User' (roles/aiplatform.user) role in the project."
    elif [ "$HTTP_STATUS" = "404" ]; then
      check_result "FAIL" "Vertex AI Model API not found (HTTP 404)" "Ensure the Vertex AI API (aiplatform.googleapis.com) has been enabled in the project: gcloud services enable aiplatform.googleapis.com"
    elif [ "$HTTP_STATUS" = "000" ]; then
      check_result "FAIL" "Connection timed out (no network response)" "Outbound traffic to *.aiplatform.googleapis.com on port 443 is blocked. Please contact your Enterprise Security/Network team to whitelist Google Cloud APIs."
    else
      check_result "WARN" "Received unexpected response (HTTP $HTTP_STATUS) from Vertex AI API" "Ensure your project has Vertex AI API enabled and that you are using a validated regional endpoint."
    fi
  fi
fi

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}═════════════════════════════════════════════════════════════════════════${NC}"
echo -e "   ${GREEN}📋 Verification Summary${NC}"
echo -e "      - ${GREEN}$PASS passed${NC}"
echo -e "      - ${YELLOW}$WARN warnings${NC}"
echo -e "      - ${RED}$FAIL failures${NC}"
echo -e "${BLUE}═════════════════════════════════════════════════════════════════════════${NC}\n"

if [ $FAIL -eq 0 ]; then
  if [ $WARN -eq 0 ]; then
    echo -e "${GREEN}🎉 CONGRATULATIONS! Your local workstation is perfectly prepared for the workshop!${NC}\n"
  else
    echo -e "${YELLOW}⚠️  Your local workstation is mostly ready. Review the warnings above before starting.${NC}\n"
  fi
  exit 0
else
  echo -e "${RED}❌ Please resolve the $FAIL critical failure(s) listed above before starting the workshop.${NC}\n"
  exit 1
fi
