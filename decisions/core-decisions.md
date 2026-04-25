# Core Decisions

> A running log of decisions that shape this project. Each entry captures **what was decided, why, and what changed** — so future you (and future agents) can reconstruct the reasoning, not just the outcome.

---

## D1: <Title of the first decision>

- **Date**: YYYY-MM-DD
- **Context**: <The problem or question that prompted this decision.>
- **Rationale**: <Why this option over the alternatives.>
- **Impact**: <What changes after this decision — files, behavior, conventions.>

## D-Example: Adopt 3-Layer Defense in Depth

- **Date**: 2025-10-01
- **Context**: Long Claude Code sessions lost project context after compaction; we needed a recovery path measured in seconds, not minutes.
- **Rationale**: Layered storage (RAG-Memory + files + Obsidian) gives multiple recovery routes with different speed/depth trade-offs. No single layer can fail catastrophically.
- **Impact**: All projects bootstrapped from this template start with `_template/.memory/`, `decisions/`, and Obsidian-aware frontmatter. /start can restore in 5–60 seconds.

---

> Add new entries with the next available number (D2, D3, …). Keep entries concise; details belong in `logs/YYYY-MM/` or `wiki/`.
