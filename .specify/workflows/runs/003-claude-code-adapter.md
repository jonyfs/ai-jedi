---
Summary: Orchestration and review-chain run log for the Claude Code Adapter feature.
Tags: [#runlog #orchestration #adapter #projection]
---

# Run Log: 003-claude-code-adapter

Feature: [[spec]] · Plan: [[plan]] · Tasks: [[tasks]]

## Orchestration

Single-agent, single branch `003-claude-code-adapter`. Zero parallel implementation units — every
writing task edits `project.sh` or `run-tests.sh` and contends (Principle XI). No worktree created.

## Gate — /speckit-analyze, five passes

Severity trend: 2 CRITICAL, then 2, then 1, then 0. Three of the five CRITICALs were resolved by
amending the constitution rather than by asserting exceptions in the plan — Governance says the
constitution wins, so a plan cannot grant itself relief.

| Pass | CRITICAL | Resolution |
|---|---|---|
| 1 | 2 | Principle IX gained the one-time fork migration exception (I vs IX conflict); Principle XI sanctioned the PR-per-story exception that `instructions.md` already carried without backing |
| 2 | — | (feature 002) |
| 3 | 2 | TDD inversion from my own late insertions; ungated migration window between two tasks |
| 4 | 1 | Constitution v1.16.0: the over-limit clause now permits refusing, not only summarizing |
| 5 | 0 | Gate satisfied |

## Phase 1-2 — Setup and declaration

- T002 baseline: 56 lines, fork span 6-56, exactly one heading matching `^# .* V[0-9]+:`, zero matching
  the versioned pattern. Stored outside `/tmp` and gitignored — it is a copy of the operator's personal
  configuration in a public repository.
- T004 `adapter.yml`: all declared fields present, including the four the authoring constraints require
  of every adapter, the fork patterns as literal expressions, the backup naming pattern, and
  `over_limit: refuse` with its reasoning.

## Phase 3-5 — TDD

**RED observed before any implementation**: 11 real failures across create, idempotent, fork, drift,
backup, selfverify.

Two harness bugs found by actually running it, both worth recording:

- **`GROUPS` is a special bash array** (process group IDs). macOS `/bin/sh` is bash in POSIX mode, so
  assigning it is silently ignored: the dispatch loop never iterated, the suite printed nothing, and
  exited 1 with no diagnostic. Renamed `TEST_GROUPS`.
- `assert_refused` snapshotted fixtures with `cp`, which fails on a `chmod 000` fixture, so the
  unreadable-target case reported a false mutation. Now fingerprints by size and mtime.

**Recorded caveat**: a stub that refuses everything passes all seven refusal cases, because
`assert_refused` only requires a non-zero exit and an unmutated target. Refusal tests cannot distinguish
"correctly refuses" from "does nothing". The RED signal came from the writing groups instead.

**GREEN**: 49 assertions, 0 failures, across all ten groups.

One implementation bug found in GREEN: fork detection stripped the `N: ` line-number prefix when
*counting* matches but not when *locating* the line, and the declaration's patterns are `^`-anchored —
so the prefix ate the anchor and `FORK_START` came back empty. Re-anchored past the prefix.

One test expectation was wrong, not the code: the inline marker-like text case asserted a refusal.
FR-014's exact full-line matching means such text is simply invisible to detection, so appending a real
region is correct behavior. Test corrected.

## Phase 6 — Real projection (T028)

```
Unmarked fork detected.
  signal matched: # ⚡ SYSTEM SPECIFICATION V4: SUPERPOWERS & CAVEMAN-ENFORCED LLM WIKI
  span: lines 6-56 of <target>
```

Verified against the T002 baseline:

| Check | Result |
|---|---|
| Fork removed | 0 occurrences of the pre-revision title |
| `@RTK.md` import | present |
| `# graphify` section | present |
| Byte-identity above the region | identical |
| Below the region | empty — the fork ran to EOF |
| Backup on disk | 1 |
| Drift check | `current (v0.1.0)` |
| Second run on the real config | byte-identical |
| Resulting file | 419 lines, under the declared 800 |

This is the first time in the project's history that `instructions.md` configures an installed tool.
It also closed a standing Principle I violation: the target had been carrying a hand-maintained fork,
drifted two versions behind.

## Phase 7 — Parity

README corrected: the claim "No adapter has been written for any tool yet" became false on merge.
Frontmatter re-evaluated per the authoring constraints. Codex, Copilot and OpenCode remain stated as
unexercised, because they are.
## Phase 8 — Review-to-merge loop

**Round limit: 3** (constitutional default). Target: PR #5.

### Round 1 — reviewer

Scope: 14 files, +1743/-14, of which ~430 lines are the deliverable. Deliverable reviewed in depth;
feature artifacts skimmed after five analyze passes. `shellcheck` is not installed here, so neither
shell file was linted — recorded as N1 rather than left unstated.

**Verdict: comment — 0 blocking, 2 high, 3 medium, 2 nits.**

| ID | Severity | Finding |
|---|---|---|
| H1 | High | `project.sh` had two `mktemp` calls and zero `trap`. Every `die()` between a mktemp and its `rm -f` leaked, and the `$NEW` leak would leave a full copy of the projected instruction set in the temp directory. |
| H2 | High | `stat -f '%z %m'` is BSD-only. On GNU coreutils `-f` means FILESYSTEM stat and that format is invalid, so both fingerprints fell through to the same fallback string, compared EQUAL, and all seven refusal mutation-checks passed vacuously. Seven assertions reporting green while verifying nothing — worse than a failing test. |
| M1 | Medium | Backups accumulate with no retention policy; the declaration acknowledges the load hazard but not unbounded growth. |
| M2 | Medium | Seconds-granularity backup names collide when two runs land in the same second, and the second `cp` overwrites the first. |
| M3 | Medium | No `set -e`; the compose block's `head`/`tail`/`sed`/`awk` are unchecked, and a truncated `$NEW` would still pass FR-015 verification because markers and version would be present. |
| N1 | Nit | `shellcheck` never run. |
| N2 | Nit | `decl()` used once. |

### Round 1 — shepherd

- H1: cleanup trap added, both temp variables pre-initialized.
- H2: replaced with a portable `fingerprint()` using `cksum` plus `wc -c`, with `ls -ln` for the
  unreadable case. Verified independently that it detects a same-length content change, is stable
  across identical content, and returns non-empty for a `chmod 000` file — a fix that did not actually
  detect mutation would have been cosmetic.
- M2: `$$` appended to the backup name.
- M3: **partially** fixed. Added a pre-write assertion that the composed file is not shorter than the
  source content, which catches the truncation case FR-015 cannot see. Adding `set -e` to a script this
  branch-heavy was rejected as riskier than the defect.
- M1 and the rest of M3: deferred to the backlog rather than fixed here. Retention policy is a design
  decision, not a review finding, and `set -e` conversion needs its own verification.
- N1: deferred — adding a linter the machine lacks would be a green group that never runs.

Suite after the fixes: 49 passed, 0 failed. Real config still projects idempotently. Zero temp files
leaked.

### Round 2 — re-review of the shepherd's own diff (Principle VI step 3)

Target: 3 files, +74/-3. Reviewed independently rather than merged on round 1's verdict.

| Finding | Status |
|---|---|
| H1 | RESOLVED — trap covers both temps; `cleanup()` returns 0 so the EXIT trap does not alter the exit code |
| H2 | RESOLVED — portable `fingerprint()`; the only remaining `stat -f` occurrence is the comment documenting the bug |
| M2 | RESOLVED — `$$` in the backup name |
| M3 | PARTIALLY resolved as stated; remainder deferred |

Exit codes verified unchanged: `--check` returns 0, an unwritable target returns 1 with `REFUSED: write
failed` rather than silently doing nothing. No regression: 49 passed, 0 failed.

**Round 2 verdict: approve — 0 blocking, 0 high, 0 medium, 0 nits.** Rounds used: 2 of 3.

### Check gate — evaluated

Observed state: no `.github/workflows` directory, `gh pr checks 5` reports none, `required_status_checks`
is null. This is the **absent-checks case**, not a failure and not a pending state. Merge proceeded on
review approval, and the absence is recorded here so a later reader can distinguish "checks passed" from
"no checks existed". **No checks existed.**

### Merge and cleanup

Merged as `5254770`. Remote branch removed by the platform (`delete_branch_on_merge`), local branch
deleted, remote pruned, one worktree, zero merged branches remaining.

Branch protection on `main` byte-identical before and after: `enforce_admins` true, pull request
required, conversation resolution required, force pushes and deletions both disabled.

Verified on `main`: suite 49 passed 0 failed, `--check` reports `current (v0.1.0)`.

## Deferred

- **T043** — the cross-tool behavioral probe. A fresh session must confirm it applies a rule present only
  in v0.1.0. Cannot be self-administered by the session that ran the projection, which still holds the
  instructions it loaded at start.
- **M1** backup retention, the rest of **M3** (`set -e` conversion), and **N1** shellcheck. Recorded in
  `specs/BACKLOG.md` rather than left in a merged review thread.
