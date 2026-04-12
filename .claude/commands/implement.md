---
allowed-tools: Read, Write, Bash, Glob, Grep
description: Implement a feature or task following the project plan
---

Implement: $ARGUMENTS

1. Read the plan if it exists in `specs/`
2. Understand existing patterns in the codebase (templates, scripts, SKILL.md)
3. Implement the changes:
   - Templates go in `assets/templates/`
   - Detection logic goes in `scripts/detect-stack.sh`
   - Skill docs go in `SKILL.md` or `references/`
4. Ensure all new `{{PLACEHOLDER}}` variables are:
   - Documented in SKILL.md placeholder reference table
   - Used consistently across related templates
5. Self-review before presenting:
   - No raw `{{PLACEHOLDER}}` left without documentation
   - No invalid hook event names
   - JSON files are valid
6. Summarize what was implemented and decisions made
