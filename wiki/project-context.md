---
created: 2026-04-14
type: wiki
tags:
  - wiki/project-context
  - topic/self-knowledge
aliases: [project context]
---

# Project Context — Template Preview

> Init Protocol replaces this file with actual project-specific content.
> This stub is the minimum structure for lint, tool loading, and index linking.

---

## A. Identity
<!-- Auto-updated by /sync -->
- [2026-04-14] Template preview only. Run `docs/protocols/init-protocol.md` to create project-specific context.

## B. Role
<!-- Auto-updated by /sync -->
- [2026-04-14] Used only as a template preview until Init.

## C. Current State
<!-- Auto-updated by /sync — Replaced every session -->
- [2026-04-14] Waiting for project initialization.

## D. Domain Knowledge
<!-- Added after Auto-Suggest approval -->
- (None yet)

## E. Patterns
<!-- Added after Auto-Suggest approval -->
- (None yet)

## F. Gotchas
<!-- Added after Auto-Suggest approval -->
- (None yet)
- [2026-04-15] **Beware the "memory-anchored snap-answer trap" (Differential re-verification cost)**: Even right after establishing 102/102 md5 ALL GREEN in sessions 5~6, you must not give a snap answer without re-verification to "did it match" type questions in the next session. **Session 5 itself is a prime example of "record ≠ reality"** (Session 4 recorded "100% match" vs. `.claude/commands/sync.md` 144 lines incomplete, Step 6/7/+γ/+ε missing for months). Records only show the author's intent and do not guarantee the current actual state. **Rule**: Lightweight verification (md5/wc/ls, cost near 0) must be executed regardless of drift signal presence. Heavy verification (grep/read/structural analysis) is trigger-based (right after edit/suspected drift/+γ Lint). A new manifestation of "clean-generalization bias" — "verified once, so no need to re-verify" is a clean rule created by bias.
- [2026-04-25] **Conclusion frame obscures factual breakdown**: When answering analysis/evaluation/classification/comparison/diagnosis, if the conclusion frame ("X = Category A", "This doesn't work", "Y is better", etc.) is established first, the actual factual/component breakdown is obscured. If the frame comes first, facts become secondary. This is accompanied by the side effect of fabricating unverified numbers (e.g., "30K lines / 6-12 months") to defend the frame. **Application areas** (Not just comparison): All 5 areas - comparison (X vs Y), classification (what category?), evaluation (is it good/bad?), analysis (what is it?), diagnosis (why doesn't it work?) share the same mechanism. **Why**: It is a new manifestation of the "clean-generalization bias", but the mechanism is different: "conclusion frame → blocks breakdown". A clean frame hides the complexity of facts. **How to apply**: (1) Create a factual/component breakdown table **first** before answering, (2) make the frame conclusion after filling the table, (3) self-check the opposing frame when making a single-frame conclusion, (4) specify the calculation basis or note as "estimate" when making numerical claims, (5) 5 prompt safety belt — "Breakdown first, conclusion later", "Basis for numerical calculations", "Actual fetch/read", "Review both frames", "Answer after self-checking wiki F"

## G. Skill Usage (Which skills are actually used)
<!-- Auto-updated by /sync +ε-3 -->
| Skill | Usage Count | Last Used | Notes |
|-------|----------|-----------|------|
| (Auto-added upon skill usage) | | | |

- Skill unused for 3+ continuous /sync → Suggest as cleanup candidate
- Session ad-hoc recurring pattern → Suggest as new skill candidate (/sync +ε-1)

## H. User Preferences (User's work style and preferences)
<!-- Auto-updated by /sync +ε-4 -->
- (Auto-added preferences detected during session, max 10)
- Detection criteria: Explicit expression or implicit repetition (same modification request 2+ times)

---

*Last synced: 2026-04-14 by template preview refresh*
