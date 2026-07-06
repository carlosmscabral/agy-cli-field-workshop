#!/usr/bin/env bash
# PostToolUse hook: Lightweight post-write reminder
# Matcher: write_file|edit
# Performance: <10ms — no external calls, pure string output
#
# PURPOSE: After file writes to source paths, nudge the agent
# to consider running tests. This steers behavior without
# actually running tests (which adds latency). The agent
# decides whether to act on the nudge.
#
# AGY CLI hook event: PostToolUse
# Register in: .agents/hooks.json (workspace) under "PostToolUse"
# Tool names for matcher: write_file, edit (AGY uses "edit" not "replace_in_file")

input=$(cat)
filepath=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null)

# Nudge for source files — remind the agent about tests
if echo "$filepath" | grep -qE '\.(js|ts|jsx|tsx|py|go)$'; then
    if echo "$filepath" | grep -qvE '(test|spec|__tests__)'; then
        echo "{\"systemMessage\":\"Reminder: you modified a source file. Consider running tests to verify no regressions.\"}"
    else
        echo '{}'
    fi
else
    echo '{}'
fi
