#!/bin/sh
# AI Jedi adapter — Claude Code.
#
# Projects the content between instructions.md's markers into the Claude Code global
# configuration, wrapped in its own marker pair carrying the source version.
#
# Every vendor-specific value comes from adapter.yml. Nothing is hardcoded here.
#
# Usage:
#   project.sh                      project (refuses fork migration without confirmation)
#   project.sh --confirm-migration  authorize a one-time unmarked-fork migration
#   project.sh --check              report current | stale | not-installed; never writes
#
# Env (testing only):
#   AIJEDI_TARGET          override the resolved target path
#   AIJEDI_CORRUPT_WRITE   inject a corrupt write to exercise verification + rollback

set -u

HERE=$(cd "$(dirname "$0")" && pwd)
DECL="$HERE/adapter.yml"
REPO=$(cd "$HERE/../../.." && pwd)
SOURCE="$REPO/instructions.md"

OUTSIDE=""
NEW=""
# H1: every die() between a mktemp and its rm would otherwise leak, and the $NEW leak
# would leave a full copy of the projected instruction set in the temp directory.
# shellcheck disable=SC2329  # invoked indirectly by the trap on the next line.
cleanup() { [ -n "$OUTSIDE" ] && rm -f "$OUTSIDE"; [ -n "$NEW" ] && rm -f "$NEW"; return 0; }
trap cleanup EXIT INT TERM

die()  { printf 'REFUSED: %s\n' "$1" >&2; exit 1; }
note() { printf '%s\n' "$1"; }

[ -f "$DECL" ]   || die "missing declaration: $DECL"
[ -f "$SOURCE" ] || die "missing source: $SOURCE"

# --- declaration ------------------------------------------------------------
decl() { sed -n "s/^$1: *//p" "$DECL" | head -1 | sed 's/^"//;s/"$//'; }
# Strips BOTH quote styles. An earlier version stripped only single quotes, so a
# double-quoted value came back with the quotes attached — the backup glob then contained
# literal quote characters and matched nothing, silently disabling pruning.
sub()  { sed -n "s/^  $1: *//p" "$DECL" | head -1 | sed "s/^['\"]//;s/['\"]$//"; }

PATH_PATTERN=$(decl path_pattern)
[ -n "$PATH_PATTERN" ] || die "declaration has no path_pattern"
LIMIT_LINES=$(sub lines)
LIMIT_SCOPE=$(sub applies_to)
OVER_LIMIT=$(sub over_limit)
FORK_VERSIONED=$(sub versioned_title)
FORK_GENERATION=$(sub generation_marker)
# D1: derived from the declaration, not a constant of this script. The header's claim that
# nothing is hardcoded here has to actually hold, and pruning must match a pattern the
# declaration describes (Principle II).
BACKUP_SUFFIX=$(sub suffix)
[ -n "$BACKUP_SUFFIX" ] || die "declaration has no backup.suffix"
BACKUP_RETAIN=$(sub retain)

MSTART_RE='^<!-- AI-JEDI:INSTRUCTIONS:START v[0-9][0-9.]* -->$'
MEND_RE='^<!-- AI-JEDI:INSTRUCTIONS:END -->$'

# --- arguments --------------------------------------------------------------
MODE=project
CONFIRM_MIGRATION=no
for arg in "$@"; do
  case $arg in
    --check) MODE=check ;;
    --confirm-migration) CONFIRM_MIGRATION=yes ;;
    --) : ;;
    *) die "unknown argument: $arg" ;;
  esac
done

# --- target resolution ------------------------------------------------------
TARGET=${AIJEDI_TARGET:-"$HOME/$PATH_PATTERN"}

# FR-002: never write inside a project working tree. A projection there would scope a
# global instruction set to one repository and commit machine-wide config into its history.
TARGET_DIR=$(dirname "$TARGET")
if [ -d "$TARGET_DIR" ] && git -C "$TARGET_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  die "resolved target is inside a git working tree: $TARGET"
fi

# FR-007: an unreadable existing target is never overwritten.
if [ -e "$TARGET" ] && [ ! -r "$TARGET" ]; then
  die "target exists but cannot be read: $TARGET"
fi

# --- source ----------------------------------------------------------------
SRC_VERSION=$(grep -oE 'AI-JEDI:INSTRUCTIONS:START v[0-9][0-9.]*' "$SOURCE" | head -1 | sed 's/.*START v//')
[ -n "$SRC_VERSION" ] || die "source carries no version in its start marker"

