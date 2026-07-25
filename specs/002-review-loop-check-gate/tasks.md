---
Summary: Dependency-ordered task list adding the check gate, standing merge authorization, and skip-shepherd rule to instructions.md section 8.
Tags: [#tasks #instructions #review-loop]
---

# Tasks: Review Loop Check Gate

**Input**: Design documents from `specs/002-review-loop-check-gate/`

**Prerequisites**: [[plan]] (required), [[spec]] (user stories), [[quickstart]]

**Tests**: No automated test tasks. The deliverable is Markdown with no executable surface;
verification is the documented procedure in [[quickstart]]. TDD does not apply — the constitution
scopes it to executable changes. The `grep`/`git` commands in the quickstart are procedural
verification aids, not a test suite.

**Organization**: Grouped by user story. Each story is verifiable against its own quickstart step.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1–US3 per [[spec]]
- Exact file paths in every description

## Path Conventions

Instruction control plane, no source tree. Deliverable: `instructions.md` at the repository root.
Feature artifacts under `specs/002-review-loop-check-gate/`. Run log under `.specify/workflows/runs/`.

**Serialization warning**: every writing task edits `instructions.md` and therefore contends. `[P]`
appears only on tasks writing different files. Per Principle XI, a worktree would not change this — a
single-file deliverable serializes regardless of isolation.

---

## Phase 1: Setup

- [X] T001 [P] Create `.specify/workflows/runs/002-review-loop-check-gate.md` with frontmatter to hold orchestration and review-chain state
- [X] T002 [P] Capture the pre-change directive inventory by running the Step 6 extraction from `specs/002-review-loop-check-gate/quickstart.md` against `git show main:instructions.md`, recording the count in the run log

**Checkpoint**: Pre-change baseline captured so losslessness is verifiable.

---

## Phase 2: User Story 1 — An agent knows when it may merge and when it must stop (Priority: P1) 🎯 MVP

**Goal**: Section 8 states all five check states, each mapping to exactly one action.

**Independent Test**: Quickstart Step 2 — all five states present, each with one unambiguous action.

- [X] T003 [US1] Write the "Check gate" subsection into section 8 of `instructions.md`, positioned between the loop steps and the autonomy bounds to match the constitution's ordering, stating the green, pending, failing-from-change, and failing-unrelated states with the distinct action each requires (FR-001)
- [X] T004 [US1] Add to that subsection in `instructions.md` the rule that a failure unrelated to the change is NEVER handed to the shepherd as a code defect, with the reason: there is no defect to fix, and repairing it would mean altering unrelated infrastructure — the scope expansion the bounds prohibit (FR-002)
- [X] T005 [US1] Add to that subsection in `instructions.md` the rule that distinguishing a change-caused failure from an unrelated one is a judgment call that MUST be recorded with its supporting evidence, noting that guessing permissively merges unverified work while guessing restrictively costs only a halt (FR-003)
- [X] T006 [US1] Add the fifth state to that subsection in `instructions.md`: no configured checks is NOT a blocker — merge proceeds on review approval and the absence is recorded so a later reader can distinguish "checks passed" from "no checks existed" (FR-004)

**Checkpoint**: US1 delivers the decision table an agent needs to merge or stop correctly.

---

## Phase 3: User Story 2 — An agent does not ask permission it already has (Priority: P1)

**Goal**: The standing merge authorization is stated, with its boundary complete.

**Independent Test**: Quickstart Step 3 — standing consent stated, confirmation prohibited, all four
exclusions named.

- [X] T007 [US2] Write the standing merge authorization into section 8 of `instructions.md`: when every gate is clear the loop completes the merge without requesting confirmation, and requesting it anyway is prohibited because asking each time converts the automation into a prompt. State that this removes the confirmation, NOT the automerge mechanism step 4 already prescribes (FR-005)
- [X] T008 [US2] Add the consent boundary to section 8 of `instructions.md`, naming all four exclusions explicitly — weakening branch protection, force pushing, deleting an unmerged branch, and merging over an open blocking finding — each remaining individually gated regardless of the standing grant (FR-006)

**Checkpoint**: US2 delivers the grant and, critically, its limits.

---

## Phase 4: User Story 3 — A clean review does not spend a round on an empty fix (Priority: P2)

**Goal**: A finding-free review skips the shepherd.

**Independent Test**: Quickstart Step 4 — the rule is stated with its rationale.

- [X] T009 [US3] Amend loop step 4 in section 8 of `instructions.md` so a review closing with no findings skips the shepherd entirely, stating why: a no-op invocation wastes a round AND produces a diff the re-review step must then examine (FR-007)

**Checkpoint**: US3 removes a wasted round from the loop.

---

## Phase 5: Version, Region & Frontmatter Integrity (Principles VII, IX)

- [X] T010 Bump the `instructions.md` H1 title to `v0.1.0` per the bump declared in `specs/002-review-loop-check-gate/plan.md` (FR-009)
- [X] T011 Update the `AI-JEDI:INSTRUCTIONS:START` marker in `instructions.md` to carry `v0.1.0`, matching the title (Principle IX)
- [X] T012 Re-evaluate the `instructions.md` frontmatter: change the version string in `Summary:` from `v0.0.1` to `v0.1.0`, extend the description to cover the directives now carried, and add tags for the check-gate and merge-authorization areas (Authoring Constraints, FR-009)

**Checkpoint**: Version, marker, and frontmatter agree.

---

## Phase 6: Polish & Parity

- [X] T013 [P] Update the review-chain section of `README.md` so it describes the check gate and the standing authorization in operator terms, with every claim backed by a directive now present in `instructions.md` (Principle XII)
- [X] T014 Audit every directive added in T003–T009 in `instructions.md` against the trigger/obligation/exception form, writing `Exception: none` explicitly where none exists (FR-008)
- [X] T015 Run Quickstart Steps 1–8 against `instructions.md` and `README.md`, recording every result in `.specify/workflows/runs/002-review-loop-check-gate.md`. Step 9 is discharged by Phase 7 (T018–T026), not here
- [X] T016 Walk the pre-change directive inventory from T002 against `instructions.md` MANUALLY, not by grep alone — the mechanized extraction under-covers — confirming zero directives lost or weakened, and record the counted total in `.specify/workflows/runs/002-review-loop-check-gate.md` (SC-006, FR-009)
- [X] T017 Cross-check section 8 of `instructions.md` against Principle VI in `.specify/memory/constitution.md`, confirming zero gaps — the role nouns `reviewer` and `shepherd` match the constitution; only the literal command forms are deliberately absent (SC-005)

---

## Phase 7: Autonomous Review-to-Merge Loop (Principle VI)

**Purpose**: Implementation is complete only when the change has MERGED. Runs automatically on pull
request creation — the operator does not ask.

**Round limit: 3** — constitutional default, not overridden.

- [X] T018 Open a pull request from `002-review-loop-check-gate` to `main`, declaring its base and that it implements all three stories together per the plan's PR-granularity exception
- [X] T019 Run the reviewer against the pull request and record the severity-ranked verdict, with its round number, in `.specify/workflows/runs/002-review-loop-check-gate.md`
- [X] T020 If findings exist, run the shepherd only after the review closes, resolving ONLY what review raised in `instructions.md`, `README.md`, or the feature artifacts — no scope expansion
- [X] T021 If the shepherd ran, re-review its own diff — those edits are content no reviewer has seen and MUST NOT merge on the strength of the prior review
- [X] T022 Repeat T020–T021 until a review closes with no findings, or until round 3, recording each round in the run log
- [X] T023 Evaluate the check gate before merging and record the observed state in `.specify/workflows/runs/002-review-loop-check-gate.md`. Expected result is the absent-workflows case — this repository has no configured checks today — but record what is actually observed rather than asserting the expectation
- [X] T024 Complete the merge into `main` without requesting confirmation, per the standing authorization — arming automerge remains the mechanism, as section 8 step 4 already states — and record the outcome in `.specify/workflows/runs/002-review-loop-check-gate.md`
- [X] T025 AFTER the merge completes, confirm the platform already removed the remote ref (`delete_branch_on_merge` is enabled, so GitHub deletes it at merge — do not report its absence as a failure), then delete the LOCAL branch `002-review-loop-check-gate` and confirm no worktree remains. Never on approval alone; never `main`
- [X] T026 Confirm branch protection on `main` is byte-identical to before the loop, and record the comparison in `.specify/workflows/runs/002-review-loop-check-gate.md`

---

## Dependencies & Execution Order

**Phase order**: 1 → 2 (US1) → 3 (US2) → 4 (US3) → 5 → 6 → 7.

**Story dependencies**: US1, US2, and US3 all write section 8, so they serialize. None depends on
another's content, so the order is by priority rather than by requirement.

**Within-phase order**: T003 before T004–T006 (they extend the subsection T003 creates). T010 before
T011 (the marker copies the title version). **T014 before T012** — the directive-form audit may still
edit `instructions.md`, and frontmatter written before it would ship describing content that changed
afterward, which the accuracy rule prohibits. T012 is therefore the last content task in execution
order even though it appears earlier by ID. T019 before T020 — running the shepherd before
the review closes is prohibited. T020 before T021 — the shepherd's diff must be re-reviewed. T024 before
T025 — the branch is deleted after the MERGE, never on approval, because the branch is what the merge
consumes.

## Parallel Opportunities

Thin by design. Genuinely parallel: T001 and T002 (different files), and T013 (edits `README.md`).
Everything in Phases 2–5 edits `instructions.md` and contends.

## Implementation Strategy

**MVP**: Phase 1 + Phase 2 (US1). The five-state check gate alone fixes the decision an agent most
needs and most easily gets wrong.

**Increment 2**: Phase 3 (US2) — the standing grant and its limits.

**Increment 3**: Phase 4 (US3) — the wasted round removed.

**Increment 4**: Phases 5–6 — version, marker, frontmatter, README parity, verification.

**Increment 5**: Phase 7 — the loop merges the change and cleans up.

**Gate**: `/speckit-analyze` MUST report convergence before T003, the first task that edits
`instructions.md` (Principle V).
