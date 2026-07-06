# PowerShell Script for Antigravity CLI Field Workshop — Workstation Verification
# This script is run by workshop attendees on their local Windows workstation 
# to verify environment readiness, corporate network egress, and GCP IAM permissions.

$ErrorActionPreference = "Stop"

# Define colors for terminal output
$green = "Green"
$red = "Red"
$yellow = "Yellow"
$blue = "Cyan"
$white = "White"

function Write-HostColor ($text, $color) {
    Write-Host $text -ForegroundColor $color
}

function Print-Header {
    Write-HostColor "═════════════════════════════════════════════════════════════════════════" $blue
    Write-HostColor "   🚀 Antigravity CLI Field Workshop — Workstation Verification (Windows)" $green
    Write-HostColor "═════════════════════════════════════════════════════════════════════════`n" $blue
}

$passCount = 0
$failCount = 0
$warnCount = 0

function Assert-Result ($status, $message, $helpTip = "") {
    if ($status -eq "PASS") {
        Write-Host "  ✅ PASS: $message" -ForegroundColor $green
        $script:passCount++
    } elseif ($status -eq "WARN") {
        Write-Host "  ⚠️  WARN: $message" -ForegroundColor $yellow
        if ($helpTip) {
            Write-Host "           Tip: $helpTip" -ForegroundColor $yellow
        }
        $script:warnCount++
    } else {
        Write-Host "  ❌ FAIL: $message" -ForegroundColor $red
        if ($helpTip) {
            Write-Host "           Action required: $helpTip" -ForegroundColor $red
        }
        $script:failCount++
    }
}

Print-Header

# -----------------------------------------------------------------------------
# 1. System Environment Checks
# -----------------------------------------------------------------------------
Write-HostColor "[1/5] Checking Workstation Operating System & Core Utilities" $blue

# OS details
$os = [System.Environment]::OSVersion.VersionString
Write-Host "  💻 Operating System: $os" -ForegroundColor $green

# Check Git
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) {
    $gitVer = (git --version) -join ""
    Assert-Result "PASS" "Git is installed ($gitVer)"
} else {
    Assert-Result "FAIL" "Git is not installed" "Install Git for Windows from https://git-scm.com/download/win"
}

# Check jq
$jqCmd = Get-Command jq -ErrorAction SilentlyContinue
if ($jqCmd) {
    Assert-Result "PASS" "jq is installed"
} else {
    Assert-Result "WARN" "jq is not installed (optional)" "Recommended for parsing JSON payloads in later SDK exercises. Install via: winget install jqlang.jq"
}

Write-Host ""

# -----------------------------------------------------------------------------
# 2. Python & Package Installation Checks
# -----------------------------------------------------------------------------
Write-HostColor "[2/5] Checking Python 3 Runtime & Package Isolation" $blue

$pythonCmd = $null
foreach ($cmd in "python", "python3") {
    $found = Get-Command $cmd -ErrorAction SilentlyContinue
    if ($found) {
        $pythonCmd = $cmd
        break
    }
}

if ($pythonCmd) {
    $pyVerStr = & $pythonCmd -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')"
    $pyMajor = & $pythonCmd -c "import sys; print(sys.version_info.major)"
    $pyMinor = & $pythonCmd -c "import sys; print(sys.version_info.minor)"

    if ($pyMajor -eq 3 -and $pyMinor -ge 10) {
        Assert-Result "PASS" "Python version is compliant ($pyVerStr)"
    } else {
        Assert-Result "FAIL" "Python version is $pyVerStr (minimum 3.10+ required)" "Please download and install Python 3.10, 3.11, or 3.12 from python.org"
    }
} else {
    Assert-Result "FAIL" "Python is not installed" "Please install Python 3.10+ from python.org. Make sure to check 'Add python.exe to PATH' during installation."
}

# Pip mirror checks
Write-Host "  📦 Checking package manager (pip) and corporate proxies..."
if ($env:PIP_INDEX_URL) {
    Write-Host "     - Found environment variable PIP_INDEX_URL: $env:PIP_INDEX_URL"
}
$appData = $env:APPDATA
$pipIniPath = Join-Path $appData "pip\pip.ini"
if (Test-Path $pipIniPath) {
    Write-Host "     - Found local user pip.ini file at $pipIniPath"
}

