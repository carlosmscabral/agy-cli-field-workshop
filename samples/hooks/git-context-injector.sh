#!/usr/bin/env bash
# PreToolUse hook: Injects git context into the model's awareness
# Matcher: write_file|edit
# Performance: <100ms — single git command
#
# PURPOSE: Before any file write, inject recent git changes for the
# target file so the agent is aware of recent modifications.
# This improves context quality without burdening the model
# with irrelevant information.
#
# AGY CLI hook event: PreToolUse
# Register in: .agents/hooks.json or settings.json under "PreToolUse"
# Tool names for matcher: write_file, edit (AGY uses "edit" not "replace_in_file")

input=$(cat)
filepath=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null)

# Only inject context if the file exists and has git history
if [ -n "$filepath" ] && [ -f "$filepath" ]; then
    recent_changes=$(git log --oneline -3 -- "$filepath" 2>/dev/null | head -3)
    if [ -n "$recent_changes" ]; then
        echo "{\"systemMessage\":\"Recent changes to $filepath:\\n$recent_changes\"}"
    else
        echo '{}'
    fi
else
    echo '{}'
fi
