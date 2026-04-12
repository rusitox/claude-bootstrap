---
name: claude-bootstrap
description: >
  Initialize and scaffold the complete .claude/ directory structure for a project.
  Auto-detects the tech stack and creates commands, agents, skills, rules, hooks,
  settings, and CLAUDE.md. Use this skill whenever entering a project that is missing
  a .claude/ folder, when the user mentions "bootstrap", "init claude", "setup claude
  code", "scaffold claude", or when setting up a new project for agentic development.
  Also trigger when the user asks about configuring Claude Code for their project,
  wants to standardize their team's Claude setup, or mentions that .claude/ is missing.
  Make sure to use this skill even if the user just says "initialize this project"
  or "set up claude here" or "prepare this repo for claude code".
allowed-tools: Read, Write, Bash, Glob, Grep
---

# Claude Bootstrap Skill v2

> Scaffold a complete, production-ready `.claude/` structure for any project.
> Now with conditional specialized agents and corrected hook events.

## When to Trigger

- The project has NO `.claude/` directory
- The project has a partial `.claude/` setup (missing commands, agents, or skills)
- The user explicitly asks to bootstrap/init/setup Claude Code configuration

## Step 1: Detect the Project Stack

Run the detection script to build a JSON profile:

```bash
bash <skill-path>/scripts/detect-stack.sh
```

This outputs a JSON object with: project_name, language, package_manager,
framework, database, linter, test_framework, all commands, and flags for
existing .claude/ structure.

**Additional detection for conditional agents:**

```bash
# Frontend detection
ls src/components/ 2>/dev/null || ls app/components/ 2>/dev/null
grep -rl "useState\|useEffect\|React\|vue\|svelte" src/ 2>/dev/null | head -3

# Backend detection
ls src/routes/ 2>/dev/null || ls src/api/ 2>/dev/null || ls app/api/ 2>/dev/null
grep -rl "express\|fastify\|fastapi\|django\|flask\|NestFactory" src/ 2>/dev/null | head -3

# Database detection
ls prisma/ 2>/dev/null || ls drizzle/ 2>/dev/null || ls migrations/ 2>/dev/null
grep -rl "schema\|migration\|sequelize\|typeorm\|drizzle\|prisma" src/ 2>/dev/null | head -3

# DevOps detection
ls .github/workflows/ 2>/dev/null
ls Dockerfile 2>/dev/null || ls docker-compose.yml 2>/dev/null
ls .gitlab-ci.yml 2>/dev/null || ls Jenkinsfile 2>/dev/null
ls terraform/ 2>/dev/null || ls infrastructure/ 2>/dev/null
```

## Step 2: Interactive Confirmation

Present the detected profile AND proposed agents:

```
📋 Stack detectado:

  Lenguaje:        TypeScript
  Package Manager: pnpm
  Framework:       React Native (Expo)
  Base de Datos:   -
  Linter:          ESLint
  Testing:         Jest

🤖 Agentes propuestos:

  ✅ planner        — Arquitectura y planificación (siempre)
  ✅ code-reviewer  — Revisión de código y calidad (siempre)
  ✅ qa             — Testing, QA y validación (siempre)
  ✅ frontend       — Especialista React Native/Expo (detectado)
  ⬚ backend        — No detectado
  ⬚ database       — No detectado
  ⬚ devops         — No detectado

¿Es correcto? ¿Querés agregar o quitar algún agente?
```

Also ask these questions if not obvious from detection:

1. **Build command**: What command builds the project?
2. **Lint command**: What command lints?
3. **Test command**: What command runs tests?
4. **Type check command**: (e.g., `npx tsc --noEmit`)
5. **Key files**: Most important files Claude should read first?
6. **GitHub Issues integration**: Should the QA agent automatically create GitHub Issues
   when it finds bugs or failing tests that can't be auto-fixed?
   Detect with: `gh auth status 2>/dev/null && gh repo view 2>/dev/null`
   — suggest `true` only if both commands succeed (authenticated + inside a GitHub repo).
   Show in the confirmation screen as:
   `✅ github-issues  — QA crea issues automáticamente (detectado)` or
   `⬚ github-issues  — gh no autenticado o no es repo GitHub`

## Step 3: Create the Directory Structure

Create the complete `.claude/` scaffold:

```
.claude/
├── commands/          # Slash commands (12 standard + custom)
│   ├── prime.md
│   ├── plan.md
│   ├── implement.md
│   ├── validate.md
│   ├── commit.md
│   ├── create-pr.md
│   ├── review-pr.md
│   ├── prd.md
│   ├── rca.md
│   ├── check-ignores.md
│   ├── create-command.md
│   └── create-rules.md
│
├── agents/            # Base + conditional agents
│   ├── planner.md         # (always)
│   ├── code-reviewer.md   # (always)
│   ├── qa.md              # (always)
│   ├── frontend.md        # (if frontend detected)
│   ├── backend.md         # (if backend detected)
│   ├── database.md        # (if database detected)
│   └── devops.md          # (if CI/CD detected)
│
├── rules/             # File-pattern-specific rules
│   ├── typescript.md  # (if TypeScript)
│   └── components.md  # (if React/Vue/Svelte)
│
├── settings.json      # Hooks and permissions
└── settings.local.json # Personal overrides (gitignored)
```

## Step 4: Generate Files Using Templates

Read template files from `assets/templates/` and customize based on stack profile.

### Placeholder Reference

