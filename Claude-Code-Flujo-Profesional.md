# Claude Code — Flujo Profesional de Desarrollo

> Guía completa del sistema `claude-bootstrap` v2 y el flujo de trabajo
> profesional para proyectos con Claude Code.
>
> Definido por **Rusitox** — Flock IT Innovation · Abril 2026

---

## TL;DR

`claude-bootstrap` es un skill auto-invocable que detecta el stack de tu proyecto
y genera toda la estructura `.claude/` necesaria: 12 slash commands, agentes
especializados (base + condicionales según el stack), rules, hooks y permisos.
El resultado es un entorno de desarrollo asistido por IA con control determinístico,
no dependiente de que el modelo "se acuerde" de seguir las reglas.

---

## 1. Instalación del Skill

```bash
# Primera vez
unzip claude-bootstrap-v2.zip -d ~/.claude/skills/
chmod +x ~/.claude/skills/claude-bootstrap/scripts/detect-stack.sh

# Actualización desde v1
mv ~/.claude/skills/claude-bootstrap ~/.claude/skills/claude-bootstrap.v1.bak
unzip claude-bootstrap-v2.zip -d ~/.claude/skills/
chmod +x ~/.claude/skills/claude-bootstrap/scripts/detect-stack.sh
```

El skill queda en `~/.claude/skills/claude-bootstrap/` y aplica **a todos tus proyectos**.

---

## 2. Bootstrap de un Proyecto Nuevo

Entrás a un proyecto sin configuración de Claude Code y el skill se activa
automáticamente (o lo invocás manualmente diciendo "bootstrap" o "init claude").

### Paso 1 — Detección automática del stack

El script `detect-stack.sh` analiza el proyecto y detecta:

| Qué detecta | Cómo |
|---|---|
| Lenguaje | tsconfig.json, package.json, pyproject.toml, Cargo.toml, go.mod |
| Package manager | bun.lockb, pnpm-lock.yaml, yarn.lock, package-lock.json |
| Framework | Dependencias en package.json o requirements.txt |
| Base de datos / ORM | Prisma, Drizzle, TypeORM, Sequelize, SQLAlchemy, Supabase |
| Linter | biome.json, eslint, ruff, prettier |
| Testing | vitest, jest, playwright, cypress, pytest |
| Frontend | Directorio components/, framework frontend detectado |
| Backend | Directorio routes/ o api/, framework backend detectado |
| DevOps | .github/workflows/, Dockerfile, .gitlab-ci.yml, terraform/ |

### Paso 2 — Confirmación interactiva

Claude presenta el perfil detectado y los agentes propuestos:

```
📋 Stack detectado:
  Lenguaje:        TypeScript
  Package Manager: pnpm
  Framework:       React Native (Expo)
  Linter:          ESLint
  Testing:         Jest

🤖 Agentes propuestos:
  ✅ planner        — siempre
  ✅ code-reviewer  — siempre
  ✅ qa             — siempre
  ✅ frontend       — detectado: React Native/Expo
  ⬚ backend        — no detectado
  ⬚ database       — no detectado
  ⬚ devops         — no detectado

¿Es correcto? ¿Querés agregar o quitar alguno?
```

Podés agregar agentes que no se detectaron o quitar los que no necesitás.

### Paso 3 — Generación

Se crea toda la estructura `.claude/` con los placeholders reemplazados
por los valores reales del proyecto.

---

## 3. Estructura Generada

```
tu-proyecto/
├── CLAUDE.md                          ← Contexto del proyecto
└── .claude/
    ├── commands/                      ← 12 slash commands
    │   ├── prime.md                   → /project:prime
    │   ├── plan.md                    → /project:plan
    │   ├── implement.md               → /project:implement
    │   ├── validate.md                → /project:validate
    │   ├── commit.md                  → /project:commit
    │   ├── create-pr.md               → /project:create-pr
    │   ├── review-pr.md               → /project:review-pr
    │   ├── prd.md                     → /project:prd
    │   ├── rca.md                     → /project:rca
    │   ├── check-ignores.md           → /project:check-ignores
    │   ├── create-command.md          → /project:create-command
    │   └── create-rules.md            → /project:create-rules
    │
    ├── agents/                        ← Agentes especializados
    │   ├── planner.md                 ← siempre
    │   ├── code-reviewer.md           ← siempre
    │   ├── qa.md                      ← siempre
    │   ├── frontend.md                ← condicional
    │   ├── backend.md                 ← condicional
    │   ├── database.md                ← condicional
    │   └── devops.md                  ← condicional
    │
    ├── rules/                         ← Convenciones por tipo de archivo
    │   ├── typescript.md              ← si TypeScript
    │   ├── react-components.md        ← si React/RN
    │   └── python.md                  ← si Python
    │
    ├── settings.json                  ← Hooks + permisos (se commitea)
    └── settings.local.json            ← Overrides personales (gitignored)
```

