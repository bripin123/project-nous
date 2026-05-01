---
tags: [protocol, sdd, dev]
type: protocol
aliases: [SDD, spec-driven development]
created: 2026-03-02
---

# Spec-Driven Development (SDD) Workflow

> Applies only to software development projects. Skip for documentation/planning projects.
> A framework combining Spec-first + Delta workflow + AI quality gates.

---

## Core Concept

**From "Vibe Coding" to "Spec-Driven Development"**

Roughly requesting via natural language (Vibe Coding) fails in complex projects.
A clear Spec document determines AI coding quality.

**3 Pillars**:
- **Spec-first**: Create the spec before the code
- **Delta workflow**: Do not overwrite the master spec directly; work isolated in change/proposal/delta
- **AI quality gates**: Scope Challenge, Contract, Test Matrix, 2-Pass Review, Ship Readiness

---

## Entry Criteria by Scale

Not every change requires the full 7-Phases.

| Change Scale | Example | Applied Phases | Notes |
|----------|------|-----------|------|
| **Bug fix** | Error fix, restoring intended behavior | 5→6 | Spec unnecessary. Implement + Verify immediately. Regression test required |
| **Small** | Config change, UI text edit, < 10 lines | 5→6 | Spec unnecessary. Implement + Verify immediately |
| **Medium** | New feature, add API, modify existing behavior | 2→3→4→5→6→7 | Start with Scaffold. Contract + Verify required |
| **Large** | Architecture change, multi-module, Breaking change | 1→2→3→4→5→6→7 | Full 7-Phase. Start from PRD/TRD |

**Judgment Criteria**: Modifying 3+ files or creating a new function/component → Medium or higher.

---

## 7-Phase Workflow

```
Phase 1: SPECIFY ──→ Phase 2: DESIGN ──→ Phase 3: PLAN
                                            ↓
Phase 4: CONTRACT ──→ Phase 5: IMPLEMENT ──→ Phase 6: VERIFY ──→ Phase 7: DEPLOY
```

**Core (Always Execute)**: Phase 4 CONTRACT → Phase 5 IMPLEMENT → Phase 6 VERIFY
**Optional (Depending on scale)**: Phase 1, 2, 3, 7

---

### Phase 1: SPECIFY (Requirements Definition)

> For Large changes or starting a new project. Medium starts from Phase 2.

**When starting a new project**:
```
specs/master/requirements.md — PRD (EARS syntax)
specs/master/design.md — TRD (Technical Design)
```

**EARS Syntax** (Easy Approach to Requirements Syntax):
```markdown
### FR-001: [Feature Name]
**Priority**: High | Medium | Low
- **When** [Trigger condition]
- **The system SHALL** [System behavior]
- **So that** [User value]

**Acceptance Criteria**:
- [ ] Criterion 1
- [ ] Criterion 2
```

**Optional Skill**: `superpowers:brainstorming` — Define via brainstorm when requirements are unclear (auto-trigger)

---

### Phase 2: DESIGN (Design + Prevent Over-engineering)

> Explore existing code first, create an isolated workspace with Scaffold.

**2a. Explore**:
```
1. searchNodes("[feature keyword]") → check relevant entities
2. Understand existing code structure via Glob/Grep
3. Check relevant requirements in specs/master/requirements.md
4. Check patterns in CODE_CONTEXT.md
```

**2b. Scaffold (Create isolated workspace)**:

Create the following structure:
- `specs/changes/[change-id]/proposal.md` — Why and what is changing
- `specs/changes/[change-id]/tasks.md` — Implementation checklist
- `specs/changes/[change-id]/delta-specs/[capability].spec.md` — Spec changes (ADDED/MODIFIED/REMOVED)

**Delta Spec Rules** (OpenSpec core):
- `## ADDED|MODIFIED|REMOVED|RENAMED Requirements` section required
- `### Requirement:` block must contain `SHALL` or `MUST`
- At least 1 `#### Scenario:` per Requirement (GIVEN/WHEN/THEN)

**2c. Scope Challenge (Prevent Over-engineering)** — Mandatory before implementation:

| # | Check | On Failure |
|---|------|--------|
| 1 | **Code Reuse**: Is there a reusable function/module in existing code? | Use existing |
| 2 | **Minimal Scope**: Minimal change to satisfy requirements? Exclude "might need later" | Reduce scope |
| 3 | **Complexity Smell**: Modifying 8+ files or 2+ new classes? | Consider splitting |
| 4 | **Framework Built-in**: Is the feature already in the framework/library? | Use built-in |
| 5 | **Test Goal**: Set a 100% coverage goal for changed code | — |

