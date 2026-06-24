# Environment Setup

> Complete this before starting any module. Takes ~15 minutes.

---

## System Requirements

| Component | Minimum | Notes |
| :-- | :-- | :-- |
| **agy** | Latest | Install instructions below |
| **Git** | v2.30+ | For exercise repos |
| **Terminal** | Any | iTerm2, macOS Terminal, or VS Code integrated |
| **jq** | Optional | Useful for parsing `--print` JSON output |

---

## Step 1: Install agy

> 📖 Full instructions: [Getting Started docs](https://www.antigravity.google/docs/cli-getting-started)

### macOS / Linux

```bash
curl -fsSL https://antigravity.google/cli/install.sh | bash
```

### Windows

```powershell
# PowerShell
irm https://antigravity.google/cli/install.ps1 | iex

# Or via WSL (recommended)
curl -fsSL https://antigravity.google/cli/install.sh | bash
```

After install, verify the binary is available:

```bash
# Verify the binary is in your PATH
which agy

# Confirm the version
agy --version
```

---

## Step 2: Authentication

`agy` uses **browser-based Google Sign-In**. On first run, it will:

- **Local machine:** Automatically open your default browser for sign-in.
- **SSH / remote session:** Print a URL to paste into any browser, then paste the auth code back into the terminal.

```bash
# Start agy — auth will trigger automatically on first run
agy
```

To sign out:

```text
# Run this inside an agy interactive session (not in your terminal):
/logout
```

> 📖 For enterprise authentication via GCP project, see the [Enterprise docs](https://www.antigravity.google/docs/enterprise).

Once auth is configured, run a quick smoke test:

```bash
agy --print "Say 'Workshop ready!' in exactly two words." --print-timeout 30s
```

Expected output: `Workshop ready!`

---

## Step 3: Initialize Your Project Workspace

During the workshop, we use two separate repositories to keep your configuration clean and avoid self-referencing issues:

1. **Workshop Repository**: Contains all documentation, curriculum, and exercises.
2. **Sample Application Sandbox**: The target project workspace (`agy-sample-app`) where you will run `agy`, make modifications, refactor code, and write unit tests.

### Clone the Workshop Repository

```bash
git clone https://github.com/carlosmscabral/agy-cli-field-workshop.git
cd agy-cli-field-workshop
```

### Clone the Target Sandbox Application

```bash
# Clone the sandbox into the parent directory
git clone https://github.com/carlosmscabral/agy-sample-app.git ../agy-sample-app
```

### Understanding .agents/ Folder Creation

`agy` auto-discovers workspace settings by looking for a `.agents/` folder. It does **not** auto-create this folder on a standard run to avoid cluttering fresh projects.

If you want to use local, project-scoped customizations (such as custom skills, rules, or local MCP configurations), you **must create it manually**:

```bash
# Change into your sandbox app
cd ../agy-sample-app

# Create the agents directory
mkdir -p .agents
```

---

## Step 4: Verify Everything

```bash
# Check agy is accessible
agy --help

# Quick print-mode smoke test
agy --print "What is 2 + 2?" --print-timeout 30s
```

Checklist before the workshop starts:

- [ ] `agy --help` shows flags and subcommands
- [ ] `agy --print "..."` returns a response

---

## Troubleshooting

| Issue | Solution |
| :-- | :-- |
| `agy: command not found` | Check that the binary is in your PATH. Run `echo $PATH` and ensure the install dir is included. Re-run the install script if needed |
| Auth errors / browser doesn't open | For SSH sessions, copy the printed URL manually. For local, check default browser settings. Run `/logout` and retry |
| Slow first response | First run may be slower as agy indexes your workspace |
| Config not loading | Check `~/.gemini/antigravity-cli/settings.json` (user settings) and `.agents/` (project settings) |

---

## Next Step

→ Start with **[Module 1: SDLC Productivity](sdlc-productivity.md)**
