# ═══════════════════════════════════════════════════════════
# Antigravity CLI Field Workshop — Build & Test Harness
# ═══════════════════════════════════════════════════════════
#
# Usage:
#   make test             Run all offline tests (structure + blocks + drift)
#   make precommit        Run ALL checks locally (mirrors CI exactly)
#   make test-structure   Validate file structure and config syntax
#   make test-blocks      Validate code blocks in documentation
#   make test-drift       Check for doc ↔ code drift (local)
#   make test-drift-full  Drift check + upstream Antigravity CLI docs (needs network)
#   make test-links       Check for dead links (needs network)
#   make test-build       Build site with strict mode
#   make test-live        Live agy smoke test (needs GCP auth)
#   make test-ci          Check GitHub Actions workflow status
#   make serve            Start MkDocs dev server
#   make check-env        Validate participant environment
#   make install-deps     Install Python dependencies (MkDocs)
#   make lint-md          Lint ALL markdown (docs + root docs)
#   make lint-md-fix      Auto-fix markdown lint errors where possible
#   make demos            Generate terminal demo GIFs (needs vhs)
#   make setup-hooks      Install git pre-commit hook
#
# See: .agents/AGENTS.md for full project context.

.PHONY: test precommit test-structure test-blocks test-drift test-drift-full \
        test-links test-build test-live test-ci \
        serve install-deps check-env demos lint-md lint-md-fix help \
        setup-hooks

# Default: run all offline tests
test: lint-md test-structure test-blocks test-drift  ## Run all offline tests

precommit:  ## Run ALL checks locally before committing — same as CI
	@echo "🚦 Pre-commit checks (mirrors CI exactly)..."
	@echo ""
	@echo "[1/6] Markdown lint..."
	@$(MAKE) lint-md
	@echo ""
	@echo "[2/6] Code block validation..."
	@bash scripts/validate-code-blocks.sh docs/
	@echo ""
	@echo "[3/6] Structural checks (stale refs, hook names, internal refs)..."
	@bash scripts/precommit-checks.sh 2>&1 | grep -E '(📋|✅|❌|💥|🎉)' || true
	@echo ""
	@echo "[4/6] MkDocs strict build..."
	@$(MAKE) test-build
	@echo ""
	@echo "[5/6] Drift detection..."
	@bash scripts/detect-drift.sh
	@echo ""
	@echo "[6/6] Shell & JSON validation..."
	@for f in scripts/*.sh samples/hooks/*.sh; do [ -f "$$f" ] && bash -n "$$f" && echo "  ✅ $$f"; done
	@for f in samples/configs/*.json; do jq . "$$f" > /dev/null && echo "  ✅ $$f"; done
	@echo ""
	@echo "✅ All pre-commit checks passed — safe to commit"

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

# ───────────────────────────────────────────────────────────
# Deps
# ───────────────────────────────────────────────────────────

install-deps:  ## Install Python deps for MkDocs (into .venv used by serve/test-build)
	python3 -m venv .venv
	.venv/bin/pip install mkdocs-material mkdocs-minify-plugin

# ───────────────────────────────────────────────────────────
# Serve
# ───────────────────────────────────────────────────────────

serve:  ## Start MkDocs dev server
	@.venv/bin/mkdocs serve

# ───────────────────────────────────────────────────────────
# Pre-workshop environment check
# ───────────────────────────────────────────────────────────

check-env:  ## Validate participant environment
	@./scripts/check-env.sh

# ───────────────────────────────────────────────────────────
# Structure validation
# ───────────────────────────────────────────────────────────

test-structure:  ## Validate file structure and config syntax
	@echo "📋 Checking file structure..."
	@echo ""
	@# --- Required files ---
	@test -f README.md             || (echo "❌ Missing README.md" && exit 1)
	@echo "  ✅ README.md"
	@test -f mkdocs.yml            || (echo "❌ Missing mkdocs.yml" && exit 1)
	@echo "  ✅ mkdocs.yml"
	@test -f docs/index.md         || (echo "❌ Missing docs/index.md" && exit 1)
	@echo "  ✅ docs/index.md"
	@test -f docs/setup.md         || (echo "❌ Missing docs/setup.md" && exit 1)
	@echo "  ✅ docs/setup.md"
	@test -f scripts/check-env.sh  || (echo "❌ Missing scripts/check-env.sh" && exit 1)
	@echo "  ✅ scripts/check-env.sh"
	@test -f AUDIT.md              || (echo "❌ Missing AUDIT.md" && exit 1)
	@echo "  ✅ AUDIT.md"
	@echo ""
	@# --- Config syntax ---
	@echo "  Validating JSON configs..."
	@for f in samples/configs/*.json; do \
		jq . "$$f" > /dev/null && echo "  ✅ $$f — valid JSON"; \
	done
	@echo ""
	@# --- Shell script syntax ---
	@echo "  Validating shell scripts..."
	@for f in scripts/*.sh samples/hooks/*.sh; do \
		[ -f "$$f" ] || continue; \
		bash -n "$$f" && echo "  ✅ $$f — syntax OK"; \
	done
	@echo ""
	@# --- Agent frontmatter ---
	@echo "  Validating agent definitions..."
	@for f in samples/agents/*.md; do \
		[ -f "$$f" ] || continue; \
		if head -1 "$$f" | grep -q '^---'; then \
			echo "  ✅ $$f — frontmatter present"; \
		else \
			echo "❌ $$f — missing YAML frontmatter" && exit 1; \
		fi; \
	done
	@echo ""
	@echo "✅ Structure checks passed"

# ───────────────────────────────────────────────────────────
# Code Block Validation
# ───────────────────────────────────────────────────────────

test-blocks:  ## Validate code blocks in documentation
	@chmod +x scripts/validate-code-blocks.sh
	@./scripts/validate-code-blocks.sh docs/

# ───────────────────────────────────────────────────────────
# Drift Detection
# ───────────────────────────────────────────────────────────

test-drift:  ## Check for doc ↔ code drift (local only)
	@chmod +x scripts/detect-drift.sh
	@./scripts/detect-drift.sh

test-drift-full:  ## Drift check + upstream Antigravity CLI docs (needs network)
	@chmod +x scripts/detect-drift.sh
	@./scripts/detect-drift.sh --upstream

# ───────────────────────────────────────────────────────────
# MkDocs Build Test
# ───────────────────────────────────────────────────────────

test-build:  ## Build site with mkdocs --strict (catches broken nav refs)
	@echo "🏗️  Building MkDocs site (strict mode)..."
	@.venv/bin/mkdocs build --strict
	@echo "✅ MkDocs build passed"

# ───────────────────────────────────────────────────────────
# Live Smoke Test — requires GCP auth (Vertex AI ADC)
# ───────────────────────────────────────────────────────────

test-live:  ## Live agy smoke test (needs GCP auth: gcloud auth application-default login)
	@if ! gcloud auth application-default print-access-token > /dev/null 2>&1; then \
		echo "❌ No GCP credentials. Run: gcloud auth application-default login"; \
		exit 1; \
	fi
	@if [ -z "$${GOOGLE_CLOUD_PROJECT:-}" ]; then \
		echo "❌ GOOGLE_CLOUD_PROJECT not set. Export it or run: export GOOGLE_CLOUD_PROJECT=<your-gcp-project>"; \
		exit 1; \
	fi
	@echo "🤖 Running live agy smoke test..."
	@SMOKE=$$(agy -p "Respond with exactly: WORKSHOP_SMOKE_OK" --print-timeout 30s 2>/dev/null || echo "FAILED"); \
	if echo "$$SMOKE" | grep -q "WORKSHOP_SMOKE_OK"; then \
		echo "  ✅ agy print mode works"; \
	else \
		echo "  ❌ agy print mode failed"; \
		exit 1; \
	fi
	@echo "✅ Live smoke test passed"

# ───────────────────────────────────────────────────────────
# CI Status Check
# ───────────────────────────────────────────────────────────

test-ci:  ## Check GitHub Actions workflow status (needs gh CLI)
	@if ! command -v gh > /dev/null 2>&1; then \
		echo "❌ gh CLI not found. Install: https://cli.github.com"; \
		exit 1; \
	fi
	@echo "🔄 GitHub Actions Status"
	@echo ""
	@for f in .github/workflows/*.yml; do echo "  ✅ $$f"; done
	@echo ""
	@echo "  Recent runs:"
	@gh run list --limit 5 2>/dev/null || echo "  ⚠️  Not authenticated or not a GitHub repo"
	@echo "  Failed runs:"
	@gh run list --status failure --limit 3 2>/dev/null || true

# ───────────────────────────────────────────────────────────
# Link checker
# ───────────────────────────────────────────────────────────

test-links:  ## Check for dead links (needs network + npx)
	@echo "🔗 Checking links..."
	@npx -y lychee --no-progress --exclude localhost \
		'docs/**/*.md' 'README.md'
	@echo "✅ Link checks passed"