---

## 4. Los Agentes

### Agentes Base (siempre presentes)

| Agente | Rol | Cuándo usarlo |
|---|---|---|
| **planner** | Arquitectura y planificación. Analiza el codebase, crea planes por fases, nunca escribe código. | Antes de features medianas/grandes |
| **code-reviewer** | Revisa calidad, seguridad, performance, tipos, cobertura de tests. | Después de escribir código o para revisar PRs |
| **qa** | Escribe tests, genera test matrices, valida edge cases, corre suites, crea regression tests. | Al implementar features, investigar bugs, antes de releases |

### Agentes Condicionales (según el stack)

| Agente | Se genera si detecta | Especialización |
|---|---|---|
| **frontend** | React, React Native, Next.js, Vue, Svelte, Angular | Componentes, accesibilidad, performance, styling, estados |
| **backend** | Express, Fastify, NestJS, FastAPI, Django, Flask | APIs, auth, validación, middleware, error handling |
| **database** | Prisma, Drizzle, TypeORM, Sequelize, SQLAlchemy | Schema, migraciones, queries, índices, integridad |
| **devops** | .github/workflows, Dockerfile, GitLab CI, Terraform | Pipelines, Docker, deploys, monitoring, seguridad |

Cada agente tiene en su system prompt las **tecnologías específicas** de tu proyecto.
No es genérico — un agente frontend para React Native sabe de Expo, y uno para
Next.js sabe de App Router y Server Components.

---

## 5. Flujo de Trabajo Profesional

### Iniciar sesión

```
/project:prime
```

Carga el contexto del proyecto, lee archivos clave, verifica que lint y types pasen.

### Desarrollar una feature (flujo completo)

```
1. /project:prd sistema de notificaciones push
   → Define QUÉ construir y POR QUÉ
   → Genera specs/prd-notificaciones.md

2. /project:plan implementar notificaciones push
   → Analiza el codebase, crea plan por fases
   → Genera specs/plan-notificaciones.md
   → El agente planner trabaja en contexto aislado

3. /project:implement fase 1 del plan de notificaciones
   → Implementa incrementalmente
   → Valida lint + types después de cada cambio
   → Self-review antes de presentar

4. /project:validate
   → Corre lint, types, build, tests
   → Reporte de estado completo

5. /project:commit
   → Genera commit message con Conventional Commits
   → El hook PreToolUse corre lint + typecheck antes del commit

6. /project:create-pr
   → Genera descripción estructurada del PR
   → Crea el PR en GitHub con gh
```

### Debugging

```
/project:rca el login falla después de 24hs
→ Reproduce, busca evidencia, traza el flujo
→ Identifica causa raíz (no solo el síntoma)
→ Propone fix + prevención
```

### Review

```
/project:review-pr 42
→ Lee el diff del PR #42
→ El agente code-reviewer analiza en contexto aislado
→ Reporte con 🔴 Critical / 🟡 Warning / 🟢 Suggestion
```

### Extensión

```
/project:create-command    → Crear nuevos slash commands
/project:create-rules      → Crear reglas por tipo de archivo
/project:check-ignores     → Verificar .gitignore
```

---

## 6. El settings.json Explicado

### Hooks

```jsonc
{
  "hooks": {
    // Pre-commit: corre lint + typecheck antes de cada git commit
    // ⚠️ NO existe "PreCommit" como evento — se usa PreToolUse + Bash matcher
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "bash -c 'INPUT=$(cat); CMD=$(echo \"$INPUT\" | jq -r \".tool_input.command // empty\"); if echo \"$CMD\" | grep -q \"git commit\"; then pnpm lint && pnpm typecheck; fi'"
        }]
      }
    ],
    // Post-edit: auto-format después de cada escritura de archivo
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{
          "type": "command",
          "command": "pnpm run lint --fix"
        }]
      }
    ]
  }
}
```

### Permisos

```jsonc
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Bash(pnpm run:*)",        // Comandos de build/dev/test
      "Bash(git status:*)",      // Git read-only
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)"       // Git write (protegido por hook)
    ],
    "deny": [
      "Bash(rm -rf:*)",          // Nunca borrar recursivo
      "Bash(git push --force:*)" // Nunca force push
    ]
  }
}
```

