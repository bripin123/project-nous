# Contributing to project-nous

Thanks for your interest. This is a small project; the maintainer ships intentionally and conservatively.

## What helps most

- **Bug reports** — Something in `_template/` doesn't work as documented? Open an issue with the file path and what you observed.
- **Documentation clarifications** — A protocol step that was confusing? An unstated assumption? PRs welcome.
- **Adapter patches for CLI agents** — If a new Claude / Gemini / Codex CLI version changes the surface, send a small PR.

## What's harder to land

- **New protocols or skills** — `_template/` cascades into every deployment. New protocols need real-world evidence (one or more downstream uses) before they ship. Open a discussion first.
- **Major refactors** — Please open an issue or discussion before opening a large PR. The maintainer may have an in-flight plan that conflicts.

## Process

1. Fork, create a branch.
2. Make focused changes (one concern per PR).
3. Run `rg -P '[^\x00-\x7F]' .` — should return nothing.
4. Open a PR. Link to any related issue.
5. Expect feedback in a few days; ping politely if a week passes.

## Contact

For non-public matters — security disclosures, partnership inquiries, or anything not appropriate for a public issue — reach the maintainer at **heesong.koh@hotmail.com**. For everything else, please open a GitHub issue or discussion; public discussion is preferred.

## Code of Conduct

By participating, you agree to follow [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
