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
#   make lint-md          Lint ALL markdown (English + translated + root docs)
#   make lint-md-fix      Auto-fix markdown lint errors where possible
#   make demos            Generate terminal demo GIFs (needs vhs)
#   make setup-hooks      Install git pre-commit hook
#
# Translation pipeline:
#   make translate L=ko          Translate all docs to Korean
#   make translate-file FILE=docs/setup.md L=ko
#   make post-translate L=ko     Normalize translated files after translation
#   make translate-validate L=ko
#   make translate-drift L=ko
#   make translate-list
#
# See: .agents/AGENTS.md for full project context.

.PHONY: test precommit test-structure test-blocks test-drift test-drift-full \
        test-links test-build test-live test-ci \
        serve install-deps check-env demos lint-md lint-md-fix help \
        translate translate-file post-translate translate-validate translate-drift translate-list \
        check-translations setup-hooks

# Default: run all offline tests
test: lint-md test-structure test-blocks test-drift  ## Run all offline tests

precommit:  ## Run ALL checks locally before committing — same as CI
	@echo "🚦 Pre-commit checks (mirrors CI exactly)..."
	@echo ""
	@echo "[1/5] Markdown lint..."
	@$(MAKE) lint-md
	@echo ""
	@echo "[2/5] Code block validation..."
	@bash scripts/validate-code-blocks.sh docs/
	@echo ""
	@echo "[3/5] MkDocs strict build..."
	@$(MAKE) test-build
	@echo ""
	@echo "[4/5] Drift detection..."
	@bash scripts/detect-drift.sh
	@echo ""
	@echo "[5/5] Shell & JSON validation..."
	@for f in scripts/*.sh samples/hooks/*.sh; do [ -f "$$f" ] && bash -n "$$f" && echo "  ✅ $$f"; done
	@for f in samples/configs/*.json; do jq . "$$f" > /dev/null && echo "  ✅ $$f"; done
	@echo ""
	@echo "ℹ️  [Advisory] Translation drift check (non-blocking)..."
	@$(MAKE) check-translations
	@echo ""
	@echo "✅ All pre-commit checks passed — safe to commit"

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
	@mkdocs build --strict
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

lint-md:  ## Lint ALL markdown (English + translated + root docs)
	@echo "📝 Linting markdown..."
	@TRANSLATED_MDS=$$(find docs -mindepth 2 -name "*.md" 2>/dev/null | tr '\n' ' '); \
	npx -y markdownlint-cli2 "docs/*.md" "README.md" "AGENTS.md" "CONTRIBUTING.md" "CHANGELOG.md" "exercises/**/*.md" $$TRANSLATED_MDS 2>&1
	@echo "✅ Markdown lint passed"

lint-md-fix:  ## Auto-fix markdown lint errors where possible
	@echo "🔧 Auto-fixing markdown..."
	@TRANSLATED_MDS=$$(find docs -mindepth 2 -name "*.md" 2>/dev/null | tr '\n' ' '); \
	npx -y markdownlint-cli2 --fix "docs/*.md" "README.md" "AGENTS.md" "CONTRIBUTING.md" "CHANGELOG.md" "exercises/**/*.md" $$TRANSLATED_MDS 2>&1 || true
	@echo "  🔧 Fixing MD022 blank-lines-around-headings in translated files..."
	@find docs -mindepth 2 -name "*.md" 2>/dev/null | while read f; do \
		perl -i -0pe 's/(\S)\n(##\s)/$$1\n\n$$2/g' "$$f"; \
	done
	@echo "  🔧 Normalizing table separators..."
	@find docs -mindepth 2 -name "*.md" 2>/dev/null | while read f; do \
		perl -i -pe 'if (/^\|[-:| ]+\|$$/) { s/\|\s*:?-+:?\s*/| :-- /g; s/ $$//; s/\| :-- $$/|/; }' "$$f"; \
	done
	@echo "✅ Auto-fix complete — re-run lint-md to verify"

