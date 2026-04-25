"""SessionStart Hook (compact): Auto-reinject core context after compaction

Output to stdout will be automatically injected into Claude's context.
"""
import os
import glob
import pathlib

BASE = str(pathlib.Path(__file__).resolve().parent.parent.parent)

# 1. Read current-focus.md
focus_path = os.path.join(BASE, "decisions", "current-focus.md")
if os.path.exists(focus_path):
    with open(focus_path, "r", encoding="utf-8") as f:
        content = f.read()
    lines = content.splitlines()
    if len(lines) > 50:
        lines = lines[:50]
        lines.append("... (truncated)")
    print("## [Compaction Recovery] Current Focus")
    print("\n".join(lines))
    print()

# 2. Last 30 lines of the recent daily log
logs_dir = os.path.join(BASE, "logs")
log_files = sorted(glob.glob(os.path.join(logs_dir, "*", "????-??-??.md")))
if log_files:
    latest = log_files[-1]
    with open(latest, "r", encoding="utf-8") as f:
        log_lines = f.readlines()
    tail = log_lines[-30:] if len(log_lines) > 30 else log_lines
    print(f"## [Compaction Recovery] Latest Log: {os.path.basename(latest)}")
    print("".join(tail))
    print()

# 3. Core Reminders
print("## [Compaction Recovery] Reminders")
print(f"- Project root: {BASE}")
print("- logs/ path: logs/ within the project folder")
