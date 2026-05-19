# ═══════════════════════════════════════════════════════════
# agy-cli Field Workshop — Build & Test Harness
# ═══════════════════════════════════════════════════════════
#
# Usage:
#   make serve          Start MkDocs dev server
#   make install-deps   Install Python dependencies (MkDocs)
#   make check-env      Validate participant environment
#   make test-structure Validate file structure
#   make test-links     Check for dead links (needs network)
#   make demos          Generate terminal demo GIFs (needs vhs)
#   make lint-md        Lint markdown files

.PHONY: serve install-deps check-env test-structure test-links demos lint-md help

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

# ───────────────────────────────────────────────────────────
# Deps
# ───────────────────────────────────────────────────────────

install-deps:  ## Install Python deps for MkDocs
	pip install mkdocs-material mkdocs-minify-plugin

# ───────────────────────────────────────────────────────────
# Serve
# ───────────────────────────────────────────────────────────

serve:  ## Start MkDocs dev server
	@mkdocs serve

# ───────────────────────────────────────────────────────────
# Pre-workshop environment check
# ───────────────────────────────────────────────────────────

check-env:  ## Validate participant environment
	@./scripts/check-env.sh

# ───────────────────────────────────────────────────────────
# Structure validation
# ───────────────────────────────────────────────────────────

test-structure:  ## Validate required files exist
	@echo "📋 Checking file structure..."
	@test -f README.md        || (echo "❌ Missing README.md" && exit 1)
	@echo "  ✅ README.md"
	@test -f mkdocs.yml       || (echo "❌ Missing mkdocs.yml" && exit 1)
	@echo "  ✅ mkdocs.yml"
	@test -f docs/index.md    || (echo "❌ Missing docs/index.md" && exit 1)
	@echo "  ✅ docs/index.md"
	@test -f docs/setup.md    || (echo "❌ Missing docs/setup.md" && exit 1)
	@echo "  ✅ docs/setup.md"
	@test -f scripts/check-env.sh || (echo "❌ Missing scripts/check-env.sh" && exit 1)
	@echo "  ✅ scripts/check-env.sh"
	@echo ""
	@echo "✅ Structure checks passed"

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
# Markdown lint
# ───────────────────────────────────────────────────────────

lint-md:  ## Lint markdown files
	@echo "📝 Linting markdown..."
	@npx -y markdownlint-cli2 "docs/**/*.md" "README.md" "exercises/**/*.md"
	@echo "✅ Markdown lint passed"