# Content BETWEEN the source's own markers — not the markers themselves.
SRC_CONTENT=$(awk '/AI-JEDI:INSTRUCTIONS:START/{f=1;next} /AI-JEDI:INSTRUCTIONS:END/{f=0} f' "$SOURCE")
[ -n "$SRC_CONTENT" ] || die "source has no content between its markers"

# --- region inspection ------------------------------------------------------
# echoes: absent | corrupt | "present <start> <end> <version>"
region_state() {
  [ -f "$TARGET" ] || { echo absent; return; }
  s=$(grep -nE "$MSTART_RE" "$TARGET" | head -1 | cut -d: -f1)
  e=$(grep -nE "$MEND_RE" "$TARGET" | head -1 | cut -d: -f1)
  if [ -z "$s" ] && [ -z "$e" ]; then echo absent; return; fi
  if [ -z "$s" ] || [ -z "$e" ]; then echo corrupt; return; fi
  if [ "$e" -lt "$s" ]; then echo corrupt; return; fi
  v=$(sed -n "${s}p" "$TARGET" | sed 's/.*START v//;s/ -->.*//')
  echo "present $s $e $v"
}

STATE=$(region_state)
KIND=$(echo "$STATE" | cut -d' ' -f1)

# --- FR-010: drift check, read-only -----------------------------------------
if [ "$MODE" = check ]; then
  case $KIND in
    absent)  note "not-installed (source is v$SRC_VERSION)"; exit 0 ;;
    corrupt) die "region is corrupt: markers missing or out of order in $TARGET" ;;
    present)
      tv=$(echo "$STATE" | cut -d' ' -f4)
      if [ "$tv" = "$SRC_VERSION" ]; then
        note "current (v$tv)"
      else
        note "stale: target v$tv, source v$SRC_VERSION"
      fi
      exit 0 ;;
  esac
fi

[ "$KIND" = corrupt ] && die "region is corrupt: markers missing or out of order in $TARGET"

# --- FR-009: already current -------------------------------------------------
if [ "$KIND" = present ]; then
  TV=$(echo "$STATE" | cut -d' ' -f4)
  if [ "$TV" = "$SRC_VERSION" ]; then
    note "projection already current at v$TV — nothing written."
    exit 0
  fi
fi

