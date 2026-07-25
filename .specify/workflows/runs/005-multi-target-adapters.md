---
Summary: Orchestration and review-chain run log for the Multi-Target Adapters feature.
Tags: [#runlog #orchestration #adapter #multi-target]
---

# Run Log: 005-multi-target-adapters

## Gate — /speckit-analyze, four passes

CRITICAL count: 0, 1, 1, 0. One amendment came out of it — constitution v1.17.0 added the
no-integration case to the Authoring Constraints, after pass 3 caught the plan qualifying an unqualified
MUST inside a table cell and then asserting "no violations" two sections later.

Pass 4 found zero content problems and two synchronisation ones, both of them my own earlier corrections
left half-applied. That was the signal to stop refining artifacts and implement: four passes over
documents describing work not yet done, with defects that were drift between files rather than design
errors.

## Phases 1-2 — Setup and restructure

- T002 FR-005 reference captured: cksum `2195510091 25097`.
- T003 backed up the four target files that exist. Codex had none.
- T004 `git mv` into one `project.sh`, one `tests/`, and `targets/<tool>.yml`.
- T004a brought `claude-code.yml` up to the normative schema. It predated `missing_directory` and
  `speckit_integration` and would otherwise have ended the feature as the only non-conforming declaration.
- T006 replaced the hardcoded `SPECKIT` literals with each declaration's own `foreign_markers` — a key
  that had been declared and ignored since feature 003.
- T007 after the restructure: 64 passed, 0 failed.

Two bugs of mine in this phase, the same class both times:

- The first `--target` implementation put a comment mid-command-substitution and took the suite from 64
  passing to 24 failing. Reverted and redone by passing `--target "$TEST_TARGET"` quoted, which needs no
  suppression at all. The cleaner fix was also the simpler one.
- I printed "substitution applied" from a script whose `.replace()` had not matched, and reported
  success. The Copilot failure survived a fix I had already announced as done. Redone with an assert.

## Phases 3-4 — Declarations

Five declarations, 15/15 normative fields each. Full suite against every target:

| Target | Result |
|---|---|
| claude-code | 64 passed, 0 failed |
| opencode | 64 passed, 0 failed |
| gemini | 64 passed, 0 failed |
| copilot | 64 passed, 0 failed |
| codex | 64 passed, 0 failed |

320 assertions total. Zero shellcheck findings.

The Copilot target declares `missing_directory: refuse`, and the `create` group failed against it — the
TEST was wrong, not the code. It asserted creation unconditionally while the declaration said refuse.
Fixed to assert the DECLARED policy, which is exactly what analyze finding A1 had asked for: "either
creates or refuses" passes for any behavior and is no assertion at all.

## Phase 5 — Real projection

All five targets projected and reporting `current (v0.1.0)`.

| Check | Result |
|---|---|
| SC-002 — content between markers identical across all five | one cksum, five files |
| SC-003 — OpenCode's caveman region | byte-identical to its T003 backup |
| `AGENTS.md` collision, Codex vs OpenCode | no cross-contamination; Codex holds no caveman content |
| Backups on disk | 4 — Codex had no prior file |
| FR-005 — Claude Code success path | cksum unchanged through the entire restructure |

## Phase 6 — Parity

README tool table lists all seven surveyed tools: five projected, two not covered with the reason
stated. The Status block was corrected — under a heading promising "honest current state" it had said
constitution v1.16.0, "Ten test groups, 49 assertions", and "the other three tools", all three wrong.
