---
tags: [protocol, code-context, dev]
type: protocol
aliases: [code context]
created: {{CREATED_DATE}}
---

# Code Context Protocol (Development Projects Only)

> Applies only to software development projects. Skip for documentation/planning projects.

---

## Core Principle

**"CODE_CONTEXT.md First, Code Second"** — Always refer to CODE_CONTEXT.md before writing/modifying code.

---

## Code Context Check

**When**: Right before starting to write/modify code in a development project (upon entering SDD Phase 5 IMPLEMENT).
**Note**: Not loaded during `/start` session start — this protocol auto-loads when code work begins.
**What**: Check for the existence of CODE_CONTEXT.md and take action.

### If CODE_CONTEXT.md EXISTS:

```
READ CODE_CONTEXT.md (Entire file)
CHECK if RAG-Memory document "code-context" exists
  If missing → deleteDocuments → storeDocument → chunkDocument → embedChunks → linkEntitiesToDocument
  If outdated → re-sync
```

- Architecture section → Understand file structure, routing rules
- Patterns section → Adhere to code patterns
- Conventions section → Adhere to naming, Import order
- Constraints section → Check for prohibited actions

**RAG-Memory Utilization**:
```
# Search code patterns
hybridSearch("component pattern server client") → CODE_CONTEXT chunks

# Check prohibited patterns
hybridSearch("constraints forbidden prohibited") → Constraints section
```

### If CODE_CONTEXT.md DOES NOT EXIST:

**Suggest immediate creation**:
```
There is no CODE_CONTEXT.md in this project.
Shall I create CODE_CONTEXT.md for code consistency?

Contents to be included upon creation:
1. Architecture (File structure, routing rules)
2. Patterns (Frequently used code patterns)
3. Conventions (Naming, Import order)
4. Constraints (Prohibited actions, precautions)
```

---

## CODE_CONTEXT.md Recommended Structure

1. **Architecture** — File structure, routing rules, folder descriptions
2. **Patterns** — Frequently used code patterns, component classification
3. **Conventions** — Naming, Import order, component structure
4. **Constraints** — Prohibitions, precautions, performance guides
5. **Tech Stack Quick Reference**
6. **Common Tasks** — How to add a new page/API/component
7. **File References** — List of existing files to reference

---

## Code Writing Rules

Mandatory checks when writing/modifying code:

| Check Item | Reference Section | Example |
|-----------|----------|------|
| File Location | Architecture | `app/[locale]/page.tsx` vs `app/page.tsx` |
| Component Pattern | Patterns | Server Component vs Client Component |
| Naming Convention | Conventions | PascalCase, camelCase, kebab-case |
| Prohibited Pattern | Constraints | `next/image` instead of `<img>` |
| Import Order | Conventions | React → External → Internal → Types → Styles |

---

## Auto-Update Trigger

When to suggest updating CODE_CONTEXT.md:
- When a new pattern is introduced
- When the tech stack changes
- When there is recurring code review feedback