# Sandbox venv and local pip test
if ($pythonCmd) {
    Write-Host "  🧪 Testing virtual environment and local pip installations..."
    $tempRoot = [System.IO.Path]::GetTempPath()
    $tempDir = Join-Path $tempRoot ("agy_venv_verify_" + [System.IO.Path]::GetRandomFileName())
    
    try {
        # Attempt to create virtual environment
        & $pythonCmd -m venv $tempDir
        $pipPath = Join-Path $tempDir "Scripts\pip.exe"
        
        if (Test-Path $pipPath) {
            # Attempt to install package with dry run (testing network egress to index)
            $dryRunProcess = Start-Process -FilePath $pipPath -ArgumentList "install", "--dry-run", "packaging" -NoNewWindow -PassThru -Wait -RedirectStandardError (Join-Path $tempDir "err.log") -RedirectStandardOutput (Join-Path $tempDir "out.log")
            
            if ($dryRunProcess.ExitCode -eq 0) {
                Assert-Result "PASS" "Isolated virtual environments can install pip packages"
            } else {
                Assert-Result "WARN" "Virtual environment cannot download packages via pip" "Your machine may be behind an enterprise decrypting proxy or firewall. Ask your Network Admin to configure pip to use your internal mirror (e.g. Artifactory) or import corporate certificates using `$env:PIP_CERT = 'C:\Path\To\corporate-ca.crt'`"
            }
        } else {
            Assert-Result "FAIL" "Python environment created but pip is missing in Scripts folder"
        }
    } catch {
        Assert-Result "FAIL" "Failed to create Python virtual environments" "Verify your Python installation is healthy and can run 'python -m venv'"
    } finally {
        # Clean up temp virtual environment folder
        if (Test-Path $tempDir) {
            Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
        }
    }
} else {
    Assert-Result "FAIL" "Pip check skipped (Python missing)"
}

Write-Host ""

# -----------------------------------------------------------------------------
# 3. Google Cloud SDK & Authentication Checks
# -----------------------------------------------------------------------------
Write-HostColor "[3/5] Checking Google Cloud SDK & Authentication Setup" $blue

$gcloudCmd = Get-Command gcloud -ErrorAction SilentlyContinue
if ($gcloudCmd) {
    # Extract version safely
    $gcloudVer = (gcloud --version | Select-Object -First 1)
    Assert-Result "PASS" "Google Cloud SDK is installed ($gcloudVer)"
} else {
    Assert-Result "FAIL" "Google Cloud SDK (gcloud CLI) is not installed" "Please download and install Cloud SDK from https://cloud.google.com/sdk/docs/install#windows"
}

# Check Application Default Credentials (ADC) path
$adcPath = Join-Path $env:APPDATA "gcloud\application_default_credentials.json"
if (Test-Path $adcPath) {
    Assert-Result "PASS" "Application Default Credentials (ADC) are configured locally"
} else {
    Assert-Result "FAIL" "Application Default Credentials (ADC) are missing" "Please authenticate your local workstation by running: gcloud auth application-default login"
}

# Check active project
$gcpProject = $null
if ($gcloudCmd) {
    try {
        $gcpProject = (gcloud config get-value project 2>$null) -join ""
        if ($gcpProject -and $gcpProject -ne "(unset)") {
            Assert-Result "PASS" "Active Google Cloud project configured: $gcpProject"
        } else {
            Assert-Result "WARN" "No active Google Cloud project configured in gcloud CLI" "Configure your project using: gcloud config set project <your-project-id>"
            $gcpProject = $null
        }
    } catch {
        Assert-Result "WARN" "Could not retrieve project from gcloud configuration"
    }
} else {
    Assert-Result "FAIL" "GCP active project check skipped (gcloud missing)"
}

Write-Host ""

# -----------------------------------------------------------------------------
# 4. Antigravity CLI (agy) & Docker Environment Checks
# -----------------------------------------------------------------------------
Write-HostColor "[4/5] Checking Antigravity CLI (agy) & Docker Environment" $blue

# Check agy installation
$agyCmd = Get-Command agy -ErrorAction SilentlyContinue
if ($agyCmd) {
    try {
        $agyVer = (agy --version 2>$null) -join ""
        Assert-Result "PASS" "agy CLI is installed and in user PATH (version $agyVer)"
    } catch {
        Assert-Result "PASS" "agy CLI is installed and in user PATH"
    }
} else {
    Assert-Result "FAIL" "agy CLI is not installed or not in your system PATH" "Follow the instructions in setup.md to install agy"
}

