#!/bin/sh
# Fixture-driven suite for the Claude Code adapter.
#
# SAFETY: every case runs against a temporary fixture. This suite NEVER touches
# ~/.claude/CLAUDE.md. A test that writes the operator's real configuration is a defect
# whether or not it passes.
#
# Usage: ./run-tests.sh [group ...]
#   Groups: refusals create idempotent preserve fork drift backup size foreign selfverify
#           retention composition lint
#   No arguments runs every group.

set -u

HERE=$(cd "$(dirname "$0")" && pwd)
ADAPTER="$HERE/.."
SCRIPT="$ADAPTER/project.sh"
DECL="$ADAPTER/adapter.yml"
REPO=$(cd "$ADAPTER/../../.." && pwd)
SOURCE="$REPO/instructions.md"

PASS=0
FAIL=0
SKIP=0
WORK=""

cleanup() { [ -n "$WORK" ] && rm -rf "$WORK"; }
trap cleanup EXIT INT TERM

fresh_work() {
  cleanup
  WORK=$(mktemp -d) || { echo "cannot create temp dir"; exit 1; }
}

# H2: stat -f is BSD-only. On GNU coreutils -f means FILESYSTEM stat and the format is
# invalid, so both fingerprints fell through to the same fallback string, became equal, and
# every mutation check passed vacuously — seven assertions reporting green while verifying
# nothing. cksum plus wc -c is portable and actually content-sensitive.
fingerprint() {
  if [ -r "$1" ]; then
    printf '%s %s' "$(cksum < "$1" 2>/dev/null)" "$(wc -c < "$1" 2>/dev/null)"
  else
    # Unreadable: fall back to inode metadata via ls, which both BSD and GNU provide.
    ls -ln "$1" 2>/dev/null | awk '{print $5}'
  fi
}

