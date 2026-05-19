# Environment Setup

> Complete this before starting any module. Takes ~15 minutes.

---

## System Requirements

| Component | Minimum | Notes |
|---|---|---|
| **agy-cli** | Latest | Install instructions below |
| **Git** | v2.30+ | For exercise repos |
| **Terminal** | Any | iTerm2, macOS Terminal, or VS Code integrated |
| **jq** | Optional | Useful for parsing `--print` JSON output |

---

## Step 1: Install agy-cli

<!-- TODO: confirm official install path post-Google I/O -->

agy-cli is distributed as a single binary. Ask your facilitator for the download link or internal distribution channel.

```bash
# Verify the binary is in your PATH
which agy

# Confirm the version
agy changelog
```

!!! tip "Shell Alias"
    agy-cli is also available as `agy-cli` via a shell alias. Both `agy` and `agy-cli` invoke the same binary.

---

## Step 2: Authentication

<!-- TODO: confirm auth flow post-Google I/O. Current working assumption: ADC or API key. -->

!!! warning "Auth Details Pending"
    Authentication details will be confirmed after Google I/O. Your facilitator will provide credentials for this workshop session.

Once auth is configured, run a quick smoke test:

```bash
agy --print "Say 'Workshop ready!' in exactly two words." --print-timeout 30s
```

Expected output: `Workshop ready!`

---

## Step 3: Initialize Your Project Workspace

agy-cli auto-discovers project config by walking up from your current directory, looking for a `.antigravitycli/` folder. Create one for the workshop:

```bash
# Clone the workshop exercises repo
git clone https://github.com/pauldatta/agy-cli-field-workshop.git
cd agy-cli-field-workshop

# agy will create .antigravitycli/ on first run
agy --print "List the files in the current directory."
```

You'll see a `.antigravitycli/` folder created with a project config JSON.

!!! info ".gemini/ compatibility"
    agy-cli also reads `.gemini/` directories — useful if you already have a Gemini CLI project setup. Both config locations are respected.

---

## Step 4: Verify Everything

```bash
# Check agy is accessible
agy --help

# Confirm plugins are available
agy plugin list

# Quick print-mode smoke test
agy --print "What is 2 + 2?" --print-timeout 30s
```

Checklist before the workshop starts:

- [ ] `agy --help` shows flags and subcommands
- [ ] `agy plugin list` returns JSON without errors
- [ ] `agy --print "..."` returns a response

---

## Troubleshooting

| Issue | Solution |
|---|---|
| `agy: command not found` | Check that the binary is in your PATH. Run `echo $PATH` and ensure the install dir is included |
| Auth errors | Contact your facilitator — auth details are session-specific |
| `agy plugin list` returns empty `{}` | Expected on a fresh install. You'll populate plugins in Module 2 |
| Slow first response | First run may be slower as agy indexes your workspace |

---

## Next Step

→ Start with **[Module 1: SDLC Productivity](sdlc-productivity.md)**
