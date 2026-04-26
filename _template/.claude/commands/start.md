# /start — Session Start Protocol

> Designed 1:1 symmetrically with /sync. Restores the context of the previous session and continues work.
> Step 1↔1, 2↔2, 3↔3, 4↔4, 5↔5, 6↔6 — Save↔Read Symmetry.
>
> ⚠ **Body-Adapter Consistency**: This file must correspond 1:1 with the body of `docs/protocols/session-start-protocol.md`.
> If the body is modified, the identical change must be cascaded to all three CLI adapters (`.claude/commands/start.md`, `.codex/commands/start.md`, `.gemini/commands/start.toml`).
> Verify that each Step number matches the body before concluding the /start execution.
>
> **CRITICAL**: Execute the Steps below one by one using actual tool calls. Output the "Completion Report" only after all Steps have been actually executed. If you skip a step, you must specify the reason (e.g., "Step 4: skipped — `specs/changes/` does not exist").

## Step 1: Read current-focus.md (Grasp direction)

```
READ decisions/current-focus.md
```

- Updated date → calculate staleness (0-2 days Fresh, 3-6 days Stale, 7+ days Critical)
- Current Priority → primary direction
- Blockers → blocking elements
- Next Actions → tasks to do next
- Session Context Files → list of files to read in Step 3

## Step 2: Read latest daily log (Bridge between sessions)

```
GLOB logs/YYYY-MM/*.md → most recent file
READ [most recent log]
```

- Work summary of the last session
- Incomplete items
- Memos/TODOs

## Step 3: Read Session Context Files (Restore technical context)

```
READ each file in Session Context Files table
```

- Read sequentially the files recorded in current-focus.md
- Skip if empty

## Step 4: [Dev] SDD Status Check (Development projects only)

> Execute only in development projects where the `specs/changes/` folder exists. Skip if none.

```
GLOB specs/changes/*/tasks.md → check active changes
READ [active change tasks.md]
```

- Active Change ID (folder name)
- Total tasks vs completed tasks ([ ] / [x] count)
- Next incomplete task (first `[ ]` item)
- Current Phase

> **Note**: Do not read proposal.md, delta-specs/, or CODE_CONTEXT.md here.
> When the user starts implementation, the SDD protocol (`sdd-workflow.md`) auto-loads.

## Step 5: RAG-Memory Search (3-Tier Smart Search)

```
getKnowledgeGraphStats()
```

**3-Tier Search (Tier 1 → 2 → 3, skip lower tiers if upper tier is sufficient)**:
- **Tier 1**: `openNodes([exact entity name])` — When the name is known (~50 tokens)
- **Tier 2**: `searchNodes("[dynamic keyword]", limit=5)` — When only the concept is known (~200 tokens)
- **Tier 3**: `hybridSearch()` → `getDetailedContext()` — When document details are needed (~500 tokens)

- Use dynamic keywords (extracted from Current Priority/Blockers)
- Check Document sync status

## Step 6: Load User Preferences & Skill Usage

> Check sections G, H of wiki/project-context.md and apply them to this session.

```
READ wiki/project-context.md (Sections G, H)
```

- **User Preferences (H)**: Apply the user's preferred style and constraints throughout this session
- **Skill Usage (G)**: Identify and utilize frequently used skills

## Completion Report

> The report is not "an external observer listing data",
> but written in the format of "I, as this project, am perceiving the current state".

```markdown
## Session Start — Current State Perception

### My Current Direction
- [Describe what was read from current-focus.md in my own context]
- Last updated [N] days ago — [Fresh/Stale/Critical]
- Blocking elements: [Be specific if any, otherwise "None"]

### What I did last session
- **Date**: [from daily log]
- [Not a simple list, but what was done and why it's important with context]
- **Unfinished**: [Incomplete items and reasons]

### SDD Progress (Development projects only)
- [change-id]: [Completed]/[Total] tasks ([N]%)
- To do next: [First incomplete task]
- (Omit this section if none)

### My Knowledge State
- Knowledge Graph: Entities [N] / Relations [N] / Documents [N]
- [The meaning of accumulated knowledge in one line — e.g., "Accumulated 73 halal certification standards, secured domain expertise"]

### Recent Evolution
- [Search for [Evolution] tag in recent logs → summarize promoted rules, otherwise "None"]

### User Environment
- **User Preferences**: [Apply a 1-2 line summary of grasped user preferences]
- **Skill Usage**: [Key skills to utilize]

### What I need to do this session
[Synthesize current-focus.md Next Actions + daily log incomplete + SDD next task,
 describe with priority and reason. Not "what to do" but from the perspective of "what I need to do"]
```
