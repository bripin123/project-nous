#!/bin/bash
# /freeze hook — Lock edit scope
# Executed during PreToolUse(Edit|Write)
# Enable: echo "/path/to/dir/" > ~/.gstack/freeze-dir.txt
# Disable: rm ~/.gstack/freeze-dir.txt

FREEZE_FILE="${HOME}/.gstack/freeze-dir.txt"

# Pass if freeze is inactive
if [ ! -f "$FREEZE_FILE" ]; then
  echo '{"decision":"approve"}'
  exit 0
fi

FREEZE_DIR=$(cat "$FREEZE_FILE" | tr -d '\n')

if [ -z "$FREEZE_DIR" ]; then
  echo '{"decision":"approve"}'
  exit 0
fi

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  echo '{"decision":"approve"}'
  exit 0
fi

# Verify if the file path is within the freeze directory
case "$FILE_PATH" in
  ${FREEZE_DIR}*)
    echo '{"decision":"approve"}'
    ;;
  *)
    echo "{\"decision\":\"ask\",\"message\":\"🔒 Freeze active: Attempting to edit a file outside ${FREEZE_DIR} — ${FILE_PATH}. Allow?\"}"
    ;;
esac
