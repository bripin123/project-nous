#!/usr/bin/env bash
# audit-rag-memory.sh — RAG-Memory DB Integrity Audit (Read-only)
#
# Usage:
#   ./scripts/audit-rag-memory.sh [DB_PATH]
#
# If DB_PATH is omitted, uses .memory/rag-memory.db in the project root.
#
# Audit items (read-only, does not auto-fix):
#   1. Environment   — Can load brew sqlite3 + sqlite-vec (vec0)
#   2. Integrity     — PRAGMA integrity_check
#   3. Foreign keys  — PRAGMA foreign_key_check
#   4. Migration     — schema_migrations table version + pending check
#   5. Types         — entity/relation type count (drift monitoring)
#   6. Orphan meta   — entity_embedding_metadata without entity
#   7. Orphan vec0   — entity_embeddings without metadata (vec0 rowid)
#   8. Missing embed — entity without embedding (silent search failure)
#   9. Corrupted id  — damaged id patterns like entity_[_]+
#
# Output: ✓/⚠/✗ per item + overall verdict (GREEN/YELLOW/RED)
# Exit code: 0=green, 1=yellow, 2=red, 3=environment error

set -u

# --- Colors ---
if [[ -t 1 ]]; then
  GREEN=$'\033[0;32m'
  YELLOW=$'\033[0;33m'
  RED=$'\033[0;31m'
  BOLD=$'\033[1m'
  RESET=$'\033[0m'
else
  GREEN='' YELLOW='' RED='' BOLD='' RESET=''
fi

# --- Result Accumulation ---
VERDICT_GREEN=0
VERDICT_YELLOW=0
VERDICT_RED=0
FINDINGS=()

ok()    { echo "  ${GREEN}✓${RESET} $*"; VERDICT_GREEN=$((VERDICT_GREEN+1)); }
warn()  { echo "  ${YELLOW}⚠${RESET} $*"; VERDICT_YELLOW=$((VERDICT_YELLOW+1)); FINDINGS+=("⚠ $*"); }
fail()  { echo "  ${RED}✗${RESET} $*"; VERDICT_RED=$((VERDICT_RED+1)); FINDINGS+=("✗ $*"); }
info()  { echo "    $*"; }
section() { echo ""; echo "${BOLD}$*${RESET}"; }

# --- Determine DB Path ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DB_PATH="${1:-$PROJECT_ROOT/.memory/rag-memory.db}"

if [[ ! -f "$DB_PATH" ]]; then
  echo "${RED}ERROR: DB not found: $DB_PATH${RESET}" >&2
  exit 3
fi

# --- Detect sqlite3 + vec0 Environment ---
section "1. Environment"

BREW_SQLITE=""
for candidate in \
  "/opt/homebrew/opt/sqlite/bin/sqlite3" \
  "/usr/local/opt/sqlite/bin/sqlite3" \
  "$(command -v sqlite3 2>/dev/null)"; do
  if [[ -x "$candidate" ]]; then
    # Test if extension loadable (check .load command support)
    if "$candidate" :memory: ".load /nonexistent" 2>&1 | grep -q "Error.*cannot open shared library\|Error.*no such file"; then
      BREW_SQLITE="$candidate"
      break
    fi
  fi
done

if [[ -z "$BREW_SQLITE" ]]; then
  fail "No extension-capable sqlite3 found (Apple system sqlite3 is built with \`-DSQLITE_OMIT_LOAD_EXTENSION\`)"
  info "Solution: brew install sqlite"
  echo ""
  echo "${RED}RED: Audit halted due to environment error${RESET}"
  exit 3
fi
ok "sqlite3 (extension-capable): $BREW_SQLITE"
info "version: $("$BREW_SQLITE" --version | awk '{print $1}')"

VEC0=""
# ~/.npm/_npx/*/node_modules/sqlite-vec-darwin-arm64/vec0.dylib or vec0
for candidate in ~/.npm/_npx/*/node_modules/sqlite-vec-darwin-arm64/vec0.dylib \
                 ~/.npm/_npx/*/node_modules/sqlite-vec-darwin-arm64/vec0 \
                 ~/.npm/_npx/*/node_modules/sqlite-vec-darwin-x64/vec0.so \
                 ~/.npm/_npx/*/node_modules/sqlite-vec-linux-x64/vec0.so; do
  if [[ -f "$candidate" ]]; then
    VEC0="${candidate%.dylib}"
    VEC0="${VEC0%.so}"
    break
  fi
