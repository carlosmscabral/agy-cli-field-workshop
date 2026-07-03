#!/usr/bin/env bash
# agy-cli Field Workshop — Environment Check
# Run this before the workshop starts: make check-env

set -euo pipefail

PASS=0
FAIL=0

check() {
  local label="$1"
  local cmd="$2"
  if eval "$cmd" &>/dev/null; then
    echo "  ✅ $label"
    PASS=$((PASS + 1))
  else
    echo "  ❌ $label"
    FAIL=$((FAIL + 1))
  fi
}

echo ""
echo "🔍 agy-cli Field Workshop — Environment Check"
echo "══════════════════════════════════════════════"
echo ""

echo "Core tools:"
check "agy-cli installed" "command -v agy"
check "git available" "command -v git && git --version | grep -q 'git version'"
check "jq available (optional)" "command -v jq"
echo ""

echo "agy-cli:"
check "agy --help responds" "agy --help 2>&1 | grep -q 'print'"
  check "agy plugin list runs" "agy plugin list"
echo ""

echo "Print mode smoke test:"
SMOKE=$(agy --print "Respond with exactly: WORKSHOP_READY" --print-timeout 30s 2>/dev/null || echo "FAILED")
if echo "$SMOKE" | grep -q "WORKSHOP_READY"; then
  echo "  ✅ agy --print mode works (got response)"
  PASS=$((PASS + 1))
else
  echo "  ❌ agy --print mode failed or auth not configured"
  echo "     Response: $SMOKE"
  FAIL=$((FAIL + 1))
fi
echo ""

echo "Optional tools for facilitators:"
check "vhs installed (demo generation)" "command -v vhs"
check "asciinema installed (session recording)" "command -v asciinema"
check "mkdocs installed (doc server)" "command -v mkdocs"
echo ""

echo "══════════════════════════════════════════════"
echo "Results: $PASS passed, $FAIL failed"
echo ""

if [ $FAIL -eq 0 ]; then
  echo "✅ All checks passed. Ready for the workshop!"
elif [ $FAIL -le 2 ] && ! agy --help 2>&1 | grep -q 'print'; then
  echo "❌ Critical failure: agy-cli is not working. Contact your facilitator."
  exit 1
else
  echo "⚠️  Some optional checks failed. Workshop can proceed — contact facilitator if agy --print failed."
fi
echo ""
