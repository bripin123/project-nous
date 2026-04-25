---
tags: [reference, skills, dev]
type: reference
aliases: [skill guide]
created: 2026-03-28
---

# Skills Guide — Workflow Auxiliary Tools

> 5 SDD skills + 1 Research skill derived from the gstack pattern + superpowers automatic triggers.
> Claude Code: `.claude/skills/` — invoke via `/command`. Gemini CLI: `.gemini/skills/[name]/SKILL.md` — mirrors the same functionality.
> Use alongside the SDD 7-Phase protocol, but each skill can also be invoked independently.
> (2026-04-14: Added Gemini skills descriptions. 2026-04-11: Added /research. 2026-04-10: Consolidated from 10→5)

---

## Overview

The SDD protocol (`docs/protocols/sdd-workflow.md`) has 6 items **automatically built-in**: Scope Challenge, Test Matrix, 2-Pass Code Review, Regression Test, Coverage Gate, and Document Sync. If you follow the SDD workflow, these 6 execute automatically without separate invocation.

The 6 skills below are **auxiliary tools manually invoked by the user when needed**.
Debugging (`superpowers:systematic-debugging`) and code review (`superpowers:requesting-code-review`) are automatically triggered by the superpowers plugin.

---

## Research Skill

### 6. `/research` — AI Research Automation

**Files**: `.claude/skills/research.md` | `.gemini/skills/research/SKILL.md`

**Purpose**: Receives a topic, automatically determines the research type (Quick/Practical/Deep/Academic), directly executes automatable steps (WebSearch, Gemini CLI, Chrome DevTools YouTube search, NotebookLM MCP), and waits after guiding the user for manual steps (Deep Research via Gemini/Claude/ChatGPT app).

**When to use**:
- Investigations requiring synthesis of multiple sources ("research this", "look into this")
- Market analysis, competitor comparison, technical investigation, academic literature search
- Excludes simple searches ("what is this?")

**Research Types**:
| Type | Criteria | Core Tools |
|------|----------|----------|
| Quick | Single fact confirmation | WebSearch + Gemini CLI |
| Practical Know-how | Tool/workflow comparison | NotebookLM + YouTube + Web |
| Deep | Market/policy/strategy analysis | NotebookLM + Manual Deep Research in parallel |
| Academic | Paper-based evidence | NotebookLM + Research Rabbit/Elicit |

**MCP Dependencies**: WebSearch, WebFetch, Gemini CLI, Chrome DevTools, NotebookLM MCP

**Note**: Can be invoked during the research phase of the Writing/Research protocol (`docs/protocols/writing-research-protocol.md`)

---

## SDD Skill List

### 1. `/plan-design-review` — Design Audit

**Files**: `.claude/skills/plan-design-review.md` | `.gemini/skills/plan-design-review/SKILL.md`

**Purpose**: Evaluate UI/UX design across 8 dimensions (consistency, accessibility, responsiveness, visual hierarchy, interaction, performance, typography, spacing) with a 0-10 score.

**When to use**:
- Verifying design quality after implementing frontend components
- Checking the application status of the design system
- When requesting UI review

**Output**: Score per dimension + rationale + AUTO-FIX/ASK categorized improvement suggestions

**Note**: Unnecessary for backend-only projects

---

### 2. `/design-consultation` — Design System Generation

**Files**: `.claude/skills/design-consultation.md` | `.gemini/skills/design-consultation/SKILL.md`

**Purpose**: Generate a design system (color palette, typography scale, spacing system, component patterns) tailored to the project.

**When to use**:
- Building a design system from scratch in a new frontend project
- When design unification is needed in an existing project
- Configuring Tailwind/CSS themes

**Output**: DESIGN.md + Tailwind/CSS configuration file modification suggestions

**Note**: If a design system already exists, it is more appropriate to audit it using `/plan-design-review`

---

### 3. `/qa` — QA Testing + Bug Fixing

**Files**: `.claude/skills/qa.md` | `.gemini/skills/qa/SKILL.md`

**Purpose**: Execute systematic QA testing. Fix bugs when found + automatically generate regression tests. 3 tiers (Quick/Standard/Exhaustive).

**When to use**:
- When additional QA is needed beyond the basic verification in SDD Phase 6 VERIFY
- Full quality check before release
- When you only want a bug report via `--report-only` mode

**Test Tiers**:
| Tier | Quick | Standard (Default) | Exhaustive |
|------|-------|----------------|------------|
| Scope | Critical+High | +Medium | +Low+Cosmetic |