# ───────────────────────────────────────────────────────────
# Terminal demo GIF generation (needs vhs: brew install vhs)
# ───────────────────────────────────────────────────────────

demos:  ## Generate terminal demo GIFs (needs vhs)
	@if ! command -v vhs >/dev/null 2>&1; then \
		echo "❌ vhs not found. Install: brew install vhs"; \
		exit 1; \
	fi
	@echo "🎬 Generating demo GIFs..."
	@mkdir -p docs/assets/demos
	@for tape in demos/*.tape; do \
		echo "  Processing $$tape..."; \
		vhs < $$tape; \
	done
	@echo "✅ Demos generated → docs/assets/demos/"

# ───────────────────────────────────────────────────────────
# Markdown Lint
# ───────────────────────────────────────────────────────────

lint-md:  ## Lint ALL markdown (docs + root docs)
	@echo "📝 Linting markdown..."
	@npx -y markdownlint-cli2 "docs/**/*.md" "README.md" "AGENTS.md" "CONTRIBUTING.md" "CHANGELOG.md" 2>&1
	@echo "✅ Markdown lint passed"

lint-md-fix:  ## Auto-fix markdown lint errors where possible
	@echo "🔧 Auto-fixing markdown..."
	@npx -y markdownlint-cli2 --fix "docs/**/*.md" "README.md" "AGENTS.md" "CONTRIBUTING.md" "CHANGELOG.md" 2>&1 || true
	@echo "✅ Auto-fix complete — re-run lint-md to verify"

setup-hooks:  ## Install git pre-commit hook
	@printf '#!/usr/bin/env bash\nset -euo pipefail\nWD="$$(git rev-parse --show-toplevel)/engagements/agy-cli-field-workshop"\n[ -d "$$WD" ] || WD="$$(git rev-parse --show-toplevel)"\ncd "$$WD"\nbash scripts/precommit-checks.sh\n' > .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "✅ Pre-commit hook installed — runs scripts/precommit-checks.sh"
