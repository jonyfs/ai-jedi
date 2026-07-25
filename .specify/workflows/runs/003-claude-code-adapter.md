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
