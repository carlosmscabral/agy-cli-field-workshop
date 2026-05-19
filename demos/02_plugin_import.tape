# VHS Demo: 02 — Plugin Import
# agy-cli Field Workshop
# Run: vhs < demos/02_plugin_import.tape

Output demos/02_plugin_import.gif

Set Shell "bash"
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Dracula"
Set Padding 20

Type "clear"
Enter

# Show empty plugin list first
Type "agy plugin list"
Enter
Sleep 2s

# Import from Gemini
Type "agy plugin import gemini"
Enter
Sleep 8s

# Show populated list
Type "agy plugin list | python3 -m json.tool"
Enter
Sleep 3s
