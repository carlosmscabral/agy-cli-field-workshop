# VHS Demo: 05 — /btw Mid-Task Steering
# agy-cli Field Workshop
# Run: vhs < demos/05_btw.tape

Output demos/05_btw.gif

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

# Start a long-running task
Type "Refactor the error handling across this entire project to use a consistent pattern. Start with analysis — don't write any files yet."
Enter
Sleep 5s

# Mid-task injection
Type "/btw Only touch files in the backend/ directory. Skip frontend for now."
Enter
Sleep 3s

Type "/btw Use a custom Error class hierarchy, not just raw Error objects."
Enter
Sleep 6s
