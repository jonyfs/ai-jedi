---
Summary: Ordered task list for the merge-scope propagation, grouped by user story, with the version bump placed last among content edits so no projection is written twice.
Tags: [#tasks #instructions #merge-authorization #scope #projection #versioning]
---

# Tasks: Merge-Scope Propagation

**Feature**: `006-merge-scope-propagation` | **Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

**Serial, not parallel.** Every content task edits `instructions.md`. Units contending for one artifact
contend regardless of worktree isolation, so no `[P]` marker appears here — per Principle XI, marking
them parallel would advertise something that cannot be honored.

## Phase 1: Baseline

- [ ] T001 Capture the pre-change reference: `cksum` of the managed region in `instructions.md` and the
  line count, recorded in `.specify/workflows/runs/006-merge-scope-propagation.md`, so any unintended
  change to untouched content is detectable afterwards
- [ ] T002 Run every step of [quickstart.md](quickstart.md) against the CURRENT file and record which
  steps fail, in the run log. Expected baseline, established by the analyze gate rather than assumed:
  Steps 2, 4, 5 and 6 FAIL; Step 3 fails once its grep is scoped to the new block; **Step 1 PASSES at
  baseline by design** — it is a regression guard against introducing the deictic form, not a RED test,
  because section 8 carries no scope wording yet. Any OTHER step passing at baseline means its
  requirement was misread

## Phase 2: User Story 1 — merge scope (P1)

- [ ] T003 [US1] Add the **Scope of the standing authorization** block to `instructions.md` section 8,
  immediately after the existing "The authorization covers the merge step ONLY" carve-out list,
  stating: authorization applies only to a repository whose own `.specify/memory/constitution.md`
  records the grant (FR-001)
- [ ] T004 [US1] Express that test as a lookup against the working tree in the same block, and state
  explicitly why the deictic form is rejected, so a later author does not reintroduce it (FR-002)
- [ ] T005 [US1] State in the same block that outside an authorized repository the chain runs in FULL —
  review, shepherd, re-review, check gate, run log — and halts at the merge with a report (FR-003)
- [ ] T006 [US1] State that consent elsewhere is per repository, explicit, standing thereafter, and
  that silence is NOT consent for this, naming the deliberate contrast with the chain-level rule where
  silence IS consent to run the chain (FR-004)
- [ ] T007 [US1] State that when a merge proceeds under the grant with neither checks nor branch
  protection configured, the run log MUST record which protection was absent (FR-005)
- [ ] T008 [US1] Run quickstart Steps 1–3 and confirm all three now pass (SC-001, SC-002)

## Phase 3: User Story 2 — Orchestrator trigger (P2)

- [ ] T009 [US2] Narrow section 11's trigger in `instructions.md` so it requires a SpecKit
  installation rather than the presence of a `tasks.md` alone (FR-006)
- [ ] T010 [US2] Run quickstart Step 4 and confirm the trigger no longer fires on a bare `tasks.md`
  (SC-003)

## Phase 4: User Stories 3 and 4 — honesty and degradation (P3)

- [ ] T011 [US3] Replace section 6's `~65% token reduction` in `instructions.md` with a statement that
  the reduction is unmeasured, or with a measured figure and its method (FR-007)
- [ ] T012 [US4] Add a section 14 degradation row for an absent `.specify/integration.json`, stating
  the fallback and requiring the absence be reported (FR-008)
- [ ] T013 Annotate section 9's `[[README]]` and `[[constitution]]` as resolving only in the source
  repository, so a reader of a projection is not sent to files that are not there (FR-009)
- [ ] T014 Run quickstart Steps 5–6 and confirm both pass (SC-004, SC-005)

## Phase 5: Version bump

Placed here deliberately: the bump is what makes every projection stale, so it lands only once all
content is final and no target gets written twice.

- [ ] T015 Bump the title in `instructions.md` from `v0.1.0` to `v0.2.0` and the managed region's start
  marker to match (FR-010)
- [ ] T016 Re-evaluate the frontmatter `Summary` and `Tags` so they describe the directives actually
  carried, per section 1's own obligation — including the new scope rule (FR-010, FR-011)
- [ ] T017 Run quickstart Step 7 and confirm no `v0.1.0` remains anywhere in `instructions.md`
- [ ] T018 Run quickstart Step 9 and confirm the file is still under the 800-line ceiling

## Phase 6: Projection

- [ ] T019 Run the adapter suite against all five targets and confirm no new failures BEFORE writing
  any real config — 72/0/0 for claude-code and opencode, 65/0/1 for the other three (SC-007)
- [ ] T020 Project to all five real targets with `.specify/adapters/project.sh --target <name> --` and
  confirm each reports success (FR-012)
- [ ] T021 Confirm all five report `current (v0.2.0)` (SC-006)
- [ ] T022 Confirm one cksum for the content between markers across all five files (SC-006)
- [ ] T023 Confirm OpenCode's caveman region survived the version bump — this is the run that rewrites
  every region, so it is the run most likely to destroy a foreign one (SC-006)
- [ ] T024 Confirm the version bump required NO adapter code change, verifying the version is read from
  source rather than hardcoded (SC-007)

## Phase 7: Parity

- [ ] T025 Update `README.md`'s version references from `v0.1.0` to `v0.2.0` and re-check its stated
  test counts against the actual suite output rather than copying the previous claim (Principle XII)
- [ ] T026 Record the whole run in `.specify/workflows/runs/006-merge-scope-propagation.md`, including
  which quickstart steps failed at T002 and pass at the end
- [ ] T027 Remove the propagation entry from `specs/BACKLOG.md`, which exists only because this feature
  had not run

## Phase 8: Review-to-merge loop

- [ ] T028 Open a pull request declaring the Principle XI single-PR exception and its reason
- [ ] T029 Run the reviewer; record the verdict and round number in the run log. **Grep for the deictic
  form as part of the review** — the constitution amendment shipped that defect to round 1, and this
  feature copies its wording
- [ ] T030 If findings exist, run the shepherd only after the review closes, fixing only what review
  raised. If the review closed clean, skip the shepherd entirely
- [ ] T031 If the shepherd ran, re-review its own diff and record the round
- [ ] T032 Repeat T030–T031 until a review closes clean or round 3
- [ ] T033 Evaluate the check gate and record the OBSERVED state, distinguishing "checks passed" from
  "no checks existed"
- [ ] T034 Complete the merge without requesting confirmation. This repository is authorized under the
  very rule being propagated — its constitution records the grant and `main` carries enforced branch
  protection
- [ ] T035 AFTER the merge, confirm the platform removed the remote ref, delete the local branch,
  confirm no worktree remains, and verify branch protection on `main` is unchanged

## Dependency graph

```
T001 → T002 → Phase 2 (T003…T008) → Phase 3 (T009–T010) → Phase 4 (T011…T014)
                                                              ↓
                                        Phase 5 (T015…T018) — bump AFTER all content
                                                              ↓
                                        Phase 6 (T019…T024) — projection AFTER bump
                                                              ↓
                                        Phase 7 → Phase 8
```

Phases 2, 3 and 4 are independently testable stories but NOT independently mergeable: all three edit
`instructions.md`. They run in story order in one branch.
