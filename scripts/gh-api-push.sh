#!/usr/bin/env bash
# Push a local directory to a GitHub repo via API (no git binary needed)
# Usage: ./scripts/gh-api-push.sh
set -euo pipefail

REPO="pauldatta/agy-cli-field-workshop"
BRANCH="main"
COMMIT_MSG="feat: initial agy-cli field workshop scaffold

- 4 modules: SDLC productivity, plugin ecosystem, devops automation, multi-agent
- 6 hands-on exercises (ex01-ex06)
- Cheatsheet, facilitator guide, setup guide
- 5 VHS demo tape stubs
- Makefile, check-env.sh, sample plugin"

REPO_DIR="/Users/pauldatta/Code/workshop/gemini-cli-workshop/engagements/agy-cli-field-workshop"

echo "📦 Pushing $REPO_DIR → github.com/$REPO via API..."
echo ""

# Step 1: Create blobs for each file
declare -a BLOB_SHAS
declare -a FILE_PATHS

while IFS= read -r -d '' filepath; do
  relpath="${filepath#$REPO_DIR/}"

  # Skip .git and .antigravitycli
  if [[ "$relpath" == .git/* ]] || [[ "$relpath" == .antigravitycli/* ]]; then
    continue
  fi

  echo "  📄 Uploading: $relpath"

  # Base64-encode the file content
  if file --mime-encoding "$filepath" 2>/dev/null | grep -q binary; then
    content=$(base64 -i "$filepath")
    encoding="base64"
  else
    content=$(base64 -i "$filepath")
    encoding="base64"
  fi

  # Create blob
  sha=$(gh api \
    --method POST \
    "repos/$REPO/git/blobs" \
    -f "content=$content" \
    -f "encoding=base64" \
    --jq '.sha')

  BLOB_SHAS+=("$sha")
  FILE_PATHS+=("$relpath")

done < <(find "$REPO_DIR" -type f -not -path '*/.git/*' -not -path '*/.antigravitycli/*' -print0)

echo ""
echo "  ✅ ${#BLOB_SHAS[@]} blobs created"

# Step 2: Build tree JSON
tree_json="["
for i in "${!FILE_PATHS[@]}"; do
  if [ $i -gt 0 ]; then tree_json+=","; fi
  tree_json+="{\"path\":\"${FILE_PATHS[$i]}\",\"mode\":\"100644\",\"type\":\"blob\",\"sha\":\"${BLOB_SHAS[$i]}\"}"
done
# Make scripts executable
for i in "${!FILE_PATHS[@]}"; do
  if [[ "${FILE_PATHS[$i]}" == scripts/* ]] || [[ "${FILE_PATHS[$i]}" == setup.sh ]]; then
    tree_json+=",{\"path\":\"${FILE_PATHS[$i]}\",\"mode\":\"100755\",\"type\":\"blob\",\"sha\":\"${BLOB_SHAS[$i]}\"}"
  fi
done
tree_json+="]"

echo "  🌲 Creating tree..."
TREE_SHA=$(echo "$tree_json" | gh api \
  --method POST \
  "repos/$REPO/git/trees" \
  --input - \
  --jq '.sha' 2>/dev/null || \
  gh api \
    --method POST \
    "repos/$REPO/git/trees" \
    -F "tree=$tree_json" \
    --jq '.sha')

echo "  ✅ Tree SHA: $TREE_SHA"

# Step 3: Create commit (no parent — initial commit)
echo "  💾 Creating commit..."
COMMIT_SHA=$(gh api \
  --method POST \
  "repos/$REPO/git/commits" \
  -f "message=$COMMIT_MSG" \
  -f "tree=$TREE_SHA" \
  --jq '.sha')

echo "  ✅ Commit SHA: $COMMIT_SHA"

# Step 4: Create the main branch ref
echo "  🌿 Creating branch: $BRANCH"
gh api \
  --method POST \
  "repos/$REPO/git/refs" \
  -f "ref=refs/heads/$BRANCH" \
  -f "sha=$COMMIT_SHA"

echo ""
echo "✅ Done! Pushed to https://github.com/$REPO"
