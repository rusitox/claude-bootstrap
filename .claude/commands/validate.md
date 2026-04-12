---
allowed-tools: Read, Bash, Glob, Grep
description: Run all validation checks on the skill
---

Run comprehensive validation:

1. **JSON validity**: `python3 -m json.tool assets/templates/settings.json.template > /dev/null && echo "✅ settings.json template: valid JSON structure"`
2. **Detection script**: `bash scripts/detect-stack.sh` — verify output is valid JSON with all required fields
3. **Placeholder consistency**: Check all `{{PLACEHOLDER}}` in templates are documented in SKILL.md
4. **Hook events**: Search for invalid events (`PreCommit`, `PostCommit`) in all templates
5. **Frontmatter**: Verify YAML frontmatter in all .md.template files is valid

Report:
```
✅/❌ JSON templates:       PASS/FAIL
✅/❌ Detection script:     PASS/FAIL
✅/❌ Placeholder coverage: PASS/FAIL
✅/❌ Hook events:          PASS/FAIL
✅/❌ Frontmatter YAML:     PASS/FAIL
⚠️  Warnings: [list]
```
