# Guía de Actualización: Memoria Persistente en Agentes

## ¿Qué cambia?

Se agrega `memory: project` al frontmatter YAML de cada agente y se incluyen
instrucciones explícitas de memoria en el system prompt. Esto hace que cada
subagente acumule conocimiento entre sesiones.

### Antes
```yaml
---
name: code-reviewer
description: Expert code reviewer...
tools: Read, Grep, Glob
model: inherit
---
```

### Después
```yaml
---
name: code-reviewer
description: Expert code reviewer...
tools: Read, Grep, Glob
model: inherit
memory: project
---

## Memory

- Before starting, review your memory for patterns and decisions from previous sessions.
- After completing your task, save what you learned to your memory.
```

---

## Método 1: Script automático (proyectos ya bootstrapeados)

```bash
# Desde la raíz de tu proyecto
curl -sO https://raw.githubusercontent.com/TU_REPO/update-agents-memory.sh
# O copiá el archivo update-agents-memory.sh a la raíz
bash update-agents-memory.sh
```

El script:
- Detecta todos los .md en `.claude/agents/`
- Agrega `memory: project` al frontmatter si no existe
- Inserta la sección `## Memory` con instrucciones
- Salta agentes que ya tienen memory configurado

---

## Método 2: Desde Claude Code (recomendado)

Abrí Claude Code en tu proyecto y pegá:

```
Actualizá todos los agentes en .claude/agents/ para agregar memoria persistente:

1. En el frontmatter YAML de cada agente, agregá `memory: project` después de `model:`
2. Después del frontmatter (después del segundo ---), agregá una sección:

## Memory

- Before starting, review your memory for patterns and decisions from previous sessions.  
- After completing your task, save what you learned to your memory.

3. No modifiques el resto del contenido del agente.
4. Hacé git commit con mensaje: "feat: add persistent memory to all agents"
```

---

## Método 3: Manual (agente por agente)

Para cada archivo en `.claude/agents/*.md`:

1. Abrí el archivo
2. En el bloque YAML (entre los `---`), agregá: `memory: project`
3. Después del frontmatter, agregá el bloque `## Memory`
4. Guardá y commiteá

---

## Actualizar el Skill claude-bootstrap

Para que los NUEVOS proyectos ya se generen con memoria, reemplazá los
templates de agentes en el skill:

```bash
# Backup
cp -r ~/.claude/skills/claude-bootstrap/assets/templates/agents \
      ~/.claude/skills/claude-bootstrap/assets/templates/agents.bak

# Copiar templates actualizados
cp claude-bootstrap-v3/agents/*.template \
   ~/.claude/skills/claude-bootstrap/assets/templates/agents/
```

---

## Scopes de memoria disponibles

| Scope     | Ubicación                                    | Git | Compartido | Cuándo usar |
|-----------|----------------------------------------------|-----|------------|-------------|
| `project` | `.claude/agent-memory/<agent>/`              | Sí  | Sí (equipo)| **Recomendado** — conocimiento del proyecto |
| `user`    | `~/.claude/agent-memory/<agent>/`            | No  | No         | Conocimiento cross-project |
| `local`   | `.claude/agent-memory/<agent>/` (gitignored) | No  | No         | Notas personales del dev |

---

## Verificación post-actualización

1. **Verificar frontmatter**:
```bash
grep -l "memory:" .claude/agents/*.md
# Debería listar TODOS los agentes
```

2. **Verificar auto memory del agente principal**:
```
# En Claude Code:
/memory
# → Verificar que auto memory está ON
# → Verificar que auto dream está ON
```

3. **Probar un agente con memoria**:
```
# En Claude Code:
Usá el agente code-reviewer para revisar los últimos cambios.
Después pedile que guarde lo aprendido en su memoria.
```

4. **Ver qué guardó**:
```bash
ls -la .claude/agent-memory/code-reviewer/
cat .claude/agent-memory/code-reviewer/MEMORY.md
```

---

## Tips

- **`memory: project`** es el scope recomendado porque se commitea y comparte con el equipo
- Los agentes NO guardan memoria automáticamente — necesitan las instrucciones explícitas en el prompt
- Auto-Dream solo aplica al agente principal, no a subagentes
- Podés ver/editar la memoria de un agente en `.claude/agent-memory/<nombre>/MEMORY.md`
- Si un agente acumula mucha memoria (>200 líneas en MEMORY.md), pedile que organice y consolide
