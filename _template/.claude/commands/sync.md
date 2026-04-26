# /sync — Session Save Protocol

> Designed 1:1 symmetrically with /start. Save session work contents to the system.
> Step 1↔1, 2↔2, 3↔3, 4↔4, 5↔5, 6↔6, 7↔7 — Save↔Read Symmetry.
>
> ⚠ **Body-Adapter Consistency**: This file must correspond 1:1 with the body of `docs/protocols/direction-maintenance.md`.
> If the body is modified, the identical change must be cascaded to all three CLI adapters (`.claude/commands/sync.md`, `.codex/commands/sync.md`, `.gemini/commands/sync.toml`).
> Verify that each Step number matches the body before concluding the /sync execution.
>
> **CRITICAL**: Execute the Steps below one by one using actual tool calls. Output the "Completion Report" only after all Steps have been actually executed. If you skip a step, you must specify the reason (e.g., "Step 4: skipped — `specs/` does not exist").

## Step 1: Update current-focus.md

- Add completed items to Recently Completed
- Update In Progress status
- Refresh Next Actions
- Refresh Updated date

**1b. Archiving Completed Items**:
- If Recently Completed exceeds 10 → Move to `decisions/archives/completed-YYYY-MM.md`
- Direction History 6+ months → Move to the same archive file
- Keep only the latest 10 completed + recent 6 months History in current-focus.md

## Step 2: Write logs

- Check `logs/YYYY-MM/YYYY-MM-DD.md` file
- Create if missing, append today's work content if exists
- Record work summary, changes, and decisions

## Step 3: Update Session Context Files

- Refresh the `Session Context Files` table in current-focus.md
- Record the list of files to read in the next session:
  - Code/document file paths currently in progress
  - Spec, design documents being referenced
  - Important files discovered during work
- If empty, clear the table (remove previous items)

## Step 4: [Dev] SDD Task Sync (Development projects only)

> Execute only if `specs/` folder exists. Skip if none.

**4a. Reflect Task Progress**:
- Check `specs/changes/[feat]/tasks.md` checkbox status
- Completed task → Reflect in current-focus.md Recently Completed
- Next incomplete task → Reflect in current-focus.md Next Actions
- Update RAG-Memory Task entity status (pending → done)

**4b. Spec + CODE_CONTEXT.md Sync** (Only if modified):
- New/modified spec file → Document Sync (Same as Step 5 process)
  - Document ID: `spec-[feature-name]`
- Review CODE_CONTEXT.md:
  - Check if new patterns/rules were discovered
  - Suggest CODE_CONTEXT.md update if necessary
  - Upon change → Document Sync (Document ID: `code-context`)

**4c. Verification Reminder**:
- If code was written/modified this session → Remind "Did you complete verification (tests/typecheck/lint)?"
- When all tasks are completed → Suggest "Executing Ship Readiness Gate is recommended"

## Step 4W: [Writing/Research] Document Sync (Writing/Research projects only)

> Execute only if outline.md, chapters/, sources/ exist. Skip if none.

- If `outline.md` modified → Document Sync
- If `chapters/*.md` modified → Document Sync (Document ID: `chapter-[name]`)
- If `sources/*.md` modified → Document Sync (Document ID: `source-[name]`)

## Step 5: RAG-Memory Entity + Document Sync

**5a. Save Entity**:
- Create major work/decisions as entities (`createEntities`)
- Create related relations (`createRelations`)
- **Register REFERENCE_DOC** (Tier 2 Metadata): If a `type: reference|guide|plan|analysis` document was created during the session, register it as a REFERENCE_DOC entity
  - `createEntities([{ name: "filename.md", entityType: "REFERENCE_DOC", observations: ["Path: [path]", "Topic: [keywords]", "Created: YYYY-MM-DD", "Description: [one line]"] }])`
  - Exclude registration: `type: email|log|draft|status` (ephemeral or managed by other systems)

**5b. Document Sync** (Check based on file modification date):

