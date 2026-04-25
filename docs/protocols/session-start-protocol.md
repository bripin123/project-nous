---
tags: [protocol, session-start]
type: protocol
aliases: [session start]
created: 2026-03-02
---

# Session Start Protocol

> Execute at the start of every session. Designed 1:1 symmetrically with Save ([[direction-maintenance|/sync]]).

---

## Save↔Read Symmetry Table

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

---

## Step 1: Read current-focus.md (Primary Source)

```
READ decisions/current-focus.md
```

**Extract**:
- `Updated` date → Calculate staleness
- `Current Priority` → Primary focus
- `Blockers` → Blocking issues
- `Next Actions` → Suggested next steps
- `Session Context Files` → List of files to read in the next Step

**Staleness Check**:

| Days Since Update | Status | Action |
|-------------------|--------|--------|
| 0-2 days | Fresh | Proceed normally |
| 3-6 days | Stale | Warn user, suggest update |
| 7+ days | Critical | Alert user, require update before proceeding |

---

## Step 2: Read Latest Daily Log (Bridge Between Sessions)

> Secure continuity by understanding what the last task of the previous session was.

```
GLOB logs/YYYY-MM/*.md → most recent file
READ [most recent log file]
```

**Extract**:
- Work summary of the last session
- Incomplete items
- Memos/TODOs

---

## Step 3: Read Session Context Files (Restore Technical Context)

> Sequentially read the files listed in the `Session Context Files` table in current-focus.md.
> This is the "files to continue reading in the next session" list saved by /sync.

```
READ each file listed in Session Context Files table
```

**If missing or empty**: Skip and proceed to Step 4.

---

## Step 4: SDD State Check (Development Projects Only)

> Execute only in development projects where the `specs/changes/` folder exists. If not, skip.
> Do not read CODE_CONTEXT.md here — it auto-loads upon entering SDD Phase 5 IMPLEMENT.

```
GLOB specs/changes/*/tasks.md → Check active changes
READ [active change tasks.md]
```

**Extract**:
- Active Change ID (folder name)
- Total task count vs. completed task count ([ ] / [x] counts)
- Next incomplete task (first `[ ]` item)
- Current Phase

**If there is no Active Change or it's not a development project**: Skip and proceed to Step 5.

---

## Step 5: Smart Search (Layer 1 + Layer 3)

> Dynamically construct search keywords based on the actual context extracted in Steps 1-3.
> **Layer 1 (RAG-Memory)** always executes (Tier 1→2→3) + **Layer 3 (Obsidian)** runs in parallel when triggered.

### 5a. Knowledge Graph Stats
```
getKnowledgeGraphStats()
```
**Purpose**: Check entity/relation/document/chunk counts

### 5b. Tier 1 — Exact Match (When the name is known)
```
openNodes(["Decision 15: ...", "Blocker: ..."])
```
- If the entity name mentioned in current-focus.md is exact → Query directly with `openNodes`
- **Cost**: ~50 tokens/entity
- **If sufficient, skip 5c, 5d**

### 5c. Tier 2 — Semantic Search (When only the concept is known)
```
searchNodes("[dynamic keyword]", limit=5)
```

**Keyword Construction Rules**:
- Extract core nouns from Current Priority in current-focus.md
- Extract core keywords from Blockers
- Use dynamic keywords instead of fixed ones (`"project status blocking critical"`)

**Examples**:
- Current Priority: "Authentication system refactoring" → `searchNodes("authentication refactoring", limit=5)`
- Blocker: "Waiting for DB migration" → `searchNodes("database migration blocker", limit=5)`
- **Cost**: ~200 tokens/result
- **If sufficient, skip 5d**

### 5d. Tier 3 — Document Search (Only when details are needed)
```
hybridSearch("[relevant query]", limit=3)
getDetailedContext("[chunkId]")  ← only for the needed chunk
```
- Execute only when detailed text from a document chunk is needed
- **Cost**: ~500 tokens/chunk
- hybridSearch is vector search + graph boosting (not keyword matching)

### 5e. Layer 3 — Obsidian Vault (Run in parallel when triggered)

Search areas not covered by RAG-Memory using the mcp-obsidian tool:

