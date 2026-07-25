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
