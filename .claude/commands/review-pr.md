---
allowed-tools: Read, Bash(git:*), Bash(gh:*), Grep, Glob
description: Review a Pull Request for quality and correctness
---

Review PR: $ARGUMENTS

1. Fetch PR diff: `gh pr diff $ARGUMENTS`
2. Read changed files for context
3. Review for:
   - Template correctness (valid placeholders, frontmatter, hook events)
   - Script correctness (valid JSON output, portability)
   - Documentation clarity
   - Placeholder coverage (all new `{{VARS}}` documented in SKILL.md)
4. Output findings using 🔴 Critical / 🟡 Warning / 🟢 Suggestion format
5. Provide overall assessment: APPROVE / REQUEST CHANGES / COMMENT
