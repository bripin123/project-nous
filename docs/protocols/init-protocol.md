---
tags: [protocol, init]
type: protocol
aliases: [project init]
created: {{CREATED_DATE}}
---

# Init Protocol

> Executes when `{{` placeholders are detected in AGENTS.md in a new project.
> Collects project information via conversation and automatically completes setup.

---

## Pre-check

1. `pwd` → Confirm project absolute path (used for `{{PROJECT_ROOT}}` replacement later)
2. Extract information already mentioned in the user's initial message (name, type, framework, etc.)

---

## Phase 1: Information Collection

### Round 1 — Common (All types)

Ask the following items **all at once**. Skip and just confirm items the user has already mentioned.

| Item | Purpose | Example |
|------|------|------|
| Project Name | `{{PROJECT_NAME}}` | "example-project-1 Website" |
| One-line Description | `{{PROJECT_PURPOSE}}` | "Halal certification body website" |
| Project Goal | `{{PROJECT_GOAL}}` | "Build a responsive website using Next.js" |
| Project Type | Project Type section | Dev / Writing / Research / Mixed |
| Content Language | `{{CONTENT_LANGUAGE}}` | Korean / English |

### Round 2 — Dev/Mixed only

Ask additional questions only when the type is Development or Mixed:

| Item | Purpose | Example |
|------|------|------|
| Programming Language | `{{LANGUAGE}}` | TypeScript |
| Framework | `{{FRAMEWORK}}` | Next.js 14 |
| Package Manager | `{{PACKAGE_MANAGER}}` | npm / pnpm / yarn |
| Database usage | `{{DATABASE}}` | Firebase / PostgreSQL / None |

### Extraction Rules

If the user says "Initiate a Next.js project":
- Type = Dev (Extracted)
- FRAMEWORK = Next.js (Extracted)
- Ask only the rest: "Please tell me the project name, goal, content language, and programming language/package manager/DB."

---

## Phase 2: Auto-Execution

> Execute the following sequentially without conversation after collecting user responses.

### Step 1: Placeholder Replacement

**Targeting all files** (`replace_all`):

