# project-nous

> A persistent project intelligence framework for AI-augmented work.

**Tagline:** *The personal workbench for polymaths working with AI.*
AI coding + knowledge management + self-evolution, unified into one project skeleton — usable from Claude Code, Codex CLI, or Gemini CLI without modification.

---

## Why project-nous?

You spin up many projects with AI assistants. The session ends. The next session starts blank. The agent forgets why you made the decision you made yesterday, and asks again.

**project-nous** treats your project folder itself as the persistent intelligence — and your AI model as the swappable execution engine. Decisions, patterns, gotchas, direction, and accumulated lessons live in the folder, structured so any AI agent can reload context in seconds and contribute new knowledge in real time.

You only make decisions. The system maintains the rest.

---

## Quickstart

A first session takes about 10 minutes end-to-end.

### Prerequisites

- **nvm + Node 24** (the bundled MCP configs invoke `nvm use 24`)
- One of: **[Claude Code](https://docs.claude.com/en/docs/claude-code)**, **[Codex CLI](https://github.com/openai/codex)**, or **[Gemini CLI](https://github.com/google-gemini/gemini-cli)**
- macOS or Linux (Windows variants of MCP configs are included as `_win` files)

**Recommended:** run the CLI inside an IDE terminal (VS Code, Cursor, JetBrains, etc.), or install the CLI's official IDE extension. Keeping the agent and file edits in one window makes the `/start` → work → `/sync` loop noticeably smoother — you can review the agent's diffs in the editor while the conversation continues in the terminal pane.

### Step 1 — Install Node 24 + the RAG-Memory MCP server

Make sure Node 24 is available, then install the persistence engine once globally. The bundled MCP configs call it via `npx -y`, which prefers the globally installed copy when the version matches — so a single global install is shared across all your project-nous projects.

```bash
# If you don't already have nvm + Node 24:
nvm install 24
nvm use 24

# One-time global install of the persistence engine (~1.5 GB; bundles
# bge-m3 multilingual embeddings via @huggingface/transformers and
# sqlite-vec/better-sqlite3 native binaries):
npm install -g rag-memory-epf-mcp
```

Each project keeps its own SQLite database under `.memory/` — isolation comes from the per-project `env.DB_FILE_PATH` in the MCP config, not from where the server binary lives. Without a global install, `npx -y` would re-download the ~1.5 GB dependency tree into a new cache slot every time the package version changes.

### Step 2 — Copy the template into a new project

```bash
git clone https://github.com/bripin123/project-nous.git
cp -r project-nous/_template ~/projects/my-new-project
cd ~/projects/my-new-project
```

If you prefer not to clone, [`degit`](https://github.com/Rich-Harris/degit) works too:

```bash
npx degit bripin123/project-nous/_template my-new-project
```

### Step 3 — Point your CLI's MCP config at this project

The template ships with three MCP configs, one per CLI. Open whichever you use and replace `{{PROJECT_ROOT}}` with the absolute path to your new project:

| CLI | File | Field |
|-----|------|-------|
| Claude Code | `.mcp.json` | `env.DB_FILE_PATH` |
| Codex CLI | `.codex/config.toml` | `env.DB_FILE_PATH` |
| Gemini CLI | `.gemini/settings.json` | `env.DB_FILE_PATH` |

Each config wires the `rag-memory-epf-mcp` server to a project-local SQLite file at `.memory/rag-memory.db`. Other CLIs' configs can stay untouched — they only activate when that CLI is launched in this folder.

### Step 4 — First `/start` (initialization)

Open the project in your CLI and run `/start`. Because `AGENTS.md` still contains `{{PROJECT_NAME}}` and other placeholders, the agent automatically routes into **`init-protocol.md`**. It will:

1. Ask you a short series of questions (project name, purpose, type, AI's role).
2. Substitute placeholders across `AGENTS.md`, `wiki/project-context.md`, `decisions/current-focus.md`, and the MCP configs.
3. Create the initial `decisions/core-decisions.md` and the first daily log under `logs/YYYY-MM/`.
4. Run a baseline RAG-Memory health check.

Expected outcome: every `{{` placeholder is gone, and the agent reports its newly-loaded role and current focus in plain language.

### Step 5 — First `/sync` (persist what you just learned)

After your first real working session, run `/sync`. The agent will:

1. Update `current-focus.md` with what changed and what's next.
2. Append a daily log under `logs/YYYY-MM/`.
3. Save new entities (decisions, blockers, patterns) to RAG-Memory after asking your approval.
4. Run lint/structural checks (`+γ`) if you've modified 5+ files.
5. Suggest promoting recurring lessons to AGENTS.md rules (`+δ`) or extracting reusable workflows into skills (`+ε`).

From this point on, every future `/start` reloads in 5 seconds with full context.

---

## Architecture: 3-Layer Defense in Depth

| Layer | Recovery Time | Purpose | Implementation |
|-------|---------------|---------|----------------|
| **Layer 1** | ~5 sec | Instant restore, semantic + structural lookup | `rag-memory-epf-mcp` (entity-relation-observation graph + vector embeddings + FTS5 + graph analytics) |
| **Layer 2** | ~30 sec | Plain-text durable backup | `decisions/core-decisions.md`, `decisions/current-focus.md`, `logs/YYYY-MM/*.md` |
| **Layer 3** | ~5 min | Visual graph + manual exploration | The project folder doubles as an [Obsidian](https://obsidian.md) vault — wikilinks, frontmatter, graph view |

Each layer can fail without losing the others. Even with the SQLite database deleted, `/start` will rebuild context from the markdown files alone.

---

## Core Capabilities

### 3-Tier Smart Search

Sessions begin by searching memory before reading files. The agent escalates only when each tier is insufficient:

| Tier | Tool | When | Approx. cost |
|------|------|------|--------------|
| 1. Exact | `openNodes` | Entity name is known | ~50 tokens/entity |
| 2. Semantic | `searchNodes` | Only the concept is known | ~200 tokens/result |
| 3. Document | `hybridSearch` → `getDetailedContext` | Need long-form passages | ~500 tokens/chunk |

### 16 Auto-Suggest triggers

The framework does not auto-save anything. Instead, the agent watches for events and **suggests** persistence at the right moment — letting you approve or skip. Triggers include:

- Architecture / tech / direction decision finalized → suggest a `DECISION` entity
- Same error twice or "stuck" mentioned → suggest a `BLOCKER` entity
- 5+ files modified, or a major refactor → suggest a work-summary entity
- 30+ minutes without `/sync` → suggest running `/sync`
- A recurring solution surfaces twice → suggest extracting a `wiki/` page or skill candidate
- Same gotcha recurs 2+ times → suggest promoting it to an AGENTS.md rule
- User states a preference (explicit or implicit-twice) → suggest recording it under User Preferences

The full table of 16 triggers is in `_template/AGENTS.md`.

### Self-Evolution loop

`/sync` carries five extensions that turn one-off lessons into permanent improvements:

- **`+α` Auto-Suggest sweep** — surface anything the session generated that wasn't yet saved.
- **`+β` Consolidation** — prune `current-focus.md` and archive stale items when it crosses 10K tokens.
- **`+γ` File-Level Lint** — cross-reference check after cascade-style changes (commands ↔ protocols ↔ AGENTS.md).
- **`+δ` Gotcha → Rule promotion** — if a Gotcha has recurred, propose moving it to AGENTS.md as a binding rule.
- **`+ε` Skill extraction** — if a workflow has repeated 2+ times, propose materializing it as a `.claude/skills/<name>/` skill.

The system measurably grows session over session. The framework's own evolution log lives in `archives/` of the canonical workspace and validates that the loop works.

### Cross-CLI parity

`AGENTS.md` is the single source of truth, and the three CLI adapters carry **byte-identical bodies**:

- `.claude/commands/{start,sync}.md` (Claude Code)
- `.codex/commands/{start,sync}.md` (Codex CLI)
- `.gemini/commands/{start,sync}.toml` (Gemini CLI, embedded as a TOML literal multi-line string)

A change made in one place propagates to all three with one edit + one copy. No CLI is "primary".

### Anti-bias guardrails

`AGENTS.md` codifies a small set of cognitive guardrails the framework has learned the hard way and now requires the agent to honor every session:

- **Clean-generalization bias** — preserve the user's original meaning when summarizing; do not collapse fusion into separation.
- **Status-quo rationalization** — examine alternatives before defending a current choice.
- **Frame-first bias** — when answering analysis / comparison / classification / evaluation / diagnosis, decompose facts first, conclude the frame last.
- **Numerical claims** — always provide the calculation basis or label it as an estimate.
- **Skip-report verification** — when a parallel sub-agent reports "file missing", verify with `ls` before believing it.

These are enforced as part of the agent's standing instructions, not as docs.

---

## RAG-Memory Engine

project-nous depends on **[`rag-memory-epf-mcp`](https://www.npmjs.com/package/rag-memory-epf-mcp)** — a single MCP server exposing **30 tools** across four capability layers. This is the persistence engine that makes the project folder behave as a queryable intelligence rather than a pile of files.

### Hybrid Search (not keyword matching)

`hybridSearch` fuses three signals in one query:

- **Vector similarity** — bge-m3 1024-dim multilingual embeddings
- **FTS5 BM25** — SQLite full-text scoring with Reciprocal Rank Fusion
- **Knowledge-graph re-ranking** — boost results connected to entities mentioned in the query (geometric decay across hops)

Returns ranked chunks with their entity context. For exact name lookups use `openNodes`; for natural-language entity discovery use `searchNodes`.

### Knowledge Graph (entity-relation-observation)

Ten tools manage a typed graph that grows alongside the project:

| Tool | Purpose |
|------|---------|
| `createEntities` / `deleteEntities` | Add/remove typed nodes (PROJECT, DECISION, TASK, BLOCKER, WIKI_PAGE, …) |
| `addObservations` / `deleteObservations` | Append timestamped facts to existing entities |
| `createRelations` / `updateRelations` / `deleteRelations` | Manage typed edges (`part_of`, `depends_on`, `blocks`, `implements`, …) |
| `openNodes` | Exact retrieval by name |
| `searchNodes` | Semantic discovery from natural language |
| `readGraph` / `getNeighbors` | Walk the graph |

### Graph Analytics (powered by graphology)

Three structural-analysis tools added in v3.3.0:

- **`getGraphMetrics`** — centrality scores per entity (degree, betweenness, PageRank). Identifies bridge entities and orphan nodes.
- **`detectCommunities`** — Louvain clustering with modularity score. Surfaces topic groups and isolated clusters.
- **`analyzeGraphStructure`** — graph density, connected components, clustering coefficient. Periodic health check.

### Document RAG (5-step ingestion)

Long-form sources go through a strict pipeline (`delete → store → chunk → embed → link`):

| Tool | Purpose |
|------|---------|
| `storeDocument` | Store raw markdown/text with metadata |
| `chunkDocument` | Split into semantic chunks |
| `embedChunks` | Generate vector embeddings for chunks |
| `linkEntitiesToDocument` | Connect chunks to graph entities (chunk-level linking, v3.2.0+) |
| `getDetailedContext` | Retrieve chunk text with surrounding context |
| `extractTerms` | Surface domain terms from a document |
| `listDocuments` / `deleteDocuments` | Manage the document store |

### System & Migration

- **`getKnowledgeGraphStats`** — entity / relation / document counts by type, used by `/start` and `/sync` for health checks.
- **`exportGraph` / `importGraph`** — JSON snapshot for backup or cross-project transfer.
- **`runMigrations` / `rollbackMigration` / `getMigrationStatus`** — schema evolution without data loss.
- **`embedAllEntities`** — batch re-embed (e.g., when switching embedding models).

### Why a custom MCP server?

Mainstream memory MCPs expose ~10 tools focused on key/value note-taking. project-nous needs **typed graph + document RAG + structural analytics in one engine**, with deterministic SQLite storage that lives inside the project folder. `rag-memory-epf-mcp` was extracted from this framework's actual usage and is published independently on npm.

---

## `/start` and `/sync` Workflows

Two slash commands carry the framework's day-to-day discipline. They are symmetrical — Step *N* of `/sync` writes what Step *N* of `/start` will read tomorrow.

### `/start` — restore 

1. Read `decisions/current-focus.md` (direction, blockers, next actions).
2. Read the latest daily log under `logs/YYYY-MM/`.
3. Read the Session Context Files listed in `current-focus.md`.
4. SDD status check (only if `specs/changes/` exists).
5. RAG-Memory 3-Tier search using dynamic keywords from the current focus.
6. Load User Preferences and Skill Usage from `wiki/project-context.md`.

The agent then reports current state in first-person ("I am this project, my current direction is …") rather than as an external summary.

### `/sync` — persist 

1. Update `current-focus.md` with what changed and the new next actions.
2. Append a daily log entry.
3. Update RAG-Memory entities/relations after Auto-Suggest approval.
4. Document Sync (5 mandatory steps: `delete → store → chunk → embed → link`) for any updated long-form docs.
5. Refresh `wiki/project-context.md` (Identity / Role / Current State).
6. Re-distill the Project Briefing in `AGENTS.md`.

Plus the five extensions (`+α … +ε`) described under Self-Evolution above. None auto-runs without user approval; the agent surfaces the trigger and waits.

---

## Protocols & Skills

### 10 Protocols

The agent loads these on demand, never all at once:

| Protocol | When |
|----------|------|
| `init-protocol.md` | First session (placeholder substitution) |
| `session-start-protocol.md` | Every `/start` |
| `direction-maintenance.md` | Every `/sync` |
| `rag-memory-sync-protocol.md` | When discrepancies are detected |
| `task-management-protocol.md` | Creating or managing tasks |
| `code-context-protocol.md` | Before writing or modifying code |
| `sdd-workflow.md` | Working on a new feature/spec (Spec-Driven Development) |
| `sdd-superpowers-integrated.md` | Medium+ feature — combines SDD gates with `superpowers` brainstorm/plan/execute |
| `writing-research-protocol.md` | Long-form writing or research |
| `knowledge-wiki-protocol.md` | Ingesting or distilling wiki pages |

### 6 Custom Skills

Under `.claude/skills/` (mirrored to other CLIs):

- **`qa`** — structured testing/validation pass on a deliverable.
- **`cso`** — chief-of-staff review across direction, blockers, follow-ups.
- **`deploy`** — release-readiness checklist for shippable artifacts.
- **`design-consultation`** — architectural review before implementation.
- **`plan-design-review`** — review a written plan against the spec it implements.
- **`research`** — multi-source research with citation discipline.

### Task Entry Rule

Workflow scales with task size — chosen before any work begins:

| Scale | With SDD | Without SDD |
|-------|----------|-------------|
| Trivial (typo, 1 line) | Direct edit | Direct edit |
| Small (< 10 lines, < 30 min) | `superpowers` only | `superpowers` only |
| Medium (3+ files, new component) | **Integrated workflow** (SDD gates + superpowers) | superpowers brainstorm → plan → execute |
| Large (architecture change) | **Integrated workflow (full)** | superpowers brainstorm → plan → execute |

---

## Use Cases

project-nous is project-type-agnostic. Real-world deployments cover:

- **Full-stack development** — web apps, learning management systems, e-commerce, blockchain services. The SDD workflow plus skills like `qa` and `deploy` keep specs, code, and ship-readiness aligned across sessions.
- **Domain-specific advisory systems** — legal, financial, regulatory compliance assistants where the same documents are queried repeatedly and answers must cite stable evidence. RAG-Memory's hybrid search and chunk-level entity linking are the load-bearing parts here.
- **Long-form writing** — fiction, memoir, technical documentation. Switches into Writing/Research mode (`writing-research-protocol.md`) with chapter and source tracking.
- **AI-augmented research and ideation** — brainstorming, multi-source consolidation, decision-record-driven exploration. The `research` skill and the Knowledge Wiki protocol handle ingest → distill cycles.
- **Polymath workspaces** — many concurrent projects with different agents (Claude / Codex / Gemini) without context bleed between them. Each project folder is its own intelligence; the framework's discipline is the same everywhere.
- **Business operations** — funding applications, recurring reporting, document workflows where last week's decisions must resurface accurately this week.

The common thread: **work that lives across many sessions**, where "what did we decide and why" matters as much as "what does the code do".

## How project-nous compares

| Tool | Coverage | Where project-nous fits |
|------|----------|-------------------------|
| Cursor / Claude Code (vanilla) | AI coding only | + knowledge management + self-evolution |
| Obsidian | Knowledge management only | + AI agent workflow integration |
| Notion + AI | Knowledge + lightweight AI | + real coding-agent integration |
| Jira / Linear / Asana | Static project management | A living, self-evolving project manager |
| Vanilla `CLAUDE.md` | Static rules file | Lessons accumulate; rules get promoted automatically |

---

## Status

This is **v1.0** — production-validated on a hidden internal workspace across 17 deployed projects (development, research, writing, business operations) and now opened to the public. The roadmap is conservative: respond to real-world reports first, then evolve.

## License

Apache-2.0 — see [LICENSE](LICENSE).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). The bar is high for "what becomes part of `_template/`" because every change cascades into every deployment. Issues for bugs, clarifications, and missing platforms are welcome.

## Acknowledgments

- Anthropic Claude Code skills (docx / pdf / pptx / xlsx pass-through bundled under `_template/.claude/skills/`)
- [`rag-memory-epf-mcp`](https://www.npmjs.com/package/rag-memory-epf-mcp) — the persistence engine
- [`superpowers`](https://github.com/obra/superpowers) — brainstorming / planning / TDD discipline integrated into the SDD workflow
