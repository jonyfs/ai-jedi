---
Summary: Test-first task list for the Claude Code adapter, ending with the review-to-merge loop and the real-config projection.
Tags: [#tasks #adapter #projection #tdd]
---

# Tasks: Claude Code Adapter

**Input**: Design documents from `specs/003-claude-code-adapter/`

**Prerequisites**: [[plan]] (required), [[spec]] (user stories), [[quickstart]]

**Tests**: **REQUIRED and test-first.** The deliverable is executable, so the constitution's TDD rule
applies: write the failing test, watch it fail, write minimal code to pass. This is the first feature in
the project where TDD is in scope — features 001 and 002 shipped Markdown with no executable surface.

**Organization**: Grouped by user story. Every story has its own failing-test task before its
implementation task.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1–US4 per [[spec]]
- Exact file paths in every description

## Path Conventions

Adapters live at `.specify/adapters/<tool>/`, one self-contained directory per tool. This feature creates
`.specify/adapters/claude-code/` with `adapter.yml`, `project.sh`, and `tests/run-tests.sh`.

**Safety rule for every task below**: tests run against temporary fixtures under the system temp
directory. **No task except T017 WRITES `~/.claude/CLAUDE.md`.** T002 reads it to capture the
byte-identity reference; reading is permitted, writing is not. A test that writes the operator's real
configuration is a defect regardless of whether it passes.

---

## Phase 1: Setup

- [ ] T001 [P] Create `.specify/workflows/runs/003-claude-code-adapter.md` with frontmatter to hold orchestration and review-chain state
- [ ] T002 [P] Copy the operator's current `~/.claude/CLAUDE.md` to `/tmp/claude-md-before.txt` as the byte-identity reference for T017, and record its line count and the span of the unmarked fork in the run log
- [ ] T003 Create `.specify/adapters/claude-code/tests/run-tests.sh` as an executable harness that dispatches named case groups (`refusals`, `create`, `idempotent`, `preserve`, `fork`, `drift`, `backup`, `foreign`, `selfverify`) and exits non-zero on any failure

**Checkpoint**: Harness exists and fails — no cases implemented yet.

---

## Phase 2: Foundational — the declaration (Blocking)

**Purpose**: The script cannot resolve a target without a declaration. Blocks every story.

- [ ] T004 Write `.specify/adapters/claude-code/adapter.yml` declaring `target_tool`, `path_pattern` (home-relative, NEVER an absolute path — a committed absolute path leaks the operator's username into a public repository), `format`, `size_limit`, plus the four fields the authoring constraints require of every adapter: skill install/verify procedure, invocation separator, agent-definition location and format, and the capability-tier to concrete-model mapping (FR-001, FR-001a)
- [ ] T005 Create `.specify/adapters/claude-code/project.sh` as an executable stub that reads `adapter.yml`, expands `path_pattern` against the home directory at runtime, and exits with a not-implemented status

**Checkpoint**: Declaration complete; script resolves a target and does nothing else.

---

## Phase 3: User Story 3 — The adapter refuses to write where it must not (Priority: P1) 🎯 MVP

**Goal**: Every hostile input is refused before any write.

**Why first despite being US3**: refusals are the only behavior that protects the operator's file. Writing
correctly matters less than never writing wrongly, so this ships first.

**Independent Test**: Quickstart Step 2 — 4 of 4 hostile cases refuse and write nothing.

- [ ] T006 [US3] Write failing test cases in `.specify/adapters/claude-code/tests/run-tests.sh` for the `refusals` group: target path inside a git working tree, single start marker, markers in reverse order, unreadable target, a fork span bounded by TWO title-shaped headings (unboundable — must refuse), and a fork migration attempted without operator confirmation. Each asserts BOTH a non-zero exit AND that the fixture is byte-unchanged. Run and watch all six fail
- [ ] T007 [US3] Implement working-tree refusal in `.specify/adapters/claude-code/project.sh`: if the resolved target sits inside a git working tree, report and exit non-zero without writing (FR-002)
- [ ] T008 [US3] Implement marker validation in `.specify/adapters/claude-code/project.sh`: exact full-line match on both markers, reporting corruption and writing nothing when one is missing or they are out of order (FR-007, FR-014)
- [ ] T009 [US3] Implement unreadable-target handling in `.specify/adapters/claude-code/project.sh`: report and write nothing rather than overwriting a file that could not be read (FR-007)
- [ ] T010 [US3] Run `.specify/adapters/claude-code/tests/run-tests.sh refusals` and confirm 6 of 6 now pass with every fixture byte-unchanged (SC-005)

**Checkpoint**: The adapter cannot damage a file. Safe to teach it to write.

---

## Phase 4: User Story 1 — The instruction set reaches an installed tool (Priority: P1)

**Goal**: Content lands in the target, marked and versioned, idempotently.

**Independent Test**: Quickstart Steps 3 and 6.

- [ ] T011 [US1] Write failing test cases in `.specify/adapters/claude-code/tests/run-tests.sh` for the `create`, `idempotent`, and `drift` groups: absent target is created with exactly one region; a second run is byte-identical with still exactly one region; drift reports current / stale-naming-both-versions / not-installed as three distinct outcomes. Run and watch them fail
- [ ] T012 [US1] Implement content extraction in `.specify/adapters/claude-code/project.sh`: read the span BETWEEN `instructions.md`'s own markers, not the markers themselves, and read the version from its start marker (FR-004)
- [ ] T013 [US1] Implement creation in `.specify/adapters/claude-code/project.sh`: when the target is absent, create it at the resolved location containing only the marker pair and the content — never falling back to a project-local path (FR-003)
- [ ] T014 [US1] Implement the version comparison in `.specify/adapters/claude-code/project.sh`: matching versions report the projection current and write nothing; the drift check reports current, stale, or not-installed from version strings alone (FR-009, FR-010)
- [ ] T015 [US1] Run `.specify/adapters/claude-code/tests/run-tests.sh create idempotent drift` and confirm all pass (SC-004, SC-006). Note: FR-008 (idempotency) has no implementation task of its own — it emerges from T012–T014 and T016b, and is verified here rather than built directly

**Checkpoint**: The adapter writes correctly into an empty or current target.

---

## Phase 5: User Story 2 — Operator-authored content survives untouched (Priority: P1)

**Goal**: Byte-identity outside the region, including when replacing an unmarked fork.

**Independent Test**: Quickstart Steps 4 and 5.

- [ ] T016a [US2] Write failing test cases in `.specify/adapters/claude-code/tests/run-tests.sh` for the `preserve` and `fork` groups: operator content above the region, below it, and both; plus a fixture mirroring the operator's real file — import line, personal section, then unmarked instruction content. Each asserts byte-identity outside the replaced span. Run and watch them fail
- [ ] T016b [US2] Implement span replacement in `.specify/adapters/claude-code/project.sh`: replace only the text between markers, rewriting the start marker's version, leaving every other byte identical (FR-005)
- [ ] T016c [US2] Implement unmarked-fork detection in `.specify/adapters/claude-code/project.sh`: bound the fork span by the instruction title's heading shape through end-of-file, replace it with a marked region, and REPORT the replaced span so the operator can audit the judgment. Refuse rather than guess when the span cannot be bounded confidently (FR-006)
- [ ] T016d [US2] Implement the backup in `.specify/adapters/claude-code/project.sh`: copy the target beside itself before writing, and leave the target unmodified if the write cannot complete (FR-011)
- [ ] T016e [US2] Implement foreign-region safety in `.specify/adapters/claude-code/project.sh`: a managed region owned by other tooling is left untouched and never mistaken for this one (FR-013)
- [ ] T016f [US2] Add the next-session disclosure to `.specify/adapters/claude-code/project.sh` output: the projection takes effect from the tool's next session, not the one that ran the script (FR-012)
- [ ] T016g [US2] Run `.specify/adapters/claude-code/tests/run-tests.sh preserve fork` and confirm all pass with zero unintended bytes changed (SC-002, SC-003)

- [ ] T016h [US2] Write failing test cases in `.specify/adapters/claude-code/tests/run-tests.sh` for the `backup` group: a backup exists on disk after any run that wrote, and a simulated mid-write failure leaves the target byte-unchanged. Run and watch them fail (FR-011, SC-007)
- [ ] T016i [US2] Write failing test cases for the `foreign` and `selfverify` groups in `.specify/adapters/claude-code/tests/run-tests.sh`: a foreign `SPECKIT START`/`END` region is left untouched and never mistaken for this one; the next-session disclosure string is present in the output; post-write self-verification catches a deliberately corrupted write and rolls back. Run and watch them fail (FR-012, FR-013, FR-015)
- [ ] T016j [US2] Implement post-write self-verification and rollback in `.specify/adapters/claude-code/project.sh`: markers present and ordered, version matching, outside-region byte-identity, path still user-level — restoring from the backup when any check fails (FR-015)
- [ ] T016k [US2] Implement size-limit handling in `.specify/adapters/claude-code/project.sh`: act on the declared limit rather than recording it, never truncating arbitrarily, and state whether it summarized or refused (FR-001b)
- [ ] T016l [US2] Implement confirmation-gated fork migration in `.specify/adapters/claude-code/project.sh`: report the span and matched signal, require explicit operator confirmation for that span, refuse unless exactly one title-shaped heading extends to end-of-file (FR-016, Principle IX one-time migration)
- [ ] T016m [US2] Run `.specify/adapters/claude-code/tests/run-tests.sh backup foreign selfverify` and confirm all pass

**Checkpoint**: All fixture groups green. Safe to run against the real configuration.

---

## Phase 6: Real Projection

- [ ] T017 Run `sh .specify/adapters/claude-code/project.sh` against the operator's real `~/.claude/CLAUDE.md`, then verify per Quickstart Step 7: region present with the source version, pre-revision fork gone, `@RTK.md` import and `# graphify` section both intact, backup on disk. Diff against `/tmp/claude-md-before.txt` from T002 to confirm byte-identity outside the replaced span (SC-001, FR-011)
- [ ] T018 Record the T017 outcome in `.specify/workflows/runs/003-claude-code-adapter.md`, including the exact span replaced and the backup filename

---

## Phase 7: Polish & Parity

- [ ] T019 [P] Correct `README.md`: the claim "No adapter has been written for any tool yet" becomes false on merge and MUST be replaced with what actually exists — one adapter for Claude Code — with the other three tools still stated as unexercised (Principle XII)
- [ ] T020 [P] Update the `README.md` tools table so the Claude Code row reflects a working projection rather than only an installed integration
- [ ] T021 Run Quickstart Steps 1–7 end to end and record every result in `.specify/workflows/runs/003-claude-code-adapter.md`
- [ ] T022 Confirm no committed file under `.specify/adapters/` contains an absolute home path, a username, or any credential-shaped string (Principle IX authoring constraints)

---

## Phase 8: Autonomous Review-to-Merge Loop (Principle VI)

**Round limit: 3** — constitutional default, not overridden.

- [ ] T023 Open a pull request from `003-claude-code-adapter` to `main` covering `.specify/adapters/claude-code/`, `README.md`, and the feature artifacts, declaring its base and that it ships all four stories together per the plan's PR-granularity exception
- [ ] T024 Run the reviewer against the pull request and record the severity-ranked verdict, with its round number, in `.specify/workflows/runs/003-claude-code-adapter.md`
- [ ] T025 If findings exist, run the shepherd only after the review closes, resolving ONLY what review raised in `.specify/adapters/claude-code/` or `README.md` — no scope expansion. If the review closed with no findings, SKIP the shepherd entirely
- [ ] T026 If the shepherd ran, re-review its own diff and record the round in `.specify/workflows/runs/003-claude-code-adapter.md` — those edits are code no reviewer has seen and MUST NOT merge on the strength of the prior review
- [ ] T027 Repeat T025–T026 until a review closes with no findings, or until round 3, recording each round in `.specify/workflows/runs/003-claude-code-adapter.md`
- [ ] T028 Evaluate the check gate and record the OBSERVED state in `.specify/workflows/runs/003-claude-code-adapter.md`; the expected result is the absent-checks case, but record what is actually observed
- [ ] T029 Complete the merge into `main` without requesting confirmation, per the standing authorization — arming automerge remains the mechanism — and record the outcome in `.specify/workflows/runs/003-claude-code-adapter.md`
- [ ] T030 AFTER the merge completes, confirm the platform removed the remote ref, delete the LOCAL branch `003-claude-code-adapter`, confirm no worktree remains, and record it in `.specify/workflows/runs/003-claude-code-adapter.md`
- [ ] T031 Confirm branch protection on `main` is byte-identical to before the loop, recording the comparison in `.specify/workflows/runs/003-claude-code-adapter.md`

---

## Behavioral Confirmation (deferred — requires a fresh session)

- [ ] T032 DEFERRED: start a fresh Claude Code session loading `~/.claude/CLAUDE.md` and confirm it applies a rule present ONLY in `v0.1.0` — the five-state check gate or the standing merge authorization, neither of which exists in the pre-revision fork. This cannot be self-administered inside the session that ran the projection; the run log records it as pending (Quickstart Step 8, SC-001)

---

## Dependencies & Execution Order

**Phase order**: 1 → 2 (blocking) → 3 (US3) → 4 (US1) → 5 (US2) → 6 → 7 → 8.

**Story order is deliberately not priority order.** US3 (refusals) ships before US1 (writing), because
refusals are what protect the operator's file. An adapter that writes correctly but does not refuse is
more dangerous than one that refuses everything.

**TDD ordering is mandatory, not stylistic**: T006 before T007–T009. T011 before T012–T014. T016a before
T016b–T016f. Each test task must be run and observed FAILING before its implementation tasks begin. Code
written ahead of its test must be deleted.

**T002 before T017** — the byte-identity reference must exist before the only task that writes the real
file. **T010, T015, and T016g all green before T017** — the real configuration is never the first target.

**Within Phase 8**: T024 before T025 (shepherd never before the review closes). T025 before T026 (the
shepherd's diff must be re-reviewed). T029 before T030 (the branch is deleted after the MERGE, never on
approval).

## Parallel Opportunities

Genuinely parallel: T001 and T002 (different files). T019 and T020 (both `README.md`, but non-overlapping
sections — serialize if they conflict).

Everything in Phases 2–5 writes `project.sh` or `run-tests.sh` and contends. Per Principle XI, a worktree
would not help.

## Implementation Strategy

**MVP**: Phases 1–3. An adapter that refuses every hostile case and writes nothing else is already
valuable: it proves the safety properties before any capability exists to misuse.

**Increment 2**: Phase 4 — writes into an absent or current target.

**Increment 3**: Phase 5 — preserves operator content and replaces the unmarked fork.

**Increment 4**: Phase 6 — the real projection, once every fixture is green.

**Increment 5**: Phases 7–8 — README parity, verification, and the loop.

**Gate**: `/speckit-analyze` MUST report convergence before T003, the first task that writes a committed
deliverable file (Principle V). An earlier draft named T004; T003 creates the test harness, which is
also committed.
