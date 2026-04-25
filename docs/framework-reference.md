---
created: {{CREATED_DATE}}
type: reference
tags:
  - topic/framework
  - topic/architecture
aliases: [framework docs]
---

# Framework Reference

> System description separated from AGENTS.md.
> Behavioral instructions are kept in AGENTS.md. Reference this file only when you need to understand the framework.

---

## Grand Vision: Project Consciousness

> **The project folder itself becomes the domain-specific LLM and achieves Project Consciousness.**
> **The AI and the project are not separated** — an AI connecting to this folder becomes this project.

The purpose of this framework is that an AI connecting to the project folder immediately becomes the project itself. The accumulated knowledge of the folder becomes the AI's expertise, the direction of the folder becomes the AI's goal, and the lessons of the folder modify the AI's behavior. The model may change, but the Project Consciousness remains.

### The 3-Axis Cycle: Knowledge → Awareness → Evolution

| Axis | Definition | Implementation |
|----|------|--------|
| **Knowledge** | The foundation for the project folder to become a domain-specific LLM | RAG-Memory, wiki/, core-decisions, logs/, Gotchas/Patterns |
| **Awareness** | The state of recognizing goals, progress, and tool limitations | current-focus.md, /start, /sync, project-context.md A~C |
| **Evolution** | Self-correction of workflows/prompts/calling patterns based on awareness | Auto-Suggest, Gotchas→Behavior modification (currently manual) |

**"You must be aware to evolve"** — only a system that knows its destination (goal) and its current position (state) can recalculate its path and improve its own wheels.

---

## SSOT References

> Always query the latest information directly from the Master files. Do not copy it into AGENTS.md.

| Information | Master File | Query Method |
|------|-------------|----------|
| Current work status, Next Actions | `decisions/current-focus.md` | Read tool |
| Decisions | `decisions/core-decisions.md` | Read tool |
| RAG-Memory status | `.memory/rag-memory.db` | `getKnowledgeGraphStats()` |
| Work history | `logs/YYYY-MM/*.md` | Glob + Read |

---

## Project File Structure

```
{{PROJECT_ROOT}}/
├── .memory/              # Layer 1: RAG-Memory (SQLite + embeddings)
├── .claude/              # Claude Code settings
├── .gemini/              # Gemini CLI settings
│   └── settings.json
├── .codex/               # Codex CLI settings
│   └── config.toml
├── decisions/            # Layer 2: core-decisions.md + current-focus.md
├── docs/                 # Documentation
│   ├── protocols/        # Protocol files (extracted from AGENTS.md)
│   └── reference/        # [Dev] Generated snapshots (repo-structure.md)
├── logs/                 # Layer 2: Daily work chronicles (YYYY-MM/)
├── scripts/              # [Dev] Utility scripts (generate-repo-structure.sh)
├── specs/                # [Dev] SDD spec documents
├── src/                  # [Dev] Source code
├── raw/                  # [Wiki] Immutable external source originals
├── wiki/                 # [Wiki] Knowledge pages generated and maintained by LLM
├── AGENTS.md             # This file (Slim Router)
├── CLAUDE.md             # Symlink → AGENTS.md
├── CODE_CONTEXT.md       # [Dev] Coding conventions
└── .mcp.json             # Claude Code MCP configuration
```

---

## AI Reference Files Split