ok()   { PASS=$((PASS+1)); printf '  PASS  %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '  FAIL  %s\n' "$1"; }
# SKIP is a third outcome, deliberately NOT counted toward PASS. A group reporting green
# because its tool is missing is the vacuous assertion the stat -f defect already taught.
skip() { SKIP=$((SKIP+1)); printf '  SKIP  %s\n' "$1"; }

# assert_refused <label> <fixture> -- <args...>
# Requires BOTH a non-zero exit AND a byte-unchanged fixture. A refusal that mutates the
# target is not a refusal.
assert_refused() {
  label=$1; fixture=$2; shift 3
  # Fingerprint by size+mtime rather than by copying: an unreadable fixture (chmod 000)
  # cannot be cp'd, and a failed copy would make every comparison report a false mutation.
  before=$(fingerprint "$fixture")
  AIJEDI_TARGET="$fixture" sh "$SCRIPT" "$@" >/dev/null 2>&1
  rc=$?
  after=$(fingerprint "$fixture")
  if [ "$rc" -eq 0 ]; then
    bad "$label (exited 0; expected refusal)"
  elif [ "$before" != "$after" ]; then
    bad "$label (refused but MUTATED the target)"
  else
    ok "$label"
  fi
}

assert_unchanged_outside() {
  label=$1; fixture=$2; baseline=$3
  # Compare everything above the start marker and below the end marker.
  s=$(grep -n 'AI-JEDI:INSTRUCTIONS:START' "$fixture" | head -1 | cut -d: -f1)
  if [ -z "$s" ]; then bad "$label (no start marker to bound comparison)"; return; fi
  above_now=$(head -n $((s-1)) "$fixture")
  above_was=$(head -n $((s-1)) "$baseline" 2>/dev/null)
  if [ "$above_now" = "$above_was" ]; then ok "$label above-region"; else bad "$label above-region differs"; fi
  below_now=$(sed -n '/AI-JEDI:INSTRUCTIONS:END/,$p' "$fixture" | tail -n +2)
  below_was=$(sed -n '/AI-JEDI:INSTRUCTIONS:END/,$p' "$baseline" 2>/dev/null | tail -n +2)
  if [ "$below_now" = "$below_was" ]; then ok "$label below-region"; else bad "$label below-region differs"; fi
}

# ---------------------------------------------------------------------------
# Groups. Each is written to FAIL until its implementation task lands (TDD).
#
# CAVEAT on the refusals group: a stub that refuses EVERYTHING passes all seven cases,
# because assert_refused only requires a non-zero exit and an unmutated target. Refusal
# tests cannot distinguish "correctly refuses" from "does nothing". The RED signal for
# this suite therefore comes from create/idempotent/preserve/fork/drift, which a stub
# cannot satisfy. Both must be green at the end: refusals still refusing while the
# writing groups actually write.
# ---------------------------------------------------------------------------

group_refusals() {
  echo "group: refusals (7 cases, SC-005)"
  fresh_work

  # 1. Target inside a git working tree
  mkdir -p "$WORK/proj" && (cd "$WORK/proj" && git init -q .)
  printf 'operator\n' > "$WORK/proj/CLAUDE.md"
  assert_refused "target inside git working tree" "$WORK/proj/CLAUDE.md" --

  # 2. Only a start marker
  printf 'op\n<!-- AI-JEDI:INSTRUCTIONS:START v0.0.1 -->\ncontent\n' > "$WORK/single.md"
  assert_refused "single start marker" "$WORK/single.md" --

  # 3. Markers reversed
  printf 'op\n<!-- AI-JEDI:INSTRUCTIONS:END -->\nx\n<!-- AI-JEDI:INSTRUCTIONS:START v0.0.1 -->\n' > "$WORK/rev.md"
  assert_refused "markers reversed" "$WORK/rev.md" --

  # 4. Unreadable target
  printf 'op\n' > "$WORK/noread.md"; chmod 000 "$WORK/noread.md"
  assert_refused "unreadable target" "$WORK/noread.md" --
  chmod 644 "$WORK/noread.md"

  # 5. Two title-shaped headings — cannot tell which is the fork
  printf 'op\n# One V1: a\ntext\n# Two V2: b\nmore\n' > "$WORK/two.md"
  assert_refused "two title-shaped headings" "$WORK/two.md" --confirm-migration

  # 6. Fork migration without confirmation
  printf 'op\n# Spec V4: x\nbody\n' > "$WORK/noconfirm.md"
  assert_refused "fork migration without confirmation" "$WORK/noconfirm.md" --

  # 7. Matching heading that does NOT reach end-of-file (FR-018)
  printf 'op\n# Spec V4: x\nbody\n\n# Operator section\nmine\n' > "$WORK/noeof.md"
  assert_refused "heading not reaching end-of-file" "$WORK/noeof.md" --confirm-migration
}

group_create() {
  echo "group: create (FR-003)"
  fresh_work
  target="$WORK/absent/CLAUDE.md"
  AIJEDI_TARGET="$target" sh "$SCRIPT" -- >/dev/null 2>&1
  if [ ! -f "$target" ]; then bad "absent target created"; return; fi
  n=$(grep -c 'AI-JEDI:INSTRUCTIONS:START' "$target")
  [ "$n" = "1" ] && ok "exactly one region created" || bad "expected 1 region, found $n"
}

group_idempotent() {
  echo "group: idempotent (FR-008, SC-004)"
  fresh_work
  target="$WORK/idem.md"; printf 'operator line\n' > "$target"
  AIJEDI_TARGET="$target" sh "$SCRIPT" -- >/dev/null 2>&1
  first=$(mktemp); cp "$target" "$first"
  AIJEDI_TARGET="$target" sh "$SCRIPT" -- >/dev/null 2>&1
  cmp -s "$target" "$first" && ok "second run byte-identical" || bad "second run differs"
  n=$(grep -c 'AI-JEDI:INSTRUCTIONS:START' "$target")
  [ "$n" = "1" ] && ok "still exactly one region" || bad "expected 1 region, found $n"
  rm -f "$first"
}

group_preserve() {
  echo "group: preserve (FR-005, SC-002 — 3 runs per fixture)"
  fresh_work
  for shape in above below both; do
    target="$WORK/pres-$shape.md"
    case $shape in
      above) printf 'mine above\n<!-- AI-JEDI:INSTRUCTIONS:START v0.0.1 -->\nold\n<!-- AI-JEDI:INSTRUCTIONS:END -->\n' > "$target" ;;
      below) printf '<!-- AI-JEDI:INSTRUCTIONS:START v0.0.1 -->\nold\n<!-- AI-JEDI:INSTRUCTIONS:END -->\nmine below\n' > "$target" ;;
      both)  printf 'mine above\n<!-- AI-JEDI:INSTRUCTIONS:START v0.0.1 -->\nold\n<!-- AI-JEDI:INSTRUCTIONS:END -->\nmine below\n' > "$target" ;;
    esac
    base=$(mktemp); cp "$target" "$base"
    run=1
    while [ "$run" -le 3 ]; do
      AIJEDI_TARGET="$target" sh "$SCRIPT" -- >/dev/null 2>&1
      assert_unchanged_outside "preserve $shape run $run" "$target" "$base"
      run=$((run+1))
    done
    rm -f "$base"
  done
}

