---
tags: [protocol, knowledge-wiki]
type: protocol
aliases: [wiki, knowledge wiki]
created: {{CREATED_DATE}}
---

# Knowledge Wiki Protocol

> A protocol for synthesizing and accumulating valuable knowledge in wiki/ from external sources, discoveries during work, or Q&A.
> Active only in projects where the `wiki/` directory exists.

---

## Activation Condition

Determined by the existence of the `wiki/` directory. If it doesn't exist, ignore this entire protocol.

---

## Operations

### Operation 1: Ingest (External source → wiki)

**Source origins**:
- `raw/` files (Obsidian Web Clipper clippings, PDFs, etc.)
- URLs provided by the user (WebFetch)
- Agent web research (WebSearch, Tavily, Gemini googleSearch)

**Flow**:
```
Read source (raw/ file, URL, web research)
    ↓
Agent discusses core contents with the user
    ↓
With agreed contents:
  1. Create a wiki/ page or update an existing page
  2. Update wiki/index.md
  3. Create RAG-Memory WIKI_PAGE entity
  4. Add wikilink cross-references to relevant wiki pages
```

**Rules**:
- Original sources are kept in `raw/` (immutable — LLM does not modify them)
- Track origin in the wiki page frontmatter using the `source:` field
- One source can update multiple wiki pages
- Only reflect contents agreed upon after discussion with the user (no auto-generation)

### Operation 2: Query→Save (Q&A → wiki)

```
User question → Agent answer
    ↓
Auto-Suggest: "Shall I save this analysis as a wiki page?"
    ↓ (Upon approval)
  1. Create wiki/ page
  2. Update wiki/index.md
  3. Create RAG-Memory WIKI_PAGE entity
  4. Add cross-references
```

Integrates with existing Auto-Suggest Analysis triggers.

### Operation 3: Distill (Discovery during work → wiki)

```
Valuable pattern/solution discovered during work
    ↓
Auto-Suggest: "Shall I save this discovery as a wiki page?"
    ↓ (Upon approval)
  1. Create a wiki/ page or append to an existing page
  2. Update wiki/index.md
  3. Create RAG-Memory WIKI_PAGE entity
  4. Add cross-references
```

---

## Common Post-Processing

All 3 Operations share the same post-processing. **Process in real-time at the moment of creation** rather than deferring to /sync.

```
1. Create wiki/page.md (frontmatter + body)
2. Update wiki/index.md
3. createEntities → WIKI_PAGE entity
4. createRelations → connect with relevant wiki pages/sources
```

---

## Wiki Page Standards

### Frontmatter

Standard Frontmatter & Wikilink Standards + `type: wiki` + `wiki/` tags:

```yaml
---
created: YYYY-MM-DD
type: wiki
tags:
  - wiki/concept        # wiki page type
  - topic/<keyword>     # topic tag
source: raw/filename.md # source (omit if none)
aliases: [<english-alias>]
---
```

### Types of wiki/ tags

| Tag | Purpose | Example |
|------|------|------|
| `wiki/concept` | Concept explanation | "Compliance certification process" |
| `wiki/pattern` | Repeatedly discovered solution | "Next.js deployment pattern" |
| `wiki/entity` | Tool/technology/organization | "RAG-Memory MCP" |
| `wiki/comparison` | Comparative analysis | "BM25 vs Vector Search" |
| `wiki/synthesis` | Synthesis of multiple sources | "2026 AI Security Trends" |

### Directory Structure

**2-tier structure by purpose**. Filenames use English kebab-case.

#### Tier 1 — Root (meta / framework / system SSOT)

- **Purpose**: Project meta-knowledge, framework, taxonomy, general patterns
- **Limit**: **Around 10 items** (consistent with the scale of active knowledge in D/E/F). Exceeding this triggers a pruning or subfolder move suggestion in γ-7 Lint
- **Example files** (General):
  - `project-context.md` — System SSOT (auto-managed by `/sync`)
  - `index.md` — Registry
  - `classification-framework.md` — Judgment/classification framework
  - `nextjs-deployment-patterns.md` — Reusable patterns
  - `mcp-configuration-quirks.md` — Environment config memos

#### Tier 2 — Subfolders (Domain Case DB)

- **Purpose**: Domain knowledge expected to scale to dozens or hundreds of items
- **Limit**: None (allowing scale — the essence of a domain KB)
- **Folder names**: Plural kebab-case. Named according to the project domain
  - e.g., `entities/`, `cases/`, `patterns/`, `references/`, `concepts/`
- **Example files** (General):
  - `wiki/entities/<entity-name>.md` — Individual entity case file
  - `wiki/cases/<case-id>.md` — Case study
  - `wiki/patterns/<pattern-name>.md` — Pattern catalog

