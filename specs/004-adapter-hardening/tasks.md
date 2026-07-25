---
Summary: Test-first task list for adapter hardening — bounded retention, content-based composition check, and a skip-aware lint group.
Tags: [#tasks #adapter #hardening #tdd]
---

# Tasks: Adapter Hardening

**Input**: Design documents from `specs/004-adapter-hardening/`

**Prerequisites**: [[plan]], [[spec]]

**Tests**: REQUIRED and test-first. The deliverable is executable, so the constitution's TDD rule applies.

**Organization**: by user story. Failing tests precede implementation in every phase.

## Format: `[ID] [P?] [Story] Description`

## Path Conventions

Everything lives in `.specify/adapters/claude-code/`. Fixtures under the system temp directory.

**Safety rule**: no task writes `~/.claude/CLAUDE.md`. T014 verifies against it read-only. The adapter is
live in the operator's global config, so an accidental write there is worse than a failing test.

---

## Phase 1: Setup

- [ ] T001 [P] Create `.specify/workflows/runs/004-adapter-hardening.md` with frontmatter for orchestration and review state
- [ ] T002 [P] Capture the current success-path output as the FR-005 reference: run the adapter against a temp fixture, store the result under the system temp directory, and record its checksum in the run log

**Checkpoint**: the byte-identity reference for FR-005 exists before anything changes.

---

## Phase 2: Foundational — declaration (Blocking)

- [ ] T003 Add `retain: 3` under the `backup` key in `.specify/adapters/claude-code/adapter.yml`, with a comment stating why 3 and that pruning is subordinate to the projection (FR-001)

**Checkpoint**: the limit is declared, so pruning has a value to read rather than a constant to hardcode.

---

## Phase 3: User Story 1 — Backups stay bounded (Priority: P1) 🎯 MVP

**Independent Test**: run more times than the limit; count stops at the limit with the newest kept.

- [ ] T004 [US1] Write failing cases for a `retention` group in `.specify/adapters/claude-code/tests/run-tests.sh`: below the limit adds without removing; at the limit removes the oldest and holds steady; a pruning failure leaves the projection successful; files not matching the declared pattern are never considered; the live target is never a pruning candidate. Run and watch them fail (FR-001, FR-002, FR-003)
- [ ] T005 [US1] Implement pruning in `.specify/adapters/claude-code/project.sh`, running AFTER a successful write and never before — pruning first would delete the safety net the write might still need. Match only the declared backup pattern, remove oldest first, and swallow any failure with a warning rather than failing the projection (FR-001, FR-002, FR-003)
- [ ] T006 [US1] Run `.specify/adapters/claude-code/tests/run-tests.sh retention` and confirm all cases pass (SC-001, SC-002)

---

## Phase 4: User Story 2 — No silent failure produces a valid-looking projection (Priority: P1)

**Independent Test**: inject a compose failure; the adapter refuses and the target is byte-unchanged.

- [ ] T007 [US2] Write failing cases for a `composition` group in `.specify/adapters/claude-code/tests/run-tests.sh`: a truncated composition that still carries valid markers and the correct version is REJECTED on content grounds; the target is byte-unchanged after rejection. Run and watch them fail (FR-004)
- [ ] T008 [US2] Strengthen the composition check in `.specify/adapters/claude-code/project.sh` so it is content-based rather than structural, and add an injection hook so the truncation case is reachable from a fixture (FR-004)
- [ ] T009 [US2] Run `.specify/adapters/claude-code/tests/run-tests.sh composition` and confirm all cases pass (SC-003)

---

## Phase 5: User Story 3 — The shell is statically checked (Priority: P2)

**Independent Test**: with the linter absent the group reports SKIPPED and is excluded from the pass count.

- [ ] T010 [US3] Write failing cases for a `lint` group in `.specify/adapters/claude-code/tests/run-tests.sh`: when the linter is present the group executes and its result counts toward the verdict; when absent it reports SKIPPED and is NOT counted as a pass; the linter version is recorded so a differing result elsewhere is attributable. Run and watch them fail (FR-006, FR-008)
- [ ] T011 [US3] Implement the lint group in `.specify/adapters/claude-code/tests/run-tests.sh` with three distinct outcomes — pass, fail, skipped — and a `skip()` counter separate from `ok()`, because a skipped group counted as passing is the vacuous assertion the PR #5 review caught in `stat -f` (FR-006, FR-008)
- [ ] T012 [US3] Run `.specify/adapters/claude-code/tests/run-tests.sh lint` on this machine, where the linter is absent, and confirm it reports SKIPPED rather than PASSED (SC-005)

---

## Phase 6: Regression & Parity

- [ ] T013 Run the full suite `.specify/adapters/claude-code/tests/run-tests.sh` and confirm every pre-existing group still passes — hardening must not alter correct behavior
- [ ] T014 Verify FR-005 against the T002 reference: project into a temp fixture and confirm the success-path output is byte-identical to the pre-change reference. Then confirm read-only that `~/.claude/CLAUDE.md` still reports `current` via `project.sh --check` (SC-004)
- [ ] T015 Record the reviewed no-change decision for `README.md` in `.specify/workflows/runs/004-adapter-hardening.md`: retention and linting are not operator-visible benefits, so no README claim changes (Principle XII, Authoring Constraints)
- [ ] T016 Confirm no committed file under `.specify/adapters/` contains an absolute home path, a username, or a credential-shaped string (Principle IX)

---

## Phase 7: Autonomous Review-to-Merge Loop (Principle VI)

**Round limit: 3** — constitutional default.

- [ ] T017 Open a pull request from `004-adapter-hardening` to `main` covering `.specify/adapters/claude-code/` and the feature artifacts, declaring the Principle XI single-PR exception
- [ ] T018 Run the reviewer and record the severity-ranked verdict with its round number in `.specify/workflows/runs/004-adapter-hardening.md`
- [ ] T019 If findings exist, run the shepherd only after the review closes, fixing ONLY what review raised in `.specify/adapters/claude-code/`. If the review closed with no findings, SKIP the shepherd entirely
- [ ] T020 If the shepherd ran, re-review its own diff and record the round in `.specify/workflows/runs/004-adapter-hardening.md`
- [ ] T021 Repeat T019–T020 until a review closes clean or round 3 is reached, recording each round in `.specify/workflows/runs/004-adapter-hardening.md`
- [ ] T022 Evaluate the check gate and record the OBSERVED state in `.specify/workflows/runs/004-adapter-hardening.md`
- [ ] T023 Complete the merge into `main` without requesting confirmation per the standing authorization, recording the outcome in `.specify/workflows/runs/004-adapter-hardening.md`
- [ ] T024 AFTER the merge, confirm the platform removed the remote ref, delete the LOCAL branch `004-adapter-hardening`, confirm no worktree remains, and verify branch protection on `main` is byte-identical to before the loop

---

## Dependencies & Execution Order

**Phase order**: 1 → 2 (blocking) → 3 → 4 → 5 → 6 → 7.

**TDD ordering is mandatory**: T004 before T005. T007 before T008. T010 before T011. Each test task must
be run and observed FAILING before its implementation. Code written ahead of its test must be deleted.

**T002 before T014** — the FR-005 reference must exist before the change that could violate it.

**Within Phase 7**: T018 before T019 (shepherd never before the review closes). T019 before T020 (the
shepherd's diff must be re-reviewed). T023 before T024 (branch deleted after the MERGE, never on approval).

## Parallel Opportunities

T001 and T002 only. Everything in Phases 2–5 edits `project.sh` or `run-tests.sh` and contends; per
Principle XI a worktree would not change that.

## Implementation Strategy

**MVP**: Phases 1–3. Bounded retention alone removes the only defect already accruing in the operator's
configuration directory.

**Increment 2**: Phase 4 — the content check closes a gap the structural check cannot see.

**Increment 3**: Phase 5 — linting, which finds classes rather than instances.

**Gate**: `/speckit-analyze` MUST report convergence before T003, the first task that writes a deliverable.