group_fork() {
  echo "group: fork (FR-006, FR-016, FR-017, SC-003)"
  fresh_work
  # Mirrors the operator's real file: import, personal section, then unmarked fork to EOF.
  target="$WORK/fork.md"
  printf '@RTK.md\n# graphify\n- graphify note\n# %s V4: title\nforked body\nmore forked\n' "SPEC" > "$target"
  base=$(mktemp); cp "$target" "$base"
  out=$(AIJEDI_TARGET="$target" sh "$SCRIPT" --confirm-migration 2>&1)
  echo "$out" | grep -q 'V4' && ok "reports the matched signal" || bad "did not report matched signal"
  echo "$out" | grep -qE '[0-9]+' && ok "reports the span" || bad "did not report the span"
  n=$(grep -c 'AI-JEDI:INSTRUCTIONS:START' "$target" 2>/dev/null || echo 0)
  [ "$n" = "1" ] && ok "fork replaced by exactly one region" || bad "expected 1 region, found $n"
  grep -q '^@RTK.md' "$target" 2>/dev/null && ok "operator import survived" || bad "operator import lost"
  grep -q '^# graphify' "$target" 2>/dev/null && ok "operator section survived" || bad "operator section lost"
  grep -q 'forked body' "$target" 2>/dev/null && bad "fork content still present (duplicated)" || ok "fork content gone"
  # FR-017: second run must NOT see its own projected title as a fork.
  second=$(mktemp); cp "$target" "$second"
  AIJEDI_TARGET="$target" sh "$SCRIPT" -- >/dev/null 2>&1
  cmp -s "$target" "$second" && ok "second run found no fork in its own output" || bad "second run migrated its own output (FR-017)"
  rm -f "$base" "$second"
}

group_drift() {
  echo "group: drift (FR-010, SC-006)"
  fresh_work
  # not-installed
  printf 'operator only\n' > "$WORK/d1.md"
  out=$(AIJEDI_TARGET="$WORK/d1.md" sh "$SCRIPT" --check 2>&1)
  echo "$out" | grep -qi 'not-installed' && ok "reports not-installed" || bad "not-installed not reported"
  # current
  AIJEDI_TARGET="$WORK/d1.md" sh "$SCRIPT" -- >/dev/null 2>&1
  out=$(AIJEDI_TARGET="$WORK/d1.md" sh "$SCRIPT" --check 2>&1)
  echo "$out" | grep -qi 'current' && ok "reports current" || bad "current not reported"
  # stale — rewrite the marker version backwards
  sed 's/START v[0-9.]*/START v0.0.1/' "$WORK/d1.md" > "$WORK/d2.md"
  out=$(AIJEDI_TARGET="$WORK/d2.md" sh "$SCRIPT" --check 2>&1)
  echo "$out" | grep -qi 'stale' && ok "reports stale" || bad "stale not reported"
  echo "$out" | grep -q '0\.0\.1' && ok "stale names both versions" || bad "stale did not name both versions"
  # --check must never write
  cp "$WORK/d2.md" "$WORK/d2.before"
  AIJEDI_TARGET="$WORK/d2.md" sh "$SCRIPT" --check >/dev/null 2>&1
  cmp -s "$WORK/d2.md" "$WORK/d2.before" && ok "--check wrote nothing" || bad "--check MUTATED the target"
}

