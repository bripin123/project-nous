---
tags: [protocol, sync, direction]
type: protocol
aliases: [sync, /sync, direction maintenance]
created: 2026-03-02
---

# Direction Maintenance Protocols

> A collection of workflows for maintaining project direction. 1:1 symmetrical with [[session-start-protocol|Session Start]].

---

## /sync — Integrated Sync Command (Recommended)

> The unified command to save session work contents to the system.
> Operates in 1:1 symmetry with the Read of the Session Start Protocol.

### Save↔Read Symmetry Table

> /start (Read) and /sync (Save) operate in 1:1 symmetry for Steps 1~7.
> +α~+ε are extended steps exclusive to /sync. There is no corresponding step on the /start side, or they are absorbed by the automatic loading of the AGENTS.md Briefing.

| Step | /start (Read)                       | /sync (Save)                                        |
|------|-------------------------------------|-----------------------------------------------------|
| 1    | Read current-focus.md               | Update current-focus.md                             |
| 2    | Read latest daily log               | Write logs                                          |
| 3    | Read Session Context Files          | Update Session Context Files                        |
| 4    | [Dev] SDD Status Check              | [Dev] SDD Task Sync + verification reminder         |
| 4W   | —                                   | [Writing] Document Sync (outline/chapters/sources)  |
| 5    | RAG-Memory 3-Tier Smart Search      | RAG-Memory Entity + Document Sync (5-step pipeline) |
| 6    | Load User Preferences & Skill Usage | Update wiki/project-context.md                      |
| 7    | *(AGENTS.md Briefing auto-loads)*   | Distill AGENTS.md Briefing                          |
| +α   | —                                   | Save confirmation (stats + listDocuments)           |
| +β   | —                                   | Consolidation (if current-focus.md > 8K tokens)     |
| +γ   | —                                   | File-Level Lint (required after cascade/structural changes) |
| +δ   | —                                   | Self-Evolution (review Gotcha→Rule promotion)       |
| +ε   | —                                   | Skill Extraction (ε-1 Detect / ε-2 Create / ε-3 Usage / ε-4 Preferences) |

**Protocol-body exclusive verification steps** (session-start-protocol.md Step 7, 8 — not included in the command adapters; execute manually/optionally):
- **Document Sync Verification**: Verify the existence of the core 3 documents (core-decisions, current-focus, agents-md) via `getKnowledgeGraphStats()` results.
- **Cross-Reference Validation**: Check consistency across current-focus.md ↔ logs ↔ RAG-Memory.

These two steps are **separate** from /start Step 7 (Briefing auto-loading). Kept only in the Protocol body to keep command adapters lightweight. Execute manually if needed.

### Execution Steps (/sync Step 1-5 + α + β)

> Corresponds 1:1 with commands/sync.md. See the command for details.

**Step 1**: Update current-focus.md
- Recently Completed, In Progress, Next Actions, Updated date

**1b. Archiving Completed Items**:
- If items in Recently Completed exceed 10 → Move to `decisions/archives/completed-YYYY-MM.md`
- Items 6+ months old in Direction History → Move to the same archive file
- Maintain only the latest 10 completed + recent 6 months History in current-focus.md

**Step 2**: Write logs
- Check/create `logs/YYYY-MM/YYYY-MM-DD.md`, append work content

**Step 3**: Update Session Context Files
- Refresh the `Session Context Files` table in current-focus.md

**Step 4**: [Dev] SDD Task Sync (Development projects only)
- 4a. Reflect task progress (checkboxes → current-focus.md + RAG-Memory)
- 4b. Sync Spec + CODE_CONTEXT.md (only if modified)
- 4c. Verification reminder + Ship Readiness suggestion

**Step 4W**: [Writing/Research] Document Sync (Writing/Research projects only)
```
If outline.md modified → re-sync
If chapters/*.md modified → re-sync (Document ID: chapter-[name])
If sources/*.md modified → re-sync (Document ID: source-[name])
```

**Step 5**: RAG-Memory Entity + Document Sync
- 5a. Save Entity/Relation + register REFERENCE_DOC
- 5b. Document Sync (based on file modification date — 5-Step pipeline: delete→store→chunk→embed→link)

**Step 6**: Update wiki/project-context.md

- 6a. **Auto-update A~C**
  - Detect changes in Identity/Role → Add/modify items in sections A, B (skip if no changes)
  - C. Current State → Replace with current state (delete previous, keep only latest)

- 6b. **Verify D~F consistency**
  - Check if D~F items added via Auto-Suggest during the session have been properly reflected in the wiki
  - Supplement if missing, clean up duplicates

- 6c. **Size management**
  - If sections D, E, or F exceed 10 items each → prune the oldest item
  - Before pruning, verify if the item exists in RAG-Memory (if not, migrate first with addObservations)
  - Wiki retains 10 active knowledge items; RAG-Memory archives the full history

