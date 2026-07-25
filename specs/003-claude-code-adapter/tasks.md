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

- [X] T001 [P] Create `.specify/workflows/runs/003-claude-code-adapter.md` with frontmatter to hold orchestration and review-chain state
- [X] T002 [P] Copy the operator's current `~/.claude/CLAUDE.md` to `specs/003-claude-code-adapter/.baseline-claude-md.txt` as the byte-identity reference for T028 — NOT under the system temp directory, which a reboot or cleaner can empty between T002 and T028, silently removing the only baseline — and record its line count and the fork span in the run log. Add that filename to `.gitignore`: it is a copy of the operator's personal configuration and MUST NOT be committed to a public repository
- [X] T003 Create `.specify/adapters/claude-code/tests/run-tests.sh` as an executable harness that dispatches named case groups (`refusals`, `create`, `idempotent`, `preserve`, `fork`, `drift`, `backup`, `size`, `foreign`, `selfverify`) and exits non-zero on any failure

**Checkpoint**: Harness exists and fails — no cases implemented yet.

---

## Phase 2: Foundational — the declaration (Blocking)

**Purpose**: The script cannot resolve a target without a declaration. Blocks every story.

- [X] T004 Write `.specify/adapters/claude-code/adapter.yml` declaring `target_tool`, `path_pattern` (home-relative, NEVER an absolute path — a committed absolute path leaks the operator's username into a public repository), `format`, `size_limit`, plus the four fields the authoring constraints require of every adapter: skill install/verify procedure, invocation separator, agent-definition location and format, and the capability-tier to concrete-model mapping (FR-001, FR-001a)
- [X] T005 Create `.specify/adapters/claude-code/project.sh` as an executable stub that reads `adapter.yml`, expands `path_pattern` against the home directory at runtime, and exits with a not-implemented status

**Checkpoint**: Declaration complete; script resolves a target and does nothing else.

---

## Phase 3: User Story 3 — The adapter refuses to write where it must not (Priority: P1) 🎯 MVP

**Goal**: Every hostile input is refused before any write.

**Why first despite being US3**: refusals are the only behavior that protects the operator's file. Writing
correctly matters less than never writing wrongly, so this ships first.

**Independent Test**: Quickstart Step 2 — 7 of 7 hostile cases refuse and write nothing.

- [X] T006 [US3] Write failing test cases in `.specify/adapters/claude-code/tests/run-tests.sh` for the `refusals` group: target path inside a git working tree, single start marker, markers in reverse order, unreadable target, a fork span bounded by TWO title-shaped headings (unboundable — must refuse), a fork migration attempted without operator confirmation, and a matching heading followed by operator content instead of end-of-file (span cannot be bounded — must refuse). Each asserts BOTH a non-zero exit AND that the fixture is byte-unchanged. Run and watch all seven fail
- [X] T007 [US3] Implement working-tree refusal in `.specify/adapters/claude-code/project.sh`: if the resolved target sits inside a git working tree, report and exit non-zero without writing (FR-002)
- [X] T008 [US3] Implement marker validation in `.specify/adapters/claude-code/project.sh`: exact full-line match on both markers, reporting corruption and writing nothing when one is missing or they are out of order (FR-007, FR-014)
- [X] T009 [US3] Implement unreadable-target handling in `.specify/adapters/claude-code/project.sh`: report and write nothing rather than overwriting a file that could not be read (FR-007)
- [X] T010 [US3] Run `.specify/adapters/claude-code/tests/run-tests.sh refusals` and confirm 7 of 7 now pass with every fixture byte-unchanged (SC-005)

**Checkpoint**: The adapter cannot damage a file. Safe to teach it to write.

---

## Phase 4: User Story 1 — The instruction set reaches an installed tool (Priority: P1)

**Goal**: Content lands in the target, marked and versioned, idempotently.

**Independent Test**: Quickstart Steps 3 and 6.

- [X] T011 [US1] Write failing test cases in `.specify/adapters/claude-code/tests/run-tests.sh` for the `create`, `idempotent`, and `drift` groups: absent target is created with exactly one region; a second run is byte-identical with still exactly one region; drift reports current / stale-naming-both-versions / not-installed as three distinct outcomes. Run and watch them fail
- [X] T012 [US1] Implement content extraction in `.specify/adapters/claude-code/project.sh`: read the span BETWEEN `instructions.md`'s own markers, not the markers themselves, and read the version from its start marker (FR-004)
- [X] T013 [US1] Implement creation in `.specify/adapters/claude-code/project.sh`: when the target is absent, create it at the resolved location containing only the marker pair and the content — never falling back to a project-local path (FR-003)
- [X] T014 [US1] Implement the version comparison in `.specify/adapters/claude-code/project.sh`: matching versions report the projection current and write nothing. Expose the drift check as an explicit read-only invocation — `project.sh --check` — reporting current, stale (naming both versions), or not-installed from version strings alone, and never writing (FR-009, FR-010)
- [X] T015 [US1] Run `.specify/adapters/claude-code/tests/run-tests.sh create idempotent drift` and confirm all pass (SC-004, SC-006). Note: FR-008 (idempotency) has no implementation task of its own — it emerges from T012–T014 and T020, and is verified here rather than built directly

**Checkpoint**: The adapter writes correctly into an empty or current target.

---

## Phase 5: User Story 2 — Operator-authored content survives untouched (Priority: P1)

**Goal**: Byte-identity outside the region, including when replacing an unmarked fork.

**Independent Test**: Quickstart Steps 4 and 5.

**TDD note**: all four failing-test tasks (T016–T019) come first, then every implementation task. An
earlier draft interleaved them and shipped three implementations ahead of their tests — the inversion the
constitution forbids and this file calls mandatory.

### Failing tests first

- [X] T016 [US2] Write failing cases in `.specify/adapters/claude-code/tests/run-tests.sh` for the `preserve` group: operator content above the region, below it, and both. Each asserts byte-identity outside the replaced span, **repeated three times per fixture** so SC-002's "3 of 3 runs" is actually measured. Run and watch them fail
- [X] T017 [US2] Write failing cases in `.specify/adapters/claude-code/tests/run-tests.sh` for the `fork` group, mirroring the operator's real file — import line, personal section, then unmarked instruction content. Assert byte-identity outside the span, that the span and matched signal are REPORTED, and that migration without confirmation refuses. Add a case that runs the adapter TWICE against a fresh target and asserts the second run detects NO fork — the projected content's own title matches the fork pattern, so a scan including region interiors would migrate its own output. Run and watch them fail
- [X] T018 [US2] Write failing cases in `.specify/adapters/claude-code/tests/run-tests.sh` for the `backup` and `size` groups: a backup exists on disk after any run that wrote; a simulated mid-write failure leaves the target byte-unchanged; content exceeding the declared limit is REFUSED, never truncated and never summarized. Run and watch them fail
- [X] T019 [US2] Write failing cases in `.specify/adapters/claude-code/tests/run-tests.sh` for the `foreign` and `selfverify` groups: a foreign `SPECKIT START`/`END` region is left untouched and never mistaken for this one; the next-session disclosure string is present in the output; post-write self-verification catches a deliberately corrupted write and rolls back from the backup. Run and watch them fail

### Implementation

- [X] T020 [US2] Implement span replacement in `.specify/adapters/claude-code/project.sh`: replace only the text between markers, rewriting the start marker's version, leaving every other byte identical (FR-005)
- [X] T021 [US2] Implement the backup and write atomicity in `.specify/adapters/claude-code/project.sh`: copy the target beside itself before writing using the filename pattern declared in `adapter.yml` — a suffix the tool does NOT load as configuration, since a backup read as instructions would inject a stale copy of the whole instruction set into every session — and leave the target unmodified if the write cannot complete (FR-011)
- [X] T022 [US2] Implement confirmation-gated fork migration in `.specify/adapters/claude-code/project.sh` as ONE task, never as a bare replacement that a later task gates: scan ONLY content outside every managed region — its own and any foreign one, because the projected content carries a heading matching the same pattern and including region interiors would make the second run detect its own output as a fork — then bound the span by **exactly one** matching heading extending to end-of-file: zero matches means no fork, two or more means refuse, and a match not reaching end-of-file means refuse — report the span and the matched signal, and require explicit operator confirmation for that specific span before writing. Absent report, confirmation, or backup, refuse (FR-006, FR-016, Principle IX one-time migration)
- [X] T023 [US2] Implement size-limit handling in `.specify/adapters/claude-code/project.sh`: compare the RESULTING FILE TOTAL — projected content plus the operator content already present — against the declared limit and REFUSE when it exceeds, matching the quantity the limit is sourced from — this adapter does not summarize, because a summarized region would break the verbatim projection FR-004/FR-005 require and would carry a source version it does not actually contain (FR-001b)
- [X] T024 [US2] Implement foreign-region safety in `.specify/adapters/claude-code/project.sh`: a managed region owned by other tooling is left untouched and never mistaken for this one (FR-013)
- [X] T025 [US2] Add the next-session disclosure to `.specify/adapters/claude-code/project.sh` output: the projection takes effect from the tool's next session, not the one that ran the script (FR-012)
- [X] T026 [US2] Implement post-write self-verification and rollback in `.specify/adapters/claude-code/project.sh`: markers present and ordered, version matching, outside-region byte-identity, path still user-level — restoring from the backup when any check fails (FR-015)
- [X] T027 [US2] Run `.specify/adapters/claude-code/tests/run-tests.sh preserve fork backup size foreign selfverify` and confirm all pass with zero unintended bytes changed (SC-002, SC-003, SC-007)

**Checkpoint**: All fixture groups green. Safe to run against the real configuration.

---

## Phase 6: Real Projection

- [X] T028 Run `sh .specify/adapters/claude-code/project.sh` against the operator's real `~/.claude/CLAUDE.md`, then verify per Quickstart Step 7: region present with the source version, pre-revision fork gone, `@RTK.md` import and `# graphify` section both intact, backup on disk. Diff against `specs/003-claude-code-adapter/.baseline-claude-md.txt` from T002 to confirm byte-identity outside the replaced span (SC-001, FR-011)
- [X] T029 Record the T028 outcome in `.specify/workflows/runs/003-claude-code-adapter.md`, including the exact span replaced and the backup filename

---

## Phase 7: Polish & Parity

- [X] T030 [P] Correct `README.md`: the claim "No adapter has been written for any tool yet" becomes false on merge and MUST be replaced with what actually exists — one adapter for Claude Code — with the other three tools still stated as unexercised (Principle XII)
- [X] T031 [P] Update the `README.md` tools table so the Claude Code row reflects a working projection rather than only an installed integration
- [X] T031a Re-evaluate the `README.md` frontmatter after T030 and T031: `Summary:` and `Tags:` must describe the file as it now stands, or the reviewed no-change decision must be recorded in `.specify/workflows/runs/003-claude-code-adapter.md` (Authoring Constraints)
- [X] T032 Run Quickstart Steps 1, 2, 3, 4, 5, 5b, 6, 6b and 7 end to end and record every result in `.specify/workflows/runs/003-claude-code-adapter.md`. Step 8 is the deferred behavioral probe (T043); Step 9 is discharged by Phase 8
- [X] T033 Confirm no committed file under `.specify/adapters/` OR `specs/003-claude-code-adapter/` contains an absolute home path, a username, or any credential-shaped string, and that the T002 baseline copy is gitignored rather than committed (Principle IX authoring constraints)

---

## Phase 8: Autonomous Review-to-Merge Loop (Principle VI)

**Round limit: 3** — constitutional default, not overridden.

- [ ] T034 Open a pull request from `003-claude-code-adapter` to `main` covering `.specify/adapters/claude-code/`, `README.md`, and the feature artifacts, declaring its base and that it ships all four stories together per the plan's PR-granularity exception
- [ ] T035 Run the reviewer against the pull request and record the severity-ranked verdict, with its round number, in `.specify/workflows/runs/003-claude-code-adapter.md`
- [ ] T036 If findings exist, run the shepherd only after the review closes, resolving ONLY what review raised in `.specify/adapters/claude-code/` or `README.md` — no scope expansion. If the review closed with no findings, SKIP the shepherd entirely
- [ ] T037 If the shepherd ran, re-review its own diff and record the round in `.specify/workflows/runs/003-claude-code-adapter.md` — those edits are code no reviewer has seen and MUST NOT merge on the strength of the prior review
- [ ] T038 Repeat T036–T037 until a review closes with no findings, or until round 3, recording each round in `.specify/workflows/runs/003-claude-code-adapter.md`
- [ ] T039 Evaluate the check gate and record the OBSERVED state in `.specify/workflows/runs/003-claude-code-adapter.md`; the expected result is the absent-checks case, but record what is actually observed
- [ ] T040 Complete the merge into `main` without requesting confirmation, per the standing authorization — arming automerge remains the mechanism — and record the outcome in `.specify/workflows/runs/003-claude-code-adapter.md`
- [ ] T041 AFTER the merge completes, confirm the platform removed the remote ref, delete the LOCAL branch `003-claude-code-adapter`, confirm no worktree remains, and record it in `.specify/workflows/runs/003-claude-code-adapter.md`
- [ ] T042 Confirm branch protection on `main` is byte-identical to before the loop, recording the comparison in `.specify/workflows/runs/003-claude-code-adapter.md`

---

## Behavioral Confirmation (deferred — requires a fresh session)

- [ ] T043 DEFERRED: start a fresh Claude Code session loading `~/.claude/CLAUDE.md` and confirm it applies a rule present ONLY in `v0.1.0` — the check gate (four states plus the absent-workflows case) or the standing merge authorization, neither of which exists in the pre-revision fork. This cannot be self-administered inside the session that ran the projection; the run log records it as pending (Quickstart Step 8, SC-001)

---

## Dependencies & Execution Order

**Phase order**: 1 → 2 (blocking) → 3 (US3) → 4 (US1) → 5 (US2) → 6 → 7 → 8.

**Story order is deliberately not priority order.** US3 (refusals) ships before US1 (writing), because
refusals are what protect the operator's file. An adapter that writes correctly but does not refuse is
more dangerous than one that refuses everything.

**TDD ordering is mandatory, not stylistic**: T006 before T007–T009. T011 before T012–T014. **T016–T019
before T020–T026** — all four failing-test tasks precede every Phase 5 implementation task. Each test task
must be run and observed FAILING before its implementation tasks begin. Code written ahead of its test must
be deleted.

An earlier draft of this file interleaved Phase 5 so three implementations (backup, foreign region,
disclosure) preceded their tests. `/speckit-analyze` caught it as CRITICAL. The current ordering is the
correction; do not re-interleave when adding tasks.

**T002 before T028** — the byte-identity reference must exist before the only task that writes the real
file. **T010, T015, and T027 all green before T028** — the real configuration is never the first target.

**Within Phase 8**: T035 before T036 (shepherd never before the review closes). T036 before T037 (the
shepherd's diff must be re-reviewed). T040 before T041 (the branch is deleted after the MERGE, never on
approval).

## Parallel Opportunities

Genuinely parallel: T001 and T002 (different files). T030 and T031 (both `README.md`, but non-overlapping
sections — serialize if they conflict).

Everything in Phases 2–5 writes `project.sh` or `run-tests.sh` and contends. Per Principle XI, a worktree
would not help.

**FR ID note**: functional-requirement IDs in [[spec]] are in insertion order, not numeric order — FR-001a,
FR-001b, FR-015 and FR-016 were added by the analyze passes. Renumbering them is deferred rather than done
mid-feature: the churn across four files would risk breaking the traceability it aims to improve.

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