Scope Challenge Failure → Re-evaluate after modifying design.

**2d. Domain Modeling (Optional — when the domain is genuinely complex)**:

For complex business domains, consider DDD strategic patterns:
- **Bounded Context**: define the boundary where this model applies consistently
- **Aggregate**: identify the cluster of objects that must hold an invariant together + the Root entity
- **Ubiquitous Language**: align on domain vocabulary → crystallize as RAG-Memory entity types (e.g., STOCK/SIGNAL/STRATEGY)

Skip for CRUD-heavy or simple domains — the overhead exceeds the value.

**Optional Skills**:
- `/plan-design-review` — Frontend design 0-10 audit
- `/design-consultation` — Create design system (new frontend)

---

### Phase 3: PLAN (Task Breakdown + Test Plan)

**3a. Write tasks.md**:
- Task breakdown per phase (each task = a unit completable with one AI prompt)
- Indicate dependency order
- Track progress with `[ ]` checkboxes

**3b. Test Matrix** — Establish test plan before implementation:

1. **Code Path Tracing**: Identify all branches in the target files
   - Conditionals, error handlers, guard clauses, external calls
2. **Existing Test Mapping**:
   - `★★★` Edge cases+errors | `★★` Happy path only | `★` Smoke | `GAP` None
3. **Coverage Diagram**:
```
[+] src/services/payment.ts
    ├── processPayment()
    │   ├── [★★★] Success + Card declined + Timeout
    │   ├── [GAP]  Network error path
    │   └── [GAP]  Invalid currency code
    ├── refund()
    │   └── [★]    Smoke test only

COVERAGE: 3/8 paths (37%)
GAPS: Need tests for 5 paths (2 E2E, 3 Unit)
```
4. **Test Classification**: `[Unit]` Pure function | `[E2E]` Integration flow | `[Eval]` LLM prompt validation
5. **Regression Rule**: Modifying existing code + no tests → Auto-add to test plan

**Record Test Matrix in `tasks.md` under the `## Test Plan` section.**

---

### Phase 4: CONTRACT (Agree on Definition of Done) — Core, Always Execute

> Define specifically "what complete means" before coding.

```
1. Write verifiable completion criteria for each task in tasks.md
2. UI → What should happen on which screen
3. API → Which endpoint should return what response
4. DB → What data should be in what state
5. Begin implementation after user confirmation
```

Completion criteria are recorded in `tasks.md` or `proposal.md`.
During Fresh-Context Execution → Include in Context Packet under `## Success Criteria`.

---

### Phase 5: IMPLEMENT — Core, Always Execute

- Read `proposal.md` + `delta-specs/*.md` + `CODE_CONTEXT.md`
- Implement **one task at a time**
- When complete, change `[ ] → [x]` in `tasks.md`

**Hooks (Auto-trigger)**:
- `check-careful.sh` — Warns on destructive commands (rm -rf, git push --force, etc.)
- `check-freeze.sh` — Blocks edits outside specified directories when freeze is active
- `log-file-change.py` — Auto-logs all file changes to the daily log

**Optional Skill**: `superpowers:systematic-debugging` — Structured debugging if bugs occur (auto-trigger)

---

### Phase 6: VERIFY — Core, Always Execute

Mandatory execution after implementing each task. Sequence: A → B → C → D → E.

**A. Code Verification** (All projects):
1. Run tests (pytest, vitest, jest, etc.)
2. Type check (pyright, tsc, etc.)
3. Confirm Lint passes

**B. Live Verification** (UI/API projects):
1. Manipulate actual app via Chrome DevTools MCP
2. Check API responses
3. Verify DOM/DB states
4. Capture screenshots

**C. Contract Checking**:
- Check the completion criteria agreed upon in Phase 4 one by one
- If unfulfilled → Report specific defects and fix

**D. 2-Pass Code Review**:

| Pass | Scope | Action |
|------|------|------|
| **Pass 1 — CRITICAL** | SQL injection, Race condition, XSS, LLM trust boundary, Enum completeness | Fix immediately (without asking) |
| **Pass 2 — INFORMATIONAL** | Dead code, N+1, stale comments, magic numbers, unused variables, version mismatch → **AUTO-FIX** | Fix mechanically + 1-line summary |
| | Security design decisions, race condition resolution direction, enum completeness impact, user-visible changes → **ASK** | Ask the user individually |

