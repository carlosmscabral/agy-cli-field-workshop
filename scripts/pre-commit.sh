#!/usr/bin/env bash
# Pre-commit hook: run fast offline lint checks before every commit
# Only runs: markdown lint + code block validation (fast, offline, objective)
# Translation drift is advisory — run: make check-translations
# Full check: make precommit

set -euo pipefail
cd "$(git rev-parse --show-toplevel)/engagements/agy-cli-field-workshop" 2>/dev/null || \
  cd "$(git rev-parse --show-toplevel)"

echo "🚦 Pre-commit: running fast lint checks..."

# 1. Markdown lint — fast, catches most CI failures
if command -v npx >/dev/null 2>&1; then
  npx markdownlint-cli2 "docs/**/*.md" "README.md" "AGENTS.md" "CONTRIBUTING.md" 2>&1 | tail -3
fi

# 2. Code block validation
if [ -f scripts/validate-code-blocks.sh ]; then
  bash scripts/validate-code-blocks.sh docs/ 2>&1 | tail -3
fi

echo "✅ Pre-commit checks passed"
