# claude-bootstrap — Skill para Claude Code

Skill auto-invocable para Claude Code que detecta el stack de un proyecto y
scaffoldea una configuración `.claude/` completa y lista para producción.

## ¿Qué genera?

| Categoría | Contenido |
|---|---|
| **14 slash commands** | prime, prd, design, plan, implement, validate, commit, create-pr, review-pr, rca, check-ignores, create-command, create-rules, upgrade |
| **3 agentes base** | planner, code-reviewer, qa (siempre presentes) |
| **5 agentes condicionales** | frontend, design, backend, database, devops |
| **Rules** | typescript, react-components, python (según stack) |
| **settings.json** | Hooks en 3 capas + permisos |
| **CLAUDE.md** | Contexto del proyecto + guías de comportamiento |

## Flujo de desarrollo generado

```
/prd "feature"        → Crea specs/sdd-[feature].md (secciones 1-2: requisitos)
/design "feature"     → Agrega sección 3 al SDD (UX/UI, design system, a11y)
/plan "feature"       → Agrega secciones 4-5 al SDD (arquitectura + plan)
/implement "feature"  → Lee el SDD y ejecuta la implementación
/validate             → Lint + types + build + tests
/commit               → Gate automático antes de commitear
/create-pr            → Gate automático + PR con descripción estructurada
```

Cada feature tiene un único `specs/sdd-[feature].md` como fuente de verdad.

## Hook architecture

| Capa | Evento | Qué hace |
|---|---|---|
| 1 | `PostToolUse` | Auto-lint al guardar archivos |
| 2 | `Stop` | Corre tests + agente QA revisa cobertura |
| 3 | `PreToolUse` | Bloquea `git commit` y `gh pr create` si no pasan lint+types+tests |

## Instalación

```bash
# Clonar o descargar el skill
git clone https://github.com/rusitox/claude-bootstrap.git

# Copiar al directorio global de skills de Claude Code
cp -r claude-bootstrap ~/.claude/skills/claude-bootstrap
```

A partir de ahí Claude Code lo invoca automáticamente cuando detecta un proyecto
sin `.claude/`, o cuando le pedís "bootstrap this project", "init claude", etc.

## Uso en un proyecto nuevo

Abrí Claude Code en tu proyecto y escribí:

```
bootstrap this project
```

El skill va a:
1. Detectar el stack automáticamente
2. Mostrar los agentes propuestos y preguntar confirmación
3. Hacer preguntas sobre comandos y GitHub Issues integration
4. Generar toda la estructura `.claude/`

## Actualizar un proyecto existente

Si ya tenés un proyecto bootstrapeado con una versión anterior:

```
/project:upgrade
```

El comando `/upgrade` detecta qué cambió, muestra un plan de lo que va a
actualizar, pide confirmación, y aplica los cambios. **Nunca modifica
`.claude/agent-memory/`** — la memoria acumulada de los agentes queda intacta.

Para proyectos que no tienen el comando `/upgrade` todavía, invocar el skill
directamente: Claude detecta el `.claude/` existente y ofrece el modo upgrade.

## Actualizar el skill

```bash
cd ~/.claude/skills/claude-bootstrap
git pull
```

Los proyectos existentes siguen usando los archivos generados hasta que
corrás `/project:upgrade` en cada uno.

## Estructura del skill

```
claude-bootstrap/
├── SKILL.md                          ← Definición principal del skill
├── scripts/
│   └── detect-stack.sh               ← Detecta lenguaje, framework, tools
├── references/
│   └── ARCHITECTURE.md               ← Arquitectura y decisiones de diseño
└── assets/templates/
    ├── CLAUDE.md.template             ← Stack info + guías de comportamiento
    ├── settings.json.template         ← Hooks y permisos
    ├── settings.local.json.template   ← Overrides personales (gitignoreado)
    ├── commands/                      ← 14 slash commands
    │   ├── prime.md.template          ← Carga contexto + lista SDDs activos
    │   ├── prd.md.template            ← Crea SDD + secciones 1-2
    │   ├── design.md.template         ← Agrega sección 3 al SDD
    │   ├── plan.md.template           ← Agrega secciones 4-5 al SDD
    │   ├── implement.md.template      ← Implementa siguiendo el SDD
    │   ├── validate.md.template       ← Lint + types + build + tests
    │   ├── commit.md.template         ← Conventional commit
    │   ├── create-pr.md.template      ← PR estructurado
    │   ├── review-pr.md.template      ← Code review
    │   ├── rca.md.template            ← Root cause analysis
    │   ├── check-ignores.md.template  ← Verifica .gitignore
    │   ├── create-command.md.template ← Crea nuevo slash command
    │   ├── create-rules.md.template   ← Crea nueva rule
    │   └── upgrade.md.template        ← Actualiza .claude/ preservando memoria
    ├── agents/
    │   ├── planner.md.template        ← (siempre) Arquitectura y planificación
    │   ├── code-reviewer.md.template  ← (siempre) Revisión de código
    │   ├── qa.md.template             ← (siempre) Testing + GitHub Issues
    │   ├── frontend.md.template       ← (si frontend) Especialista de UI
    │   ├── design.md.template         ← (si frontend) UX/UI, design system, a11y
    │   ├── backend.md.template        ← (si backend) APIs, auth, middleware
    │   ├── database.md.template       ← (si DB) Schema, migraciones, queries
    │   └── devops.md.template         ← (si CI/CD) Pipelines, Docker, deploy
    └── rules/
        ├── typescript.md.template
        ├── react-components.md.template
        └── python.md.template
```

## SDD — Software Design Document

Cada feature genera un único documento en `specs/sdd-[feature].md`:

```markdown
# SDD: [Feature]
**Status:** Draft | In Review | Approved | Implemented

## 1. Overview          ← /prd
## 2. Requirements      ← /prd
## 3. UI/UX Design      ← /design
## 4. Architecture      ← /plan
## 5. Implementation    ← /plan
## 6. Testing Strategy  ← QA agent (durante implementación)
## 7. Open Questions    ← cualquier comando
```

## Placeholders

| Placeholder | Ejemplo |
|---|---|
| `{{PROJECT_NAME}}` | my-app |
| `{{LANGUAGE}}` | TypeScript, Python |
| `{{FRAMEWORK}}` | Next.js, React Native, FastAPI |
| `{{PACKAGE_MANAGER}}` | bun, pnpm, npm, yarn |
| `{{LINT_COMMAND}}` | pnpm run lint |
| `{{LINT_FIX_COMMAND}}` | pnpm run lint --fix |
| `{{BUILD_COMMAND}}` | pnpm run build |
| `{{TEST_COMMAND}}` | pnpm run test |
| `{{TYPECHECK_COMMAND}}` | npx tsc --noEmit |
| `{{LINTER}}` | ESLint, Biome, Ruff |
| `{{TEST_FRAMEWORK}}` | Vitest, Jest, Pytest |
| `{{KEY_FILES}}` | Lista de archivos clave |
| `{{GITHUB_ISSUES_ENABLED}}` | true / false |
| `{{GITHUB_ISSUES_SECTION}}` | Sección completa o vacío |
