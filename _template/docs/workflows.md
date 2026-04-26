# AI Memory Management - Workflow Guide

> **Purpose**: Practical workflows for the 3-Layer Defense system
> **Target**: All project types (Development, Research, Writing)

---

## 🔑 Core Principle: Independent Project Management

### ⚡ Independent Execution per Project

**Each project is executed completely independently.**

```bash
# Work on project A
cd /path/to/project-A
claude  # uses project-A/.memory/rag-memory.db

# Work on project B
cd /path/to/project-B
claude  # uses project-B/.memory/rag-memory.db (completely separated from A)
```

**Important**: AI CLIs **only access the `.memory/` of the current directory**.

### 🚫 Absolute Prohibitions

```bash
# ❌ Prohibited to share .memory/ across projects
→ Decisions, logs, and project status must ONLY be in the respective project's .memory/
→ Do not reference or share the .memory/ of other projects

# ✅ Correct Structure
Local Project/.mcp.json (Claude Code MCP settings)
Local Project/.gemini/settings.json (Gemini CLI MCP settings)
Local Project/.codex/config.toml (Codex CLI MCP settings)
→ Each CLI references the same .memory/rag-memory.db in its own configuration
→ DB_FILE_PATH: "./.memory/rag-memory.db"

Local Project/.claude/settings.json + settings.local.json
→ settings.json: Git-committed minimal structure
→ settings.local.json: Git-ignored, Claude Code permission settings
```

### ✅ Correct Workflow

**When switching projects**:
1. Move to the current project folder: `cd /path/to/project`
2. Execute AI CLI: `claude` / `gemini` / `codex`
3. AI automatically loads this project's `.memory/`
4. Exit CLI after work is complete
5. Repeat from step 1 to switch to another project

**Advantages of independent management**:
- ✅ Zero context crosstalk between projects
- ✅ Copying project folder = Includes all context
- ✅ Deleting project = Automatically deletes all Memory
- ✅ Can work on multiple projects simultaneously (each is independent)

---

## 📋 Table of Contents

