# VHS Demo: 03 — --print Pipeline
# agy-cli Field Workshop
# Run: vhs < demos/03_print_pipeline.tape

Output demos/03_print_pipeline.gif

Set Shell "bash"
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Dracula"
Set Padding 20

Type "clear"
Enter

# Pipe git diff into agy
Type "git diff --cached | agy --print \"Review these staged changes for bugs and security issues.\" --print-timeout 60s"
Enter
Sleep 10s

# Show it writing to a file
Type "agy -p \"Generate OpenAPI docs for src/api.js\" --print-timeout 90s > docs/api.yaml && echo Done"
Enter
Sleep 12s
