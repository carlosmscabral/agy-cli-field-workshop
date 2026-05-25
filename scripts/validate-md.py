#!/usr/bin/env python3
"""
validate-md.py — Comprehensive markdown validator for the AGY CLI workshop.

Checks every .md file in docs/ (recursively) for the classes of bug that
repeatedly broke the rendered workshop site:

  1. FENCES     — tagged closing fences (```bash as closer breaks all renderers)
                  opening fences with content on same line
                  unclosed code blocks
  2. TABLES     — header / separator / data column-count mismatches
                  separator row with no header row above it
  3. LINKS      — internal relative links pointing to files that don't exist
  4. BLANKS     — fenced block not preceded by a blank line (MD031)
  5. CODE       — bash blocks that fail `bash -n` (skips placeholders/prompts)
                  json blocks that fail `jq .` (skips partial snippets)

Usage:
    python3 scripts/validate-md.py [docs_dir]
    python3 scripts/validate-md.py          # defaults to docs/

Exit code: 0 = all clean, 1 = errors found.
"""

import re
import sys
import json
import pathlib
import subprocess
import tempfile

DOCS_DIR = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "docs")
ERRORS: list[str] = []
WARNINGS: list[str] = []

# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

def err(path: pathlib.Path, line: int, msg: str) -> None:
    ERRORS.append(f"  {path}:{line}  {msg}")

def warn(path: pathlib.Path, line: int, msg: str) -> None:
    WARNINGS.append(f"  {path}:{line}  {msg}")

def col_count(row: str) -> int:
    """Number of cells in a markdown table row."""
    return len([c for c in row.strip().strip("|").split("|")])

def is_separator(row: str) -> bool:
    """True only for markdown table separator rows — must start and end with pipe."""
    s = row.strip()
    if not (s.startswith("|") and s.endswith("|")):
        return False
    cells = [c.strip() for c in s.strip("|").split("|")]
    return bool(cells) and all(re.match(r"^:?-+:?$", c) for c in cells if c)

def is_table_row(row: str) -> bool:
    """True only for lines that look like markdown table rows (pipe-delimited)."""
    s = row.strip()
    return s.startswith("|") and s.endswith("|") and len(s) > 2

# ─────────────────────────────────────────────────────────────────────────────
# Per-file checks
# ─────────────────────────────────────────────────────────────────────────────

def check_fences(path: pathlib.Path, lines: list[str]) -> list[tuple[int, str, str]]:
    """
    Returns list of (start_line, lang, body) for each valid fenced block.
    Emits errors for structural fence problems.
    """
    blocks = []
    in_block = False
    current_lang = ""
    block_start = 0
    block_body: list[str] = []

    for i, raw in enumerate(lines, 1):
        line = raw.rstrip("\n")

        # Opening fence with content on the same line: ```bash some content
        if not in_block and re.match(r"^( {0,3})```\w+\s+\S", line):
            err(path, i, f"opening fence has content on same line: {line[:60]!r}")
            continue

        # Opening fence
        m_open = re.match(r"^( {0,3})```(\w+)\s*$", line)
        # Plain closing fence
        m_close = re.match(r"^( {0,3})```\s*$", line)
        # Tagged closing fence (the broken pattern)
        m_tagged_close = re.match(r"^( {0,3})```(\w+)\s*$", line)

        if not in_block:
            if m_open:
                in_block = True
                current_lang = m_open.group(2)
                block_start = i
                block_body = []
        else:
            if m_close:
                blocks.append((block_start, current_lang, "\n".join(block_body)))
                in_block = False
                current_lang = ""
                block_body = []
            elif m_tagged_close:
                err(path, i,
                    f"tagged closing fence '```{m_tagged_close.group(2)}' "
                    f"inside open '```{current_lang}' block — "
                    f"renderers only recognise plain ``` as a closer")
                # Treat as implicit close so we can continue scanning
                blocks.append((block_start, current_lang, "\n".join(block_body)))
                in_block = False
                current_lang = ""
                block_body = []
            else:
                block_body.append(raw.rstrip("\n"))

    if in_block:
        err(path, block_start, f"unclosed '```{current_lang}' block — runs to EOF")

    return blocks


def check_blank_before_fence(path: pathlib.Path, lines: list[str]) -> None:
    """MD031 — fenced block must be preceded by a blank line (or start of file)."""
    in_block = False
    for i, raw in enumerate(lines, 1):
        line = raw.rstrip("\n")
        if not in_block and re.match(r"^( {0,3})```\w*\s*$", line):
            if i > 1:
                prev = lines[i - 2].rstrip("\n")
                # Blank line, another fence line, or a heading/list marker are ok
                if prev.strip() and not re.match(r"^( {0,3})```", prev):
                    err(path, i, f"fenced block not preceded by blank line (MD031): {line!r}")
            in_block = True
        elif in_block and re.match(r"^( {0,3})```\s*$", line):
            in_block = False