**Filosofía**: lo que está en `allow` se ejecuta sin preguntar.
Lo que está en `deny` se bloquea siempre. Todo lo demás pide confirmación.

### Eventos de Hook válidos

| Evento | Cuándo se dispara | Uso típico |
|---|---|---|
| `PreToolUse` | Antes de ejecutar una herramienta | Bloquear comandos peligrosos, pre-commit checks |
| `PostToolUse` | Después de ejecutar una herramienta | Auto-format, logging |
| `Stop` | Cuando Claude termina de responder | Notificaciones, auto-commit |
| `SessionStart` | Al iniciar/resumir sesión | Inyectar contexto, git status |
| `UserPromptSubmit` | Antes de procesar un prompt | Validación de prompts |
| `Notification` | Cuando Claude envía notificación | Desktop alerts, Slack |
| `SubagentStop` | Cuando un subagente termina | Cleanup, validación |
| `PreCompact` | Antes de compactar contexto | Backup de transcript |
| `PermissionRequest` | Cuando Claude pide permiso | Auto-approve seguro |

> ⚠️ **NO existen** `PreCommit`, `PostCommit`, ni ningún evento de git.
> Para hooks de git, usá `PreToolUse` con matcher `Bash` y detectá el comando.

---

## 7. Actualizar Proyectos Existentes

### Desde v1 del skill (tenía PreCommit inválido)

```bash
cd tu-proyecto

# Corregir settings.json manualmente:
# Reemplazar "PreCommit" por "PreToolUse" con el patrón Bash

# Agregar el agente QA (nuevo en v2):
# Copiar el template y reemplazar placeholders
```

### Re-bootstrap completo

En Claude Code, dentro del proyecto:

```
Re-bootstrap este proyecto con el skill actualizado.
Mantené los commands y rules custom que ya tengo.
```

---

## 8. Resumen Visual del Flujo

```
┌─────────────────────────────────────────────────┐
│                NUEVO PROYECTO                    │
│                                                  │
│  1. cd mi-proyecto                               │
│  2. claude  (abre Claude Code)                   │
│  3. "bootstrap" → skill se activa                │
│     ┌──────────────────────────────────────┐     │
│     │  detect-stack.sh                     │     │
│     │  → Detecta lenguaje, framework,      │     │
│     │    ORM, CI/CD, frontend/backend      │     │
│     │  → Propone agentes                   │     │
│     │  → Confirma con el usuario           │     │
│     │  → Genera .claude/ completo          │     │
│     └──────────────────────────────────────┘     │
│                                                  │
│  4. /project:prime → Cargar contexto             │
│  5. Empezar a trabajar                           │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│              DESARROLLO DIARIO                   │
│                                                  │
│  /project:prime    → Cargar contexto             │
│       ↓                                          │
│  /project:prd      → Definir QUÉ (PRD)          │
│       ↓                                          │
│  /project:plan     → Planificar CÓMO             │
│       ↓                 ← agente: planner        │
│  /project:implement → Construir                  │
│       ↓                 ← agente: frontend/back  │
│  /project:validate  → Verificar calidad          │
│       ↓                 ← agente: qa             │
│  /project:commit    → Commitear                  │
│       ↓                 ← hook: lint + typecheck  │
│  /project:create-pr → Abrir PR                   │
│       ↓                                          │
│  /project:review-pr → Revisar PR                 │
│                         ← agente: code-reviewer  │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│              DEBUGGING                           │
│                                                  │
│  /project:rca "descripción del bug"              │
│  → Reproduce → Evidencia → Traza → Root cause    │
│  → Fix propuesto → Prevención                    │
│  → El agente qa genera regression test           │
└─────────────────────────────────────────────────┘
```

---

## 9. Filosofía

- **Determinismo sobre esperanza**: Los hooks garantizan que lint y typecheck
  corran siempre, no dependemos de que el modelo se acuerde.
- **Agentes especializados sobre genéricos**: Cada agente conoce el stack
  específico de tu proyecto. Un QA de Vitest no es lo mismo que uno de Pytest.
- **Fail loud, not silent**: Los permisos bloquean explícitamente lo peligroso
  (rm -rf, force push). Lo no listado pide confirmación.
- **Plan before code**: El flujo PRD → Plan → Implement no es opcional.
  Es la diferencia entre vibe coding y ingeniería profesional.
- **Contexto aislado**: Los agentes trabajan en su propio contexto.
  No contaminan la conversación principal.

---

*Generado desde conversación Claude.ai · Abril 2026*
*Skill: claude-bootstrap v2 · 29 archivos · 7 agentes · 12 commands*
