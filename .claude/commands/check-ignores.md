---
allowed-tools: Read, Bash(git:*), Glob
description: Verify .gitignore is properly configured
---

1. Read `.gitignore`
2. Check for common missing entries: `.DS_Store`, `.claude/settings.local.json`
3. Check for tracked files that should be ignored: `git ls-files -i --exclude-standard`
4. Check for sensitive files accidentally tracked: `git ls-files | grep -iE '\.env|secret|credential|\.pem|\.key'`
5. Report findings and suggest fixes
