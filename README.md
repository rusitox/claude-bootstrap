# claude-bootstrap v2 — Skill para estandarizar proyectos

Skill auto-invocable para Claude Code que detecta cuando un proyecto no tiene
configuración de `.claude/` y lo scaffoldea completo.

## ¿Qué hace?

1. **Detecta** el stack del proyecto (lenguaje, framework, ORM, CI/CD)
2. **Pregunta** confirmación y ajustes
3. **Genera** la estructura `.claude/` completa:
   - 12 slash commands estándar
   - 3 agentes base (planner, code-reviewer, qa)
   - Agentes condicionales (frontend, backend, database, devops)
   - Rules según el lenguaje/framework
   - settings.json con hooks y permisos
   - CLAUDE.md con contexto del proyecto

## Cambios en v2

- **FIX**: Hooks corregidos — `PreCommit` (inválido) → `PreToolUse` con matcher
- **NEW**: Agente QA — siempre presente, testing y validación
- **NEW**: Agentes condicionales — frontend, backend, database, devops
- **NEW**: Detección expandida — detecta si el proyecto tiene frontend/backend/DB/CI
- **IMPROVED**: Agentes especializados por stack (no genéricos)

## Instalación (nueva)

```bash
# Copiar a tu directorio global de skills
cp -r claude-bootstrap ~/.claude/skills/claude-bootstrap
```

## Actualización (desde v1)

```bash
# Backup del skill anterior
mv ~/.claude/skills/claude-bootstrap ~/.claude/skills/claude-bootstrap.v1.bak

# Instalar v2
cp -r claude-bootstrap ~/.claude/skills/claude-bootstrap

# Actualizar proyectos existentes que tienen el hook PreCommit inválido:
# En cada proyecto, abrir .claude/settings.json y reemplazar:
#   "PreCommit": [...]
# por el nuevo patrón PreToolUse (ver settings.json.template)
```

## Actualizar un proyecto existente

Si ya tenés un proyecto bootstrapeado con v1:

```bash
cd tu-proyecto

# Opción 1: Re-bootstrap completo (regenera todo)
# En Claude Code, ejecutar:
#   "re-bootstrap este proyecto con el skill actualizado"

# Opción 2: Actualización manual selectiva
# 1. Corregir settings.json (cambiar PreCommit → PreToolUse)
# 2. Agregar los nuevos agentes:
cp ~/.claude/skills/claude-bootstrap/assets/templates/agents/qa.md.template .claude/agents/qa.md
# Editar qa.md y reemplazar los {{placeholders}} con los valores de tu proyecto
# 3. Agregar agentes condicionales si aplican (frontend, backend, etc.)
```

## Estructura del Skill

```
claude-bootstrap/
├── SKILL.md                          ← Definición principal (auto-invocable)
├── README.md                         ← Este archivo
├── scripts/
│   └── detect-stack.sh               ← Detecta lenguaje, framework, tools
├── references/
│   └── ARCHITECTURE.md               ← Referencia de la arquitectura .claude/
└── assets/templates/
    ├── CLAUDE.md.template             ← Template para CLAUDE.md
    ├── settings.json.template         ← Hooks y permisos (FIXED)
    ├── settings.local.json.template   ← Overrides personales
    ├── commands/                      ← 12 slash commands
    │   ├── prime.md.template
    │   ├── plan.md.template
    │   ├── implement.md.template
    │   ├── validate.md.template
    │   ├── commit.md.template
    │   ├── create-pr.md.template
    │   ├── review-pr.md.template
    │   ├── prd.md.template
    │   ├── rca.md.template
    │   ├── check-ignores.md.template
    │   ├── create-command.md.template
    │   └── create-rules.md.template
    ├── agents/                        ← Base + condicionales
    │   ├── planner.md.template        ← (siempre)
    │   ├── code-reviewer.md.template  ← (siempre)
    │   ├── qa.md.template             ← (siempre) NEW
    │   ├── frontend.md.template       ← (condicional) NEW
    │   ├── backend.md.template        ← (condicional) NEW
    │   ├── database.md.template       ← (condicional) NEW
    │   └── devops.md.template         ← (condicional) NEW
    └── rules/
        ├── typescript.md.template
        ├── react-components.md.template
        └── python.md.template
```

## Placeholders

| Placeholder | Ejemplo |
|---|---|
| `{{PACKAGE_MANAGER}}` | bun, pnpm, npm, yarn |
| `{{LINT_COMMAND}}` | pnpm run lint |
| `{{LINT_FIX_COMMAND}}` | pnpm run lint --fix |
| `{{BUILD_COMMAND}}` | pnpm run build |
| `{{TEST_COMMAND}}` | pnpm run test |
| `{{TYPECHECK_COMMAND}}` | npx tsc --noEmit |
| `{{FRAMEWORK}}` | Next.js, React Native, FastAPI |
| `{{LANGUAGE}}` | TypeScript, Python |
| `{{DATABASE}}` | Prisma, Drizzle, SQLAlchemy |
| `{{LINTER}}` | ESLint, Biome, Ruff |
| `{{TEST_FRAMEWORK}}` | Vitest, Jest, Pytest |
| `{{KEY_FILES}}` | Lista de archivos clave |
| `{{PROJECT_NAME}}` | nombre del proyecto |
