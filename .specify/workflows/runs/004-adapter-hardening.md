---
Summary: Orchestration and review-chain run log for the Adapter Hardening feature.
Tags: [#runlog #orchestration #adapter #hardening]
---

# Run Log: 004-adapter-hardening

Feature: [[spec]] · Plan: [[plan]] · Tasks: [[tasks]]

## Orchestration

Single-agent, single branch. Zero parallel implementation units — every task edits `project.sh` or
`run-tests.sh` and contends (Principle XI).

## Gate — /speckit-analyze

0 CRITICAL, 3 HIGH, 4 MEDIUM, 2 LOW. Two of the HIGH were my own errors:

- **F1** — the spec required rejection "on content grounds, not structural ones" while the plan delivered
  a line-count floor and *admitted* the weakness instead of resolving it. A line count is itself a
  structural proxy: it would accept a same-length substitution. Resolved by doing the real check — compare
  the `cksum` of the region extracted from the composed file against the `cksum` of the same
  `$SRC_CONTENT` used to compose it. Exact by construction, and the trailing-newline worry that motivated
  the line-count idea does not arise when both sides come from one variable.
- **D1** — a Principle II violation in already-merged code. `BACKUP_SUFFIX` is hardcoded in
  `project.sh` while `adapter.yml` declares a different pattern, and the real filename gained a `-$$`
  the declaration never recorded. The script header claims "nothing is hardcoded here" — false as shipped.
- **E1** — FR-007 and SC-006 had no task, and could not have one: the linter is absent, so no finding
  exists to suppress. Deferred explicitly in the spec with the reason, and tracked in the backlog. A task
  pretending to triage findings it cannot generate would be worse than an honest deferral.

## Phase 1 — Setup

- T002 FR-005 reference captured at `/tmp/aijedi-fr005-ref.md`, cksum `2195510091 25097`. Any change to the success path must
  reproduce this byte-for-byte.

## Phases 2-5 — TDD

**RED observed**: 7 failures across `retention` and `composition` before implementation. The `lint` group
reported SKIP and was correctly excluded from the pass count — 5 passed, not 6.

**GREEN**: 12 passed, 0 failed, 1 skipped in the new groups.

One bug found during GREEN, with a single root cause behind two symptoms: `sub()` stripped single quotes
but not double quotes, so `backup.suffix` came back as `".aijedi-backup"` with the quotes attached. The
pruning glob then contained literal quote characters and matched nothing — pruning was silently disabled,
and both the count assertion and the pre-seeded case failed. Fixed to strip both quote styles.

Worth noting: this is the same class as the earlier `stat -f` defect — a mechanism that looked like it
worked because nothing it examined ever matched.

## Phase 6 — Regression and FR-005

| Check | Result |
|---|---|
| Full suite | 61 passed, 0 failed, 1 skipped |
| FR-005 success-path byte-identity | cksum `2195510091 25097` before and after — identical |
| Live global config (read-only) | `current (v0.1.0)` |
| Backups in the operator's config directory | 1, within the declared limit of 3 |
| Absolute paths or credentials in committed adapter files | none |

**T015 — README no-change decision, reviewed and recorded.** Retention limits and static linting are not
operator-visible benefits: the README describes what the adapter does for the operator, and neither
changes that. No claim in it became false. Frontmatter re-evaluated and left as is.

## Phase 7 — Review-to-merge loop

**Round limit: 3.** Target: PR #7.

### Round 1 — reviewer

Several things checked and found NOT to be defects, recorded so a later reader does not re-litigate
them: the `while` loop runs in a subshell but sets no variables, so nothing is lost; `cksum` of empty
output (`4294967295 0`) differs from a bare newline, so the empty-composition case is genuinely caught;
the injection branch is inert when unset, and FR-005 proves it byte-for-byte.

**Verdict: comment — 0 blocking, 0 high, 2 medium, 2 nits.**

| ID | Severity | Finding |
|---|---|---|
| M1 | Medium | `retain` comes from an operator-editable declaration. A non-numeric value reached both the comparison and the arithmetic, erroring noisily on every run — disturbing the projection that FR-003 says housekeeping must not disturb. |
| M2 | Medium | `prune_backups \|\| printf ...` was unreachable: the function ends in `return 0` by design, so the `\|\|` branch read as protection that does not exist. |
| N1 | Nit | A test-only branch lives in production code. Inert and FR-005-verified, but a real cost — the alternative was making each compose step individually checkable, which is larger. Named so the trade is visible rather than incidental. |
| N2 | Nit | `ls \| wc -l` miscounts a filename containing a newline. Not reachable through the adapter's own naming. |

### Round 1 — shepherd

M1: non-numeric `retain` now warns and skips pruning cleanly. Verified behaviourally, not just
structurally — the warning appears AND the projection still succeeds with exit 0.

M2: the dead `||` removed, with a comment stating that `prune_backups` returns 0 by design so a future
reader does not re-add it.

N1 and N2 left as recorded observations. N1 is a design trade already made and verified; N2 is not
reachable through this adapter's own naming.

### Round 2 — re-review of the shepherd's own diff

Suite 61 passed, 0 failed, 1 skipped. FR-005 byte-identity intact — cksum `2195510091 25097` unchanged
through both the hardening and its review fixes.

**Round 2 verdict: approve — 0 findings.** Rounds used: 2 of 3.

## Phase 8 — Lint triage (FR-007, SC-006, unblocked)

The operator installed shellcheck 0.11.0, so the group switched from SKIPPED to executing — and
immediately failed, which is what a real assertion does.

| Finding | Count | Disposition |
|---|---|---|
| SC2015 — `A && B \|\| C` is not if-then-else | 31 | **Fixed.** Safe today only because `ok()` always returns 0 — an accidental property. If it ever changed, every assertion would report pass AND fail. Converted to `if/then/else`. |
| SC2012 / SC2010 — parsing `ls` | 7 | **Fixed** with glob enumeration. |
| SC2181 — checking `$?` indirectly | 1 | **Fixed.** |
| SC2329 — function never invoked | 1 | **Suppressed inline** with justification: `cleanup()` is invoked by the `trap` on the following line. A genuine false positive. |
| SC2012 on the unreadable-file fallback | 1 | **Suppressed inline** with justification: a `chmod 000` file cannot be read, so `wc -c` is unavailable; `ls -ln` is the portable way to get its size without reading. Single known path, no glob expansion. |

**SC2012 is the one worth recording.** It flagged exactly the `ls`-parsing weakness I raised as N2 in my
own PR #7 review and then dismissed as "not reachable through this adapter's own naming". The linter
disagreed and was right: robustness should not depend on nobody creating an awkward filename. A reviewer
talked himself out of a finding a tool then caught — an argument for running the tool.

Result: **64 passed, 0 failed, 0 skipped**. Zero shellcheck findings. FR-005 byte-identity still intact
at cksum `2195510091 25097`.
