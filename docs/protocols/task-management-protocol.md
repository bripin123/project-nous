---
tags: [protocol, task-management]
type: protocol
aliases: [task management]
created: {{CREATED_DATE}}
---

# Task Management Protocol

> Task management integrated through Layer 1 RAG-Memory + Layer 2 files.

**SSOT Rule**: If `specs/*/tasks.md` exists, the file is the SSOT (RAG-Memory mirrors it). Otherwise, the RAG-Memory TASK entity is the SSOT.

---

## Task Entity Structure

```
Entity Name: "Task: [Task Title]"
Entity Type: "TASK"
Observations:
  - "Status: pending | in_progress | done"
  - "Priority: high | medium | low"
  - "Progress: [0-100]%"
  - "Phase: [Phase Name]"
  - "Created: YYYY-MM-DD"
  - "Completed: YYYY-MM-DD" (if done)
  - "[Additional context/notes]"

Relations:
  - Task --[depends_on]--> Other Task
  - Task --[blocks]--> Other Task
  - Task --[part_of]--> Phase Entity
  - Task --[implements]--> Decision Entity
  - Task --[has_subtask]--> Subtask Entity
```

---

## Task Lifecycle

```
pending → in_progress → done
    ↑         ↓
    └── blocked (by dependency)
```

**Auto-updates on Status Change**:

| Status Change | Auto-Update |
|----------|--------------|
| → in_progress | Add to Active Work in current-focus.md |
| → done | Remove from current-focus.md, record in logs/, Progress 100% |
| → blocked | Add to Blockers section, specifying the blocking task |

---

## Dependency Management

| Relation Type | Meaning | Example |
|--------------|------|------|
| `depends_on` | Prerequisite task needed | Task B depends_on Task A |
| `blocks` | Blocks another task | Task A blocks Task B |
| `parallel_with` | Can run concurrently | Task C parallel_with Task D |

---

## Phase Organization

```
Entity Name: "Phase: [Phase Name]"
Entity Type: "PHASE"
Observations:
  - "Phase Number: [N]"
  - "Description: [Phase description]"
  - "Task Count: [N]"
  - "Completion: [0-100]%"
  - "Status: not_started | in_progress | completed"

Relations:
  - Phase --[contains]--> Task Entity (multiple)
  - Phase --[follows]--> Previous Phase
```

---

## Subtask Management

```
Parent Task: "Implement Authentication"
├── Subtask: "Setup JWT library"
├── Subtask: "Create auth middleware"
└── Subtask: "Write unit tests"
```

Parent Progress = (Completed Subtasks / Total Subtasks) * 100

---

## Next Task Recommendation

**AI Auto-Recommendation Logic**:
1. Filter tasks where all dependencies are completed
2. Sort by Priority (high > medium > low)
3. Consider Phase order
4. Check number of currently in_progress tasks

**Recommendation Response Format**:
```markdown
## Next Task Recommendation

### Recommended Task
- **Task**: [Task Name]
- **Priority**: high
- **Phase**: Phase 2
- **Reason**: All dependencies completed, highest priority

### Also Available
1. [Task B] - medium priority
2. [Task C] - low priority

### Blocked Tasks (cannot start)
1. [Task D] - waiting for: [Task A]
```

---

## Task-Decision Linking

- Upon creating a Decision, search for related tasks and suggest linking
- Upon completing a Task, update the progress of related Decisions

---

## Commands Summary

```
# Task CRUD
"Create new task: [Title], Phase: [N], Priority: [high/medium/low]"
"Change [Task Name] status to [status]"
"Mark [Task Name] as done and update current-focus.md"

# Dependencies
"Set [Task A] as depends_on for [Task B]"
"Show all dependencies for [Task Name]"

# Phases
"Show current phase progress"
"Transition to the next phase"

# Recommendations
"Recommend the next task"
"Show tasks I can do today"
```