**How to detect changes** (Based on file modification date, not session edit status):
1. Check `metadata.updated` of each document saved in RAG-Memory via `listDocuments()`
2. Compare with the **actual file modification date** of the core 3 documents (`ls -l` or Bash `stat`)
3. File modification date > metadata.updated → **re-sync required** (Auto-detects omissions from previous sessions)
4. Documents edited in this session are naturally included

**5-Step Process per document** (MUST execute all 5 steps):
```
1. deleteDocuments(documentId)
2. storeDocument(documentId, content, {source: "filepath", updated: "YYYY-MM-DD"})
3. chunkDocument(documentId)
4. embedChunks(documentId)
5. linkEntitiesToDocument(documentId, relevantEntityNames)
```
- **storeDocument metadata**: MUST include `{ "updated": "YYYY-MM-DD" }` (For comparison in the next /sync)

**Document ID Rules**:
| File | Document ID |
|------|-------------|
| `decisions/core-decisions.md` | `core-decisions` |
| `decisions/current-focus.md` | `current-focus` |
| `AGENTS.md` | `agents-md` |

## Step 6: Update wiki/project-context.md

**6a. Auto-update A~C**:
- Detect changes in Identity → Add/modify items in section A (skip if no change)
- Detect changes in Role → Add/modify items in section B (skip if no change)
- C. Current State → Replace with current state (delete previous, keep only latest)

**6b. Verify D~F consistency**:
- Check if D~F items added via Auto-Suggest during the session have been properly reflected in the wiki
- Supplement if missing, clean up duplicates

**6c. Size management**:
- If D, E, or F sections exceed 10 items each → prune the oldest item
- Before pruning, verify if the item exists in RAG-Memory (if not, `addObservations` first)
- Wiki retains 10 active knowledge items, RAG-Memory archives the full history

**6d. RAG-Memory Synchronization**:
- Changes in wiki → Reflect as observations per prefix in the PROJECT entity
- Self-knowledge prefixes: `Identity:`, `Role:`, `Status:`, `Domain:`, `Pattern:`, `Gotcha:`
- New item: `addObservations`, Deleted/Modified: `deleteObservations` → `addObservations`
- Separated from Step 5 RAG-Memory Sync: Step 5 excludes PROJECT self-knowledge prefixes, Step 6d handles it exclusively
- Update `Last synced` date in wiki/project-context.md

## Step 7: Distill AGENTS.md Briefing

**7a. Read wiki/project-context.md**

**7b. Distillation Rules**:
- A. Identity → "Project" line (1 line)
- B. Role → "AI Role" line (1 line)
- C. Current State → "Last Session" + "Next Actions" + "Blockers" (3 lines)
- Domain (D) latest 2~3 items → "Core Context" bullets
- E. Patterns latest 2~3 items → "Core Context" bullets
- F. Gotchas latest 2~3 items → "Core Context" bullets
- User Preferences (H) all → append to the end of "Core Context"

**7c. Replace between `<!-- BRIEFING_START -->` and `<!-- BRIEFING_END -->` in AGENTS.md using Edit**:
- Do not touch the markers or other sections

**7d. If exceeding 30 lines → Summarize and further condense D~F**

## +α: Save confirmation

- Check overall status with `getKnowledgeGraphStats()`
- Check synced documents with `listDocuments()`
- 1-line summary of increase/decrease in entities/relations/documents/chunks compared to the previous /sync

## +β: Consolidation (Measurement-based, DO NOT skip condition)

> **β-threshold [Required Measurement]**: `Bash: wc -c decisions/current-focus.md`
> - Result > 16,000 bytes → execute β-0~β-5
> - Result ≤ 16,000 bytes → explicitly output `skip: [N] bytes`, then proceed to next step
> - **No eyeballing by LLM**. Judge strictly based on actual `wc -c` output (to prevent repeat of Session 58 skip failure)
> - For Korean, 1 token ≈ 1.5~2 bytes, 16K bytes ≈ 8K tokens

