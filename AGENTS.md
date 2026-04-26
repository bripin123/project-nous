# project-nous (repository guide)

> This file is for AI agents working on the **project-nous repository itself** —
> not for projects bootstrapped from the framework.
> If you cloned this repo to start a new project, see `_template/AGENTS.md` instead.

---

## What this repo is

`project-nous` is the public release of an AI Project Lifecycle Framework. The framework lives entirely inside `_template/` — that subfolder is the deliverable users copy into their own projects.

Everything outside `_template/` (this file, `README.md`, `LICENSE`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `.github/`) is repository metadata: it explains the project to first-time visitors and governs contributions.

## Layout

```
project-nous/
├── README.md            ← public landing page (what / why / quickstart)
├── LICENSE              ← Apache-2.0
├── CONTRIBUTING.md      ← contribution guide
├── CODE_OF_CONDUCT.md   ← Contributor Covenant 2.1
├── .github/             ← issue / PR templates
└── _template/           ← THE FRAMEWORK ITSELF
    ├── AGENTS.md, CODE_CONTEXT.md, GEMINI.md, 00-Dashboard.md
    ├── decisions/       ← blueprint with example decisions
    ├── docs/            ← framework reference + protocols
    ├── wiki/            ← self-knowledge SSOT template
    ├── .claude/, .codex/, .gemini/   ← CLI adapters
    ├── .shared-memory/, scripts/, specs/, raw/
    └── .mcp.json, .mcp.json_win
```

## What to edit, where

| Change type | Edit here |
|-------------|-----------|
| Public-facing copy (landing page, contribution rules) | Root `README.md`, `CONTRIBUTING.md` |
| Framework behavior (protocols, skills, adapters) | `_template/` |
| New issue / PR template | `.github/` |
| License terms | Do not edit `LICENSE` (Apache-2.0 is fixed) |

When you change anything inside `_template/`, you are changing what every downstream user gets. Be deliberate.

## Translation note

`_template/` was translated 1:1 from a private Korean canonical workspace. Sanitization removed personal identifiers, real project names, and local paths. If you spot a residue, treat it as a bug and file an issue.

## Quickstart for working on this repo

```bash
git clone https://github.com/bripin123/project-nous.git
cd project-nous
# Edit _template/... or root metadata
git add <files>
git commit -m "<conventional message>"
```

For the agent operating model used inside `_template/` (Slim Router, /start, /sync, RAG-Memory layered defense, Knowledge Wiki, etc.), open `_template/AGENTS.md` — that file is the entry point for agents working on a project bootstrapped from the framework.

---

*This file describes the public release wrapper.*
*The framework itself lives in `_template/`.*