# --- FR-006 / FR-016 / FR-017 / FR-018: unmarked fork -----------------------
# Scanned ONLY outside every managed region. The projected content carries a heading
# matching versioned_title, so including region interiors would make a later run detect
# this adapter's own output as a fork.
FORK_START=""
if [ -f "$TARGET" ] && [ "$KIND" = absent ]; then
  OUTSIDE=$(mktemp)
  awk '
    /^<!-- AI-JEDI:INSTRUCTIONS:START/ { inr=1 }
    /^<!-- SPECKIT START -->/          { inr=1 }
    !inr { print NR": "$0 }
    /^<!-- AI-JEDI:INSTRUCTIONS:END -->/ { inr=0 }
    /^<!-- SPECKIT END -->/              { inr=0 }
  ' "$TARGET" > "$OUTSIDE"

  # OUTSIDE lines carry an "N: " prefix, so the declaration's ^-anchored patterns must be
  # re-anchored past it. Matching them unmodified finds nothing — the prefix eats the anchor.
  PV=${FORK_VERSIONED#^}
  PG=${FORK_GENERATION#^}
  PREFIXED="^[0-9]+: ($PV|$PG)"

  MATCHES=$(grep -cE "$PREFIXED" "$OUTSIDE")
  if [ "$MATCHES" -gt 1 ]; then
    rm -f "$OUTSIDE"
    die "found $MATCHES headings matching the fork pattern — cannot determine which is the fork"
  fi
  if [ "$MATCHES" -eq 1 ]; then
    FORK_START=$(grep -E "$PREFIXED" "$OUTSIDE" | head -1 | cut -d: -f1)
    FORK_SIGNAL=$(sed -n "${FORK_START}p" "$TARGET")
    TOTAL=$(wc -l < "$TARGET" | tr -d ' ')
    rm -f "$OUTSIDE"

    # FR-018: the span must reach end-of-file, or it cannot be bounded.
    TAIL_H1=$(tail -n +$((FORK_START+1)) "$TARGET" | grep -c '^# ')
    if [ "$TAIL_H1" -gt 0 ]; then
      die "fork heading at line $FORK_START does not reach end-of-file (another H1 follows) — span cannot be bounded"
    fi

    note "Unmarked fork detected."
    note "  signal matched: $FORK_SIGNAL"
    note "  span: lines $FORK_START-$TOTAL of $TARGET"
    if [ "$CONFIRM_MIGRATION" != yes ]; then
      die "fork migration requires explicit confirmation — re-run with --confirm-migration"
    fi
  else
    rm -f "$OUTSIDE"
  fi
fi

# --- compose ----------------------------------------------------------------
NEW=$(mktemp)
START_LINE="<!-- AI-JEDI:INSTRUCTIONS:START v$SRC_VERSION -->"
END_LINE="<!-- AI-JEDI:INSTRUCTIONS:END -->"

if [ ! -f "$TARGET" ]; then
  printf '%s\n%s\n%s\n' "$START_LINE" "$SRC_CONTENT" "$END_LINE" > "$NEW"
elif [ "$KIND" = present ]; then
  S=$(echo "$STATE" | cut -d' ' -f2); E=$(echo "$STATE" | cut -d' ' -f3)
  { if [ "$S" -gt 1 ]; then head -n $((S-1)) "$TARGET"; fi
    printf '%s\n%s\n%s\n' "$START_LINE" "$SRC_CONTENT" "$END_LINE"
    tail -n +$((E+1)) "$TARGET"
  } > "$NEW"
elif [ -n "$FORK_START" ]; then
  { if [ "$FORK_START" -gt 1 ]; then head -n $((FORK_START-1)) "$TARGET"; fi
    printf '%s\n%s\n%s\n' "$START_LINE" "$SRC_CONTENT" "$END_LINE"
  } > "$NEW"
else
  { cat "$TARGET"
    printf '%s\n%s\n%s\n' "$START_LINE" "$SRC_CONTENT" "$END_LINE"
  } > "$NEW"
fi

# --- FR-001b: size limit on the RESULTING FILE TOTAL ------------------------
if [ -n "$LIMIT_LINES" ] && [ "$LIMIT_SCOPE" = resulting-file-total ]; then
  RESULT_LINES=$(wc -l < "$NEW" | tr -d ' ')
  if [ "$RESULT_LINES" -gt "$LIMIT_LINES" ]; then
    rm -f "$NEW"
    if [ "$OVER_LIMIT" = refuse ]; then
      die "resulting file would be $RESULT_LINES lines, over the declared limit of $LIMIT_LINES — refusing rather than summarizing, because a summarized region would carry the source version while holding different content"
    fi
    die "over-limit handling '$OVER_LIMIT' is not implemented by this adapter"
  fi
fi

# Test-only injection. A single guarded branch: inert unless AIJEDI_TEST_INJECT is set, so
# FR-005's byte-identity on the success path is unaffected by its presence.
case "${AIJEDI_TEST_INJECT:-}" in
  truncate) head -n 3 "$NEW" > "$NEW.t" && mv "$NEW.t" "$NEW" ;;
  empty)    : > "$NEW" ;;
  fail)     rm -f "$NEW"; die "injected compose-step failure" ;;
  "")       : ;;
  *)        die "unknown AIJEDI_TEST_INJECT mode: $AIJEDI_TEST_INJECT" ;;
esac

# FR-004: content-based, not structural. The post-write verification checks markers, order
# and version — all of which a truncated file retains, so structural validity cannot see
# this failure. Compare the region extracted from the composed file against the very
# $SRC_CONTENT it was built from: exact by construction, and no trailing-newline ambiguity
# because both sides come from one variable.
COMPOSED_REGION=$(awk '/AI-JEDI:INSTRUCTIONS:START/{f=1;next} /AI-JEDI:INSTRUCTIONS:END/{f=0} f' "$NEW")
if [ "$(printf '%s' "$COMPOSED_REGION" | cksum)" != "$(printf '%s' "$SRC_CONTENT" | cksum)" ]; then
  die "composed region does not match the source content — a compose step failed silently"
fi

# --- FR-011: backup, then write ---------------------------------------------
BACKUP=""
if [ -f "$TARGET" ]; then
  # M2: seconds-granularity alone collides when two runs land in the same second, and the
  # second cp would overwrite the first backup. $$ disambiguates.
  BACKUP="${TARGET}${BACKUP_SUFFIX}-$(date +%Y%m%d%H%M%S)-$$.bak"
  cp "$TARGET" "$BACKUP" || { rm -f "$NEW"; die "could not back up $TARGET"; }