setup-hooks:  ## Install git pre-commit hook
	@cp scripts/pre-commit.sh .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "✅ Pre-commit hook installed"

# ───────────────────────────────────────────────────────────
# Translation Pipeline (Vertex AI / gemini-3.1-pro-preview)
# ───────────────────────────────────────────────────────────
# Requires:
#   gcloud auth application-default login
#   export GOOGLE_CLOUD_PROJECT=gpu-launchpad-playground
# Pipeline source: tools/i18n/ in gemini-cli-field-workshop
# Run from: engagements/gemini-cli-field-workshop/
#
# Usage: make translate L=ko
#        make translate L=ko P=8   (8 parallel workers)
#        make translate-file FILE=docs/setup.md L=ko
#        make translate-validate L=ko
#        make translate-drift L=ko
#        make translate-list

P ?= 6
AGY_TRANSLATE_SCRIPT := ../gemini-cli-field-workshop/tools/i18n/translate.py
AGY_VENV_PYTHON := ../gemini-cli-field-workshop/.venv/bin/python
AGY_TRANSLATE_ENV := GOOGLE_CLOUD_PROJECT=$${GOOGLE_CLOUD_PROJECT} GOOGLE_CLOUD_LOCATION=global AGY_REPO_ROOT=$(PWD)

translate-list:  ## Show available languages and translation status
	@echo "🌐 Antigravity CLI Field Workshop — Translation Status"
	@echo ""
	@LANGS=$$(find docs -mindepth 1 -maxdepth 1 -type d 2>/dev/null | xargs -I{} basename {} | sort); \
	if [ -z "$$LANGS" ]; then \
		echo "  ⬚  No translated languages found under docs/"; \
	else \
		for lang in $$LANGS; do \
			count=$$(ls docs/$$lang/*.md 2>/dev/null | wc -l | tr -d ' '); \
			if [ "$$count" -gt 0 ]; then \
				echo "  ✅ $$lang — $$count translated files"; \
			else \
				echo "  ⬚  $$lang — no translations yet"; \
			fi; \
		done; \
	fi
	@echo ""
	@echo "  Run: make translate L=ko"

check-translations:  ## Report translation drift and missing files (advisory, non-blocking, no GCP needed)
	@echo "🌐 Translation status check..."
	@echo ""
	@LANGS=$$(find docs -mindepth 1 -maxdepth 1 -type d 2>/dev/null | xargs -I{} basename {} | sort); \
	if [ -z "$$LANGS" ]; then \
		echo "  ℹ️  No translated languages found under docs/"; \
	else \
		for lang in $$LANGS; do \
			echo "  📖 $$lang:"; \
			for src in docs/*.md; do \
				base=$$(basename $$src); \
				target="docs/$$lang/$$base"; \
				if [ ! -f "$$target" ]; then \
					echo "    ⬚  missing  → make translate-file FILE=$$src L=$$lang"; \
				elif [ "$$src" -nt "$$target" ]; then \
					echo "    ⚠️   stale    → make translate-file FILE=$$src L=$$lang"; \
				else \
					echo "    ✅  up to date  $$target"; \
				fi; \
			done; \
			echo ""; \
		done; \
	fi
	@echo "ℹ️  To add a new language: create docs/<lang>/ and run: make translate L=<lang>"
	@echo "ℹ️  This check is advisory — translations are not required to commit."

_check-translate-env:
	@if [ -z "$${GOOGLE_CLOUD_PROJECT:-}" ]; then \
		echo "❌ Set GOOGLE_CLOUD_PROJECT first (e.g. export GOOGLE_CLOUD_PROJECT=<your-gcp-project>)"; \
		exit 1; \
	fi
	@if [ -z "$(L)" ]; then echo "❌ Specify L=ko|zh|id" && exit 1; fi
	@if [ ! -f "$(AGY_VENV_PYTHON)" ]; then \
		echo "❌ Translation venv not found at $(AGY_VENV_PYTHON)"; \
		echo "   Run: cd ../gemini-cli-field-workshop && uv pip install google-genai --index-url https://pypi.org/simple/"; \
		exit 1; \
	fi

translate: _check-translate-env  ## Translate all docs to target language (L=ko|zh|id)
	@echo "🌐 Translating all Antigravity CLI docs → $(L)..."
	@for doc in docs/setup.md docs/sdlc-productivity.md docs/plugin-ecosystem.md \
	            docs/devops-automation.md docs/multi-agent-advanced.md \
	            docs/cheatsheet.md docs/facilitator-guide.md docs/migration-guide.md; do \
		[ -f "$$doc" ] || continue; \
		$(AGY_TRANSLATE_ENV) $(AGY_VENV_PYTHON) $(AGY_TRANSLATE_SCRIPT) \
			$$doc --lang $(L) --parallel $(P) --model gemini-3.1-pro-preview; \
	done
	@echo "  ℹ️  Run: make post-translate L=$(L)  to normalize lint"

translate-file: _check-translate-env  ## Translate one file (FILE=docs/setup.md L=ko)
	@test -n "$(FILE)" || (echo "❌ Specify FILE=docs/setup.md" && exit 1)
	$(AGY_TRANSLATE_ENV) $(AGY_VENV_PYTHON) $(AGY_TRANSLATE_SCRIPT) \
		$(FILE) --lang $(L) --parallel $(P) --model gemini-3.1-pro-preview
	@echo "  ℹ️  Run: make post-translate L=$(L)  to normalize lint"

post-translate:  ## Normalize translated files after translation (run after make translate)
	@echo "🔧 Post-translation normalization for $(L)..."
	@if [ -z "$(L)" ]; then echo "❌ Specify L=ko|zh|id" && exit 1; fi
	@echo "  Step 1/3: markdownlint auto-fix..."
	@npx -y markdownlint-cli2 --fix "docs/$(L)/**/*.md" 2>&1 || true
	@echo "  Step 2/3: Fix MD022 (blank line before headings)..."
	@find docs/$(L) -name "*.md" | while read f; do \
		perl -i -0pe 's/(\S)\n(##\s)/$$1\n\n$$2/g' "$$f"; \
	done
	@echo "  Step 3/3: Normalize table separators..."
	@find docs/$(L) -name "*.md" | while read f; do \
		perl -i -pe 'if (/^\|[-:| ]+\|$$/) { s/\|\s*:?-+:?\s*/| :-- /g; s/ $$//; s/\| :-- $$/|/; }' "$$f"; \
	done
	@echo "  Verifying..."
	@npx markdownlint-cli2 "docs/$(L)/**/*.md" 2>&1 | grep -E "Summary|error" | tail -3
	@echo "✅ Post-translate normalization complete for $(L)"

translate-validate: _check-translate-env  ## Validate translation completeness (L=ko)
	@echo "✅ Checking $(L) translation coverage..."
	@for doc in docs/*.md; do \
		base=$$(basename $$doc); \
		if [ ! -f "docs/$(L)/$$base" ]; then \
			echo "  ⬚  docs/$(L)/$$base — not yet translated"; \
		else \
			echo "  ✅ docs/$(L)/$$base"; \
		fi; \
	done

translate-drift: _check-translate-env  ## Show docs changed since last translation (L=ko)
	@echo "🔍 Checking translation drift for $(L)..."
	@for doc in docs/*.md; do \
		base=$$(basename $$doc); \
		target="docs/$(L)/$$base"; \
		[ -f "$$target" ] || continue; \
		if [ "$$doc" -nt "$$target" ]; then \
			echo "  ⚠️  $$doc is newer than $$target — re-translate: make translate-file FILE=$$doc L=$(L)"; \
		else \
			echo "  ✅ $$target up to date"; \
		fi; \
	done
