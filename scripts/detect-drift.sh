#!/usr/bin/env bash
# detect-drift.sh — Detect documentation ↔ code drift in the AGY CLI workshop
#
# Two layers of validation:
#   1. LOCAL DRIFT:  File paths referenced in docs → do they exist?
#                   Agents/hooks in samples/ → are they mentioned in docs?
#                   settings.json hook refs → do matching scripts exist?
#   2. UPSTREAM DRIFT: AGY CLI commands used in docs → do they still exist
#                      in the official antigravity.google docs? (requires --upstream)
#
# Usage: ./scripts/detect-drift.sh [--upstream]
#   --upstream: Also check against antigravity.google/docs (requires network)
#
# Exit code: number of errors found (0 = all clean)

set -euo pipefail

CHECK_UPSTREAM=false
if [[ "${1:-}" == "--upstream" ]]; then
  CHECK_UPSTREAM=true
fi

ERRORS=0
WARNINGS=0

# Colors
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  CYAN='\033[0;36m'
  NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi

log_ok()      { echo -e "  ${GREEN}✅${NC} $*"; }
log_warn()    { echo -e "  ${YELLOW}⚠️${NC}  $*"; WARNINGS=$((WARNINGS + 1)); }
log_fail()    { echo -e "  ${RED}❌${NC} $*"; ERRORS=$((ERRORS + 1)); }
log_section() { echo -e "\n${CYAN}$*${NC}"; }

# ═══════════════════════════════════════════════════════════
# LOCAL DRIFT CHECKS
# ═══════════════════════════════════════════════════════════

log_section "🔍 Local Drift Detection"

# --- 1. File paths referenced in docs should exist ---
log_section "  Checking file path references..."