**E. Coverage Gap Verification**:
1. Check actual coverage against Phase 3 Test Matrix
2. If tests not created for `[GAP]` items → Create tests
3. Re-print Coverage Diagram:
```
BEFORE: 3/8 paths (37%)
AFTER:  8/8 paths (100%)
New tests: 5 (Unit 3, E2E 2)
```
4. **Coverage Gate**: Changed code coverage < 80% → Report to user + suggest additional tests

**Regression Test Mandatory Rules**:
- Modifying existing code + no tests → Auto-create regression test (without asking)
- Bug fix → Must include test reproducing the bug
- Read 2-3 existing tests in the project to match conventions (naming/import/assertion)
- Add attribution comment: `// Regression: [Bug/Change description]`
- Exclude pure CSS/cosmetic changes

**Gradable Criteria** (Only for Frontend/UI changes):

| Criteria | Evaluation Content | Weight |
|------|----------|--------|
| Quality | Visual consistency, alignment, spacing, color | 30% |
| Craft | Responsiveness, animation, accessibility, performance | 30% |
| Functionality | User flow, interaction, error states | 30% |
| Originality | Custom design vs default template | 10% |

**Execution Method**:
1. Capture screenshot after implementation (or check live via Chrome DevTools MCP)
2. Write score per criteria + one-line rationale
3. **Hard Threshold**: Weighted average < 6.0 → Feedback specific defects and loop fix
4. Report results to the user (scorecard + improvement suggestions)

```
Example:
Quality:       8/10 — Spacing/alignment consistent, slight lack of contrast in dark mode
Craft:         7/10 — Responsive OK, keyboard navigation not implemented
Functionality: 9/10 — Error states + loading + empty states all handled
Originality:   6/10 — Basic Tailwind components, minimal brand customization

Weighted Average: 7.7/10 ✅ (passes threshold 6.0)
Improvement Suggestions: Dark mode contrast, keyboard accessibility
```

**Feedback Loop on Failure**:
- Document defects specifically → Fix → Re-verify
- 2 Failures → Structured debugging with `superpowers:systematic-debugging`
- 3 Failures → Escalate to user

**Optional Skills**:
- `/qa` — QA testing + bug fixes + regression test
- `/cso` — Security audit (OWASP Top 10 + STRIDE)
- `superpowers:requesting-code-review` — Code review (auto-trigger)

---

### Phase 7: DEPLOY

> Optional. Only when PR merge/deploy is needed.

#### Ship Readiness Gate (Comprehensive pre-deploy check)

| Gate | Check Content | On Failure |
|--------|----------|---------|
| **Tests** | Entire suite passes | Abort immediately |
| **Type Check** | 0 tsc/pyright errors | Abort immediately |
| **Lint** | Rules pass | Abort immediately |
| **Pass 1 CRITICAL** | 0 security/race/injection issues | Abort immediately |
| **tasks.md** | Check incomplete tasks | Report to user (implement/defer/remove) |
| **Coverage** | ≥ 80% | Report to user |
| **Contract** | All completion criteria met | Report to user |

#### Document Sync (Code↔Document Synchronization)

Analyze `git diff <base>...HEAD`:

- **Auto Fix (Factual)**: File paths, counts, version numbers, stale links, API endpoints
- **User Confirmation (Narrative)**: Architecture descriptions, security models, README feature descriptions, VERSION bumps
- **CHANGELOG Protection**: NEVER modify/delete existing items. Append new items only.

