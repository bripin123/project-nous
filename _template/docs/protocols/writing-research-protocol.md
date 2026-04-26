---
tags: [protocol, writing, research]
type: protocol
aliases: [writing, research]
created: {{CREATED_DATE}}
---

# Writing/Research Protocol

> Applies to Writing, Research, and document production projects. For software development, see [[sdd-workflow|SDD Workflow]].
> Covers everything from writing (books/papers/analysis) to document production (reports/official letters/proposals).

---

## Core Principle

- `chapters/`, `sources/`, `deliverables/ = **Source of Truth** (Formalized documents)
- `RAG-Memory` = **Intelligence Layer** (Semantic search, reference linking, progress tracking)
- **Write by section**: Do not write the whole thing at once. Write by section → review → next section

---

## Entry Criteria by Scale

| Scale | Example | Applied Phases | Notes |
|------|------|-----------|------|
| **Short** | 1-3 page memo, email, quick report | 3→4→7 | Draft directly → review → deliver |
| **Medium** | Report, proposal, presentation | 2→3→4→5→6→7 | Start from outline. Format is important |
| **Large** | Multi-chapter report, paper, book | 1→2→3→4→5→6→7 | Full 7-Phase |

---

## 7-Phase Writing Workflow

```
Phase 1: SCOPE ──→ Phase 2: OUTLINE ──→ Phase 3: DRAFT
                                          ↓
Phase 4: REVIEW ──→ Phase 5: REVISE ──→ Phase 6: FORMAT ──→ Phase 7: DELIVER
```

**Core (Always)**: Phase 3 DRAFT → Phase 4 REVIEW
**Optional (Depending on scale)**: Phase 1, 2, 5, 6, 7

---

### Phase 1: SCOPE (Define Scope)

> For Large changes or new projects. Medium starts from Phase 2.

- Purpose: What to write, for whom, and why
- Deliverables list: What documents and how many
- Requirements: Client/format/length/deadline constraints
- References: Existing materials, preceding documents, templates

**Output**: Record scope in `outline.md` or `specs/master/requirements.md`.

---

### Phase 2: OUTLINE (Structural Design)

- Overall table of contents/section structure
- 1-2 line summary of core contents per section
- Map references ↔ sections
- Enter Phase 3 after user confirmation

```markdown
## outline.md example
1. Introduction — Project background, purpose
2. Current Status Analysis — Market research results (see sources/market-analysis.md)
3. Execution Plan — Step-by-step implementation plan
4. Budget — Calculation by item (separate xlsx)
5. Expected Effects
```

---

### Phase 3: DRAFT — Core, Always Execute

- Write **by section** (do not write the entire thing at once)
- Save to `chapters/` or deliverables folder after writing each section
- Create Chapter entity in RAG-Memory (Status: draft)
- Connect Source entity when citing references

---

### Phase 4: REVIEW — Core, Always Execute

2-Pass review after completing a section or full draft:

**Pass 1 — CRITICAL (Fix immediately):**

| Category | Check Item |
|---------|----------|
| **Factual Accuracy** | Are numbers, dates, names, and quotes accurate? |
| **Omissions** | Are required sections/items missing? |
| **Logical Consistency** | Do claims and evidence match? Any contradictions between sections? |
| **Format Compliance** | Does it follow the client/institutional format requirements? |

**Pass 2 — INFORMATIONAL (Improvement):**

| Classification | Item | Action |
|------|------|------|
| **AUTO-FIX** | Typos, spelling, numbering, mismatched reference numbers | Auto-fix |
| **ASK** | Tone/voice changes, structural rearrangement, adding/removing content | Ask user |

**Additional checks for formatted documents (reports/official letters/proposals):**

| Item | Check Content |
|------|----------|
| Required sections | Do all sections defined in the form exist? |
| Page count | Does it meet length requirements? |
| Terminology unification | Are different terms used for the same concept? |
| Table/Figure numbers | Are they sequential and referenced in the text? |
| Date/Version | Latest date, accurate version number |

---

### Phase 5: REVISE

- Reflect Phase 4 feedback
- Re-run Phase 4 after revision (Review → Revise loop)
- If unresolved after 2 loops → Ask user to judge

---

### Phase 6: FORMAT

> Apply output formatting after final content is confirmed. This is not a content editing stage.

- Determine target format: hwpx, docx, pptx, xlsx, pdf
- Apply template (if any)
- Check style consistency: fonts, spacing, headers/footers, page numbers
- Format tables/figures/charts

**Format Checklist:**
```
□ Conversion to target format complete
□ Template/form applied
□ Page numbers, headers/footers accurate
□ Table/figure numbers sequential
□ Table of contents auto-generated (if applicable)
□ Print/submission preview checked
```

---

### Phase 7: DELIVER

- Check final deliverables list (do all files exist?)
- Check naming conventions (client requirements)
- RAG-Memory Chapter entity Status: final
- Update current-focus.md
- Record completion in decisions/ if needed

---

## RAG-Memory Sync Mapping

| File/Folder | RAG-Memory Entity | Sync Direction |
|-----------|-------------------|------------|
| `outline.md` | Outline entity | Bidirectional |
| `chapters/*.md` | Chapter entities | Bidirectional |
| `sources/*.md` / `references/*.md` | Source entities | File → RAG |
| `notes/*.md` | Note entities | Bidirectional |
| Progress status (draft/review/final) | Chapter status observations | RAG ↔ File |

---

## Chapter Lifecycle

### Auto-sync when starting a chapter
```
Chapter Entity: "Chapter: [Name]"
  Status: draft, Progress: 0%
  Relations: part_of → Project, follows → Previous Chapter
```

### Status Change
```
draft → review → final
```

### Auto-connect when adding references
```
Source Entity: "Source: [Author Year - Title]"
  Relations: cited_in → Chapter, supports → Argument
```

---

---

## Sync Commands

```
# Start new chapter + RAG-Memory sync
"Start Chapter 3: Results and sync it to RAG-Memory"

# Add reference + auto-connect
"Add sources/jones-2025.md and connect it to the Literature Review chapter"

# Change chapter status + bidirectional sync
"Change Chapter 2 to review status and update RAG-Memory"

# Check full sync status
"Verify the sync status between chapters/ and RAG-Memory"

# Check project progress
"Show me the overall Writing project progress"
```

---

## Document Sync Workflow

```
# When creating a new chapter
Create chapters/chapter-01-introduction.md
→ deleteDocuments → storeDocument("chapter-introduction", content)
→ chunkDocument → embedChunks → linkEntitiesToDocument

# When modifying a chapter
→ re-sync (overwrite with same ID)

# When adding a reference
Create sources/smith-2024.md
→ deleteDocuments → storeDocument("source-smith-2024", content)
→ chunkDocument → embedChunks → linkEntitiesToDocument
```

---

## Daily Sync Verification

```markdown
## Writing/Research Sync Verification

### File Status
- Chapters: [N] total, [N] draft, [N] review, [N] final
- Sources: [N] total
- Notes: [N] total

### RAG-Memory Status
- Chapter entities: [N]
- Source entities: [N]
- Overall progress: [N]%

### Discrepancies
| Item | File | RAG-Memory | Action |
|------|------|------------|------|
```
