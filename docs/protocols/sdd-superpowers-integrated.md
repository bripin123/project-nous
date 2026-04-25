---
created: 2026-04-09
type: protocol
tags:
  - protocol
  - sdd
  - superpowers
  - integrated
aliases: [Integrated Workflow]
---

# SDD + superpowers Integrated Workflow

> A unified workflow combining SDD's quality gates with superpowers' execution capability.
> Replaces SDD Phase 3 (PLAN) and Phase 5 (IMPLEMENT) with superpowers.
> All other SDD gates remain as-is.

---

## Why Integrate?

| System | Strengths | Weaknesses |
|--------|------|------|
| **SDD** | Quality Gates (Scope Challenge, Contract, Test Matrix, 2-Pass Review, Ship Readiness) | Lacks task granularity, no execution mode |
| **superpowers** | Execution power (brainstorm, bite-sized plan, subagent execution, fresh context) | No quality gates, auto-triggers skip SDD |

**Problem**: Auto-triggering superpowers causes SDD to be bypassed.
**Solution**: Apply priority rules in AGENTS.md (AGENTS.md > superpowers skill).

---

## Entry Criteria by Scale

| Task Scale | Workflow | Required Quality Gates |
|----------|-----------|----------------|
| **Trivial** (Typo, 1 line) | Direct edit | None |
| **Small** (< 10 lines, < 30 mins) | superpowers alone OK | Optional |
| **Medium** (3+ files, new component) | **Integrated Workflow** | Scope Challenge + Contract + Test Matrix |
| **Large** (Architecture change) | **Integrated Workflow (Full)** | All gates |

**Judgment Criteria**: Modifying 3+ files or creating a new function/component → Medium or higher.

---

## Integrated Phase Flow

```
┌──────────── SDD Quality Gates ────────────┐
│                                           │
│  Phase 2: SCOPE CHALLENGE                 │
│  └─ 5-item over-engineering prevention    │
│     → see sdd-workflow.md Phase 2c        │
│                                           │
│  Phase 4: CONTRACT                        │
│  └─ Agree on completion criteria          │
│     → see sdd-workflow.md Phase 4         │
│                                           │
└───────────────────┬───────────────────────┘
                    ▼
┌──────── superpowers Execution ────────────┐
│                                           │
│  brainstorm → writing-plans               │
│  └─ 2-5 min tasks + include actual code   │
│  └─ Specify Create/Modify/Test per file   │
│                                           │
│  subagent-driven execution                │
│  └─ fresh context per task                │
│  └─ inline execution is also an option    │
│                                           │
└───────────────────┬───────────────────────┘
                    ▼
┌──────────── SDD Quality Gates ────────────┐
│                                           │
│  Phase 6: VERIFY                          │
│  └─ Test Matrix + 2-Pass Review           │
│  └─ Gradable Criteria (UI changes)        │
│     → see sdd-workflow.md Phase 6         │
│                                           │
│  Phase 7: SHIP                            │
│  └─ Ship Readiness Gate (7 gates)         │
│  └─ Document Sync + Archive               │
│     → see sdd-workflow.md Phase 7         │
│                                           │
└───────────────────────────────────────────┘
```

---

## Phase Details

### Phase 2: SCOPE CHALLENGE (As-is from SDD)

> See `sdd-workflow.md` Phase 2c. Mandatory before implementation.

| # | Check | On Failure |
|---|------|--------|
| 1 | **Code Reuse**: Is there a reusable function/module in existing code? | Use existing |
| 2 | **Minimal Scope**: Minimal change to satisfy requirements? | Reduce scope |
| 3 | **Complexity Smell**: Modifying 8+ files or 2+ new classes? | Consider splitting |
| 4 | **Framework Built-in**: Feature already in framework/library? | Use built-in |
| 5 | **Test Goal**: Set a 100% coverage goal for changed code | — |

### Phase 4: CONTRACT (As-is from SDD)

> See `sdd-workflow.md` Phase 4. Define specifically "what complete means" before coding.

- Write verifiable completion criteria for each task
- UI → What should happen on which screen
- API → Which endpoint should return what response
- Begin implementation after user confirmation

### Phase 3→ superpowers writing-plans (Replacement)

> Replace SDD Phase 3 (PLAN) with the superpowers `writing-plans` skill.

**Improvements over SDD**:
- Checkbox list → **2-5 minute bite-sized tasks + actual code included**
- Descriptive file list → **Create/Modify/Test + exact line numbers specified per file**
- Self-review checklist (spec coverage, placeholder scan, type consistency)

**Save Location**: `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`

### Phase 5→ superpowers subagent-driven execution (Replacement)

> Replace SDD Phase 5 (IMPLEMENT) with superpowers execution mode.

**Execution Mode Selection**:
1. **Subagent-Driven (Recommended)** — fresh agent per task, review between tasks
2. **Inline Execution** — sequential execution in the current session, review at checkpoints

**Improvements over SDD**:
- Manual progression → **Auto-execution + fresh context per task (prevents context contamination)**
- Automatically transitions to Phase 6 (VERIFY) after execution

### Phase 6: VERIFY (As-is from SDD)

> See `sdd-workflow.md` Phase 6. Maintain entirely.

- A. Code Verification (tests + type check + lint)
- B. Live Verification (Chrome DevTools MCP)
- C. Contract Checking
- D. 2-Pass Code Review (CRITICAL + INFORMATIONAL)
- E. Coverage Gap Verification
- Gradable Criteria (for UI changes)

### Phase 7: SHIP (As-is from SDD)

> See `sdd-workflow.md` Phase 7. Maintain entirely.

- Ship Readiness Gate (7 gates)
- Document Sync (Code↔Document synchronization)
- Archive (`specs/changes/<id>` → archive)
- Merge Proposal

---

## How to use specs/changes/

Use the `specs/changes/` structure even in the integrated workflow:

```
specs/changes/[change-id]/
├── proposal.md          # Phase 2 Scope Challenge + Phase 4 Contract results
├── tasks.md             # Link to or summary of the superpowers plan
└── delta-specs/
    └── [capability].spec.md
```

- `proposal.md`: Records Scope Challenge results + Contract (completion criteria)
- `tasks.md`: References the superpowers plan file path (`→ docs/superpowers/plans/...`)
- `delta-specs/`: Write Delta Spec if needed (ADDED/MODIFIED/REMOVED)

---

## References

- [[sdd-workflow]] — Detailed SDD 7-Phase (Phase 2c, 4, 6, 7)
- superpowers `writing-plans` skill — Plan writing rules
- superpowers `subagent-driven-development` skill — Execution mode
- superpowers `brainstorming` skill — Design exploration