**Targets**: README.md, AGENTS.md, specs/master/*.md, CHANGELOG.md, tasks.md

#### Archive (Cleanup after completion)
- Move `specs/changes/<id>` → `specs/changes/archive/YYYY-MM-DD-<id>/`
- Add completion summary to `Recent Changes` in `specs/master/tasks.md`

#### Merge Proposal (AI Suggests → Executes on Approval)
```
The <change-id> work is complete. Please suggest contents to reflect (merge) into specs/master.
- delta-specs/*.md and rationale for code changes
- Specify which files to modify
- Provide approval options only (no auto-execution)
```

**Optional Skill**: `/deploy` — Merge→CI→Deploy→Monitoring pipeline

---

## Folder Structure

```
specs/
├── master/
│   ├── requirements.md   # PRD (Source of Truth)
│   ├── design.md         # TRD (Source of Truth)
│   └── tasks.md          # Global roadmap + Recent Changes
└── changes/
    ├── [change-id]/
    │   ├── proposal.md   # Why, what is changing
    │   ├── tasks.md      # Implementation checklist + Test Plan
    │   └── delta-specs/
    │       └── [capability].spec.md
    └── archive/          # Completed changes
```

---

## OpenSpec Scripts

## SDD + RAG-Memory Integration

| Timing | Action |
|------|------|
| Feature Start | Create Phase Entity `"Phase: feat-[name]"` + Task Entities, Relations: `part_of`, `depends_on`, `blocks` |
| Task Complete | Task entity status `pending → done`, Phase completion % auto-calculated |
| Feature Complete | Move to specs/ archive + Update RAG-Memory entity status + Propose merge to specs/master/ |

---

## Specs Auto-Update Rules

| Event | Target | Action | Executor |
|--------|------|------|----------|
| Task Complete (`[x]`) | `specs/changes/[feat]/tasks.md` | Record Status + Delta | AI (Auto) |
| Spec Change | `specs/changes/[feat]/delta-specs/` | Modify Requirements/Design | AI (After user confirmation) |
| Execute Archive | `specs/master/tasks.md` | Transfer Recent Changes | AI (After user confirmation) |
| General Work | `specs/master/tasks.md` | Direct update | AI (Auto) |

---

## Document Stack

### Layer 1: Requirements Document

| Document | Purpose | Format |
|------|------|------|
| **PRD** | Business/User requirements | Markdown |
| **requirements.md** | Formalized requirements via EARS syntax | Markdown |

### Layer 2: Technical Design Document

| Document | Purpose | Format |
|------|------|------|
| **TRD** | Tech stack, architecture decisions | Markdown |
| **design.md** | System design, diagrams, schema | Markdown + Mermaid |

### Layer 3: Implementation Plan Document

| Document | Purpose | Format |
|------|------|------|
| **tasks.md** | Implementation task list, dependencies, progress | Markdown |

---

## PRD/TRD Creation Workflow (Large Change / New Project)

```
[1] DRAFT PROPOSAL → [2] REVIEW & ALIGN → [3] IMPLEMENT & ARCHIVE
```

**Stage 1: DRAFT PROPOSAL**
```
I want to start a new project/feature: [brief description]

Please create the following:
1. specs/master/requirements.md - PRD
2. specs/master/design.md - TRD
```

**Stage 2: REVIEW & ALIGN**
```
Please review the specs in specs/master/:
- Are the requirements clear and verifiable?
- Does the tech stack meet the requirements?
- Are there missing requirements or designs?
```

**Stage 3: IMPLEMENT & ARCHIVE**
```
Based on the specs/:
1. Create tasks.md
2. Start work and activate Delta Tracking
3. Archive to decisions/ upon completion
```

---

## Available Skills (Full Reference)

> Also mentioned inline per Phase, but a reference table for an at-a-glance view.

| Skill | Purpose | When to Use |
|-------|------|----------|
| `/plan-design-review` | Design 0-10 score audit | Phase 2 Frontend Design |
| `/design-consultation` | Create design system | Starting a new Frontend Project |
| `superpowers:systematic-debugging` | Structured debugging (auto-trigger) | Bug occurs during Phase 5 Implementation |
| `/qa` | QA test + bug fix + regression test | Need extra QA after Phase 6 VERIFY |
| `/cso` | Security audit (OWASP Top 10 + STRIDE) | Code handling auth/payment/sensitive data |
| `superpowers:requesting-code-review` | Code review (auto-trigger) | Need independent validation of major change |
| `/deploy` | Deploy pipeline (Merge→CI→Deploy→Monitor) | Executing Phase 7 DEPLOY |

Detailed usage: See `docs/skills-guide.md`

---

## Best Practices

1. **Docs First**: specs/ first → code later
2. **Small Units**: One prompt = One Task
3. **Verification Loop**: Always verify AI-generated code (3 failures → Escalate)
4. **Context Management**: Provide only needed context via CODE_CONTEXT.md + specs/
5. **Scope Challenge**: Check for over-engineering before implementation (5 checks)
6. **Test Matrix First**: Plan tests before implementation → Verify Coverage Gaps after
7. **Regression Test Mandatory**: Auto-create when modifying existing code / fixing bugs
8. **2-Pass Review**: CRITICAL first, INFORMATIONAL later
9. **Ship Readiness Gate**: Deploy only after passing all gates
10. **Document Sync**: Auto-detect code↔document mismatches before deployment

---

## References

- [Spec-Driven Development - ThoughtWorks](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices)
- [Kiro.dev](https://kiro.dev/)
- [Cursor Rules Documentation](https://docs.cursor.com/context/rules)
