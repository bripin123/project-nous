# project-nous

> A persistent project intelligence framework for AI-augmented work.

**Tagline:** *The personal workbench for polymaths working with AI.*
AI coding + knowledge management + self-evolution, unified into one project skeleton.

---

## Why project-nous?

You spin up many projects with AI assistants. The session ends. The next session starts blank. The agent forgets why you made the decision you made yesterday, and asks again.

**project-nous** treats your project folder itself as the persistent intelligence — and your AI model as the swappable execution engine. Decisions, patterns, gotchas, and direction live in the folder, structured so any AI agent (Claude Code, Gemini CLI, Codex CLI) can reload context in seconds.

You only make decisions. The system maintains the rest.

## Quickstart (5 minutes)

```bash
# 1. Copy the template into a new project
cp -r project-nous/_template ~/projects/my-new-project
cd ~/projects/my-new-project

# 2. Open in Claude Code, Gemini CLI, or Codex CLI
# 3. The agent reads AGENTS.md → loads protocols → ready
```

See `_template/AGENTS.md` for the full entry-point.

## Architecture: 3-Layer Defense in Depth

| Layer | Recovery Time | Purpose | Implementation |
|-------|---------------|---------|----------------|
| **Layer 1** | 5 sec | Instant restore | RAG-Memory MCP (entity-relation-observation graph + vector search) |
| **Layer 2** | 30 sec | File backup | `decisions/` + `logs/` |
| **Layer 3** | 5 min | Visualization | Obsidian Graph View (folder is also a vault) |

Each layer can fail without losing the others.

## How project-nous compares

| Tool | Coverage | Where project-nous fits |
|------|----------|-------------------------|
| Cursor / Claude Code (vanilla) | AI coding only | + knowledge management + self-evolution |
| Obsidian | Knowledge management only | + AI agent workflow integration |
| Notion + AI | Knowledge + lightweight AI | + real coding-agent integration |
| Jira / Linear / Asana | Static project management | A living, self-evolving project manager |
| Vanilla CLAUDE.md | Static rules file | Lessons accumulate; rules get promoted |

## What's inside `_template/`

- **`AGENTS.md`** — Slim Router. The first file an agent reads. Routes by task type.
- **`decisions/core-decisions.md`** — A running log of why you chose what you chose.
- **`decisions/current-focus.md`** — Living document: where are you right now?
- **`docs/protocols/`** — `/start`, `/sync`, RAG-Memory sync, knowledge wiki, task management, code-context, SDD workflow.
- **`wiki/project-context.md`** — Self-knowledge SSOT in 8 sections (Identity / Architecture / Domain / History / Patterns / Gotchas / Skill Usage / User Preferences).
- **`.claude/`, `.codex/`, `.gemini/`** — Adapters for three CLI agents, byte-identical bodies.
- **`.claude/skills/`** — Six custom skills: qa, cso, deploy, design-consultation, plan-design-review, research.

## Status

This is **v1.0** — production-validated on a hidden internal workspace and now opened to the public. Roadmap is conservative: respond to real-world reports first, then evolve.

## License

Apache-2.0 — see [LICENSE](LICENSE).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). The bar is high for "what becomes part of `_template/`" because every change cascades into every deployment. Issues for bugs and clarifications are welcome.

## Acknowledgments

Built atop Anthropic Claude Code skills (docx/pdf/pptx/xlsx pass-through) and the [`rag-memory-epf-mcp`](https://www.npmjs.com/package/rag-memory-epf-mcp) MCP server.
