"""PostToolUse Hook: Auto-record to daily log when AI modifies a file"""
import sys
import json
import os
from datetime import datetime
import pathlib

PROJECT_ROOT = str(pathlib.Path(__file__).resolve().parent.parent.parent)
LOGS_BASE = os.path.join(PROJECT_ROOT, "logs")

try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")
    tool_name = data.get("tool_name", "")

    if not file_path:
        sys.exit(0)

    now = datetime.now()
    month_dir = os.path.join(LOGS_BASE, now.strftime("%Y-%m"))
    os.makedirs(month_dir, exist_ok=True)

    log_file = os.path.join(month_dir, now.strftime("%Y-%m-%d") + ".md")
    time_str = now.strftime("%H:%M")

    # Record relative to project root
    short_path = file_path
    if file_path.startswith(PROJECT_ROOT):
        short_path = file_path[len(PROJECT_ROOT):].lstrip(os.sep)
    elif len(file_path) > 80:
        short_path = "..." + file_path[-70:]

    entry = f"- {time_str} [{tool_name}] {short_path}\n"

    if not os.path.exists(log_file):
        header = f"# {now.strftime('%Y-%m-%d')} — Auto Log\n\n## Files Changed (auto)\n"
        with open(log_file, "w", encoding="utf-8") as f:
            f.write(header)

    with open(log_file, "r", encoding="utf-8") as f:
        content = f.read()

    if "## Files Changed (auto)" not in content:
        content += "\n## Files Changed (auto)\n"
        with open(log_file, "w", encoding="utf-8") as f:
            f.write(content)

    check_str = f"{time_str} [{tool_name}] {short_path}"
    if check_str not in content:
        with open(log_file, "a", encoding="utf-8") as f:
            f.write(entry)

except Exception:
    pass

sys.exit(0)