# Check uv (Python package/venv manager used by the SDK exercises)
$uvCmd = Get-Command uv -ErrorAction SilentlyContinue
if ($uvCmd) {
    try {
        $uvVer = (uv --version 2>$null) -join ""
        Assert-Result "PASS" "uv is installed ($uvVer)"
    } catch {
        Assert-Result "PASS" "uv is installed"
    }
} else {
    Assert-Result "WARN" "uv is not installed" "uv is the recommended Python toolchain for the SDK exercises. Install it from https://docs.astral.sh/uv/getting-started/installation/"
}

# Check agents-cli (Agent Development Kit CLI)
$agentsCliCmd = Get-Command agents-cli -ErrorAction SilentlyContinue
if ($agentsCliCmd) {
    Assert-Result "PASS" "agents-cli is installed and in user PATH"
} else {
    Assert-Result "WARN" "agents-cli is not installed or not in your system PATH" "agents-cli is required for the SDK exercises. Follow the instructions in setup.md to install it."
}

# Check google-antigravity Python package
if ($pythonCmd) {
    & $pythonCmd -c "import google.antigravity" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Assert-Result "PASS" "google-antigravity Python package is importable"
    } else {
        Assert-Result "WARN" "google-antigravity Python package is not installed" "Install it into your workshop environment (e.g. uv pip install google-antigravity) as described in setup.md"
    }
}

# Check Docker Client installation
$dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
if ($dockerCmd) {
    try {
        $dockerVer = (docker --version) -join ""
        Assert-Result "PASS" "Docker client is installed ($dockerVer)"
    } catch {
        Assert-Result "PASS" "Docker client is installed"
    }
} else {
    Assert-Result "FAIL" "Docker client is not installed" "Please install Docker Desktop (or Rancher Desktop) on your workstation"
}

# Check Docker Compose (v2 preferred)
try {
    $composeProc = Start-Process -FilePath "docker" -ArgumentList "compose", "version" -NoNewWindow -PassThru -Wait
    if ($composeProc.ExitCode -eq 0) {
        Assert-Result "PASS" "Docker Compose is installed (v2)"
    } else {
        throw "Failed to run docker compose"
    }
} catch {
    $dockerComposeCmd = Get-Command docker-compose -ErrorAction SilentlyContinue
    if ($dockerComposeCmd) {
        try {
            $composeVer = (docker-compose --version) -join ""
            Assert-Result "PASS" "Docker Compose is installed (version $composeVer)"
        } catch {
            Assert-Result "PASS" "Docker Compose is installed"
        }
    } else {
        Assert-Result "FAIL" "Docker Compose is not installed" "Verify Docker Desktop is installed or configure docker-compose"
    }
}

# Check Docker Daemon running state
if ($dockerCmd) {
    try {
        $infoProc = Start-Process -FilePath "docker" -ArgumentList "info" -NoNewWindow -PassThru -Wait
        if ($infoProc.ExitCode -eq 0) {
            Assert-Result "PASS" "Docker Daemon is active & running"
        } else {
            Assert-Result "WARN" "Docker Daemon is not running" "Docker is only needed for the modernization module's container exercises. CLI-only attendees can skip this. To run those exercises, start Docker Desktop or Rancher Desktop to activate the local container runtime."
        }
    } catch {
        Assert-Result "WARN" "Docker Daemon is not running" "Docker is only needed for the modernization module's container exercises. CLI-only attendees can skip this. To run those exercises, start Docker Desktop or Rancher Desktop to activate the local container runtime."
    }
}

Write-Host ""

# -----------------------------------------------------------------------------
# 5. Network & GCP IAM Permission Integration Checks
# -----------------------------------------------------------------------------
Write-HostColor "[5/5] Checking Firewall Outbound Connection & Vertex AI IAM Permissions" $blue