1. [New Project Start Workflow](#1-new-project-start-workflow)
2. [Daily Work Workflow](#2-daily-work-workflow)
3. [Project Resume Workflow](#3-project-resume-workflow)
4. [Decision Recording Workflow](#4-decision-recording-workflow)
5. [Cross-CLI Workflow](#5-cross-cli-workflow)
6. [Task Management Workflow](#6-task-management-workflow)
7. [Troubleshooting Workflow](#7-troubleshooting-workflow)
8. [Direction Maintenance Workflow](#8-direction-maintenance-workflow)

---

## 1. New Project Start Workflow

### Step 1: Copy Template (1 min)

```bash
# 1. Copy template to the new project
cd /path/to/template-project
cp -r _template/. /path/to/new-project/

# 2. Move to the new project
cd /path/to/new-project/
```

### Step 2: CLI Selection and Configuration (30 sec)

**Claude Code Users**:
```bash
# Create AGENTS.md → CLAUDE.md symlink
ln -s AGENTS.md CLAUDE.md

# Execute Claude Code
claude
```

**Gemini CLI Users**:
```bash
# .gemini/settings.json already has contextFileName: "AGENTS.md" set
gemini
```

**Codex CLI Users**:
```bash
# AGENTS.md auto-supported (v0.27+)
codex
```

### Step 3: Request AI Initialization (1 min)

Copy-paste prompt:

```
Please help initialize the project.

Project Info:
- Name: [Project Name]
- Goal: [1-2 lines description]
- Type: [development/research/writing/data-analysis]
- Core Tech: [Python/React/etc.]

Tasks:
1. Replace all {{PLACEHOLDERS}} in AGENTS.md with actual values
2. Initialize RAG-Memory MCP (Create project entity)
3. Create Decision 1: "Adopt 3-Layer Defense system"
4. Create the first log file with today's date (logs/YYYY-MM/DD.md)
5. Update README.md

Summarize the current project status upon completion.
```

### Step 4: Verification (30 sec)

```
Please query the project information stored in RAG-Memory.
```

**Expected Results**:
- Project name displayed accurately
- Goal description confirmed
- Decision 1 existence confirmed
- Today's log file creation confirmed

### ✅ Done!

Now, as you work normally, the AI will automatically:
- Update RAG-Memory MCP in real-time
- Record important decisions in `decisions/`
- Record work history in `logs/`

---

## 2. Daily Work Workflow

### Morning: Resume Project

**Claude Code**: Execute `/start` (Auto-restore).
**Other CLIs**: "Restore the project status from RAG-Memory and suggest the next task"

> Details: `docs/protocols/session-start-protocol.md`

### During Work: Converse as Usual

```
"Implement the authentication system"
"Write the test code"
"Fix this bug"
```

**AI in the background will**:
- ✅ Auto-update RAG-Memory MCP
- ✅ Track major changes
- ✅ Maintain context (auto-connect related info via semantic search)

### Crucial Moments: Record Decisions

```
Record this decision as Decision [Number]:

Title: Use REST API instead of GraphQL
Reason:
- High team familiarity
- Mainly simple CRUD
- Easy caching implementation

Impact:
- API design pattern
- Client library selection
```

**AI automatically**:
- Updates `decisions/core-decisions.md`
- Creates an entity in RAG-Memory MCP
- Establishes relationships with related components
- Records in today's log

### Evening: Wrap up the Day

**Claude Code**: Execute `/sync` (Auto-save).
**Other CLIs**: "Summarize today's work, record it in RAG-Memory and logs, and update current-focus.md"

> Details: `docs/protocols/direction-maintenance.md`

---

## 3. Project Resume Workflow

**Claude Code**: Execute `/start` — Automatically restores in the order of current-focus → daily log → Session Context Files → SDD status → RAG-Memory.

> Details: `docs/protocols/session-start-protocol.md`

Verify context with specific questions after restoration:
```
"What is the status of the authentication system we worked on last?"
"Why did we choose REST instead of GraphQL?"
```

Resume work after verification:
```
"Then let's proceed with [next task]."
```

---

## 4. Decision Recording Workflow

### When to create a Decision?

**YES - Create a Decision**:
- ✅ Architectural choices (frameworks, libraries, patterns)
- ✅ Tech stack decisions
- ✅ Design direction changes
- ✅ Important trade-offs
- ✅ Project scope changes

**NO - Do not create a Decision**:
- ❌ Minor code edits
- ❌ Bug fixes (simple)
- ❌ Routine refactoring
- ❌ Document typo fixes

### Decision Writing Workflow

#### Step 1: Check Decision Number

```
"What is the next Decision number in decisions/core-decisions.md?"
```

#### Step 2: Request Decision Writing

```
Create Decision [Number]:

Title: [Decision Title]

Context:
[Why this decision was needed]

Options Considered:
1. [Option A]: [Pros/Cons]
2. [Option B]: [Pros/Cons]
3. [Option C]: [Pros/Cons]

Decision: [Final Choice]

Rationale:
- [Reason 1]
- [Reason 2]
- [Reason 3]

Impact:
- [Affected Area 1]
- [Affected Area 2]

Trade-offs:
- Pros: [...]
- Cons: [...]
```

#### Step 3: Verify RAG-Memory Sync

```
"Check if this Decision is also stored in the RAG-Memory MCP and
show the relationships with related entities."
```

---

## 5. Cross-CLI Workflow

### Scenario: Switch from Claude Code → Gemini CLI

#### Work in Claude Code (Day 1)

```bash
# In the project folder
claude
```

```
Implement the authentication system:
- JWT-based
- Redis session storage
- Refresh token logic
```

**AI works and updates RAG-Memory**

#### Switch to Gemini CLI (Day 2)

```bash
# In the same project folder
gemini
```

```
Load the authentication system status from RAG-Memory and
write unit tests.
```

**Gemini CLI instantly**:
- Loads the same `.memory/rag-memory.db`
- Uses the context saved by Claude Code yesterday (utilizing semantic search)
- Generates consistent test code

#### Back to Claude Code (Day 3)

```bash
claude
```

```
Restore the work context up to yesterday from RAG-Memory.
```

**Continue working perfectly synchronized**

### Precautions for Simultaneous Use

⚠️ **Do NOT run multiple CLIs simultaneously**

```bash
# ❌ Bad Example
# Terminal 1
claude

# Terminal 2 (simultaneously)
gemini
```

**Reason**: Potential concurrent write conflict to `.memory/rag-memory.db` (SQLite lock)

✅ **Correct Method**: Use only one CLI at a time

---

## 6. Task Management Workflow

> Detailed procedure: `docs/protocols/task-management-protocol.md`
> Dev project SDD: `docs/protocols/sdd-workflow.md`

### Example: Task + RAG-Memory Integration

```
Work Example:

1. Task Creation:
   → Task: Implement payment system

2. Auto-sync to RAG-Memory MCP:
   → Entity: "Task: Implement payment system"
   → Relation: depends_on → "Task: Implement API authentication"

3. Connect with Decision:
   → Relation: implements → "Decision 15 - Stripe payment gateway"

4. Query Example:
   "Show me all tasks and decisions related to payment."
   → Provides integrated results of Task + Decision + RAG-Memory
```

### Checklist

#### Task Management Initialization
```
□ current-focus.md Next Actions cleanup complete
□ tasks.md checklist ready (if necessary)
□ First TASK entity creation complete
□ Dependency / phase structure reflection complete
```

#### Daily Work
```
□ Check next task in current-focus.md and TASK entity
□ Update task status (start/complete)
□ Add to TASK entity and tasks.md when new tasks are needed
□ Verify sync with RAG-Memory MCP
```

#### Weekly Review
```
□ Review completed tasks
□ Check blocked/deferred tasks
□ Adjust priorities for next week
□ Verify consistency between RAG-Memory MCP and current-focus/tasks
```

---

## 7. Troubleshooting Workflow

### Problem: RAG-Memory is empty

#### Diagnosis

```
Check the number of entities stored in RAG-Memory.
```

**Result**: 0 entities

#### Resolution

```
Please initialize the RAG-Memory MCP.

Project Info:
- Name: [...]
- Goal: [...]
- Start Date: [...]

And create all Decisions in decisions/core-decisions.md
as entities in RAG-Memory.
```

### Problem: Different project context

#### Diagnosis

```bash
# Check current folder
pwd

# Check DB path in MCP config (per CLI)
grep DB_FILE_PATH .mcp.json              # Claude Code
grep DB_FILE_PATH .gemini/settings.json   # Gemini CLI
grep DB_FILE_PATH .codex/config.toml      # Codex CLI
```

**Identify Cause**:
- In the wrong folder
- Global RAG-Memory MCP config interference

#### Resolution

```bash
# Move to the correct project
cd /correct/project/path

# Remove the rag-memory section from the global MCP config (if using only in project scope)

# Restart CLI
```

### Problem: AGENTS.md is not loading

#### Diagnosis

**Claude Code**:
```bash
ls -la | grep -E "(AGENTS|CLAUDE)\.md"
```

**Gemini CLI**:
```bash
cat .gemini/settings.json | grep contextFileName
```

**Codex CLI**:
```bash
ls -la AGENTS.md
```

#### Resolution

**Claude Code**:
```bash
# Create Symlink
ln -s AGENTS.md CLAUDE.md
```

**Gemini CLI**:
```json
// Add to .gemini/settings.json
{
  "contextFileName": "AGENTS.md",
  ...
}
```

**Codex CLI**:
```bash
# Ensure AGENTS.md is in the project root
# Auto-supported in v0.27+
```

---

## 💡 Pro Workflows

### Weekly Review Workflow

```
Please review this week's work:

1. Analyze all logs this week from logs/
2. List of Decisions created this week
3. Summarize major changes from RAG-Memory
4. Propose priorities for next week
```

### New Team Member Onboarding Workflow

```
Create a project summary for a new team member:

1. Project overview from RAG-Memory
2. Top 10 core decisions from decisions/
3. Current architecture diagram
4. Propose the first task to get started
```

### Refactoring Workflow

```
I'm planning to refactor [Component].

First:
1. Query all Decisions related to this component in RAG-Memory
2. Analyze dependency relationships
3. Identify other affected components
4. Propose a safe refactoring plan
```

### Bug Fixing Workflow

```
I'm trying to fix [Bug].

First:
1. Query the history of related components in Memory
2. Search logs/ to see if there was a similar issue before
3. Check if there is a related Decision
4. Propose a fix after root cause analysis
```

---

## 📊 Checklist

### Start New Project

```
□ Template copy complete
□ CLI config check (.claude/ or .gemini/ or .codex/)
□ AGENTS.md exists (Claude Code is CLAUDE.md symlink)
□ Memory MCP initialization complete
□ Decision 1 record complete
□ First log file creation complete
□ README.md update complete
```

### Daily Work

```
□ Morning: Restore yesterday's work from Memory
□ Work: Proceed as usual
□ Upon important decision: Record Decision
□ Evening: Record today's work in logs/
```

### Weekly Review

```
□ Review this week's logs/
□ Review new Decisions
□ Check Memory status
□ Plan for next week
```

---

---

## 8. Direction Maintenance Workflow (🧭 Direction Maintenance)

**Claude Code**: Processed automatically when saving a session with the `/sync` command.

Detailed workflow (update current-focus, recover direction, resolve Blockers, change priority):
→ Refer to `docs/protocols/direction-maintenance.md`

---

*This workflow is part of the 3-Layer Defense system*