**Core Rules**:
- 1 atomic commit per issue
- Automatically generate regression tests for all fixes (detects project conventions)
- Execute `git revert HEAD` if a fix causes a regression
- Auto-abort if 50+ issues are found

**Output**: QA Report (N items found, N items fixed, N regression tests, categorized by severity)

---

### 4. `/cso` — Security Audit

**Files**: `.claude/skills/cso.md` | `.gemini/skills/cso/SKILL.md`

**Purpose**: Code security inspection based on OWASP Top 10 + STRIDE threat modeling.

**When to use**:
- Working on authentication/login/session related code
- Implementing payment/financial logic
- Handling user data/personal information
- Before exposing API endpoints
- Working on code that accepts external input

**Inspection Items**:
- OWASP Top 10: Injection, Broken Auth, Data Exposure, XXE, Access Control, Misconfiguration, XSS, Deserialization, Known Vulnerabilities, Logging
- STRIDE: Spoofing, Tampering, Repudiation, Info Disclosure, DoS, Privilege Escalation

**Output**: Security Audit Report (CRITICAL/HIGH/MEDIUM/INFO categorization, suggest fix code)

---

### 5. `/deploy` — Deployment Pipeline

**Files**: `.claude/skills/deploy.md` | `.gemini/skills/deploy/SKILL.md`

**Purpose**: Batch execution of merge → CI wait → production verification → post-deploy monitoring.

**When to use**:
- Executing SDD Phase 7 DEPLOY
- Actual deployment after a PR is approved
- Checking readiness for deployment via `--dry-run` mode

**Protocol**:
1. Pre-Deploy Check (branch, tests, tasks.md)
2. Merge (PR creation/merge)
3. Deployment Execution (Auto-detect platform: Vercel/Docker/Fly.io, etc.)
4. Canary Monitoring (If `--canary` option)

**Output**: Deploy Report (Pre-Deploy status, Merge result, Deploy status, Canary result)

**Note**: Deployment commands are always executed after user confirmation

---

## Hooks (Automatic Operation)

Separate from Skills, the following 2 hooks always operate in the background:

### careful (Destructive command warning)
- **File**: `.claude/hooks/check-careful.sh`
- **Trigger**: Before executing Bash tools (PreToolUse)
- **Action**: Warns upon detecting destructive commands like `rm -rf`, `DROP TABLE`, `git push --force`
- **Exceptions**: Build artifact directories like `node_modules`, `dist`, `__pycache__` are allowed

### freeze (Lock edit scope)
- **File**: `.claude/hooks/check-freeze.sh`
- **Trigger**: Before executing Edit/Write tools (PreToolUse)
- **Enable**: `echo "/path/to/dir/" > ~/.gstack/freeze-dir.txt`
- **Disable**: `rm ~/.gstack/freeze-dir.txt`
- **Action**: Warns upon attempt to edit files outside the freeze directory

---

## Skill Mapping per SDD Phase

```
Phase 1: SPECIFY
  └── [Built-in] EARS requirements writing

Phase 2: DESIGN
  ├── (Optional) /plan-design-review — UI projects
  ├── (Optional) /design-consultation — If design system is needed
  └── [Built-in] Scope Challenge 5 checks

Phase 3: PLAN
  └── [Built-in] Test Matrix + Coverage Diagram

Phase 4: CONTRACT
  └── [Built-in] Agree on completion criteria

Phase 5: IMPLEMENT
  ├── (Auto) superpowers:systematic-debugging — When bugs occur
  └── [Built-in] Implement referencing CODE_CONTEXT.md

Phase 6: VERIFY
  ├── (Optional) /qa — If additional QA is needed
  ├── (Optional) /cso — Security sensitive code
  ├── (Auto) superpowers:requesting-code-review — Code review
  ├── [Built-in] 2-Pass Code Review
  ├── [Built-in] Regression Test mandatory
  └── [Built-in] Coverage Gap verification

Phase 7: DEPLOY
  ├── (Optional) /deploy — Execute deployment pipeline
  ├── [Built-in] Ship Readiness Gate
  └── [Built-in] Document Sync
```

---

## References

- **SDD Protocol**: `docs/protocols/sdd-workflow.md`
- **Original Reference**: [gstack](https://github.com/garrytan/gstack) — Patterns derived from Garry Tan's development workflow automation tool
- **Skill File Location (Claude)**: `.claude/skills/`
- **Skill File Location (Gemini)**: `.gemini/skills/[name]/SKILL.md`
- **Hook File Location**: `.claude/hooks/`
