---
Summary: Test-first task list generalizing the adapter to per-target declarations and shipping four verified targets.
Tags: [#tasks #adapter #multi-target #tdd]
---

# Tasks: Multi-Target Adapters

**Input**: Design documents from `specs/005-multi-target-adapters/`

**Prerequisites**: [[plan]], [[spec]]

**Tests**: REQUIRED and test-first. The deliverable is executable.

**Organization**: by user story, failing tests before implementation.

## Path Conventions

`.specify/adapters/` with one `project.sh`, one `tests/`, and `targets/<tool>.yml` per tool.

**Safety rule**: no task writes any real global config. T016 projects for real, once, after every
fixture group is green for every target. Four live tool configurations are at stake, not one.

---

## Phase 1: Setup

- [ ] T001 [P] Create `.specify/workflows/runs/005-multi-target-adapters.md` with frontmatter for orchestration and review state
- [ ] T002 [P] Capture the current Claude Code success-path output as the regression reference: run the existing adapter against a temp fixture and record its cksum in `.specify/workflows/runs/005-multi-target-adapters.md`
- [ ] T003 [P] Back up all four real target files that exist to the system temp directory, recording each path and cksum in `.specify/workflows/runs/005-multi-target-adapters.md`, so T016 can be verified and reverted

---

## Phase 2: Foundational — restructure (Blocking)

- [ ] T004 Move `.specify/adapters/claude-code/adapter.yml` to `.specify/adapters/targets/claude-code.yml`, and `project.sh` plus `tests/` up to `.specify/adapters/`, with `git mv` so history follows
- [ ] T005 Change `.specify/adapters/project.sh` to take its declaration from a `--target <name>` argument resolving to `targets/<name>.yml`, defaulting to `claude-code` so existing invocations keep working (FR-002)
- [ ] T006 Move the foreign-marker list out of `project.sh` into each declaration under a `foreign_markers` key, and read it from there — the hardcoded `SPECKIT` pair cannot recognise OpenCode's `caveman-begin`/`caveman-end` syntax, and failing to recognise a foreign region means overwriting a working tool's configuration (FR-003)
- [ ] T007 Run `.specify/adapters/tests/run-tests.sh` and confirm all 64 assertions still pass for the Claude Code target after the restructure

**Checkpoint**: one script, declaration-driven, existing target unaffected.

---

## Phase 3: User Story 2 — Foreign regions survive (Priority: P1) 🎯 MVP

**Why before US1**: the OpenCode target is occupied end-to-end by a foreign region. Getting projection
working before foreign-region safety works would risk destroying a live configuration on first run.

- [ ] T008 [US2] Write failing cases in `.specify/adapters/tests/run-tests.sh` for a `foreign-multi` group: a target whose entire content is a foreign region using non-`SPECKIT` syntax keeps it byte-identical and gains the instruction region alongside; fork detection excludes the foreign interior; a target with two different foreign syntaxes leaves both alone. Run and watch them fail (FR-003, SC-003)
- [ ] T009 [US2] Implement per-declaration foreign-marker recognition in `.specify/adapters/project.sh` so the region scan and the fork scan both consult the target's declared list (FR-003)
- [ ] T010 [US2] Run `.specify/adapters/tests/run-tests.sh foreign-multi` and confirm all cases pass (SC-003)

---

## Phase 4: User Story 1 — Every capable tool is reached (Priority: P1)

- [ ] T011 [US1] Write failing cases in `.specify/adapters/tests/run-tests.sh` for a `multi-target` group: every declared target projects, creates a missing file, is idempotent, and the content between markers is byte-identical across all of them. Run and watch them fail (FR-001, FR-004, FR-005, SC-001, SC-002)
- [ ] T012 [US1] Write `.specify/adapters/targets/opencode.yml` declaring its path, format, own markers, the `caveman-begin`/`caveman-end` foreign pair, size limit, backup policy, and tier map (FR-001)
- [ ] T013 [US1] Write `.specify/adapters/targets/gemini.yml` and `.specify/adapters/targets/copilot.yml` with the same required fields (FR-001)
- [ ] T014 [US1] Write `.specify/adapters/targets/codex.yml`, whose target file is absent — the adapter creates it, which is the documented behavior for a declared path with no file yet (FR-001)
- [ ] T015 [US1] Run `.specify/adapters/tests/run-tests.sh` in full against EVERY target and confirm all groups pass for each, not only the first (SC-005)

**Checkpoint**: every fixture group green for every target. Only now is a real write safe.

---

## Phase 5: Real Projection

- [ ] T016 Project into all four real targets, confirming for each: region present at the current version, foreign regions byte-identical, operator content byte-identical, backup on disk. Compare against the T003 snapshots (SC-001, SC-003)
- [ ] T017 Verify SC-002 against the real targets: extract the region from each and confirm the content between markers is byte-identical across all five projected tools including Claude Code
- [ ] T018 Record the T016 and T017 outcomes in `.specify/workflows/runs/005-multi-target-adapters.md`, including each backup filename

---

## Phase 6: Parity & Regression

- [ ] T019 [P] Update the tool table in `README.md` so every installed tool is listed as either projected or uncovered-with-reason — Cursor and Windsurf expose no global instruction surface and MUST say so rather than being omitted (FR-006, FR-007)
- [ ] T020 [P] Re-evaluate `README.md` frontmatter after T019, or record the reviewed no-change decision in `.specify/workflows/runs/005-multi-target-adapters.md` (Authoring Constraints)
- [ ] T021 Verify the Claude Code regression reference from T002: project into a temp fixture and confirm the success path is byte-identical to before the restructure
- [ ] T022 Confirm `shellcheck -s sh` reports zero findings across `.specify/adapters/project.sh` and `.specify/adapters/tests/run-tests.sh`
- [ ] T023 Confirm no committed file under `.specify/adapters/` contains an absolute home path, a username, or a credential-shaped string (Principle IX)

---

## Phase 7: Autonomous Review-to-Merge Loop (Principle VI)

**Round limit: 3.**

- [ ] T024 Open a pull request from `005-multi-target-adapters` to `main` covering `.specify/adapters/`, `README.md`, and the feature artifacts, declaring the Principle XI single-PR exception
- [ ] T025 Run the reviewer and record the verdict with its round number in `.specify/workflows/runs/005-multi-target-adapters.md`
- [ ] T026 If findings exist, run the shepherd only after the review closes, fixing ONLY what review raised. If the review closed clean, SKIP the shepherd entirely
- [ ] T027 If the shepherd ran, re-review its own diff and record the round in `.specify/workflows/runs/005-multi-target-adapters.md`
- [ ] T028 Repeat T026–T027 until a review closes clean or round 3, recording each round in `.specify/workflows/runs/005-multi-target-adapters.md`
- [ ] T029 Evaluate the check gate and record the OBSERVED state in `.specify/workflows/runs/005-multi-target-adapters.md`
- [ ] T030 Complete the merge into `main` without requesting confirmation per the standing authorization, recording the outcome in `.specify/workflows/runs/005-multi-target-adapters.md`
- [ ] T031 AFTER the merge, confirm the platform removed the remote ref, delete the LOCAL branch, confirm no worktree remains, verify branch protection is byte-identical, and record it all in `.specify/workflows/runs/005-multi-target-adapters.md`

---

## Dependencies & Execution Order

**Phase order**: 1 → 2 (blocking) → 3 (US2) → 4 (US1) → 5 → 6 → 7.

**US2 before US1 deliberately.** Foreign-region safety must work before projection does, because one
live target is occupied end-to-end by a foreign region and a first run without that safety would destroy
a working configuration.

**TDD ordering is mandatory**: T008 before T009, T011 before T012–T014. Observe each failing first.

**T003 before T016** — snapshots of four live files must exist before the only task that writes them.
**T007, T010, T015 all green before T016** — a real configuration is never the first target.

**Within Phase 7**: T025 before T026, T026 before T027, T030 before T031.

## Parallel Opportunities

T001–T003 (different files). T012–T014 write separate declarations but land after T011's tests exist.
T019 and T020 both touch `README.md` — serialize if they conflict. Everything editing `project.sh` or
`run-tests.sh` contends.

## Implementation Strategy

**MVP**: Phases 1–3. Foreign-region safety generalized is the part that prevents damage.

**Increment 2**: Phase 4 — the four declarations.

**Increment 3**: Phases 5–6 — real projection and honest documentation.

**Gate**: `/speckit-analyze` MUST report convergence before T004, the first task that writes a deliverable.