def check_tables(path: pathlib.Path, lines: list[str]) -> None:
    """Table column consistency — header, separator, and all data rows must agree."""
    i = 0
    while i < len(lines):
        line = lines[i].rstrip("\n")

        if is_table_row(line) and not is_separator(line):
            # We're at a header row
            header_cols = col_count(line)
            header_line = i + 1

            # Next row must be separator
            if i + 1 < len(lines):
                sep = lines[i + 1].rstrip("\n")
                if is_separator(sep):
                    sep_cols = col_count(sep)
                    if sep_cols != header_cols:
                        err(path, i + 2,
                            f"table separator has {sep_cols} cols but header has {header_cols} "
                            f"(header: {line[:50]!r})")
                    # Check data rows
                    j = i + 2
                    while j < len(lines) and is_table_row(lines[j].rstrip("\n")):
                        data_cols = col_count(lines[j].rstrip("\n"))
                        if data_cols != header_cols:
                            err(path, j + 1,
                                f"table data row has {data_cols} cols but header has {header_cols}")
                        j += 1
                    i = j
                    continue
                elif is_table_row(sep):
                    # Two header rows with no separator — unusual but not illegal
                    pass
                else:
                    # Header with no separator — not a real table header
                    pass
        elif is_separator(line):
            # Separator with no header above
            if i == 0 or not is_table_row(lines[i - 1].rstrip("\n")):
                err(path, i + 1, f"separator row has no header row above it: {line[:60]!r}")

        i += 1


def check_internal_links(path: pathlib.Path, lines: list[str]) -> None:
    """Internal relative links must resolve to real files."""
    content = "\n".join(l.rstrip("\n") for l in lines)
    for m in re.finditer(r'\[.*?\]\(((?!https?://)[^)#\s]+\.md[^)]*)\)', content):
        ref = m.group(1).split("#")[0]
        target = (path.parent / ref).resolve()
        if not target.exists():
            line_num = content[: m.start()].count("\n") + 1
            err(path, line_num, f"broken internal link: {ref!r} → file not found")


def check_code_blocks(path: pathlib.Path, blocks: list[tuple[int, str, str]]) -> None:
    """Syntax-validate bash and json blocks."""
    for start, lang, body in blocks:
        if not body.strip():
            continue

        if lang == "bash":
            # Skip blocks with <placeholder> tokens — bash -n treats < as redirect
            if re.search(r"<[a-zA-Z][a-zA-Z0-9_-]*>", body):
                continue
            # Skip blocks that are purely interactive > prompt lines
            content_lines = [l for l in body.splitlines() if l.strip()]
            if content_lines and all(l.strip().startswith(">") for l in content_lines):
                continue
            # Skip blocks with embedded JSON-like content
            if re.search(r'^\s*"[a-z_]+"\s*:', body, re.MULTILINE):
                continue

            with tempfile.NamedTemporaryFile(mode="w", suffix=".sh", delete=False) as f:
                f.write(body)
                fname = f.name
            result = subprocess.run(["bash", "-n", fname], capture_output=True, text=True)
            pathlib.Path(fname).unlink(missing_ok=True)
            if result.returncode != 0:
                detail = result.stderr.strip().splitlines()[0] if result.stderr.strip() else ""
                err(path, start, f"bash syntax error: {detail}")

        elif lang == "json":
            # Skip partial snippets with // comments or ...
            if re.search(r"^\s*(//|\.\.\.)", body, re.MULTILINE):
                continue
            try:
                json.loads(body)
            except json.JSONDecodeError as e:
                err(path, start, f"invalid JSON: {e}")


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

def check_file(path: pathlib.Path) -> None:
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    blocks = check_fences(path, lines)
    check_blank_before_fence(path, lines)
    check_tables(path, lines)
    check_internal_links(path, lines)
    check_code_blocks(path, blocks)


md_files = sorted(DOCS_DIR.rglob("*.md"))
if not md_files:
    print(f"No .md files found in {DOCS_DIR}")
    sys.exit(0)

print(f"🔍 Validating {len(md_files)} markdown files in {DOCS_DIR}/\n")

for f in md_files:
    check_file(f)

print(f"{'─' * 60}")
if WARNINGS:
    print(f"\n⚠️  Warnings ({len(WARNINGS)}):")
    for w in WARNINGS:
        print(w)

if ERRORS:
    print(f"\n❌ Errors ({len(ERRORS)}):")
    for e in ERRORS:
        print(e)
    print(f"\n{'─' * 60}")
    print(f"FAILED — {len(ERRORS)} error(s) across {len(md_files)} files")
    sys.exit(1)
else:
    print(f"✅ ALL PASSED — {len(md_files)} files clean")
    sys.exit(0)