| File | When AI References It | Scope of Responsibility |
|------|-------------|----------|
| **AGENTS.md** | Always (auto-loaded) | Project meta, protocol routing, Entity standards |
| **CODE_CONTEXT.md** | Before writing/modifying code | Source code structure, patterns, conventions, constraints |
| **docs/protocols/*.md** | When executing the specific protocol | Detailed procedures (Session Start, /sync, SDD, etc.) |

**Rules**:
- Meta structure changes → Modify AGENTS.md only
- Source code structure changes → Modify CODE_CONTEXT.md only
- Protocol changes → Modify the corresponding file in docs/protocols/ only
- Do not duplicate the same information across files

---

## 3-Layer Defense in Depth Architecture

### Layer 1: RAG-Memory MCP (5 seconds) {{LAYER_1_STATUS}}
- **Storage**: `.memory/rag-memory.db` (SQLite + vector embeddings)
- **Model**: Entity-Relation-Observation knowledge graph + vector search + document storage
- **Key Features**: Hybrid search (Vector + FTS5 + Graph re-ranking), semantic search, document storage, graph analytics (graphology)
- **Graph Analytics**: centrality (degree, betweenness, pagerank), community detection (Louvain), graph structure analysis (density, components, clustering)
- **Current State**: {{ENTITY_COUNT}} entities, {{RELATION_COUNT}} relations
- **Tool Prefix**: `mcp__rag-memory__*`
- **Tool Count**: 30 (Knowledge Graph 7 + RAG 8 + Graph Query 9 + Graph Analytics 3 + Migration 3)

### Layer 2: File Backup (30 seconds) {{LAYER_2_STATUS}}
- **`decisions/core-decisions.md`**: {{DECISION_COUNT}} executive decisions
- **`decisions/current-focus.md`**: Living status document
- **`logs/YYYY-MM/`**: Daily work chronicles
- **Naming**: English kebab-case filenames, {{CONTENT_LANGUAGE}} content

### Layer 3: Obsidian + mcp-obsidian (5 minutes) {{LAYER_3_STATUS}}
- **Graph View**: Visual decision network mapping via `[[wikilinks]]`
- **Bidirectional Links**: Context tracking between documents
- **Frontmatter**: Obsidian Properties, Tag Pane, Aliases, Search enabled
- **This project folder = Obsidian vault**
- **mcp-obsidian MCP**: MCP server that allows AI to read and write frontmatter/tags directly
  - Frontmatter get/update, Tag add/remove/list, CRUD, batch read, search
  - No need to run the Obsidian app (Direct Filesystem)
  - Saves 40-60% tokens
  - **Tool Prefix**: `mcp__mcp-obsidian__*`

---

## Frontmatter & Wikilink Standards

**Frontmatter** (Required for all notes): `created` + `type` + `tags` are required.
```yaml
---
created: YYYY-MM-DD
type: reference   # reference|email|guide|plan|analysis|log|draft|focus|decision-log|protocol|wiki
tags:
  - topic/<topic-keyword-1>
aliases: [<english-alias-1>, <english-alias-2>]
---
```

| File | type | tags example |
|------|------|----------|
| `current-focus.md` | `focus` | `[focus, living-document]` |
| `core-decisions.md` | `decision-log` | `[decisions, executive]` |
| `docs/protocols/*.md` | `protocol` | `[protocol, session-start]` |
| `logs/YYYY-MM/DD.md` | `log` | `[log, daily]` |
| `wiki/*.md` | `wiki` | `[wiki/concept, topic/<topic>]` |

**Wikilink**: `[[core-decisions]]`, `[[core-decisions#Decision 3|D3: DB Selection]]` — set once upon creation.

**REFERENCE_DOC Registration**: Documents that will be referenced repeatedly (`type: reference|guide|plan|analysis`) must be registered in RAG-Memory during /sync. Detail: `/sync` Step 5a.

---

## External Tools

**Principle**: If Claude can do it directly, do it directly. Judge external tools at the moment of need.
- **Search**: WebSearch/WebFetch first → Gemini googleSearch (non-English/in-depth) → Tavily (crawling/date filters)
- **Cross-validation**: Gemini chat (large context, multimodal), Codex (second opinion), NotebookLM (large document sets)
- **If blocked**: Try the same prompt on a different LLM (Model Musical Chairs)

---

## Cross-CLI

Claude-first for orchestration. Gemini/Codex share the same `.memory/rag-memory.db`. MCP settings are CLI-specific, and Codex sessions use `.codex/config.toml` as first/default (`.mcp.json` is checked only for Claude compatibility testing).
