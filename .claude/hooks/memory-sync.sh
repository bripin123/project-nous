#!/bin/bash
# memory-sync.sh - Universal bidirectional Claude Code memory sync
# Usage: memory-sync.sh pull|push
# Works on both Windows (Git Bash) and Mac

DIRECTION="${1:-pull}"

# Project root (2 levels up from .claude/hooks/)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd)"
SHARED_MEM="$PROJECT_ROOT/.shared-memory"
PROJECT_NAME="$(basename "$PROJECT_ROOT")"

# Find local Claude Code memory directory for this project
# Claude encodes paths: /Users/foo/project → -Users-foo-project
find_local_mem() {
    local projects_dir="$HOME/.claude/projects"
    [ -d "$projects_dir" ] || return 1
    # Exact match: encode PROJECT_ROOT the same way Claude does
    local encoded=$(echo "$PROJECT_ROOT" | sed 's|/|-|g')
    if [ -d "$projects_dir/$encoded" ]; then
        echo "$projects_dir/$encoded/memory"
        return 0
    fi
    # Fallback: find directory containing the full project name
    for dir in "$projects_dir"/*/; do
        local dirname="$(basename "$dir")"
        if echo "$dirname" | grep -q "$(echo "$PROJECT_NAME" | sed 's/ /-/g')"; then
            echo "${dir}memory"
            return 0
        fi
    done
    return 1
}

LOCAL_MEM="$(find_local_mem)"
[ -z "$LOCAL_MEM" ] && exit 0

mkdir -p "$LOCAL_MEM" "$SHARED_MEM"

sync_newer() {
    local src="$1" dst="$2"
    for file in "$src"/*.md; do
        [ -f "$file" ] || continue
        local fname="$(basename "$file")"
        local dest="$dst/$fname"
        if [ ! -f "$dest" ] || [ "$file" -nt "$dest" ]; then
            cp "$file" "$dest"
        fi
    done
}

case "$DIRECTION" in
    pull) sync_newer "$SHARED_MEM" "$LOCAL_MEM" ;;
    push) sync_newer "$LOCAL_MEM" "$SHARED_MEM" ;;
    *) exit 1 ;;
esac