- 6d. **RAG-Memory Synchronization**
  - Changes in wiki → Reflect as observations per prefix in the PROJECT entity
  - Self-knowledge prefixes: Identity:, Role:, Status:, Domain:, Pattern:, Gotcha:
  - New items: addObservations, Deleted/Modified: deleteObservations → addObservations
  - Separated from Step 5 RAG-Memory Sync: Step 5 excludes PROJECT self-knowledge prefixes; Step 6d handles it exclusively
  - Update Last synced date

**Step 7**: Distill AGENTS.md Briefing

- 7a. Read wiki/project-context.md

- 7b. **Distillation Rules**:
  - A. Identity → "Project" line (1 line)
  - B. Role → "AI Role" line (1 line)
  - C. Current State → "Last Session" + "Next Actions" + "Blockers" (3 lines)
  - Domain (D) latest 2~3 items → "Core Context" bullets
  - E. Patterns latest 2~3 items → "Core Context" bullets
  - F. Gotchas latest 2~3 items → "Core Context" bullets
  - User Preferences (H) all → append to the end of "Core Context"

- 7c. Replace between `<!-- BRIEFING_START -->` ~ `<!-- BRIEFING_END -->` in AGENTS.md using Edit
  - Do not touch the markers or other sections

- 7d. If exceeding 30 lines → Summarize and further condense D~F

**+α**: Save confirmation
- `getKnowledgeGraphStats()` + `listDocuments()`

**+β**: Consolidation (Measurement-based, strictly conditional)
> **β-threshold [Required Measurement]**: `Bash: wc -c decisions/current-focus.md`
> - Result > 16,000 bytes → execute β-0~β-5
> - Result ≤ 16,000 bytes → output `skip: [N] bytes` explicitly, then proceed
> - **No eyeballing by LLM**. Judge strictly based on actual `wc -c` output (to prevent repeat of Session 58 skip failure)
> - For Korean, 1 token ≈ 1.5~2 bytes; 16K bytes ≈ 8K tokens

```
β-0. current-focus.md Pruning
     Archive older completed items (Recently Completed, Direction History)
     to decisions/archives/completed-YYYY-MM.md
     → Condense to within half the threshold (4,000 tokens)

β-1. Duplicate Detection
     searchNodes("[project core keywords]", limit=20)
     → Entity pairs with similarity 0.9+ → suggest merging (do not auto-execute)

     **Required before deletion**: read all observations of the deletion target with openNodes
     → Compare with the entity to retain: if unique obs exist, migrate first with addObservations
     → Delete only after migration is complete

β-2. Stale Entity Marking
     Detect entities not updated for 90+ days based on the latest /sync
     → addObservations("Stale: Not updated since YYYY-MM-DD")
     → Propose deletion only, do not auto-delete

β-3. DB Integrity + Orphan Cleanup
     1) Run scripts/audit-rag-memory.sh (Read-only, requires brew sqlite3 + sqlite-vec)
        → GREEN: next step / YELLOW·RED: suggest cleanup per item below
     2) Actions per finding (no auto-execution, execute only after approval)
        - Orphan Relation (source/target entity deleted) → suggest deleteRelations
        - Orphan entity_embedding_metadata (metadata without entity) → suggest SQL DELETE
        - Orphan vec0 vectors (dangling vector without metadata) → suggest SQL DELETE
        - Missing embeddings (entity without embedding = semantic search blind spot) → suggest embedAllEntities
        - Corrupted entity id (4+ consecutive underscores, remnant from pre-Korean regex patch) → suggest individual rename via SQL UPDATE
        - PRAGMA foreign_key_check violation → suggest repair after pinpointing the cause
        - Type drift (entity >15 or relation >30) → review canonicalization (manual, large-scale work)
     3) If verdict is RED (severe), resolving it is recommended before proceeding with the next /sync step

β-4. Graph Structure Analysis (graphology)
     analyzeGraphStructure() → check density, connected components, isolated nodes
     detectCommunities() → detect isolated clusters, identify need for cross-linking
     getGraphMetrics(metrics=["betweenness"]) → identify bridge entities (fragile points)

β-5. Statistics Comparison
     Report entity/relation delta compared to the previous /sync
```

**+γ**: File-Level Lint (Required after cascade/structural changes)
> **Trigger**: Immediately after template cascade or structural changes to 5+ files. Do not execute in normal sessions.

