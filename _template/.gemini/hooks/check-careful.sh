#!/bin/bash
# /careful hook — Warning before executing destructive commands
# Executed during PreToolUse(Bash)

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  echo '{"decision":"approve"}'
  exit 0
fi

# Safe directories (build artifacts, etc.)
SAFE_DIRS="node_modules|\.next|dist|__pycache__|\.cache|build|\.turbo|coverage|\.mypy_cache|\.pytest_cache"

# Destructive patterns detection
DESTRUCTIVE_PATTERNS=(
  'rm -rf'
  'rm -r '
  'DROP TABLE'
  'DROP DATABASE'
  'TRUNCATE'
  'git push --force'
  'git push -f'
  'git reset --hard'
  'git checkout \.'
  'git clean -f'
  'docker rm -f'
  'docker system prune'
  'kubectl delete'
)

for pattern in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    # Allow if targeting safe directories
    if echo "$COMMAND" | grep -qE "($SAFE_DIRS)"; then
      echo '{"decision":"approve"}'
      exit 0
    fi
    echo "{\"decision\":\"ask\",\"message\":\"⚠️ Destructive command detected: $pattern — Are you sure you want to execute this?\"}"
    exit 0
  fi
done

echo '{"decision":"approve"}'
