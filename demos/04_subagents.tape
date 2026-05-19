# VHS Demo: 04 — Subagents
# agy-cli Field Workshop
# Run: vhs < demos/04_subagents.tape

Output demos/04_subagents.gif

Set Shell "bash"
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Dracula"
Set Padding 20

Type "clear"
Enter
Type "agy"
Enter
Sleep 2s

# Spawn parallel subagents
Type "Spawn two subagents in parallel (branch mode): (1) security auditor — scan for hardcoded credentials and injection risks, (2) coverage auditor — find untested functions. Report back when both complete."
Enter
Sleep 20s