done

if [[ -z "$VEC0" ]]; then
  warn "sqlite-vec extension file (vec0) not found in ~/.npm/_npx/ — skipping vec0 checks"
  VEC0_AVAILABLE=0
else
  # Actual load test
  if "$BREW_SQLITE" -cmd ".load $VEC0" :memory: "SELECT vec_version();" 2>/dev/null | grep -q "^v"; then
    VERSION=$("$BREW_SQLITE" -cmd ".load $VEC0" :memory: "SELECT vec_version();" 2>/dev/null)
    ok "sqlite-vec: $VERSION ($VEC0)"
    VEC0_AVAILABLE=1
  else
    warn "vec0 file exists but failed to load — skipping vec0 checks"
    VEC0_AVAILABLE=0
  fi
fi

ok "DB: $DB_PATH ($(ls -lh "$DB_PATH" | awk '{print $5}'))"

# sqlite3 helper: Auto-select based on vec0 loadability
sq() {
  if [[ "$VEC0_AVAILABLE" == "1" ]]; then
    "$BREW_SQLITE" -cmd ".load $VEC0" "$DB_PATH" "$@"
  else
    "$BREW_SQLITE" "$DB_PATH" "$@"
  fi
}

# --- 2. Integrity Check ---
section "2. Integrity"

INTEGRITY=$(sq "PRAGMA integrity_check;" 2>&1 | head -1)
if [[ "$INTEGRITY" == "ok" ]]; then
  ok "integrity_check: ok"
else
  fail "integrity_check failed: $INTEGRITY"
fi

# --- 3. Foreign Key Check ---
section "3. Foreign Keys"

FK_VIOLATIONS=$(sq "PRAGMA foreign_key_check;" 2>&1)
FK_COUNT=$(echo -n "$FK_VIOLATIONS" | grep -c . || true)
if [[ "$FK_COUNT" == "0" ]]; then
  ok "foreign_key_check: 0 violations"
else
  warn "foreign_key_check: $FK_COUNT violations"
  echo "$FK_VIOLATIONS" | head -10 | while read line; do info "$line"; done
  [[ $FK_COUNT -gt 10 ]] && info "... $((FK_COUNT-10)) more items"
fi

# --- 4. Migration Status ---
section "4. Migration Status"

if sq ".tables schema_migrations" 2>/dev/null | grep -q schema_migrations; then
  MIG_MAX=$(sq "SELECT MAX(version) FROM schema_migrations;" 2>/dev/null)
  MIG_COUNT=$(sq "SELECT COUNT(*) FROM schema_migrations;" 2>/dev/null)
  ok "schema version: $MIG_MAX (applied: $MIG_COUNT)"
  LAST_MIG=$(sq "SELECT version || ' - ' || description FROM schema_migrations ORDER BY version DESC LIMIT 1;" 2>/dev/null)
  info "last: $LAST_MIG"
else
  warn "schema_migrations table not found — cannot check migration status"
fi

# --- 5. Type Counts ---
section "5. Entity/Relation Type Counts (drift monitoring)"

ENT_COUNT=$(sq "SELECT COUNT(*) FROM entities;")
ENT_TYPES=$(sq "SELECT COUNT(DISTINCT entityType) FROM entities;")
REL_COUNT=$(sq "SELECT COUNT(*) FROM relationships;")
REL_TYPES=$(sq "SELECT COUNT(DISTINCT relationType) FROM relationships;")

info "entities: $ENT_COUNT (distinct types: $ENT_TYPES)"
info "relations: $REL_COUNT (distinct types: $REL_TYPES)"

# Drift threshold: warning if >15 entity types or >30 relation types
if [[ $ENT_TYPES -gt 15 ]]; then
  warn "entity type ${ENT_TYPES} count — exceeds healthy range(10-15)"
else
  ok "entity type ${ENT_TYPES} count (healthy range)"
fi

if [[ $REL_TYPES -gt 30 ]]; then
  warn "relation type ${REL_TYPES} count — exceeds canonical range(~25)"
else
  ok "relation type ${REL_TYPES} count (canonical range)"
fi

# --- 6. Orphan embed_metadata ---
section "6. Orphan entity_embedding_metadata"

ORPHAN_META=$(sq "SELECT COUNT(*) FROM entity_embedding_metadata WHERE entity_id NOT IN (SELECT id FROM entities WHERE id IS NOT NULL);")
if [[ "$ORPHAN_META" == "0" ]]; then
  ok "Orphan embed_metadata: 0 items"
