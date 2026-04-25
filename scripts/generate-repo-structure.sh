#!/usr/bin/env bash
# Generate docs/reference/repo-structure.md — a flat snapshot of the repository layout.
# Run after adding, removing, or moving folders that change the project structure.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="$ROOT_DIR/docs/reference/repo-structure.md"
TODAY="$(date +%F)"

# Preserve original created date if file already exists
if [[ -f "$OUTPUT_FILE" ]]; then
  CREATED="$(sed -n 's/^created: //p' "$OUTPUT_FILE" | head -n 1)"
else
  CREATED="$TODAY"
fi

mkdir -p "$(dirname "$OUTPUT_FILE")"

# --- Pruned directories (never included in output) ---
PRUNE_DIRS=(
  node_modules .next dist .git coverage
  .DS_Store .temp .tmp __pycache__ .venv
  .tox .mypy_cache .pytest_cache .eggs
)

build_prune_expr() {
  local expr=""
  for d in "${PRUNE_DIRS[@]}"; do
    [[ -n "$expr" ]] && expr="$expr -o "
    expr="$expr-name $d"
  done
  echo "$expr"
}

PRUNE_EXPR="$(build_prune_expr)"

append_section() {
  local title="$1"
  local base="$2"
  local maxdepth="$3"

  # Skip if directory does not exist
  [[ -d "$ROOT_DIR/$base" ]] || return 0

  {
    printf '## %s\n\n' "$title"
    printf '```text\n'
    (
      cd "$ROOT_DIR"
      eval "find \"$base\" -maxdepth $maxdepth \\( $PRUNE_EXPR \\) -prune -o -print" \
        | sed 's#^\./##' \
        | grep -Ev '(^|/)(\.DS_Store|\.temp|\.tmp)$' \
        | sort
    )
    printf '```\n\n'
  } >> "$OUTPUT_FILE"
}

# --- Write header ---
cat > "$OUTPUT_FILE" <<EOF
---
created: $CREATED
type: reference
tags:
  - reference
  - architecture
  - repo-structure
aliases: [repository structure, file structure, repo tree]
---

# Repository Structure

> Generated snapshot of the current repository layout.
> Curated architecture notes stay in [[CODE_CONTEXT]].

**Last Generated**: $TODAY

## Refresh

Run \`bash scripts/generate-repo-structure.sh\` after adding, removing, or moving folders that change the project structure.

EOF

# --- Always: top level ---
append_section "Top Level" "." 1

# --- Auto-discover source directories ---
for candidate in src client server app lib packages; do
  if [[ -d "$ROOT_DIR/$candidate" ]]; then
    # Capitalise first letter for section title (macOS-compatible)
    title="$(echo "$candidate" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')"
    # Look for nested src/ (e.g. client/src, server/src)
    if [[ -d "$ROOT_DIR/$candidate/src" ]]; then
      append_section "$title Source" "$candidate/src" 3
    else
      append_section "$title" "$candidate" 3
    fi
  fi
done

# --- Standard project directories ---
append_section "Docs"    "docs"    2
append_section "Specs"   "specs"   3
append_section "Scripts" "scripts" 2

echo "Generated: $OUTPUT_FILE"
