# Exercise 2: Plugin Bridge

> **Duration:** 20 min | **Module:** 2 — Plugin Ecosystem

---

## Objective

Import your Gemini CLI plugin library into agy-cli, selectively enable/disable plugins, and validate a sample custom plugin.

---

## Part 1: Import from Gemini CLI (7 min)

```bash
# Check what's currently in agy
agy plugin list

# Import everything from Gemini CLI
agy plugin import gemini
```

Read the output carefully:
- Which plugins were imported?
- Which components did each plugin contribute (skills, commands, mcpServers, agents)?
- Were any skipped? Why?

```bash
# See the updated list
agy plugin list | python3 -m json.tool
```

**Question:** What plugins are now available that weren't before?

---

## Part 2: Test an Imported Plugin (5 min)

Launch agy and try a command from one of the imported plugins:

```bash
agy
```

If `code-review` was imported:
```
> /code-review Review the main entry point of this project.
```

If `gemini-deep-research` was imported:
```
> Use the deep research capability to find best practices for error handling in Node.js APIs.
```

---

## Part 3: Disable and Re-enable (3 min)

```bash
# Disable a plugin you just imported
agy plugin disable <plugin-name>

# Confirm it's disabled
agy plugin list | python3 -m json.tool

# Re-enable it
agy plugin enable <plugin-name>
```

---

## Part 4: Validate the Sample Plugin (5 min)

The workshop repo includes a sample plugin:

```bash
ls samples/plugins/workshop-helpers/

# Validate its structure
agy plugin validate samples/plugins/workshop-helpers/
```

Then intentionally break it and see what validation catches:

```bash
# Edit the manifest to remove a required field (use any text editor)
# Then re-validate
agy plugin validate samples/plugins/workshop-helpers/
```

Restore the manifest when done.

---

## Completion Criteria

- [ ] `agy plugin import gemini` ran successfully and imported at least one plugin
- [ ] Tested at least one command from an imported plugin
- [ ] Successfully disabled and re-enabled a plugin
- [ ] `agy plugin validate` returned a valid result on the sample plugin