fi

mkdir -p "$(dirname "$TARGET")" 2>/dev/null
if [ "${AIJEDI_CORRUPT_WRITE:-0}" = "1" ]; then
  printf 'deliberately corrupt\n' > "$TARGET"   # verification-failure injection
else
  cat "$NEW" > "$TARGET" || { rm -f "$NEW"; die "write failed"; }
fi
rm -f "$NEW"

# --- FR-015: verify own output, roll back on failure ------------------------
rollback() {
  if [ -n "$BACKUP" ] && [ -f "$BACKUP" ]; then
    cat "$BACKUP" > "$TARGET"
    printf 'ROLLED BACK from %s: %s\n' "$BACKUP" "$1" >&2
  else
    rm -f "$TARGET"
    printf 'REMOVED partial write: %s\n' "$1" >&2
  fi
  exit 1
}

VS=$(grep -cE "$MSTART_RE" "$TARGET")
VE=$(grep -cE "$MEND_RE" "$TARGET")
[ "$VS" = "1" ] || rollback "expected exactly one start marker, found $VS"
[ "$VE" = "1" ] || rollback "expected exactly one end marker, found $VE"
LS=$(grep -nE "$MSTART_RE" "$TARGET" | cut -d: -f1)
LE=$(grep -nE "$MEND_RE" "$TARGET" | cut -d: -f1)
[ "$LS" -lt "$LE" ] || rollback "markers out of order"
WV=$(sed -n "${LS}p" "$TARGET" | sed 's/.*START v//;s/ -->.*//')
[ "$WV" = "$SRC_VERSION" ] || rollback "written version v$WV does not match source v$SRC_VERSION"

# --- FR-001/002/003: prune backups, AFTER a successful write ------------------
# Never before: pruning first would delete the safety net this write might still need.
# Every failure below is swallowed with a warning — FR-003 makes housekeeping subordinate
# to the projection, because failing a good write over a stale file nobody asked about
# would be the wrong trade.
prune_backups() {
  [ -n "$BACKUP_RETAIN" ] || return 0
  # M1: retain comes from an operator-editable declaration. A non-numeric value would
  # reach the comparison and the arithmetic below and error noisily on every run, which
  # disturbs the projection FR-003 says housekeeping must not disturb. Skip cleanly and
  # say why instead.
  case "$BACKUP_RETAIN" in
    ''|*[!0-9]*) printf 'WARNING: backup.retain is not a number (%s) — skipping pruning\n' "$BACKUP_RETAIN" >&2; return 0 ;;
  esac
  [ "${AIJEDI_PRUNE_FAIL:-0}" = "1" ] && { printf 'WARNING: pruning failed (injected)\n' >&2; return 0; }
  # Glob derived from the declared suffix, so only this adapter's own backups are
  # candidates — never the live target, never another tool's files.
  # Enumerate by glob, not by parsing ls: ls output is not a safe list format, and a
  # filename containing a newline would corrupt a line count (SC2012). This also closes
  # N2 from the PR #7 review, which I had dismissed as unreachable — shellcheck disagreed,
  # and robustness should not depend on nobody creating an awkward filename.
  count=0
  for b in "${TARGET}${BACKUP_SUFFIX}-"*.bak; do [ -e "$b" ] && count=$((count+1)); done
  [ "$count" -le "$BACKUP_RETAIN" ] && return 0
  excess=$((count - BACKUP_RETAIN))
  # Oldest first. Names carry a sortable timestamp, so lexical order is chronological,
  # and glob expansion is already sorted.
  removed=0
  for old in "${TARGET}${BACKUP_SUFFIX}-"*.bak; do
    [ "$removed" -ge "$excess" ] && break
    [ -e "$old" ] || continue
    rm -f "$old" 2>/dev/null || printf 'WARNING: could not remove %s\n' "$old" >&2
    removed=$((removed+1))
  done
  return 0
}
# prune_backups always returns 0 by design (FR-003): every internal failure is warned
# about, never propagated. An `|| ...` here would be unreachable and would read as
# protection that does not exist.
prune_backups

# --- report ------------------------------------------------------------------
note "Projected instructions v$SRC_VERSION into $TARGET"
if [ -n "$BACKUP" ]; then note "  backup: $BACKUP"; fi
note "  This takes effect from the tool's NEXT session — the session that ran this"
note "  script still holds the instructions it loaded at start."
exit 0
