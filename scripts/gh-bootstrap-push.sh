#!/usr/bin/env bash
# Bootstrap an empty GitHub repo and push files via Contents API (no git binary)
# For empty repos: use PUT /repos/{owner}/{repo}/contents/{path} for each file
set -euo pipefail

REPO="pauldatta/agy-cli-field-workshop"
REPO_DIR="/Users/pauldatta/Code/workshop/gemini-cli-workshop/engagements/agy-cli-field-workshop"

echo "📦 Bootstrapping $REPO via GitHub Contents API..."
echo ""

PASS=0
FAIL=0

while IFS= read -r -d '' filepath; do
  relpath="${filepath#$REPO_DIR/}"

  # Skip .git and .antigravitycli
  if [[ "$relpath" == .git/* ]] || [[ "$relpath" == .antigravitycli/* ]]; then
    continue
  fi

  content=$(base64 -i "$filepath" | tr -d '\n')

  response=$(gh api \
    --method PUT \
    "repos/$REPO/contents/$relpath" \
    -f "message=feat: add $relpath" \
    -f "content=$content" \
    --jq '.commit.sha' 2>&1)

  if echo "$response" | grep -qE '^[0-9a-f]{40}$'; then
    echo "  ✅ $relpath"
    PASS=$((PASS + 1))
  else
    echo "  ❌ $relpath: $response"
    FAIL=$((FAIL + 1))
  fi

done < <(find "$REPO_DIR" -type f \
  -not -path '*/.git/*' \
  -not -path '*/.antigravitycli/*' \
  -not -name 'gh-api-push.sh' \
  -not -name 'gh-bootstrap-push.sh' \
  -print0 | sort -z)

echo ""
echo "═══════════════════════════════"
echo "Results: $PASS pushed, $FAIL failed"
if [ $FAIL -eq 0 ]; then
  echo "✅ https://github.com/$REPO"
fi
