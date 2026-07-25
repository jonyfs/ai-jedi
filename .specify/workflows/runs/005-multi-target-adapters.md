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

## Phase 7 — Review-to-merge loop

**Round limit: 3.** Target: PR #10.

### Round 1 — reviewer

Verified independently: 320 assertions across five targets, zero failures, zero shellcheck findings,
five targets reporting current, real idempotency confirmed against all five live files, OpenCode's
caveman region byte-identical.

Checked and found NOT to be a defect: claude-code carries 19 declaration fields against the others' 15.
The four extras are `skill_install`, `skill_verify`, `skill_version_source` and
`invoke_separator_source`, which exist only because that target has a real SpecKit integration. Exactly
what constitution v1.17.0 sanctions.

**Verdict: comment — 0 blocking, 1 high, 1 nit.**

| ID | Severity | Finding |
|---|---|---|
| H1 | High | I wrote twelve model identifiers across four declarations and verified none of them. Only claude-code's map came from a source this project knows; the other nine were written from plausibility. `tier_map_verify_before_use: true` suggests a checkable starting point, but presenting an invented identifier as fact is the same defect as asserting a number without counting it — now in a file another agent reads as truth. A wrong identifier either fails the dispatch or falls back silently, and the second is worse. |
| N1 | Nit | Codex maps `deep-reasoning` and `balanced-coding` to one identifier. Possibly correct, but indistinguishable from a copy-paste slip without a note. |

### Round 1 — shepherd

H1: every declaration now carries `tier_map_verified`. True for claude-code, **false** for the four
others, with a comment stating the identifiers came from plausibility rather than a vendor document and
must be resolved before dispatch. The README Status block says the same, so an operator sees it without
reading a declaration.

N1: the Codex collapse is annotated as intentional, noting it collapses UPWARD so no phase is
downgraded.

Suite after the fixes: 64 passed per target across all five, zero shellcheck findings.

### Round 2 — re-review of the shepherd's own diff

Declaration-only changes plus one README paragraph. No logic touched. All five targets still 64/0/0,
still `current`, shellcheck still clean.

**Round 2 verdict: approve — 0 findings.** Rounds used: 2 of 3.

### Check gate

No workflows configured, no checks reported, `required_status_checks` null — the absent-checks case.
Merge proceeds on review approval; the absence is recorded here.

## Phase 8 — T008/T010, completed after the merge

T024–T031 were done during the loop but left unmarked; T009 landed inside T006. T008 and T010 were
genuinely open, and the reason is worth recording: the `foreign` group tested the literal
`<!-- SPECKIT START -->` pair and nothing else. Only one declaration actually uses that pair, so the
group was passing **vacuously** for the other four — the same defect class as the `stat -f`
fingerprints, caught the same way.

New `foreignmulti` group, reading the pair out of the declaration under test:

| Case | What it asserts |
|---|---|
| All-foreign file | A file that is entirely a foreign region in the DECLARED syntax keeps it byte-identical and gains the instruction region alongside |
| Foreign interior | A heading inside the foreign region does not trigger fork detection, and survives |
| Two syntaxes | A second, undeclared foreign syntax is ordinary operator content and survives byte-identical |
| No pair declared | SKIP, plus a substitute assertion that the adapter invents no markers |

Two of my own defects in writing it, both the vacuous-assertion pattern again:

- The first fork fixture used the heading `# AI Jedi Instructions v0.0.9`. The declared fork pattern
  requires a trailing colon, so nothing matched and the case could never fail.
- Confirmed by mutation, not by inspection: hardcoding the SPECKIT pair back into `project.sh` left
  the group fully green. After the fixture fix the same mutation produces 1 failure. The group is now
  known non-vacuous rather than assumed so.

Gemini, Copilot and Codex declare `foreign_markers: []`. That is correct — no other tool writes those
files — so the group SKIPs for them and says why. A PASS there would have been the exact claim this
group exists to stop making.

Suite: 72/0/0 for Claude Code and OpenCode, 65/0/1 for the other three. 339 assertions. Zero
shellcheck findings. All five live targets still `current (v0.1.0)`; OpenCode's caveman region intact.

### PR #11 — review loop

**Round 1 — reviewer.** Verified: 339 assertions, zero shellcheck findings, five live targets
`current`, OpenCode's caveman region intact, and the mutation drops exactly one assertion, so the new
group proves what it claims.

**Verdict: comment — 0 blocking, 1 medium, 2 nits.**

| ID | Severity | Finding |
|---|---|---|
| M1 | Medium | The "byte-identical" comparison stripped blank lines from BOTH sides, so it was not byte-identical. Verified: `a\n\n\nb` and `a\nb` compare equal after that sed. Had the adapter eaten or duplicated blank lines inside operator content, the assertion would have reported green — the exact defect this PR exists to fix, reproduced inside its own fix. |
| N1 | Nit | Fixture `printf`s carry literal newlines at column 0 inside the function; breaks on reindent. |
| N2 | Nit | `t`, `base`, `a`, `line` are globals reused across groups. |

**Round 1 — shepherd.** M1 fixed by narrowing the exemption to what actually happens: an `awk` filter
removes the managed region together with exactly the ONE blank separator line immediately preceding
it, and compares everything else byte-for-byte, blank lines included. Extracted as
`assert_outside_identical` and used by both call sites.

Probed in both directions rather than assumed: a fixture that loses one internal blank line is
reported as changed; a fixture with content intact plus the legitimate separator passes. N1 and N2 are
cosmetic and left as-is — churning fixture formatting inside a review loop is the scope expansion
Principle VI prohibits.

**Round 2 — re-review of the shepherd's own diff.** One helper added, two call sites replaced. Suite
unchanged at 72/0/0 and 65/0/1, zero shellcheck findings, live targets untouched.
**Approve — 0 findings.** Rounds used: 2 of 3.

**Check gate.** No workflows configured, `required_status_checks` null — the absent-checks case, same
as PR #10. Merge proceeds on review approval.