grep -rhoE '(samples|exercises)/[a-zA-Z0-9_./-]+' docs/*.md 2>/dev/null | sort -u | while read -r ref_path; do
  ref_path=$(echo "$ref_path" | sed 's/[).,;:]*$//')
  if [ -e "$ref_path" ]; then
    log_ok "Referenced path exists: $ref_path"
  elif [ -e "$(dirname "$ref_path")" ]; then
    log_warn "Path not found (parent exists): $ref_path"
  else
    log_fail "Referenced path not found: $ref_path"
  fi
done

# --- 2. Every agent in samples/agents/ should be mentioned in docs ---
log_section "  Checking agent documentation coverage..."

for agent_file in samples/agents/*.md; do
  [ -f "$agent_file" ] || continue
  agent_name=$(basename "$agent_file" .md)
  if grep -rq "$agent_name" docs/*.md 2>/dev/null; then
    log_ok "Agent '$agent_name' is documented"
  else
    log_warn "Agent '$agent_name' exists in samples/ but is not referenced in any doc"
  fi
done

# --- 3. Every hook in samples/hooks/ should be mentioned in docs ---
log_section "  Checking hook documentation coverage..."

for hook_file in samples/hooks/*.sh; do
  [ -f "$hook_file" ] || continue
  hook_name=$(basename "$hook_file" .sh)
  if grep -rq "$hook_name" docs/*.md 2>/dev/null; then
    log_ok "Hook '$hook_name' is documented"
  else
    log_warn "Hook '$hook_name' exists in samples/ but is not referenced in any doc"
  fi
done

# --- 4. Hooks referenced in settings.json should exist in samples/hooks/ ---
log_section "  Checking samples/configs/settings.json ↔ hook file alignment..."

if [ -f "samples/configs/settings.json" ]; then
  grep -oE 'hooks/[a-zA-Z0-9_-]+\.sh' samples/configs/settings.json | sort -u | while read -r hook_ref; do
    hook_basename=$(basename "$hook_ref" .sh)
    if [ -f "samples/hooks/${hook_basename}.sh" ]; then
      log_ok "settings.json hook '${hook_basename}' has matching script"
    else
      log_fail "settings.json references '${hook_ref}' but samples/hooks/${hook_basename}.sh not found"
    fi
  done
fi

# --- 5. AGY CLI hook event names — flag any Gemini CLI leftovers ---
log_section "  Checking for stale Gemini CLI hook event names..."

STALE_EVENTS=("SessionStart" "BeforeTool" "AfterTool")
AGY_EVENTS=("PreInvocation" "PreToolUse" "PostToolUse")

for stale in "${STALE_EVENTS[@]}"; do
  if grep -rq "\"${stale}\"" docs/*.md samples/ 2>/dev/null; then
    log_fail "Stale Gemini CLI hook event '${stale}' found — use AGY equivalent: PreInvocation/PreToolUse/PostToolUse"
  fi
done
log_ok "Hook event names: no stale Gemini CLI names found"

# --- 6. AGY binary references — flag any 'gemini' binary calls in docs ---
log_section "  Checking for stale 'gemini' binary references in docs..."

# Allow "gemini" as a noun (e.g., "from Gemini CLI") but flag bare 'gemini' commands
if grep -rqE '^\s*(gemini |`gemini )' docs/*.md 2>/dev/null; then
  log_warn "Found bare 'gemini' command in docs — verify these should be 'agy'"
  grep -rnoE '^\s*(gemini |`gemini )' docs/*.md 2>/dev/null | head -5
else
  log_ok "No stale 'gemini' binary references found"
fi

# --- 7. Nav entries in mkdocs.yml should have matching doc files ---
log_section "  Checking mkdocs.yml nav ↔ doc file alignment..."

if [ -f "mkdocs.yml" ]; then
  grep -E ':\s+[a-zA-Z0-9_-]+\.md\s*$' mkdocs.yml | grep -oE '[a-zA-Z0-9_-]+\.md' | sort -u | while read -r nav_file; do
    if [ -f "docs/${nav_file}" ]; then
      log_ok "Nav entry '${nav_file}' exists"
    else
      log_fail "mkdocs.yml references '${nav_file}' but docs/${nav_file} not found"
    fi
  done
fi

# ═══════════════════════════════════════════════════════════
# UPSTREAM DRIFT CHECKS (optional, needs network)
# ═══════════════════════════════════════════════════════════

if $CHECK_UPSTREAM; then
  log_section "🌐 Upstream Drift Detection (antigravity.google docs)"

  AGY_DOCS_CACHE="/tmp/agy-cli-ref-cache.html"
  CACHE_MAX_AGE=1440  # minutes (24h)

  if [ ! -f "$AGY_DOCS_CACHE" ] || [ "$(find "$AGY_DOCS_CACHE" -mmin +${CACHE_MAX_AGE} -print 2>/dev/null)" ]; then
    echo "  Fetching AGY CLI reference from antigravity.google..."
    if curl -sL "https://antigravity.google/docs/cli-overview" > "$AGY_DOCS_CACHE" 2>/dev/null; then
      log_ok "Fetched AGY CLI reference (cached for 24h)"
    else
      log_warn "Could not fetch AGY CLI reference — skipping upstream checks"
      AGY_DOCS_CACHE=""
    fi
  else
    echo "  Using cached AGY CLI reference (< 24h old)"
  fi

  if [ -n "$AGY_DOCS_CACHE" ] && [ -f "$AGY_DOCS_CACHE" ]; then
    # Check agy CLI flags used in our docs
    log_section "  Checking agy CLI flags against upstream reference..."
    grep -rhoE 'agy --[a-z-]+' docs/*.md 2>/dev/null | sed 's/agy //' | sort -u | while read -r flag; do
      if grep -qi -- "$flag" "$AGY_DOCS_CACHE"; then
        log_ok "CLI flag '$flag' found in upstream reference"
      else
        log_warn "CLI flag '$flag' used in workshop but not found in AGY CLI reference"
      fi
    done

    # Check slash commands used in our docs
    log_section "  Checking slash commands against upstream reference..."
    KNOWN_SLASH_CMDS="model agents btw clear compact fork open permissions resume rewind skills mcp usage config keybindings statusline"
    for cmd_name in $KNOWN_SLASH_CMDS; do
      if grep -rqw "/${cmd_name}" docs/*.md 2>/dev/null; then
        if grep -qi -- "$cmd_name" "$AGY_DOCS_CACHE"; then
          log_ok "Slash command '/${cmd_name}' found in upstream reference"
        else
          log_warn "Slash command '/${cmd_name}' used in workshop but not found in AGY CLI reference"
        fi
      fi
    done
  fi
else
  echo ""
  echo "  (Skipping upstream checks. Run with --upstream to enable.)"
fi

# ═══════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Errors:   $ERRORS"
echo "Warnings: $WARNINGS"

if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}DRIFT DETECTED${NC}"
  exit 1
else
  echo -e "${GREEN}ALL CLEAN${NC}"
  exit 0
fi
