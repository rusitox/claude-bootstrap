#!/usr/bin/env bash
# detect-stack.sh — Detects project tech stack and outputs JSON profile
set -euo pipefail

PROJECT_DIR="${1:-.}"
cd "$PROJECT_DIR"

# --- Language ---
LANGUAGE="Unknown"
if [ -f "tsconfig.json" ]; then LANGUAGE="TypeScript"
elif [ -f "package.json" ]; then LANGUAGE="JavaScript"
elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then LANGUAGE="Python"
elif [ -f "Cargo.toml" ]; then LANGUAGE="Rust"
elif [ -f "go.mod" ]; then LANGUAGE="Go"
elif [ -f "Gemfile" ]; then LANGUAGE="Ruby"
elif [ -f "pubspec.yaml" ]; then LANGUAGE="Dart"
fi

# --- Package Manager ---
PKG_MANAGER="npm"
if [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then PKG_MANAGER="bun"
elif [ -f "pnpm-lock.yaml" ]; then PKG_MANAGER="pnpm"
elif [ -f "yarn.lock" ]; then PKG_MANAGER="yarn"
elif [ -f "package-lock.json" ]; then PKG_MANAGER="npm"
elif [ "$LANGUAGE" = "Python" ]; then PKG_MANAGER="pip"
elif [ "$LANGUAGE" = "Rust" ]; then PKG_MANAGER="cargo"
elif [ "$LANGUAGE" = "Go" ]; then PKG_MANAGER="go"
fi

# --- Framework ---
FRAMEWORK="None"
if [ -f "package.json" ]; then
  if grep -q '"next"' package.json 2>/dev/null; then FRAMEWORK="Next.js"
  elif grep -q '"react-native"' package.json 2>/dev/null; then
    if grep -q '"expo"' package.json 2>/dev/null; then FRAMEWORK="React Native (Expo)"
    else FRAMEWORK="React Native"; fi
  elif grep -q '"nuxt"' package.json 2>/dev/null; then FRAMEWORK="Nuxt"
  elif grep -q '"@angular/core"' package.json 2>/dev/null; then FRAMEWORK="Angular"
  elif grep -q '"svelte"' package.json 2>/dev/null; then FRAMEWORK="SvelteKit"
  elif grep -q '"vue"' package.json 2>/dev/null; then FRAMEWORK="Vue"
  elif grep -q '"react"' package.json 2>/dev/null; then FRAMEWORK="React"
  elif grep -q '"express"' package.json 2>/dev/null; then FRAMEWORK="Express"
  elif grep -q '"fastify"' package.json 2>/dev/null; then FRAMEWORK="Fastify"
  elif grep -q '"@nestjs/core"' package.json 2>/dev/null; then FRAMEWORK="NestJS"
  fi
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  REQ_FILE="requirements.txt"
  [ -f "pyproject.toml" ] && REQ_FILE="pyproject.toml"
  if grep -qi "fastapi" "$REQ_FILE" 2>/dev/null; then FRAMEWORK="FastAPI"
  elif grep -qi "django" "$REQ_FILE" 2>/dev/null; then FRAMEWORK="Django"
  elif grep -qi "flask" "$REQ_FILE" 2>/dev/null; then FRAMEWORK="Flask"
  fi
fi

# --- Database / ORM ---
DATABASE="None"
if [ -d "prisma" ] || grep -q '"prisma"' package.json 2>/dev/null; then DATABASE="Prisma"
elif grep -q '"drizzle-orm"' package.json 2>/dev/null; then DATABASE="Drizzle"
elif grep -q '"typeorm"' package.json 2>/dev/null; then DATABASE="TypeORM"
elif grep -q '"sequelize"' package.json 2>/dev/null; then DATABASE="Sequelize"
elif grep -q '"@supabase/supabase-js"' package.json 2>/dev/null; then DATABASE="Supabase"
elif grep -qi "sqlalchemy" requirements.txt 2>/dev/null; then DATABASE="SQLAlchemy"
elif grep -qi "sqlalchemy" pyproject.toml 2>/dev/null; then DATABASE="SQLAlchemy"
fi

# --- Linter ---
LINTER="None"
if [ -f "biome.json" ] || [ -f "biome.jsonc" ]; then LINTER="Biome"
elif ls .eslintrc* 2>/dev/null 1>&2 || [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ]; then LINTER="ESLint"
elif [ -f "ruff.toml" ] || grep -q "ruff" pyproject.toml 2>/dev/null; then LINTER="Ruff"
elif ls .prettierrc* 2>/dev/null 1>&2; then LINTER="Prettier"
fi

# --- Test Framework ---
TEST_FRAMEWORK="None"
if [ -f "package.json" ]; then
  if grep -q '"vitest"' package.json 2>/dev/null; then TEST_FRAMEWORK="Vitest"
  elif grep -q '"jest"' package.json 2>/dev/null; then TEST_FRAMEWORK="Jest"
  elif grep -q '"playwright"' package.json 2>/dev/null; then TEST_FRAMEWORK="Playwright"
  elif grep -q '"cypress"' package.json 2>/dev/null; then TEST_FRAMEWORK="Cypress"
  fi
elif grep -qi "pytest" requirements.txt 2>/dev/null || grep -qi "pytest" pyproject.toml 2>/dev/null; then
  TEST_FRAMEWORK="Pytest"
fi

# --- Commands ---
LINT_COMMAND="echo 'No lint configured'"
LINT_FIX_COMMAND="echo 'No lint fix configured'"
TYPECHECK_COMMAND="echo 'No typecheck configured'"
TEST_COMMAND="echo 'No tests configured'"
BUILD_COMMAND="echo 'No build configured'"

if [ -f "package.json" ]; then
  if grep -q '"lint"' package.json 2>/dev/null; then
    LINT_COMMAND="${PKG_MANAGER} run lint"
    LINT_FIX_COMMAND="${PKG_MANAGER} run lint --fix"
  fi
  if grep -q '"typecheck"' package.json 2>/dev/null; then
    TYPECHECK_COMMAND="${PKG_MANAGER} run typecheck"
  elif [ -f "tsconfig.json" ]; then
    TYPECHECK_COMMAND="npx tsc --noEmit"
  fi
  if grep -q '"test"' package.json 2>/dev/null; then
    TEST_COMMAND="${PKG_MANAGER} run test"
  fi
  if grep -q '"build"' package.json 2>/dev/null; then
    BUILD_COMMAND="${PKG_MANAGER} run build"
  fi
elif [ "$LANGUAGE" = "Python" ]; then
  [ "$LINTER" = "Ruff" ] && LINT_COMMAND="ruff check ." && LINT_FIX_COMMAND="ruff check --fix ."
  [ "$TEST_FRAMEWORK" = "Pytest" ] && TEST_COMMAND="pytest"
  command -v mypy &>/dev/null && TYPECHECK_COMMAND="mypy ."
  command -v pyright &>/dev/null && TYPECHECK_COMMAND="pyright"
fi

# --- Project Name ---
PROJECT_NAME=$(basename "$(pwd)")
if [ -f "package.json" ]; then
  PKG_NAME=$(grep -o '"name": *"[^"]*"' package.json | head -1 | sed 's/"name": *"//;s/"//')
  [ -n "$PKG_NAME" ] && PROJECT_NAME="$PKG_NAME"
fi

# --- Frontend/Backend/DB/DevOps detection ---
HAS_FRONTEND="false"
HAS_BACKEND="false"
HAS_DATABASE="false"
HAS_DEVOPS="false"

# Frontend: components dir or frontend framework
if [ -d "src/components" ] || [ -d "app/components" ] || [ -d "components" ]; then
  HAS_FRONTEND="true"
fi
case "$FRAMEWORK" in
  React*|Next.js|Vue|Nuxt|Svelte*|Angular) HAS_FRONTEND="true" ;;