| Placeholder | Value | Target Files |
|-------------|-----|----------|
| `{{PROJECT_ROOT}}` | `pwd` result | AGENTS.md, .mcp.json, .codex/config.toml, .gemini/settings.json, docs/protocols/*.md |
| `{{PROJECT_NAME}}` | User input | AGENTS.md, CODE_CONTEXT.md, docs/protocols/*.md |
| `{{PROJECT_PURPOSE}}` | User input | AGENTS.md |
| `{{PROJECT_GOAL}}` | User input | AGENTS.md |
| `{{CONTENT_LANGUAGE}}` | User input | AGENTS.md |
| `{{CREATED_DATE}}` | Today's date (YYYY-MM-DD) | AGENTS.md, CODE_CONTEXT.md, decisions/*.md, docs/protocols/*.md |
| `{{LAST_UPDATED}}` | Today's date | AGENTS.md |
| `{{PROJECT_STATUS}}` | `🟡 Initial Setup` | AGENTS.md |
| `{{CURRENT_PHASE}}` | `Phase 1` | AGENTS.md |
| `{{ENTITY_COUNT}}` | `0` | AGENTS.md |
| `{{RELATION_COUNT}}` | `0` | AGENTS.md |
| `{{DECISION_COUNT}}` | `0` | AGENTS.md |
| `{{LAYER_1_STATUS}}` | `✅ ACTIVE` | AGENTS.md |
| `{{LAYER_2_STATUS}}` | `✅ ACTIVE` | AGENTS.md |
| `{{LAYER_3_STATUS}}` | `✅ ACTIVE` | AGENTS.md |
| `__VAULT_PATH__` | Vault-relative path (the part after `PARADocumentSystem/` from `{{PROJECT_ROOT}}`, e.g., `--1-PROJECTS/1-2-HAIKorea/INHART_Book_Translation`) | 00-Dashboard.md |

**Note**: `<!-- BRIEFING_START -->` / `<!-- BRIEFING_END -->` in AGENTS.md are HTML comment markers, not placeholders. Do not replace them; write the contents between them in Step 5.

**Note 2**: `__VAULT_PATH__` is the `FROM` path format for Obsidian Dataview queries (vault-relative). The placeholder format is different because Obsidian Dataview does not recognize absolute paths or `{{...}}`. Requires additional processing in Step 4c.

**Dev/Mixed Additions** (CODE_CONTEXT.md):

| Placeholder | Value |
|-------------|-----|
| `{{LANGUAGE}}` | User input |
| `{{FRAMEWORK}}` | User input |
| `{{PACKAGE_MANAGER}}` | User input |
| `{{DATABASE}}` | User input |

### Step 2: Clean up Project Type Section

Checkboxes in the Project Type section of AGENTS.md:
- Selected type → Check with `[x]`
- Remaining types → Delete those lines

### Step 3: Initialize current-focus.md

Replace `decisions/current-focus.md` with the following content:

```markdown
---
tags: [focus, living-document]
type: focus
aliases: [current status, status]
created: {Today's date}
---

# Current Focus

**Updated**: {Today's date}
**Status**: 🟡 Initial Setup

---

## Current Priority

Project initialization complete. Waiting for first task to start.

---

## Blockers

None

---

## Next Actions

1. Start first session with /start
2. {Suggest first task based on project type}

---

## Session Context Files

| File | Purpose |
|------|---------|
| (None) | |
```

### Step 4: Initialize Wiki

Create wiki files using the information collected in Phase 1.

**4a. Write wiki/project-context.md**:

```markdown
---
created: {Today's date}
type: wiki
tags:
  - wiki/concept
  - topic/project-context
aliases: [project context]
---

# {PROJECT_NAME} — Project Context

> Self-knowledge the AI needs to know about this project.
> Auto-managed by /sync Step 6. Manual edits also permitted.

## A. Identity (What is this project)
- Name: {PROJECT_NAME}
- One-line description: {PROJECT_PURPOSE}
- Type: {Project Type}
- Created: {Today's date}

## B. Role (What is the AI's role in this project)
- [Write 1 line of AI role based on Phase 1 info]

## C. Current State (Where are we now)
- Status: Initial Setup
- Progress: 0%
- Last Action: Init Protocol Executed

## D. Domain Knowledge (What we learned in this project domain)
- (None yet — will accumulate as work progresses)

## E. Patterns (Patterns repeatedly confirmed in this project)
- (None yet — will accumulate as work progresses)

## F. Gotchas (Mistakes made or things to watch out for)
- (None yet — will accumulate as work progresses)

---
Last synced: {Today's date}
```

**4b. Write wiki/index.md**:

```markdown
---
created: {Today's date}
type: wiki
tags:
  - wiki/index
aliases: [wiki index]
---

# Wiki Index

## System
- [[project-context|Project Context]] — Auto-managed by /sync [system]

## Pages
(None yet)

Last updated: {Today's date}
Total: 1 pages
```

### Step 4c: Activate Dashboard (if 00-Dashboard.md exists)

The `00-Dashboard.md` that comes with `_template` is an inactive stub. Activate it via the following steps.

**4c-1. Batch replace `__VAULT_PATH__`** (Refer to Step 1 table):
- 11 locations (9 FROM paths + 2 header notices)
- Use vault-relative paths (not absolute paths — Obsidian Dataview only recognizes paths relative to vault root)
- Edit `replace_all=true` once

**4c-2. Delete "Deployment Setup" notice in header** (Meaningless after activation):
```
>
> **Deployment Setup**: Change `__VAULT_PATH__` in all `FROM` paths below to...
> Example: `__VAULT_PATH__` → `--1-PROJECTS/MyProject`
```
Delete these 3 lines entirely.

**4c-3. Conditional processing of inbox/Work dependent sections**:
- Check: Does `ls {{PROJECT_ROOT}}/inbox/Work/_ACTIVE` exist?
- **Exists** → Keep the 3 sections (🔴 Urgent Work Items / 📅 Upcoming Schedule / 📋 All Work Items) as-is (integrated work item operations)
- **Does not exist** → Delete the 3 sections entirely along with the top and bottom marker comments (`Work Items / Calendar block (optional)` ~ `End of Work Items / Calendar optional block`), and replace with 1 inactive notice comment:
  ```
  <!--
  Work Items / Calendar block is inactive in this project (inbox/Work/ does not exist).
  For multi-project integrated work item view, use the control tower (Ultimate_AI_Personal_Assistant) dashboard.
  If needed, create inbox/Work/_ACTIVE + inbox/Work/Calendar and refer to other project dashboards.
  -->
  ```

**4c-4. Handle broken wikilinks** (if `wiki/project-modes-and-hybrid-design.md` does not exist):
- Change `[[wiki/project-modes-and-hybrid-design|...]]` in the "🏷️ Project Modes" section line to plain text + TODO marker
- `> Details: Project Modes and Hybrid Design (TODO: restore wikilink when wiki/project-modes-and-hybrid-design.md is created)`

**4c-5. Verification**:
- `grep -c __VAULT_PATH__ 00-Dashboard.md` → must be 0
- If the inbox does not exist, `📜 Recent Session Logs` must be the first dataview section

### Step 5: Write AGENTS.md Briefing

Write the Project Briefing section of AGENTS.md using the data collected in Phase 1.

> Do not distill wiki/project-context.md; write directly from Phase 1 data.
> Later, /sync Step 7 will update this via wiki distillation.

Replace the content between `<!-- BRIEFING_START -->` and `<!-- BRIEFING_END -->` in AGENTS.md with the following:

```markdown
**Project**: {PROJECT_NAME} — {PROJECT_GOAL}
**Status**: 🟡 Initial Setup | **Phase**: Phase 1
**AI Role**: [Write 1 line based on Phase 1 info]
**Last Session** ({Today's date}): Init Protocol Execution Complete
**Next Action**: Start first session with /start
**Blockers**: None

**Details**: `wiki/project-context.md` | **Current Focus**: `decisions/current-focus.md`
```

### Step 6: Create RAG-Memory PROJECT entity

```
createEntities([{
  name: "{PROJECT_NAME}",
  entityType: "PROJECT",
  observations: [
    "Goal: {PROJECT_GOAL}",
    "Type: {Project Type}",
    "Identity: {PROJECT_NAME} — {PROJECT_PURPOSE}",
    "Role: [1 line of AI role based on Phase 1 info]",
    "Status: Initial Setup",
    "Phase: Phase 1",
    "Created: {Today's date}"
  ]
}])
```

Also create WIKI_PAGE entity:

```
createEntities([{
  name: "wiki/project-context.md",
  entityType: "WIKI_PAGE",
  observations: [
    "Topic: project-context, self-knowledge",
    "Created: {Today's date}",
    "Description: Project self-knowledge — Identity, Role, State, Domain, Patterns, Gotchas"
  ]
}])

createRelations([{
  from: "wiki/project-context.md",
  to: "{PROJECT_NAME}",
  relationType: "DESCRIBES"
}])
```

### Step 7: Completion Report

```
Initialization complete.
- Project: {PROJECT_NAME}
- Type: {Type}
- Placeholders replaced: {N}
- Remaining placeholders: {List or "None"}
  (Detailed CODE_CONTEXT.md items will be filled by the Code Context protocol)
- Wiki: project-context.md + index.md created
- Dashboard: {Activation complete (inbox dependent sections {kept|deleted}) | 00-Dashboard.md not found — skip}
- Briefing: Initial Briefing written in AGENTS.md
- RAG-Memory: PROJECT entity + WIKI_PAGE entity created

Start the first session with /start.
```

---

## Edge Cases

| Situation | Handling |
|------|------|
| User already included info in initial message | Extract that info, ask only the rest |
| Placeholders partially remain (partial init) | Ask only about remaining placeholders relevant to Phase 1, replace only the rest in Phase 2 |
| No placeholders but "initiate" called | Advise "Project is already initialized. Start session with /start." |
| Copied `_template` into folder with existing code | If Dev, infer language/framework from code → Confirm "I see code indicating TypeScript + Next.js, is this correct?" |