| Placeholder | Example |
|---|---|
| `{{PACKAGE_MANAGER}}` | bun, pnpm, npm, yarn |
| `{{LINT_COMMAND}}` | pnpm run lint |
| `{{LINT_FIX_COMMAND}}` | pnpm run lint --fix |
| `{{BUILD_COMMAND}}` | pnpm run build |
| `{{TEST_COMMAND}}` | pnpm run test |
| `{{TYPECHECK_COMMAND}}` | npx tsc --noEmit |
| `{{FRAMEWORK}}` | Next.js, React Native, FastAPI |
| `{{LANGUAGE}}` | TypeScript, Python |
| `{{KEY_FILES}}` | list of important files |
| `{{PROJECT_NAME}}` | from package.json or directory |
| `{{PROJECT_DESCRIPTION}}` | from package.json or ask user |
| `{{GITHUB_ISSUES_ENABLED}}` | true / false — whether QA agent creates GitHub Issues |
| `{{GITHUB_ISSUES_SECTION}}` | Full GitHub Issues section for qa.md, or empty string |

### Agent Generation Logic

**Always generate:**
- `planner.md` from `agents/planner.md.template`
- `code-reviewer.md` from `agents/code-reviewer.md.template`
- `qa.md` from `agents/qa.md.template`

**Conditionally generate:**
- `frontend.md` — IF framework is React/React Native/Next.js/Vue/Svelte/Angular
  - Customize system prompt with specific framework name and patterns
- `backend.md` — IF framework is Express/Fastify/NestJS/FastAPI/Django/Flask
  - Customize with specific API patterns and middleware stack
- `database.md` — IF Prisma/Drizzle/TypeORM/Sequelize/SQLAlchemy detected
  - Customize with specific ORM commands and migration patterns
- `devops.md` — IF .github/workflows/ or Dockerfile or CI config detected
  - Customize with specific CI platform (GitHub Actions, GitLab CI, etc.)

### GitHub Issues Section Generation

Replace `{{GITHUB_ISSUES_SECTION}}` in `qa.md`:

- **If `GITHUB_ISSUES_ENABLED` is `true`**: replace with the following block verbatim:

```markdown
## GitHub Issues

When you find real issues during QA, create GitHub Issues to track them.

### When to create an issue
- Tests are failing and cannot be auto-fixed in this session
- A bug is discovered during code review
- Critical paths (auth, payments, data) are missing tests (>20% below the minimum standard)
- A flaky test is identified that needs investigation

### When NOT to create an issue
- Issues you already fixed in this session
- Minor coverage improvements on non-critical paths
- Warnings that don't affect functionality
- Issues that already exist in GitHub — always check first

### How to create issues

1. **Check for duplicates first:**
```bash
gh issue list --label qa --state open --limit 20
```

2. **Create the issue:**
```bash
gh issue create \
  --title "[QA] <concise description>" \
  --body "## Description\n\n<what was found>\n\n## Files Affected\n\n<list>\n\n## Steps to Reproduce\n\n<if applicable>\n\n## Expected Behavior\n\n<what should happen>" \
  --label "qa"
```

3. **Save to memory** the issue number and description to avoid duplicates in future sessions.
```

- **If `GITHUB_ISSUES_ENABLED` is `false`**: replace `{{GITHUB_ISSUES_SECTION}}` with an empty string.

### settings.json Generation

**IMPORTANT**: Use correct Claude Code hook event names. There is NO `PreCommit`
or `PostCommit` event. Valid events are: PreToolUse, PostToolUse, Stop,
SubagentStop, Notification, SessionStart, UserPromptSubmit, PreCompact,
PermissionRequest.

The settings.json implements a **professional development workflow** with 3 layers:

**Layer 1 — PostToolUse (every file edit):**
- `command`: Auto-fix lint on save (fast, deterministic)
- `prompt`: Typecheck validation (model decides if fix needed)

**Layer 2 — Stop (when Claude finishes responding):**
- `command`: Run test suite (fast, catches regressions)
- `agent`: QA agent reviews modified files, writes missing tests,
  returns `continue: true` if tests fail → auto-correction loop

**Layer 3 — PreToolUse (commit/PR gates):**
- `command`: Full validation (lint + typecheck + tests) before `git commit`
- `command`: Same full validation before `gh pr create`
- Exit code 2 = BLOCK the action. No way to skip.

Read the full template from `assets/templates/settings.json.template`.

See `references/ARCHITECTURE.md` for the complete workflow diagram.

## Step 5: Generate CLAUDE.md

If no CLAUDE.md exists at the project root, generate one from
`assets/templates/CLAUDE.md.template`. The template has two parts:
- **Top**: project-specific section with `{{PLACEHOLDERS}}` (stack, commands, key files)
- **Bottom**: hardcoded behavioral guidelines (Think Before Coding, Simplicity First,
  Surgical Changes, Goal-Driven Execution) — these are universal and stay verbatim.

## Step 6: Update .gitignore

Ensure `.gitignore` includes:
```
.claude/settings.local.json
```

## Step 7: Summary

```
✅ Claude Code bootstrap completo!

📁 Estructura creada:
   .claude/commands/     → 12 slash commands
   .claude/agents/       → N agentes (base + especializados)
   .claude/rules/        → N reglas de proyecto
   .claude/settings.json → Hooks y permisos configurados
   CLAUDE.md             → Contexto del proyecto

🤖 Agentes activos:
   planner         — Planificación y arquitectura
   code-reviewer   — Revisión de código
   qa              — Testing y validación
   [frontend]      — Especialista [framework]
   [backend]       — Especialista [framework]
   [database]      — Especialista [ORM]
   [devops]        — CI/CD y deploy

🚀 Para empezar:
   /project:prime        → Cargar contexto
   /project:plan         → Planificar una feature
   /project:implement    → Implementar
   /project:validate     → Verificar calidad
```
