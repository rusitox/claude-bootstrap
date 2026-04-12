# claude-bootstrap

A Claude Code skill that scaffolds a complete, production-ready `.claude/` directory structure for any project. Auto-detects the tech stack and generates commands, agents, rules, hooks, settings, and CLAUDE.md.

## Stack

- **Language**: Bash / Markdown
- **Framework**: Claude Code skill
- **Package Manager**: —
- **Linter**: —
- **Testing**: —

## Project Structure

```
assets/templates/       # File templates with {{PLACEHOLDER}} variables
  agents/               # Agent templates (planner, code-reviewer, qa, frontend, backend, database, devops)
  commands/             # Slash command templates (12 standard)
  rules/                # Rule templates (typescript, react-components, python)
  settings.json.template
  settings.local.json.template
  CLAUDE.md.template
scripts/
  detect-stack.sh       # Detects tech stack, outputs JSON profile
references/
  ARCHITECTURE.md       # Workflow diagrams and design decisions
SKILL.md                # Full skill specification and placeholder reference
```

## Key Commands

```bash
bash scripts/detect-stack.sh   # Run stack detection (from target project dir)
```

## Conventions

- All template variables use `{{UPPER_SNAKE_CASE}}` format
- Every placeholder must be documented in the SKILL.md placeholder reference table
- Valid hook events: `PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`, `Notification`, `SessionStart`, `UserPromptSubmit`, `PreCompact`, `PermissionRequest`
- Never use `PreCommit` or `PostCommit` — these events do not exist in Claude Code

## Key Files

- `SKILL.md` — Full specification, placeholder table, workflow steps
- `scripts/detect-stack.sh` — Stack detection logic
- `assets/templates/settings.json.template` — Hook architecture
- `references/ARCHITECTURE.md` — Design decisions
