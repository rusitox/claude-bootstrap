# .claude/ Directory Architecture Reference

## Overview

The `.claude/` directory is the configuration hub for Claude Code in your project.
It controls how Claude behaves, what commands are available, and what conventions
it follows.

## Directory Structure

```
.claude/
├── commands/              # Slash commands (/project:command-name)
├── agents/                # Sub-agents with isolated context
│   ├── planner.md         # (always) Architecture planning
│   ├── code-reviewer.md   # (always) Code review
│   ├── qa.md              # (always) Testing & QA
│   ├── frontend.md        # (conditional) Frontend specialist
│   ├── backend.md         # (conditional) Backend specialist
│   ├── database.md        # (conditional) Database specialist
│   └── devops.md          # (conditional) CI/CD specialist
├── skills/                # Auto-invocable skill packages
├── rules/                 # File-pattern-specific rules
├── settings.json          # Hooks & permissions (committed)
└── settings.local.json    # Personal overrides (gitignored)
```

## Components

### Commands (`commands/`)
User-invoked workflows. Each `.md` becomes `/project:<name>`.
Frontmatter: `allowed-tools`, `description`, `disable-model-invocation`.
Use `$ARGUMENTS` for user input.

### Agents (`agents/`)
Sub-agents run in isolated context. Main agent delegates tasks to them.
Frontmatter: `name`, `description`, `tools`, `model`.

**Base agents** (always present):
- `planner` — Plans before coding. Never writes code.
- `code-reviewer` — Reviews for quality, security, performance.
- `qa` — Writes tests, generates test cases, validates coverage.

**Conditional agents** (generated based on stack):
- `frontend` — UI components, accessibility, performance, styling.
- `backend` — APIs, auth, validation, error handling, middleware.
- `database` — Schema, migrations, queries, indexes, relationships.
- `devops` — CI/CD pipelines, Docker, deploys, monitoring.

### Rules (`rules/`)
File-pattern-specific conventions. Only activate for matching globs.

### Settings (`settings.json`)

**Valid hook events:**
- `PreToolUse` — Before tool execution (can block). Matcher: tool name.
- `PostToolUse` — After tool execution (for formatting, validation).
- `Stop` — When Claude finishes responding.
- `SubagentStop` — When a subagent completes.
- `SessionStart` — On session start/resume.
- `UserPromptSubmit` — Before a prompt is processed.
- `Notification` — When Claude sends notifications.
- `PreCompact` — Before context compaction.
- `PermissionRequest` — When Claude asks for permission.

**⚠️ There is NO `PreCommit` or `PostCommit` event.**
For pre-commit checks, use `PreToolUse` with `Bash` matcher
and detect `git commit` in the command input.

**Permissions** control what Claude can do without asking:
- `allow`: Explicitly permitted tools/commands
- `deny`: Blocked tools/commands (safety net)

## Professional Development Workflow

This is how hooks and agents interact during a typical feature development cycle:

```
┌─ FASE 1: PLANIFICACIÓN (manual) ─────────────────────────┐
│  /project:plan "feature X"                                │
│  → Agente PLANNER analiza codebase, crea plan en specs/   │
│  → Aprobación humana antes de continuar                   │
└───────────────────────────────────────────────────────────┘
                          │
┌─ FASE 2: IMPLEMENTACIÓN (auto-hooks) ────────────────────┐
│  /project:implement                                       │
│  → Claude escribe código                                  │
│  → HOOK PostToolUse [Write|Edit]                          │
│    ├─ command: lint --fix (formatea automáticamente)       │
│    └─ prompt: typecheck (valida tipos, autocorrige)       │
└───────────────────────────────────────────────────────────┘
                          │
┌─ FASE 3: TESTING (automático via Stop) ──────────────────┐
│  Claude termina de implementar                            │
│  → HOOK Stop                                              │
│    ├─ command: corre test suite                           │
│    └─ agent: QA revisa archivos modificados               │
│      → ¿Tienen tests? Si no, los escribe                 │
│      → ¿Tests pasan? Si no, continue: true               │
│      → Loop automático hasta que todo pase                │
└───────────────────────────────────────────────────────────┘
                          │
┌─ FASE 4: CODE REVIEW (manual) ───────────────────────────┐
│  "revisá el código"                                       │
│  → Agente CODE-REVIEWER analiza git diff                  │
│  → Reporta: 🔴 Critical / 🟡 Warning / 🟢 Suggestion     │
│  → Claude corrige (vuelve a triggear hooks de Fase 2+3)  │
└───────────────────────────────────────────────────────────┘
                          │
┌─ FASE 5: COMMIT (gate automático) ───────────────────────┐
│  /project:commit                                          │
│  → HOOK PreToolUse [Bash → git commit]                    │
│    → Corre lint + typecheck + tests                       │
│    → Si falla → exit 2 → BLOQUEA el commit               │
│  → Si pasa → commit con conventional commit message       │
└───────────────────────────────────────────────────────────┘
                          │
┌─ FASE 6: PR (gate automático) ───────────────────────────┐
│  /project:create-pr                                       │
│  → HOOK PreToolUse [Bash → gh pr create]                  │
│    → Corre lint + typecheck + tests (safety net final)    │
│  → Genera PR description, crea PR en GitHub               │
└───────────────────────────────────────────────────────────┘
```

### Hook Cost Guide

| Hook type | Costo | Velocidad | Uso ideal |
|-----------|-------|-----------|-----------|
| `command` | Bajo | < 200ms | Lint, format, test suite, gates |
| `prompt` | Medio | ~2-5s | Decisiones rápidas (¿necesita types?) |
| `agent` | Alto | ~10-30s | QA inteligente, review con criterio |

**Regla:** Usá `command` para validación mecánica, `prompt` para
decisiones simples, `agent` solo donde necesitás criterio y herramientas.
