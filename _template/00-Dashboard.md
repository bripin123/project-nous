---
type: dashboard
tags: [dashboard, topic/overview]
created: 2026-04-16
---

# 00-Dashboard

> Project overview dashboard — Auto-updated via Obsidian Dataview
> For AI direction summary, see [[decisions/current-focus|current-focus.md]]
> Recommended to pin to Obsidian Bookmarks for one-click access
> **Required Plugin**: Dataview (Settings > Enable JavaScript Queries ON)
>
> **Deployment Setup**: Change `__VAULT_PATH__` in all `FROM` paths below to the vault-relative path of this project.
> Example: `__VAULT_PATH__` → `projects/MyProject`

---

## 🔑 Quick Links

- [[decisions/current-focus|📍 Current Focus]] — AI Direction + Next Actions
- [[decisions/core-decisions|⚖️ Core Decisions]] — Core decision history
- [[wiki/index|📖 Wiki Index]] — Knowledge wiki list
- [[wiki/project-context|🧬 Project Context (SSOT)]] — Identity / Patterns / Gotchas
- [[CLAUDE|📋 CLAUDE.md]] — AI behavior rules

---

<!--
============================================================
  🔴📅📋 Work Items / Calendar block (optional)
  Use only in projects that have the inbox/Work/_ACTIVE/
  and inbox/Work/Calendar/ structures. Otherwise, delete this whole section.
============================================================
-->

## 🔴 Urgent Work Items

```dataview
TABLE WITHOUT ID
  link(file.path, aliases[0]) AS "Work Item",
  status AS "Status",
  dateformat(started, "MM-dd") AS "Started"
FROM "__VAULT_PATH__/inbox/Work/_ACTIVE"
WHERE file.name = "STATUS" AND contains(status, "🔴")
SORT started ASC
```

---

## 📅 Upcoming Schedule

```dataview
TABLE WITHOUT ID
  title AS "Event",
  dateformat(date, "MM-dd (EEE)") AS "Date",
  choice(allDay, "All Day", startTime + "~" + endTime) AS "Time",
  color AS "Category"
FROM "__VAULT_PATH__/inbox/Work/Calendar"
WHERE date >= date(today)
SORT date ASC
LIMIT 10
```

> Color legend: `red` urgent / `orange` in-progress / `blue` my business / `green` schedule / `yellow` backlog

---

## 📋 All Work Items

```dataview
TABLE WITHOUT ID
  link(file.path, aliases[0]) AS "Work Item",
  status AS "Status",
  dateformat(started, "yyyy-MM-dd") AS "Started"
FROM "__VAULT_PATH__/inbox/Work/_ACTIVE"
WHERE file.name = "STATUS"
SORT choice(contains(status, "🔴"), "1", choice(contains(status, "🟡"), "2", choice(contains(status, "🟢"), "3", "4"))) ASC
```

<!--
============================================================
  End of Work Items / Calendar optional block
============================================================
-->

---

## 📜 Recent Session Logs

```dataview
TABLE WITHOUT ID
  file.link AS "Log",
  dateformat(file.mtime, "yyyy-MM-dd HH:mm") AS "Modified"
FROM "__VAULT_PATH__/logs"
SORT file.name DESC
LIMIT 7
```

---

## 🧠 Wiki

```dataview
TABLE WITHOUT ID
  file.link AS "Page",
  choice(updated, dateformat(updated, "yyyy-MM-dd"), dateformat(created, "yyyy-MM-dd")) AS "Updated"
FROM "__VAULT_PATH__/wiki"
WHERE type = "wiki"
SORT file.mtime DESC
```

---

## ⚖️ Decisions

```dataview
LIST
FROM "__VAULT_PATH__/decisions"
WHERE !contains(file.folder, "archives")
SORT file.mtime DESC
```

---

## 🔗 Recently Modified Files

```dataview
TABLE WITHOUT ID
  file.link AS "File",
  dateformat(file.mtime, "MM-dd HH:mm") AS "Modified"
FROM "__VAULT_PATH__"
WHERE file.name != "00-Dashboard"
SORT file.mtime DESC
LIMIT 15
```

---

## ⚠️ Orphan Wiki Pages

> Wiki files not linked from any other file. Normal if 0.

```dataview
LIST
FROM "__VAULT_PATH__/wiki"
WHERE type = "wiki" AND length(file.inlinks) = 0 AND file.name != "index"
```

---

## 🏷️ Project Modes

> To be activated after multi-label flags (`modes: [assistant, meta]`) implementation
> Details: [[wiki/project-modes-and-hybrid-design|Project Modes and Hybrid Design]]

<!--
Uncomment the query below after implementing the _template/ modes flag schema:

```dataview
TABLE WITHOUT ID
  link(file.path, aliases[0]) AS "Work Item",
  modes AS "Modes",
  status AS "Status"
FROM "__VAULT_PATH__/inbox/Work/_ACTIVE"
WHERE file.name = "STATUS" AND modes
SORT modes ASC
```
-->

---

*Dataview Auto-Update | Recommended to pin to Bookmarks*