else
  warn "Orphan embed_metadata: $ORPHAN_META items (remnants of deleted entities)"
  info "Top 5 items:"
  sq "SELECT rowid, entity_id, substr(embedding_text,1,60) FROM entity_embedding_metadata WHERE entity_id NOT IN (SELECT id FROM entities WHERE id IS NOT NULL) LIMIT 5;" | while read line; do info "  $line"; done
fi

# --- 7. Orphan vec0 Vectors ---
section "7. Orphan vec0 Vectors"

if [[ "$VEC0_AVAILABLE" == "1" ]]; then
  ORPHAN_VEC=$(sq "SELECT COUNT(*) FROM entity_embeddings WHERE rowid NOT IN (SELECT rowid FROM entity_embedding_metadata);")
  if [[ "$ORPHAN_VEC" == "0" ]]; then
    ok "Orphan vec0 vectors: 0 items"
  else
    warn "Orphan vec0 vectors: $ORPHAN_VEC items (dangling vectors without metadata)"
  fi

  # Dimensional consistency
  DIMS=$(sq "SELECT DISTINCT vec_length(embedding) FROM entity_embeddings;")
  DIM_COUNT=$(echo "$DIMS" | grep -c . || true)
  if [[ "$DIM_COUNT" == "1" ]]; then
    ok "vec0 dimension: $DIMS (consistent)"
  else
    fail "vec0 dimension mixed: $(echo $DIMS | tr '\n' ' ')"
  fi
else
  info "(vec0 unloadable — skipped)"
fi

# --- 8. Missing Embeddings ---
section "8. Missing Embeddings (silent search failure)"

MISSING=$(sq "SELECT COUNT(*) FROM entities WHERE id NOT IN (SELECT entity_id FROM entity_embedding_metadata WHERE entity_id IS NOT NULL);")
if [[ "$MISSING" == "0" ]]; then
  ok "Entities without embeddings: 0 items"
else
  fail "Entities without embeddings: $MISSING items (semantic search blind spot)"
  info "Missing entities:"
  sq "SELECT '  - ' || e.id || ' (' || e.name || ')' FROM entities e WHERE e.id NOT IN (SELECT entity_id FROM entity_embedding_metadata WHERE entity_id IS NOT NULL) LIMIT 10;" | while read line; do info "$line"; done
  info "Solution: Call mcp__rag-memory__embedAllEntities"
fi

# --- 9. Corrupted ID Patterns ---
section "9. Corrupted entity id patterns"

# 4+ consecutive underscores are almost certainly regex corruption (3 is possible replacement like '+' → '___')
CORRUPTED=$(sq "SELECT COUNT(*) FROM entities WHERE id LIKE '%\_\_\_\_%' ESCAPE '\';")
if [[ "$CORRUPTED" == "0" ]]; then
  ok "Corrupted id patterns: 0 items"
else
  warn "Corrupted id: ${CORRUPTED} items (4+ consecutive underscores — created before Korean regex patch)"
  info "List:"
  sq "SELECT '  - ' || id || ' → ' || name FROM entities WHERE id LIKE '%\_\_\_\_%' ESCAPE '\' LIMIT 20;" | while read line; do info "$line"; done
fi

# --- Final Verdict ---
section "Overall Verdict"
TOTAL_CHECKS=$((VERDICT_GREEN + VERDICT_YELLOW + VERDICT_RED))
echo "  Total: $TOTAL_CHECKS checks"
echo "    ${GREEN}✓ $VERDICT_GREEN${RESET} / ${YELLOW}⚠ $VERDICT_YELLOW${RESET} / ${RED}✗ $VERDICT_RED${RESET}"
echo ""

if [[ $VERDICT_RED -gt 0 ]]; then
  echo "  ${RED}${BOLD}Verdict: RED${RESET} — Immediate action required"
  echo ""
  echo "Key findings:"
  printf '  %s\n' "${FINDINGS[@]}"
  exit 2
elif [[ $VERDICT_YELLOW -gt 0 ]]; then
  echo "  ${YELLOW}${BOLD}Verdict: YELLOW${RESET} — Attention needed (not an immediate breakdown)"
  echo ""
  echo "Key findings:"
  printf '  %s\n' "${FINDINGS[@]}"
  exit 1
else
  echo "  ${GREEN}${BOLD}Verdict: GREEN${RESET} — All checks passed"
  exit 0
fi