esac

# Backend: routes/api dir or backend framework
if [ -d "src/routes" ] || [ -d "src/api" ] || [ -d "app/api" ] || [ -d "routes" ]; then
  HAS_BACKEND="true"
fi
case "$FRAMEWORK" in
  Express|Fastify|NestJS|FastAPI|Django|Flask) HAS_BACKEND="true" ;;
esac

# Database: ORM detected
[ "$DATABASE" != "None" ] && HAS_DATABASE="true"

# DevOps: CI/CD configs
if [ -d ".github/workflows" ] || [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ] || \
   [ -f ".gitlab-ci.yml" ] || [ -f "Jenkinsfile" ] || [ -d "terraform" ] || [ -d "infrastructure" ]; then
  HAS_DEVOPS="true"
fi

# --- Existing .claude/ ---
HAS_CLAUDE_DIR="false"
[ -d ".claude" ] && HAS_CLAUDE_DIR="true"
HAS_CLAUDE_MD="false"
[ -f "CLAUDE.md" ] && HAS_CLAUDE_MD="true"

# --- Output JSON ---
cat <<EOF
{
  "project_name": "${PROJECT_NAME}",
  "language": "${LANGUAGE}",
  "package_manager": "${PKG_MANAGER}",
  "framework": "${FRAMEWORK}",
  "database": "${DATABASE}",
  "linter": "${LINTER}",
  "test_framework": "${TEST_FRAMEWORK}",
  "lint_command": "${LINT_COMMAND}",
  "lint_fix_command": "${LINT_FIX_COMMAND}",
  "typecheck_command": "${TYPECHECK_COMMAND}",
  "build_command": "${BUILD_COMMAND}",
  "test_command": "${TEST_COMMAND}",
  "has_frontend": ${HAS_FRONTEND},
  "has_backend": ${HAS_BACKEND},
  "has_database": ${HAS_DATABASE},
  "has_devops": ${HAS_DEVOPS},
  "has_claude_dir": ${HAS_CLAUDE_DIR},
  "has_claude_md": ${HAS_CLAUDE_MD}
}
EOF
