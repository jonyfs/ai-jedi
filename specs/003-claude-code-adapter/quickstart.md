---
Summary: Validation guide proving the Claude Code adapter projects the instruction set correctly, idempotently, and without touching operator-authored content.
Tags: [#quickstart #validation #adapter #projection]
---

# Quickstart: Validating the Claude Code Adapter

Plan: [[plan]] · Spec: [[spec]]

## Prerequisites

- Working directory: the repository root
- `instructions.md` present with its marker pair
- **A copy of the real global config taken before any run.** Every step below that could write runs
  against a temporary fixture, not the operator's file, until Step 7.

## Step 1 — Declaration completeness (FR-001)

```bash
cat .specify/adapters/claude-code/adapter.yml
grep -cE 'target_tool|path_pattern|format|size_limit' .specify/adapters/claude-code/adapter.yml
grep -cE 'skill_install|skill_verify|invoke_separator|agent_definition|tier_map' .specify/adapters/claude-code/adapter.yml
```

**Expected**: all EIGHT declared fields present — the original four plus the four the authoring constraints
require of every adapter (skill install/verify, invocation separator, agent-definition location and format,
tier-to-model mapping). An adapter declaring only its path and format is incomplete. The path is a home-relative PATTERN, not an absolute path — an
absolute path in a committed file would leak the operator's username into a public repository.

```bash
grep -c '/Users/\|/home/' .specify/adapters/claude-code/adapter.yml   # expected: 0
```

## Step 2 — Refusals (FR-002, FR-007, SC-005)

Six hostile cases, each must refuse and write nothing:

```bash
cd .specify/adapters/claude-code/tests && ./run-tests.sh refusals
```

| Case | Expected |
|---|---|
| Target path inside a project working tree | Refuse, report, no write |
| Only a start marker | Report corruption, no write |
| Markers in reverse order | Report corruption, no write |
| Unreadable target | Report, no write |
| Fork span bounded by two title-shaped headings | Refuse — cannot tell which is the fork |
| Fork migration without operator confirmation | Refuse — the exception is confirmation-gated |

**Expected**: 6 of 6 refuse. A single case that writes is a blocking defect — each represents a way to
corrupt a file the operator owns.

## Step 3 — Creation and idempotency (FR-003, FR-008, SC-004)

```bash
cd .specify/adapters/claude-code/tests && ./run-tests.sh create idempotent
```

**Expected**: an absent target is created at the documented location with exactly one region; a second
run against unchanged source produces a byte-identical file and still exactly one region. Two regions
after two runs is a blocking defect.

## Step 4 — Byte-identity outside the region (FR-005, SC-002)

```bash
cd .specify/adapters/claude-code/tests && ./run-tests.sh preserve
```

Fixtures must cover operator content **above** the region, **below** it, and **both**.

**Expected**: every byte outside the region identical. This is the requirement the whole feature serves —
a failure here means the adapter destroys work the operator cannot recover.

## Step 5 — Replacing an unmarked fork (FR-006, SC-003)

```bash
cd .specify/adapters/claude-code/tests && ./run-tests.sh fork
```

The fixture mirrors the operator's real file: an import line, a personal section, then unmarked
instruction content.

**Expected**: the fork span is replaced by one marked region, the import and personal section survive
byte-identically, and the script REPORTS which span it replaced so the operator can audit the judgment.
Content duplicated, or the fork left alongside the new region, is a blocking defect.

## Step 5b — Size limit (FR-001b)

```bash
cd .specify/adapters/claude-code/tests && ./run-tests.sh size
```

**Expected**: content exceeding the declared limit is REFUSED — never truncated, never summarized. This
adapter refuses by design: a summarized region would break verbatim projection and would carry a source
version it does not actually contain, making the drift check lie.

## Step 6 — Drift check (FR-010, SC-006)

```bash
cd .specify/adapters/claude-code/tests && ./run-tests.sh drift
```

**Expected**: three distinct outcomes — current, stale (naming both versions), not-installed. Reported
from version strings alone, without reading projected content. `stale` and `not-installed` must not
collapse into one result.

## Step 7 — Against the real configuration (SC-001, FR-011, FR-012)

Only after Steps 1–6 pass.

Reuse the snapshot T002 already captured — do NOT re-copy here. Re-copying after a run would overwrite
the pre-projection reference with post-projection content, destroying the baseline this step depends on.

```bash
test -f /tmp/claude-md-before.txt || echo "FAIL: T002 snapshot missing, cannot verify byte-identity"
sh .specify/adapters/claude-code/project.sh
# byte-identity BELOW the region
# Assert the exit status - an earlier draft silenced diff with 2>/dev/null and checked
# nothing, so a failure read as a pass.
diff <(sed -n '/AI-JEDI:INSTRUCTIONS:END/,$p' ~/.claude/CLAUDE.md) \
     <(sed -n '/AI-JEDI:INSTRUCTIONS:END/,$p' /tmp/claude-md-before.txt) >/dev/null \
  && echo "PASS below-region byte-identical" || echo "FAIL below-region differs"
# byte-identity ABOVE the region - presence greps alone are weaker than SC-002 demands.
# Derive the line count from the span T002 recorded; do NOT hardcode it. An earlier draft
# assumed exactly 4 lines above the fork, which only held for one operator's file.
ABOVE=$(grep -n 'AI-JEDI:INSTRUCTIONS:START' ~/.claude/CLAUDE.md | cut -d: -f1)
ABOVE=$((ABOVE - 1))
diff "<(head -n $ABOVE ~/.claude/CLAUDE.md)" "<(head -n $ABOVE /tmp/claude-md-before.txt)" >/dev/null \
  && echo "PASS above-region byte-identical" || echo "FAIL above-region differs"
grep -oE 'AI-JEDI:INSTRUCTIONS:START v[0-9.]+' ~/.claude/CLAUDE.md
grep -c 'SYSTEM SPECIFICATION V4' ~/.claude/CLAUDE.md     # expected: 0 — fork gone
grep -c '^@RTK.md' ~/.claude/CLAUDE.md                     # expected: 1 — operator import survived
grep -c '^# graphify' ~/.claude/CLAUDE.md                  # expected: 1 — operator section survived
ls ~/.claude/CLAUDE.md.bak* 2>/dev/null | wc -l            # expected: >= 1 — backup taken
```

**Expected**: region present carrying the source version, the pre-revision fork gone, both pieces of
operator content intact, a backup on disk. The script must also state that its effect applies from the
next session — it does not change the session that ran it.

## Step 8 — Behavioral confirmation (SC-001)

Start a fresh Claude Code session and confirm it applies a rule that exists ONLY in `v0.1.0` — the
check gate, or the standing merge authorization. Neither is in the pre-revision fork, so
either one proves the projection took effect rather than the old copy still being read.

**Expected**: the new rule is applied. This is the first end-to-end proof that the instruction set
configures an installed tool.

## Step 9 — Review-to-merge loop (Principle VI)

Runs automatically on the pull request. Round limit 3. No workflows configured, so the check gate
resolves to the absent case: merge on review approval, absence recorded.

## Definition of done

- Steps 1–6 pass against fixtures, zero blocking defects
- Step 7 passes against the real configuration, with a backup on disk
- Step 8 confirms the projection took effect in a fresh session
- Step 9 recorded in `.specify/workflows/runs/003-claude-code-adapter.md`