if (-not $gcpProject) {
    Assert-Result "FAIL" "GCP API connection check skipped" "Configure an active project first using: gcloud config set project <your-project-id>"
} elseif (-not (Test-Path $adcPath)) {
    Assert-Result "FAIL" "GCP API connection check skipped" "Ensure you have logged in via: gcloud auth application-default login"
} else {
    # Test the location the attendee configured (GOOGLE_CLOUD_LOCATION); default to global.
    # The global endpoint has no region prefix; regional endpoints do.
    $vertexLocation = if ($env:GOOGLE_CLOUD_LOCATION) { $env:GOOGLE_CLOUD_LOCATION } else { "global" }
    if ($vertexLocation -eq "global") { $vertexHost = "aiplatform.googleapis.com" } else { $vertexHost = "${vertexLocation}-aiplatform.googleapis.com" }
    Write-Host "  🌐 Testing outbound network connectivity to Vertex AI (location: $vertexLocation)..."
    
    # Safely extract ADC print-access-token
    try {
        $adcToken = (gcloud auth application-default print-access-token 2>$null) -join ""
        $adcToken = $adcToken.Trim()
    } catch {
        $adcToken = ""
    }

    if (-not $adcToken) {
        Assert-Result "FAIL" "Unable to obtain local Application Default Credentials token" "Re-run: gcloud auth application-default login"
    } else {
        # Target endpoint model is gemini-3.1-pro-preview (a live-supported, stable id)
        $uri = "https://$vertexHost/v1/projects/$gcpProject/locations/$vertexLocation/publishers/google/models/gemini-3.1-pro-preview:generateContent"
        
        $headers = @{
            "Authorization" = "Bearer $adcToken"
            "Content-Type"  = "application/json"
        }
        
        $bodyObject = @{
            contents = @(
                @{
                    role  = "user"
                    parts = @(
                        @{ text = "Hello, is this API active?" }
                    )
                }
            )
        }
        $bodyJson = $bodyObject | ConvertTo-Json -Depth 5
        
        # Bypass SSL verification if custom TLS inspection bypass is needed (informational only)
        # We perform standard request and catch HTTP status codes
        try {
            $response = Invoke-WebRequest -Method Post -Uri $uri -Headers $headers -Body $bodyJson -TimeoutSec 10 -UseBasicParsing
            if ($response.StatusCode -eq 200) {
                Assert-Result "PASS" "Vertex AI Gemini Model access is healthy & verified"
            } else {
                Assert-Result "WARN" "Received HTTP status code $($response.StatusCode) from Vertex AI API" "The model id or region may be unavailable in this project. Confirm the Vertex AI API is enabled and that model gemini-3.1-pro-preview is offered in location $vertexLocation for your project."
            }
        } catch {
            $ex = $_.Exception
            if ($_.Exception.Response) {
                $statusCode = [int]$_.Exception.Response.StatusCode
                if ($statusCode -eq 403) {
                    Assert-Result "FAIL" "IAM Permission Denied (HTTP 403) accessing Vertex AI on project $gcpProject" "Verify your GCP user has been granted the 'Vertex AI User' (roles/aiplatform.user) role in the project."
                } elseif ($statusCode -eq 404) {
                    Assert-Result "FAIL" "Vertex AI Model API not found (HTTP 404)" "The model id or region may be unavailable in this project. Verify the Vertex AI API (aiplatform.googleapis.com) is enabled (gcloud services enable aiplatform.googleapis.com), and that model gemini-3.1-pro-preview is available in location $vertexLocation for your project."
                } else {
                    Assert-Result "FAIL" "API Error (HTTP $statusCode) accessing Vertex AI" "The model id or region may be unavailable in this project. Check that the Vertex AI API is enabled and that model gemini-3.1-pro-preview is offered in location $vertexLocation for your project."
                }
            } else {
                # General connection issue (DNS, proxy, block)
                $errMsg = $ex.Message
                Assert-Result "FAIL" "Connection failed: $errMsg" "Outbound traffic to *.aiplatform.googleapis.com on port 443 is blocked. Please contact your Enterprise Security/Network team to whitelist Google Cloud APIs."
            }
        }
    }
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
Write-HostColor "`n═════════════════════════════════════════════════════════════════════════" $blue
Write-Host "   📋 Verification Summary" -ForegroundColor $green
Write-Host "      - $passCount passed" -ForegroundColor $green
Write-Host "      - $warnCount warnings" -ForegroundColor $yellow
Write-Host "      - $failCount failures" -ForegroundColor $red
Write-HostColor "═════════════════════════════════════════════════════════════════════════`n" $blue

if ($failCount -eq 0) {
    if ($warnCount -eq 0) {
        Write-HostColor "🎉 CONGRATULATIONS! Your local Windows workstation is perfectly prepared for the workshop!`n" $green
    } else {
        Write-HostColor "⚠️  Your local Windows workstation is mostly ready. Review the warnings above before starting.`n" $yellow
    }
    exit 0
} else {
    Write-HostColor "❌ Please resolve the $failCount critical failure(s) listed above before starting the workshop.`n" $red
    exit 1
}