group_backup() {
  echo "group: backup (FR-011, SC-007)"
  fresh_work
  target="$WORK/bk.md"; printf 'operator\n' > "$target"
  AIJEDI_TARGET="$target" sh "$SCRIPT" -- >/dev/null 2>&1
  found=$(ls "$WORK"/*.bak 2>/dev/null | wc -l | tr -d ' ')
  [ "$found" -ge 1 ] && ok "backup exists on disk" || bad "no backup taken"
  # The backup must not be a file the harness would load as configuration.
  ls "$WORK"/*.bak 2>/dev/null | grep -q '\.md$' && bad "backup ends in .md — target tool would load it" || ok "backup extension not loadable"
}

group_size() {
  echo "group: size (FR-001b)"
  fresh_work
  target="$WORK/big.md"
  # Operator content large enough that projected content + it exceeds the declared limit.
  i=0; : > "$target"
  while [ "$i" -lt 900 ]; do printf 'operator filler line\n' >> "$target"; i=$((i+1)); done
  base=$(mktemp); cp "$target" "$base"
  AIJEDI_TARGET="$target" sh "$SCRIPT" -- >/dev/null 2>&1
  rc=$?
  [ "$rc" -ne 0 ] && ok "over-limit refused" || bad "over-limit accepted (must refuse, never truncate)"
  cmp -s "$target" "$base" && ok "over-limit left target unchanged" || bad "over-limit MUTATED the target"
  rm -f "$base"
}

group_foreign() {
  echo "group: foreign (FR-013, FR-014)"
  fresh_work
  target="$WORK/fr.md"
  printf '<!-- SPECKIT START -->\npointer\n<!-- SPECKIT END -->\nmine\n' > "$target"
  base=$(mktemp); cp "$target" "$base"
  AIJEDI_TARGET="$target" sh "$SCRIPT" -- >/dev/null 2>&1
  sed -n '/SPECKIT START/,/SPECKIT END/p' "$target" > "$WORK/fnow"
  sed -n '/SPECKIT START/,/SPECKIT END/p' "$base"   > "$WORK/fwas"
  cmp -s "$WORK/fnow" "$WORK/fwas" && ok "foreign region untouched" || bad "foreign region modified"
  # FR-014: text merely resembling a marker must NOT be matched as one. The correct
  # behavior is to treat the file as having no region and append a real one — not to
  # refuse. An earlier version of this case asserted a refusal, which was wrong: exact
  # full-line matching means the inline text is simply invisible to detection.
  printf 'talking about <!-- AI-JEDI:INSTRUCTIONS:START --> inline\n' > "$WORK/near.md"
  AIJEDI_TARGET="$WORK/near.md" sh "$SCRIPT" -- >/dev/null 2>&1
  n=$(grep -cE '^<!-- AI-JEDI:INSTRUCTIONS:START v[0-9][0-9.]* -->$' "$WORK/near.md")
  [ "$n" = "1" ] && ok "inline marker-like text not matched; real region appended" \
    || bad "inline marker-like text mishandled (found $n full-line start markers)"
  grep -q 'talking about' "$WORK/near.md" && ok "inline text preserved" || bad "inline text lost"
  rm -f "$base"
}

group_selfverify() {
  echo "group: selfverify (FR-012, FR-015)"
  fresh_work
  target="$WORK/sv.md"; printf 'operator\n' > "$target"
  out=$(AIJEDI_TARGET="$target" sh "$SCRIPT" -- 2>&1)
  echo "$out" | grep -qi 'next session' && ok "next-session disclosure present" || bad "no next-session disclosure"
  # Corrupt-write rollback: force verification failure via the injection hook.
  target2="$WORK/sv2.md"; printf 'operator\n' > "$target2"
  base=$(mktemp); cp "$target2" "$base"
  AIJEDI_CORRUPT_WRITE=1 AIJEDI_TARGET="$target2" sh "$SCRIPT" -- >/dev/null 2>&1
  cmp -s "$target2" "$base" && ok "failed verification rolled back" || bad "corrupt write not rolled back"
  rm -f "$base"
}

group_retention() {
  echo "group: retention (FR-001, FR-002, FR-003, SC-001, SC-002)"
  fresh_work
  RETAIN=$(sed -n 's/^  retain: *//p' "$DECL" | head -1)
  [ -n "$RETAIN" ] && ok "retention limit declared ($RETAIN)" || { bad "retain not declared"; return; }

  # Below the limit: adds without removing.
  target="$WORK/r1.md"; printf 'op\n' > "$target"
  i=0
  while [ "$i" -lt "$RETAIN" ]; do
    sed -i '' "s/^<!-- AI-JEDI:INSTRUCTIONS:START v.*/<!-- AI-JEDI:INSTRUCTIONS:START v0.0.$i -->/" "$target" 2>/dev/null
    AIJEDI_TARGET="$target" sh "$SCRIPT" -- >/dev/null 2>&1
    i=$((i+1)); sleep 1
  done
  n=$(ls "$WORK"/r1.md.aijedi-backup-* 2>/dev/null | wc -l | tr -d ' ')
  [ "$n" -le "$RETAIN" ] && ok "count within limit ($n <= $RETAIN)" || bad "count $n exceeds limit $RETAIN"

  # Pre-seeded backups the adapter did not create are pruned too.
  target2="$WORK/r2.md"; printf 'op\n' > "$target2"
  j=0; while [ "$j" -lt 6 ]; do : > "$WORK/r2.md.aijedi-backup-2020010100000$j-999.bak"; j=$((j+1)); done
  AIJEDI_TARGET="$target2" sh "$SCRIPT" -- >/dev/null 2>&1
  n2=$(ls "$WORK"/r2.md.aijedi-backup-* 2>/dev/null | wc -l | tr -d ' ')
  [ "$n2" -le "$RETAIN" ] && ok "pre-seeded backups pruned ($n2 <= $RETAIN)" || bad "pre-seeded not pruned ($n2)"

  # Non-matching files are never considered.
  : > "$WORK/r2.md.someothertool.bak"
  AIJEDI_TARGET="$target2" sh "$SCRIPT" -- >/dev/null 2>&1
  [ -f "$WORK/r2.md.someothertool.bak" ] && ok "foreign backup untouched" || bad "foreign backup deleted"

  # The live target is never a pruning candidate.
  [ -f "$target2" ] && ok "live target not pruned" || bad "live target deleted"

  # A pruning failure must not fail the projection.
  target3="$WORK/r3.md"; printf 'op\n' > "$target3"
  AIJEDI_PRUNE_FAIL=1 AIJEDI_TARGET="$target3" sh "$SCRIPT" -- >/dev/null 2>&1
  [ "$?" -eq 0 ] && ok "pruning failure did not fail the projection" || bad "pruning failure aborted the projection"
}

group_composition() {
  echo "group: composition (FR-004, SC-003)"
  fresh_work
  for mode in truncate empty fail; do
    target="$WORK/c-$mode.md"; printf 'operator content\n' > "$target"
    before=$(fingerprint "$target")
    AIJEDI_TEST_INJECT="$mode" AIJEDI_TARGET="$target" sh "$SCRIPT" -- >/dev/null 2>&1
    rc=$?
    after=$(fingerprint "$target")
    [ "$rc" -ne 0 ] && ok "compose $mode rejected" || bad "compose $mode accepted"
    [ "$before" = "$after" ] && ok "compose $mode left target byte-unchanged" || bad "compose $mode MUTATED target"
  done
}

group_lint() {
  echo "group: lint (FR-006, FR-008, SC-005)"
  if ! command -v shellcheck >/dev/null 2>&1; then
    skip "shellcheck not installed — group skipped, NOT counted as a pass"
    return
  fi
  ver=$(shellcheck --version 2>/dev/null | sed -n 's/^version: *//p' | head -1)
  ok "shellcheck version recorded: ${ver:-unknown}"
  for f in "$SCRIPT" "$HERE/run-tests.sh"; do
    if shellcheck -s sh "$f" >/dev/null 2>&1; then
      ok "lint clean: $(basename "$f")"
    else
      bad "lint findings in $(basename "$f") — fix or suppress inline with justification"
    fi
  done
}

# ---------------------------------------------------------------------------

[ -f "$DECL" ]   || { echo "missing declaration: $DECL"; exit 1; }
[ -f "$SOURCE" ] || { echo "missing source: $SOURCE"; exit 1; }
[ -f "$SCRIPT" ] || { echo "missing script: $SCRIPT"; exit 1; }

# NOTE: not named GROUPS — that is a special bash array (process group IDs); assigning it
# is silently ignored under macOS /bin/sh, so the loop never iterates and nothing prints.
TEST_GROUPS=${*:-"refusals create idempotent preserve fork drift backup size foreign selfverify retention composition lint"}
for g in $TEST_GROUPS; do
  case $g in
    refusals|create|idempotent|preserve|fork|drift|backup|size|foreign|selfverify|retention|composition|lint) "group_$g" ;;
    *) echo "unknown group: $g"; exit 1 ;;
  esac
done

printf '\n%s passed, %s failed, %s skipped\n' "$PASS" "$FAIL" "$SKIP"
[ "$FAIL" -eq 0 ]
