# Exercise 2: Custom Skills and Workspace Customization

> **Duration:** 20 min | **Module:** 1 — Antigravity CLI Fundamentals

---

## Objective

Create, configure, and validate a Custom Skill and a project-scoped rule locally inside your sandbox codebase to extend `agy` with custom architectural styles and conventions.

---

## Part 1: Initialize and Structure a Local Custom Skill (7 min)

By default, `agy` does not automatically create `.agents/` folder to avoid cluttering fresh repositories. Let's create it and structure our first custom skill:

1. Open your terminal and change into your sandbox directory:

   ```bash
   cd ../agy-sample-app
   ```

2. Create the `.agents/` and skills subdirectories:

   ```bash
   mkdir -p .agents/skills/project-advisor
   ```

3. Create a `SKILL.md` file under `.agents/skills/project-advisor/SKILL.md` with a text or code editor:

   ```markdown
   ---
   name: project-advisor-skill
   description: Guides refactoring and architectural layout decisions. Triggers on keywords like architecture, refactor, structure, or patterns.
   ---

   # Project Advisor Guidelines

   When suggesting code changes or architectural layout in this repository, always enforce:
   
   1. **Single Responsibility Principle**: Each class and function should do exactly one thing.
   2. **Defensive Programming**: Validate inputs at the boundary of all public methods.
   3. **No Bare Exception Catching**: Never suggest catching generic exceptions; guide the user to handle specific, expected error subclasses.
   ```

Review the file structure you have created:

* Does the `SKILL.md` have exactly three dashes `---` at the start and end of the YAML frontmatter block?
* Are the `name` and `description` keys present? (These are required for trigger matching).

---

## Part 2: Launch and Trigger Your Custom Skill (5 min)

Now launch an interactive `agy` session inside your sandbox directory and verify your custom skill has been successfully discovered:

```bash
agy
```

At the interactive prompt, type the `/skills` slash command to open the active skills registry viewer:

```text
> /skills
```

Verify that `project-advisor-skill` appears in the list as active. Press `ESC` to exit the list viewer, and trigger the skill using your keywords:

```text
> Propose a refactored version of the main file. What structural or architectural patterns should I use?
```

Notice how `agy` matches your keywords, activates the `project-advisor-skill`, and directly references your guidelines (such as Single Responsibility, Boundary Validation, and specific Error Catching) in its proposal!

---

## Part 3: Write a Project-Scoped Rule (5 min)

Beyond skills (which trigger dynamically), you can set project-wide **Rules** that are loaded unconditionally on every run.

1. Create a rules file inside your sandbox `.agents/` folder:

   ```bash
   cat > .agents/rules.md << 'EOF'
   # Project-Scope Style Rule
   
   - Always include descriptive docstrings and type hints on every class and method.
   - When generating code comments, keep them professional, concise, and focused on non-obvious code rationale.
   EOF
   ```

2. Run `agy` in your sandbox directory to ask for a code modification:

   ```text
   > Generate a new helper function that formats currency values.
   ```

Observe that the generated helper function includes descriptive docstrings, type hints, and clean comments conforming exactly to your project rule!

---

## Part 4: Validate Custom Plugin Configurations (3 min)

If you package skills, rules, and MCP servers together as a plugin, you can validate its manifest structure before distributing it:

1. Return to your workshop directory in your terminal:

   ```bash
   cd ../agy-cli-field-workshop
   ```

2. Run the built-in validator on the helper sample plugin:

   ```bash
   agy plugin validate samples/plugins/workshop-helpers/
   ```

Verify that the output displays:

```text
✔ Plugin manifest is valid
```

---

## Completion Criteria

* [ ] `.agents/skills/project-advisor/SKILL.md` exists with valid YAML frontmatter
* [ ] Active skills list contains your custom skill
* [ ] Code modifications conform to the `.agents/rules.md` style instructions
* [ ] Plugin validation command runs successfully on the workshop's helper plugin