```
γ-1. Residual Placeholders
     Search for {{ in config files (.mcp.json, .codex/, .gemini/) + protocols
     Init substitution placeholders in `_template/` (`{{PROJECT_NAME}}`, `{{PROJECT_ROOT}}`, `{{CREATED_DATE}}`) are considered normal
     `docs/protocols/init-protocol.md` in an already initialized deployed project is an exception (dormant template)
     → Report list of unsubstituted items

γ-2. Broken Wikilinks
     Extract [[target]] patterns → verify target file existence
     → Report list of broken links

γ-3. Missing Frontmatter
     Check frontmatter in all .md files (including logs/, protocols/)
     → Report list of files missing the required 3 (created, type, tags)

γ-4. Missing Files vs. Template
     Check file existence based on the deployed-projects.md checklist
     → Report list of missing files

γ-5. Legacy/Orphan Files
     Check if files deleted from the template still remain in the project
     → Report list of residual files (delete only after approval)

γ-6. Wiki index.md Consistency (Only if wiki/ exists)
     Ensure all .md files in wiki/ (excluding index.md, **including subdirectory recursion**) are registered in index.md
     Check for items in index.md that have no actual file
     Ensure subdirectory wikilinks format as `[[subdirectory/filename|Display Name]]`
     → Report discrepancies

γ-7. Wiki Page Health Check (Only if wiki/ exists)
     Orphan pages without cross-references (wikilinks) (including subdirectory recursion)
     Missing frontmatter (type: wiki, tags, created)
     Unprocessed sources where raw/ source exists but no wiki page exists (Operation 1 Ingest incomplete)
     **Tier 1 (wiki root) file count exceeds 10** — If exceeded, suggest moving to subdirectories or archiving
       (Root is for meta/framework curation; domain cases belong in subdirectories)
     → Report check results
```

**+ε**: Skill Extraction (Executes every /sync)
> **Trigger**: Auto-executes at every /sync. Applies the Learning Loop pattern from Hermes Agent.
> ε-1 detection is automatic, ε-2 skill creation executes only after approval.

```
ε-1. Session Success Pattern Detection [Automatic]
     Were there workflow/solution patterns used 2+ times repeatedly in this session?
     e.g., Specific debugging procedures, API calling patterns, file organization methods, etc.
     → If yes, check for duplicates in existing skills/
     → If not a duplicate, suggest as a skill candidate: "Shall I save this pattern as a skill?"
     → If none, "No new patterns" — Normal (not every session has new patterns)

ε-2. Skill Creation [Approval→Execution]
     If there is a candidate from ε-1 and the user approves:
     - Create .claude/skills/[skill-name].md
     - Create .gemini/skills/[skill-name]/SKILL.md (Gemini format)
     - Register the new skill in docs/skills-guide.md
     - Add "[Date] Skill Created: [Name]" to wiki/project-context.md Patterns (E)

ε-3. Skill Usage Update [Automatic]
     If an existing skill was invoked/referenced in this session:
     - Update G. Skill Usage table in wiki/project-context.md
       (Usage count +1, last used date updated)
     - 3+ /sync continuous unused skill → mark as "Cleanup Candidate"

ε-4. User Preferences Update [Automatic]
     If a new user preference/style was detected in this session:
     - Add to H. User Preferences in wiki/project-context.md
     - If it conflicts with existing preferences → replace with the latest
     - Detection criteria: User explicitly expresses preference ("in Korean", "concisely", etc.)
       or identical modification requests 2+ times (implicit preference)
```

### Completion Report

```markdown
## Sync Complete

### Saved Contents
- logs: [filename]
- RAG-Memory: [N] entities, [N] relations
- Documents: [N] documents synced
- current-focus.md: Updated [date]
- Session Context Files: [N] files recorded

### SDD Status (Development Projects Only)
- Active Change: [change-id] (if none, "None")
- Progress: [completed]/[total] tasks ([N]%)
- Completed this session: [list of tasks completed this session]
- Next Task: [next incomplete task]
```

**When to use**:
- Before ending a session
- After completing major work
- When Context gets too long

---

## Update Current Focus (After Major Progress)

```
Please update current-focus.md:
- Completed work: [completed work]
- New priority: [new priority]
- Discovered blocker: [any blockers]
```

---

## End of Session Update

```
Before ending today's session:
1. Update current status in current-focus.md
2. Save major decisions to RAG-Memory
3. Explicitly state the tasks to start in the next session
```

---

## Direction Recovery (When Lost)

```
I've lost direction. Please check the following:
1. Current status in current-focus.md
2. Search recent decisions in RAG-Memory
3. Check recent work in logs/
4. Suggest next steps
```

---

## Blocker Resolution

```
I resolved a blocker:
- Resolved blocker: [description]
- Solution: [solution]
Please update current-focus.md and RAG-Memory
```

---

## Priority Shift

```
The priority has shifted:
- Old priority: [old priority]
- New priority: [new priority]
- Reason: [reason]
Please update current-focus.md and core-decisions.md
```