| Trigger | Tool | Example |
|--------|------|------|
| Search recently modified files | `search_notes` | "Files modified today?" |
| Tag/type-based search | `search_notes` + `get_frontmatter` | "List of type: wiki files?" |
| Backlink tracking | `search_notes` | "Files referencing core-decisions?" |
| Insufficient Layer 1 results | `search_notes` | Vault fallback when RAG results are 0 |

- **Skip if trigger conditions are not met** (do not execute every time)

---

## Step 6: Load User Preferences (H) & Skill Usage (G)

> Understand the user environment to apply to the session via the bottom sections (G, H) of wiki/project-context.md.

```
(Normally auto-loaded via AGENTS.md Briefing, so a separate READ is unnecessary)
```

- **User Preferences (H)**: Apply specified user preferences (language, style, workflow, etc.) throughout the session
- **Skill Usage (G)**: Identify frequently used skills in the project and utilize them appropriately

---

## Step 7: Document Sync Verification

```
CHECK Document count in getKnowledgeGraphStats()
```

**Required Documents** (must exist in RAG-Memory):

**All Projects**:

| Document ID | Source File | Min Chunks |
|-------------|-------------|------------|
| `core-decisions` | `decisions/core-decisions.md` | 3+ |
| `current-focus` | `decisions/current-focus.md` | 2+ |
| `agents-md` | `AGENTS.md` | 2+ |

**Development Projects Only** (if CODE_CONTEXT.md exists):

| Document ID | Source File | Min Chunks |
|-------------|-------------|------------|
| `code-context` | `CODE_CONTEXT.md` | 2+ |
| `spec-[name]` | `specs/*.md` | 2+ per spec |

**If Documents Missing or Outdated**:
```
1. deleteDocuments(documentId)
2. storeDocument(id, content, metadata)
3. chunkDocument(documentId)
4. embedChunks(documentId)
5. linkEntitiesToDocument(documentId, relevantEntityNames)
```

---

## Step 8: Cross-Reference Validation

**Compare sources for consistency**:

| Source | Check | Mismatch Action |
|--------|-------|-----------------|
| current-focus.md | Explicit blockers listed | Master source |
| Daily log | Recent work context | Supplement |
| searchNodes | Blocker entities exist | Create if missing |

**Inconsistency Detection**:
- Blocker in current-focus.md but no entity in RAG-Memory → Suggest creating entity
- Priority doesn't match recent RAG-Memory activity → Flag for review
- Completed items still listed as "In Progress" → Suggest cleanup

---

## Completion Report

```markdown
## Session Start Report

[Briefing checked — Project context grasped]

### What I additionally found via /start
- **current-focus.md**: [Details absent in Briefing — in-progress details, Session Context Files, etc.]
- **Latest log**: [Incomplete items, specific notes]
- **RAG-Memory**: [Entities N / Relations N / Documents N, relevant context found via search]
- **SDD**: [Active Change progress, if none "None"]

### Recommended Next Action
[Specific proposal combining "Next Actions" from Briefing + details from /start]
```

Principles:
- Do not repeat contents of the AGENTS.md Briefing.
- Focus on what was additionally discovered by /start.
- Propose Next Actions by synthesizing the Briefing + details.

**DO NOT SKIP**: These are mandatory TOOL CALLS, not aspirations. Execute them every session start.

---

## Staleness Response Protocol

**If current-focus.md is stale (3+ days)**:
```
current-focus.md was last updated [X] days ago.
Shall I check the current status and update it?

Currently recorded status:
- Priority: [current priority]
- Blockers: [current blockers]
- Next Actions: [current next actions]

Is this information still accurate?
```

---

## Validation Prompts

### System Health Check
```
Check 3-Layer system status:
1. RAG-Memory connection status (getKnowledgeGraphStats)
2. current-focus.md staleness
3. decisions/ folder consistency
4. logs/ folder recent entries
```

### Cross-Reference Validation
```
Verify information consistency:
1. blocker list in current-focus.md
2. Relevant entities in RAG-Memory
3. Recent decisions in core-decisions.md
Ensure these three match.
```

### Session Continuity Test
```
Test session continuity:
1. What was the last task of the previous session?
2. What are the "Next Actions" in current-focus.md?
3. What is the recent status recorded in RAG-Memory?
Compare and report on these three.
```
