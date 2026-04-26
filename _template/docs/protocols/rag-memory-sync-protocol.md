---
tags: [protocol, rag-memory, sync]
type: protocol
aliases: [RAG sync, memory sync]
created: {{CREATED_DATE}}
---

# RAG-Memory Sync Protocol

> Verification + Proposal method. Never executes automatically.
> Principle: **"Verify First, Propose Second, Execute on Approval"**

---

## When to Use

- When discrepancies are detected in the Session Start Protocol
- When the user requests a sync
- After bulk entity additions/modifications

---

## Step 1: Database Path Verification (MANDATORY)

```markdown
## RAG-Memory Database Verification

### 1. Check .mcp.json Configuration
- Expected path: {{PROJECT_ROOT}}/.memory/rag-memory.db
- Actual path: [read from .mcp.json]
- Match: Y/N

### 2. Check Database File Exists
- Command: ls -la .memory/rag-memory.db
- File exists: Y/N
- File size: [bytes]

### 3. Verify Database Content
- getKnowledgeGraphStats()
- Entity count: [N], Relation count: [N], Document count: [N]

### 4. Cross-Check Project Identity
- searchNodes("{{PROJECT_NAME}}", limit=1)
- Project entity found: Y/N
```

**Verification Failure Actions**:

| Issue | Cause | Resolution |
|-------|-------|------------|
| Path mismatch | .mcp.json wrong path | Update DB_FILE_PATH |
| File not exists | Not initialized | Create first entity |
| Empty database | Wrong DB or fresh | Verify path, re-init |
| Project entity missing | Wrong DB | Check launch directory |

---

## Step 2: Detect Sync Candidates

```markdown
## Sync Candidates Detected

### current-focus.md → RAG-Memory (Create/Update)
| Item | Type | Action | Reason |
|------|------|--------|--------|
| [Blocker 1] | Blocker | CREATE entity | Not in RAG-Memory |
| [Priority change] | Status | UPDATE entity | Outdated |

### RAG-Memory → current-focus.md (Suggest Update)
| Item | Type | Action | Reason |
|------|------|--------|--------|
| [New decision] | Decision | ADD to Next Actions | Not reflected |
| [Resolved blocker] | Blocker | REMOVE from Blockers | Resolved |
```

---

## Step 3: Propose Sync Actions (User Approval Required)

**NEVER auto-execute. Always propose and wait for approval.**

```markdown
## Proposed Sync Actions

### Batch 1: RAG-Memory Entity Creation
Shall I create the following entities in RAG-Memory?
1. [Entity Name] (type: [TYPE])
2. [Entity Name] (type: [TYPE])

### Batch 2: current-focus.md Updates
Shall I update the following items in current-focus.md?
1. [Section]: [Change]
2. [Section]: [Change]

---
Approval options:
- Approve all
- Batch 1 only
- Batch 2 only
- Select individually
- Cancel
```

---

## Step 4: Execute on Approval

**Only after user explicitly approves**:
1. Execute approved RAG-Memory operations
2. Execute approved file updates
3. Report completion with verification

```markdown
## Sync Completed

### Executed Actions
- RAG-Memory: [N] entities created, [N] relations added
- current-focus.md: [N] sections updated

### Verification
- getKnowledgeGraphStats(): Entity count [before] → [after]
- current-focus.md Updated date refreshed
```

---

## Document Sync 5-Step Pipeline

The standard process for syncing modified documents to RAG-Memory:

```
1. deleteDocuments(documentId)
2. storeDocument(id, content, metadata)
3. chunkDocument(documentId)
4. embedChunks(documentId)
5. linkEntitiesToDocument(documentId, relevantEntityNames)
```

**Document ID Rules**:

| File | Document ID |
|------|-------------|
| `decisions/core-decisions.md` | `core-decisions` |
| `decisions/current-focus.md` | `current-focus` |
| `AGENTS.md` | `agents-md` |
| `CODE_CONTEXT.md` | `code-context` |
| `specs/[name].md` | `spec-[name]` |
| `chapters/[name].md` | `chapter-[name]` |
| `sources/[name].md` | `source-[name]` |

---

## Graph Analytics (Optional, during Consolidation)

Knowledge graph structural health check. Utilized during `/sync` +β (Consolidation):

| Tool | Purpose |
|------|------|
| `analyzeGraphStructure()` | density, connected components, isolated nodes, clustering coefficient |
| `detectCommunities()` | topic cluster detection, find isolated clusters |
| `getGraphMetrics(metrics=["betweenness"])` | identify bridge entities (structural vulnerabilities) |

---

## Quick Sync Prompts

```
# Full sync verification and proposal
"Check the sync status between current-focus.md and RAG-Memory and propose necessary actions"

# Propose RAG-Memory update only
"Propose items from current-focus.md to be reflected in RAG-Memory"

# Propose current-focus.md update only
"Propose items from the latest RAG-Memory state to be reflected in current-focus.md"

# Force verification
"Verify if RAG-Memory is reading the correct local database"
```
