#!/bin/bash
# ============================================================
# update-agents-memory.sh
# Actualiza agentes existentes en .claude/agents/ para agregar
# memory: project al frontmatter y las instrucciones de memoria.
# ============================================================
# Uso:
#   cd tu-proyecto
#   bash update-agents-memory.sh
# ============================================================

set -euo pipefail

AGENTS_DIR=".claude/agents"

if [ ! -d "$AGENTS_DIR" ]; then
  echo "❌ No se encontró $AGENTS_DIR"
  echo "   Ejecutá esto desde la raíz de un proyecto bootstrapeado."
  exit 1
fi

echo "🔍 Buscando agentes en $AGENTS_DIR..."
echo ""

UPDATED=0
SKIPPED=0

for agent_file in "$AGENTS_DIR"/*.md; do
  [ -f "$agent_file" ] || continue
  
  filename=$(basename "$agent_file")
  agent_name="${filename%.md}"
  
  # Check if already has memory: in frontmatter
  if head -20 "$agent_file" | grep -q "^memory:"; then
    echo "⏭️  $filename — ya tiene memory configurado, saltando"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi
  
  echo "📝 Actualizando $filename..."
  
  # 1. Add memory: project to frontmatter (after model: line, or before ---)
  if grep -q "^model:" "$agent_file"; then
    # Insert after model: line
    sed -i '/^model:/a memory: project' "$agent_file"
  else
    # Insert before closing ---
    # Find the second --- (end of frontmatter) and insert before it
    awk '
      BEGIN { count=0 }
      /^---$/ { 
        count++
        if (count == 2) {
          print "memory: project"
        }
      }
      { print }
    ' "$agent_file" > "${agent_file}.tmp" && mv "${agent_file}.tmp" "$agent_file"
  fi
  
  # 2. Add Memory section after the frontmatter if not present
  if ! grep -q "## Memory" "$agent_file"; then
    # Find the line after the closing --- of frontmatter and insert memory section
    awk '
      BEGIN { count=0; inserted=0 }
      /^---$/ { 
        count++
        print
        if (count == 2 && inserted == 0) {
          print ""
          print "## Memory"
          print ""
          print "- Before starting, review your memory for patterns and decisions from previous sessions."
          print "- After completing your task, save what you learned to your memory."
          print ""
          inserted=1
        }
        next
      }
      { print }
    ' "$agent_file" > "${agent_file}.tmp" && mv "${agent_file}.tmp" "$agent_file"
  fi
  
  UPDATED=$((UPDATED + 1))
done

echo ""
echo "✅ Resultado:"
echo "   Actualizados: $UPDATED"
echo "   Ya tenían memory: $SKIPPED"
echo ""
echo "📋 Próximos pasos:"
echo "   1. Revisá los archivos actualizados con: cat .claude/agents/*.md"
echo "   2. En Claude Code, corré /memory para verificar que auto memory está ON"
echo "   3. Verificá Auto-Dream: /memory → toggle auto dream ON"
echo "   4. Commiteá los cambios: git add .claude/agents/ && git commit -m 'feat: add persistent memory to all agents'"