#### Judgment Criteria — Root vs. Subfolder

| Criteria | Place in Root | Place in Subfolder |
|---|---|---|
| File nature | Meta/framework/taxonomy/general pattern | Individual domain case/entity |
| Expected scale | Curated ~10 items | Scale of dozens to hundreds |
| Update freq. | Rarely (upon framework evolution) | Frequently (as cases are added) |
| Primary consumer | All-session AI context | When working on the relevant domain |

#### Overall Structure Example (General)

```
wiki/
├── index.md                       # Registry (Tier 1)
├── project-context.md             # System SSOT (Tier 1)
├── classification-framework.md    # Framework (Tier 1)
├── entities/                      # Individual entity case DB (Tier 2)
│   ├── entity-alpha.md
│   └── entity-beta.md
├── cases/                         # Case studies (Tier 2)
│   └── case-001.md
└── patterns/                      # Pattern catalog (Tier 2)
    └── retry-with-backoff.md
```

Subfolders are **created upon initial addition**. A single file can remain in the root, but promoting it to a subfolder is recommended once 2-3 items accumulate. Folder naming reflects the project domain context.

---

## wiki/index.md Format

```markdown
---
created: YYYY-MM-DD
type: wiki
tags:
  - wiki/index
  - topic/wiki-registry
aliases: [wiki index]
---

# Wiki Index

## System (Tier 1)
- [[project-context|Project Context]] — Auto-managed by /sync [system]

## Meta / Framework (Tier 1)
- [[framework-name|Framework Name]] — One-line description

## Domain Case DB (Tier 2)

<!-- Sections by subfolder. Adjust folder/section names to the project domain -->
### <subfolder-name>
- [[subfolder/page-name|Display Name]] — One-line description

Last updated: YYYY-MM-DD
Total: N pages (Tier 1: M / Tier 2: N-M)
```

Auto-updated by the agent when a page is created/deleted.
`wiki/index.md` maintains frontmatter (`created`, `type`, `tags`) just like other wiki pages.

---

## RAG-Memory Integration

### WIKI_PAGE Entity

```
createEntities([{
  name: "wiki/filename.md",
  entityType: "WIKI_PAGE",
  observations: [
    "Topic: [keyword1, keyword2]",
    "Source: [raw/filename.md or URL or web research]",
    "Created: YYYY-MM-DD",
    "Description: [One-line description]"
  ]
}])
```

### Relation Types

| Relation | Purpose |
|----------|------|
| `WIKI_PAGE --[REFERENCES]--> WIKI_PAGE` | Cross-references between wiki pages |
| `WIKI_PAGE --[DERIVED_FROM]--> REFERENCE_DOC` | Connection to source documents |

### Difference from REFERENCE_DOC

- **REFERENCE_DOC**: Registers the repeatedly referenced document itself (points to the original)
- **WIKI_PAGE**: Registers the synthesized knowledge page (created by the LLM)

### Deciding when to storeDocument+chunks

Processing all files via the 5-step `storeDocument + chunkDocument + embedChunks` when raw sources are acquired causes excessive double-indexing and signal dilution. Differentiate by source type:

| Raw Source Type | Size/Nature | RAG Processing |
|---|---|---|
| **Full-text primary** | Full PDF/HTML original, multi-page (standards, regs, papers, official docs, etc.) | ✅ **storeDocument + chunk + embed + REFERENCE_DOC entity** (target for full hybridSearch) |
| **Distillation excerpt** | Summaries/excerpts extracted by AI via WebFetch/WebSearch (~1-3KB level) | ⚠️ **REFERENCE_DOC entity only** (metadata like URL + fetched_date + one-line description, no chunks) |
| **Single quote** | One line to one paragraph level | URL + quote in the observation of a related entity |

**Judgment Criteria**:
- Body equals **5+ chunks equivalent** (approx. 5KB+) + high re-search value → primary
- If a wiki/entity already covers the same content, chunks are duplicates → treat as excerpt
- **Signal dilution**: hybridSearch results should concentrate on the raw primary original

**RAG Processing of the wiki file itself**:
- Since the wiki is a distillation layer, **storeDocument is generally not applied** (only WIKI_PAGE entity + observations)
- Avoids double-indexing with the raw/ original — hybridSearch is performed on the raw primary

---

## Lint (+γ Extension)

Executed additionally when wiki/ exists during /sync +γ:

### γ-6: Wiki index.md Consistency
- Are all .md files in wiki/ (excluding index.md) registered in index.md?
- Are there any items in index.md that do not exist as actual files?

### γ-7: Wiki Page Health Check
- Orphan pages without cross-references (wikilinks)
- Missing frontmatter (type: wiki, tags, created)
- Unprocessed sources where a raw/ source exists but no wiki page does