**β-0. current-focus.md Pruning**:
- Archive older completed items (Recently Completed, Direction History) to `decisions/archives/completed-YYYY-MM.md`
- Condense to within half the threshold (4,000 tokens)

**β-1. Duplicate Detection**:
- `searchNodes("[project core keywords]", limit=20)` → Entity pairs with similarity 0.9+ → suggest merging (do not auto-execute)
- **Mandatory before deletion**: read all observations of the deletion target with `openNodes` → Compare with the entity to retain → if unique obs exist, transfer first with `addObservations` → Delete only after transfer is complete

**β-2. Stale Entity Marking**:
- Detect entities not updated for 90+ days based on the latest /sync → `addObservations("Stale: Not updated for 90 days as of YYYY-MM-DD")`
- Propose deletion only, do not auto-delete

**β-3. DB Integrity + Orphan Cleanup**:
1. Run `scripts/audit-rag-memory.sh` (Read-only, requires brew sqlite3 + sqlite-vec)
   - Judgment GREEN → proceed to next step
   - Judgment YELLOW/RED → suggest cleanup per item (below)
2. Actions per finding (**NO auto-execution**, execute all only after user approval):
   - Orphan Relation (source/target entity deleted) → suggest `deleteRelations`
   - Orphan `entity_embedding_metadata` → suggest SQL `DELETE`
   - Orphan vec0 vector → suggest SQL `DELETE FROM entity_embeddings WHERE rowid IN (...)`
   - Missing embeddings (semantic search blind spot) → suggest `embedAllEntities`
   - Corrupted entity id (4+ consecutive underscores, remnant from pre-Korean regex patch) → suggest individual rename via SQL `UPDATE`
   - `PRAGMA foreign_key_check` violation → suggest repair after pinpointing the cause
   - Type drift (entity >15 or relation >30) → review canonicalization (manual, large-scale work)
3. If verdict is RED (severe), resolving it is recommended before proceeding with the next /sync step

**β-4. Graph Structure Analysis (graphology)**:
- `analyzeGraphStructure()` → check density, connected components, isolated nodes
- `detectCommunities()` → detect isolated clusters, identify need for cross-linking
- `getGraphMetrics(metrics=["betweenness"])` → identify bridge entities (fragile points)

**β-5. Statistics Comparison**:
- Report entity/relation delta compared to the previous /sync

## +γ: File-Level Lint (Required after cascade/structural changes)

> **Trigger**: Immediately after template cascade or structural changes to 5+ files. Skip in normal sessions.

**γ-1. Residual Placeholders**:
- Search for `{{` in config files (.mcp.json, .codex/, .gemini/) + protocols
- Init substitution placeholders in `_template/` (`{{PROJECT_NAME}}`, `{{PROJECT_ROOT}}`, `{{CREATED_DATE}}`) are considered normal
- `docs/protocols/init-protocol.md` in an already initialized deployed project is an exception (dormant template)
- → Report list of unsubstituted items

**γ-2. Broken Wikilinks**:
- Extract `[[target]]` patterns → verify target file existence
- → Report list of broken links

**γ-3. Missing Frontmatter**:
- Check frontmatter in all .md files (including logs/, protocols/)
- → Report list of files missing the required 3 (`created`, `type`, `tags`)

**γ-4. Missing Files vs. Template**:
- Check file existence based on the deployed-projects.md checklist
- → Report list of missing files

**γ-5. Legacy/Orphan Files**:
- Check if files deleted from the template still remain in the project
- → Report list of residual files (delete only after approval)

**γ-6. Wiki index.md Consistency** (Only if wiki/ exists):
- Ensure all .md files in wiki/ (excluding index.md, **including subdirectory recursion**) are registered in index.md
- Check for items in index.md that have no actual file
- Ensure subdirectory wikilinks format as `[[subdirectory/filename|Display Name]]`
- → Report discrepancies

