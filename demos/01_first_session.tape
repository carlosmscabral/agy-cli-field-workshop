# VHS Demo: 01 — First Interactive Session
# agy-cli Field Workshop
# Run: vhs < demos/01_first_session.tape

Output demos/01_first_session.gif

Set Shell "bash"
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Dracula"
Set Padding 20

# Navigate to project
Type "cd /tmp/demo-project && clear"
Enter
Sleep 500ms

# Launch agy
Type "agy"
Enter
Sleep 3s

# First prompt
Type "What does this project do? Give me a one-paragraph summary."
Enter
Sleep 8s

# Follow-up
Type "What are the top 3 files I should understand first?"
Enter
Sleep 6s

Screenshot demos/01_first_session_frame.png