**γ-7. Wiki Page Health Check** (Only if wiki/ exists):
- Orphan pages without cross-references (wikilinks) (including subdirectory recursion)
- Missing frontmatter (`type: wiki`, `tags`, `created`)
- Unprocessed sources where raw/ source exists but no wiki page exists (Operation 1 Ingest incomplete)
- **Tier 1 (wiki root) file count exceeds 10** — If exceeded, suggest moving to subdirectories or archiving (Root=meta/framework, domain case=subfolders)
- → Report check results

## +δ: Self-Evolution (Executed every /sync)

> Gotcha→Rule promotion review. The knowledge side of the Learning Loop.

1. **Lessons from this session**: Repeated problems, new patterns, struggle lessons → Suggest adding to wiki/project-context.md E/F
2. **Gotcha Recurrence Review**: Read wiki/project-context.md Gotchas(F), and if something occurred **again** in this session → Suggest promoting to AGENTS.md Guidelines
3. **Change Log**: When actually promoted, record in logs with `[Evolution]` tag

## +ε: Skill Extraction (Executed every /sync)

> Session success pattern detection and skill extraction. Applies the Learning Loop pattern of Hermes Agent.
> ε-1 detection is automatic, ε-2 skill creation executes after approval, ε-3/ε-4 are auto-updated.

**ε-1. Session Success Pattern Detection [Automatic]**:
- Were there workflow/solution patterns used 2+ times repeatedly in this session?
- e.g., Specific debugging procedures, API calling patterns, file organization methods, etc.
- → If yes, check for duplicates in existing `skills/`
- → If not a duplicate, suggest as a skill candidate: "Shall I save this pattern as a skill?"
- → If none, "No new patterns" — Normal (not every session has new patterns)

**ε-2. Skill Creation [Approval→Execution]**:
- If there is a candidate from ε-1 and the user approves:
  - Create `.claude/skills/[skill-name].md`
  - Create `.gemini/skills/[skill-name]/SKILL.md` (Gemini format)
  - Register the new skill in `docs/skills-guide.md`
  - Add `[Date] Skill Created: [Name]` to `wiki/project-context.md` Patterns (E)

**ε-3. Skill Usage Update [Automatic]**:
- If an existing skill was invoked/referenced in this session:
  - Update G. Skill Usage table in `wiki/project-context.md` (Usage count +1, last used date updated)
- 3+ /sync continuous unused skill → mark as "Cleanup Candidate"

**ε-4. User Preferences Update [Automatic]**:
- If a new user preference/style was detected in this session:
  - Add to H. User Preferences in `wiki/project-context.md`
  - If it conflicts with existing preferences → replace with the latest
  - Detection criteria: User explicitly expresses preference ("in English", "concisely", etc.) or identical modification requests 2+ times (implicit preference)

## Completion Report

> Output the report below only after executing all Steps via actual tool calls. Do not fabricate a report without execution.

```markdown
## Sync Complete

### Saved Contents
- current-focus.md: Updated [Date]
- logs: [Filename]
- Session Context Files: [N] files recorded
- wiki/project-context.md: [Summary of updated sections]
- AGENTS.md Briefing: [Re-distilled yes/no]
- RAG-Memory:
  - Entities: [N] created, [N] relations
  - Documents: [N] synced, [N] chunks embedded

### SDD Status (Development projects only)
- Active Change: [change-id] (if none, "None")
- Progress: [Completed]/[Total] tasks ([N]%)
- Completed this session: [List of tasks completed this session]
- Next Task: [Next incomplete task]
- Verification Status: [Complete/Incomplete]

### Consolidation (Only if +β executed)
- Token count before/after current-focus.md pruning
- Duplicate/Stale/Orphan action results

### Lint (Only if +γ executed)
- Discovery/resolution results for each item γ-1 ~ γ-7

### Self-Evolution (+δ)
- Lessons from this session: [N] added / None
- Gotcha→Rule promotion: [List items if any / None]

### Skill Extraction (+ε)
- ε-1 Pattern Detection: [N candidates / None]
- ε-2 Skill Creation: [File path if any / None]
- ε-3 Skill Usage Update: [N] items
- ε-4 User Preferences Update: [N] items
```
