---
Summary: Dependency-ordered task list for revising instructions.md, organized by user story so each story ships as an independent increment.
Tags: [#tasks #instructions #implementation]
---

# Tasks: Instructions Quality Revision

**Input**: Design documents from `specs/001-instructions-quality-revision/`

**Prerequisites**: [[plan]] (required), [[spec]] (user stories), [[research]], [[data-model]], [[contracts/instructions-file-contract]], [[quickstart]]

**Tests**: No automated test tasks. The deliverable is a Markdown instruction file with no executable surface; verification is the document-level procedure in [[quickstart]]. TDD does not apply (constitution: "Where a change is executable, TDD applies").

**Organization**: Grouped by user story. Every story is independently verifiable against its own quickstart step.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1–US5 per [[spec]]
- Exact file paths in every description

## Path Conventions

Instruction control plane, no source tree. Single deliverable: `instructions.md` at repository root.
Feature artifacts under `specs/001-instructions-quality-revision/`. Run log under
`.specify/workflows/runs/`.

**Serialization warning**: nearly every implementation task edits the same file,
`instructions.md`. Tasks touching it are NOT parallelizable even when logically independent. `[P]`
appears only on tasks writing to different files.

---

## Phase 1: Setup

**Purpose**: Freeze the pre-revision state so losslessness is verifiable.

- [ ] T001 Copy the pre-revision file to `specs/001-instructions-quality-revision/instructions.pre-revision.md` as the register-walk reference
- [ ] T002 [P] Verify the 41-entry register in `specs/001-instructions-quality-revision/data-model.md` against `specs/001-instructions-quality-revision/instructions.pre-revision.md`, correcting any entry that misquotes the original
- [ ] T003 [P] Create `.specify/workflows/runs/001-instructions-quality-revision.md` with frontmatter to hold orchestration and review-chain state

**Checkpoint**: Pre-revision state captured; register verified as an accurate inventory.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the section skeleton and precedence rules every later directive is placed
into. Blocks all user stories — a directive cannot be assigned a precedence level before the
ladder exists.

- [ ] T004 Rewrite the frontmatter of `instructions.md` with a one-sentence `Summary:` and `Tags:` covering the revised scope
- [ ] T005 Create section headings 2–14 in `instructions.md` in the urgency-first order defined in `specs/001-instructions-quality-revision/plan.md` (Target Section Order), leaving each body empty for now — these empties are transient scaffolding and must not survive the change set
- [ ] T006 Write section 3 "Precedence Ladder" in `instructions.md`: safety > clarity > lifecycle > density, stating that verbatim reproduction of code, error strings, API names, and CLI commands sits at clarity level (D43, D44)
- [ ] T007 Write section 2 "First-Read Bootstrap" in `instructions.md`: on load, apply the ladder, then compression, then lifecycle routing; include the meta-objectives and the language-duality rule (D01–D04, D42, D53)
- [ ] T008 Add the no-secrets / no-operator-data / no-machine-local-paths rule to section 3 of `instructions.md` (D54)

**Checkpoint**: Skeleton and precedence exist. Invariants I1, I2, I3 from `specs/001-instructions-quality-revision/contracts/instructions-file-contract.md` are satisfiable.

---

## Phase 3: User Story 1 — Any AI tool applies the rules correctly on first read (Priority: P1) 🎯 MVP

**Goal**: Every behavioral rule is phrased trigger → obligation → exception so a fresh session
applies it without the operator restating anything.

**Independent Test**: Quickstart Step 6 behavioral probes — compression, auto-clarity switch,
lifecycle routing, frontmatter — pass in a fresh session of each installed tool.

- [ ] T009 [US1] Write section 4 "Auto-Clarity Exceptions" in `instructions.md`: security warnings, irreversible-action confirmations, ambiguity-risking ordered sequences, and the resume rule (D09a–D09d), each with explicit trigger and termination
- [ ] T010 [US1] Write section 5 "Output Compression Protocol" in `instructions.md`: persistence across turns, grammar drops, tokenizer guardrails, formatting limits, and the no-intros/no-outros/no-style-labels rule (D05–D08, D25)
- [ ] T011 [US1] Write section 6 "Intensity Levels" in `instructions.md`: `lite`, `full` (default), `ultra`, each with what changes and the rule that a level persists until changed (D10–D12)
- [ ] T012 [US1] Write section 7 "Engineering Lifecycle" in `instructions.md`: brainstorm-with-design-doc, bite-sized plans with paths and verification, incremental targeted execution, TDD RED-GREEN-REFACTOR, severity-ranked review with CRITICAL freezing the branch (D13–D17)
- [ ] T013 [US1] Write section 9 "File Architecture" in `instructions.md`: mandatory frontmatter, atomic focused files with the size ceiling, `[[Wiki Links]]` for dependencies, `/inbox` triage for unformatted input (D18–D21)
- [ ] T014 [US1] Write section 10 "Path-Scoped Rules" in `instructions.md`: frontend, backend/data, and config/infra globs with their obligations, preserving each glob pattern verbatim (D22–D24)
- [ ] T015 [US1] Write section 11 "Orchestration" in `instructions.md`: activation triggers, technical-director delegation protocol, and the four guardrails — parallelization, the analyze-must-report-converged gate, isolated sub-agent context, run-log persistence (D26, D27, D38–D41)
- [ ] T016 [US1] Write the skill catalog into section 11 of `instructions.md` using the closed tier vocabulary from Principle X (`deep-reasoning` / `balanced-coding` / `fast-lightweight`) plus effort and color ID for all ten lifecycle skills, deferring concrete identifiers to section 12 (D28–D37)
- [ ] T017 [US1] Audit every directive written in T009–T016 in `instructions.md` against the trigger/obligation/exception form, filling `Exception: none` where no exception exists (FR-002, invariant I4)
- [ ] T018 [US1] Run Quickstart Step 6 probes against one installed tool and record outcomes in `.specify/workflows/runs/001-instructions-quality-revision.md`

**Checkpoint**: US1 delivers a usable instruction file on its own — sections 2–7 and 9–11 complete.

---

## Phase 4: User Story 2 — No existing directive is lost or weakened (Priority: P1)

**Goal**: All 41 pre-revision directives are present with equal or stricter force.

**Independent Test**: Quickstart Step 1 register walk returns 41 of 41 located.

- [ ] T019 [US2] Walk `D01`–`D41` from `specs/001-instructions-quality-revision/data-model.md` against `instructions.md`, recording the located line number for each in the run log
- [ ] T020 [US2] Restore into `instructions.md` any register entry the walk could not locate, placing it in the destination section named in the register
- [ ] T021 [US2] For each directive that was merged with another, confirm the merged text carries both original obligations, and split it back apart in `instructions.md` if either was weakened
- [ ] T022 [US2] Diff `instructions.md` against `specs/001-instructions-quality-revision/instructions.pre-revision.md` for verbatim-sensitive strings — glob patterns and `.specify/workflows/runs/` — confirming each survived byte-identically. EXPLICITLY EXEMPT: slash-command names, which must migrate rather than be frozen (resolves `/speckit-analyze` finding F2)
- [ ] T023 [US2] Record the final register-walk result (must be 41/41) in `.specify/workflows/runs/001-instructions-quality-revision.md`

**Checkpoint**: SC-001 met at 100%. No content lost.

---

## Phase 5: User Story 3 — Stale and conflicting content is corrected (Priority: P2)

**Goal**: No retired vendor identifiers; every constitutional principle with runtime behavior is
represented; the file obeys the rules it imposes.

**Independent Test**: Quickstart Steps 2, 3, and 4 pass — zero `claude-3*` matches, compliant
self-structure, review-chain rules present.

- [ ] T024 [US3] Write section 12 "Tool-Scoped Values" in `instructions.md` mapping the tier-neutral roles from T016 to current identifiers — `claude-opus-5`, `claude-sonnet-5`, `claude-haiku-4-5-20251001` — with the mandatory re-verify-before-use rule (D48, FR-004)
- [ ] T025 [US3] Remove every remaining `claude-3-*` identifier from `instructions.md` and confirm no vendor-specific literal appears outside section 12 (invariant I5, SC-002)
- [ ] T026 [US3] Write section 8 "Post-Implementation Review Chain" in `instructions.md`: reviewer runs first and produces a severity-ranked verdict, shepherd runs only after review closes, running the shepherd early is prohibited (D45)
- [ ] T027 [US3] Add to section 8 of `instructions.md` the CRITICAL-freezes-branch rule and the prohibition on arming automerge while CRITICAL findings are open (D46)
- [ ] T028 [US3] Add to section 8 of `instructions.md` the consent rule: silence is consent to run the chain; skipping requires an explicit per-change opt-out (D47)
- [ ] T029 [US3] Write section 13 "Degradation Paths" in `instructions.md` covering absent sub-agents, absent slash commands, absent git remote, and absent run-log directory, using the table from `specs/001-instructions-quality-revision/research.md` R3 (D49–D52, FR-006)
- [ ] T030 [US3] Cross-check `instructions.md` against Principles I–VI in `.specify/memory/constitution.md`, confirming each principle imposing runtime behavior is carried by at least one directive (SC-003)
- [ ] T031 [US3] Verify `instructions.md` self-compliance: compliant frontmatter, at least one `[[Wiki Link]]`, under the 800-line ceiling, no machine-local absolute paths, no credential-shaped strings (FR-007, FR-012, invariants I8, I9)
- [ ] T032 [US3] Confirm each of the four rule-collision pairs in Quickstart Step 5 resolves by the ladder alone, and extend section 3 of `instructions.md` if any requires a judgment call (SC-007)
- [ ] T032a [US3] Migrate every slash-command reference in `instructions.md` off the retired dot form (`/speckit.plan`), replacing shared-content references with phase names and placing the concrete form in section 12, derived from `integration_settings.<integration>.invoke_separator` in `.specify/integration.json` (D61, resolves findings F1 and F2)
- [ ] T032b [US3] Reconcile the section 11 catalog in `instructions.md` against `.specify/integrations/claude.manifest.json`: remove `baseline` (catalogued, installed in no manifest) and add `taskstoissues` (installed, uncatalogued) (D62, SC-009)

**Checkpoint**: File is current, governance-complete, and self-compliant.

---

## Phase 5B: User Story 5 — The instruction set can update itself in installed tools (Priority: P2)

**Goal**: Versioned title, delimited managed region, provisioning guidance, and global-only
targeting, so an agent can refresh the instructions in any installed tool safely.

**Independent Test**: Quickstart Step 6B — refresh trial replaces only the marked span, advances
the version, and writes to a global path.

- [ ] T032c [US5] Rewrite the `instructions.md` H1 title to carry `v0.0.1` per the bump declared in `specs/001-instructions-quality-revision/plan.md`, retiring the `V4` marker, and mirror the version in the frontmatter `Summary:` without contradiction (D55, FR-013)
- [ ] T032d [US5] Wrap the instruction content in `instructions.md` with `<!-- AI-JEDI:INSTRUCTIONS:START v0.0.1 -->` and `<!-- AI-JEDI:INSTRUCTIONS:END -->` (D56, FR-016)
- [ ] T032e [US5] Write the update protocol into section 2 of `instructions.md`: resolve the global path, refuse if it falls inside a project working tree, compare marker version, replace only the marked span, verify outside-region byte-identity (D57, D58, FR-016, FR-017)
- [ ] T032f [US5] Write section 13 "Agent Provisioning" in `instructions.md`: detection via the integration manifests, installation with the SpecKit version pinned to `.specify/integration.json`, verification against the manifest SHA256 with drift reported (D59, D60, FR-014)
- [ ] T032g [US5] Add the unavailable-skill degradation row to section 14 of `instructions.md`: the phase's obligations are followed manually, never dropped (D63, FR-006)
- [ ] T032h [US5] Confirm no project-local file in this repository carries an `AI-JEDI:INSTRUCTIONS` region, and that `CLAUDE.md` retains only its `SPECKIT` pointer region (FR-017, Principle IX)
- [ ] T032i [US5] Replace the Model Selection column in the section 11 catalog of `instructions.md` with the closed tier vocabulary — `deep-reasoning`, `balanced-coding`, `fast-lightweight` — mapping the ten existing rows from their current values (D64, FR-018)
- [ ] T032j [US5] Write the tier-to-concrete-model mapping into section 12 of `instructions.md`, one mapping per integration, plus the collapse-upward rule for harnesses offering fewer tiers (D65, D66, FR-018)
- [ ] T032k [US5] Write the agent-materialization guidance into section 13 of `instructions.md`: per-harness definition location and format, required fields, idempotent creation, collision reporting, and the no-agent-without-manifest rule (D67–D71, FR-019)
- [ ] T032l [US5] Add the no-sub-agent-concept degradation row to section 14 of `instructions.md`: phase obligations followed in the main session, in order, with the absence reported (D72, FR-019)
- [ ] T032m [US5] Expand the Parallelization guardrail in section 11 of `instructions.md`: parallel by default, one worktree and branch per unit, no two agents in one working copy, serial requires a stated dependency or contention reason, and isolation does not create parallelism on a shared artifact (D73–D75, FR-020)
- [ ] T032n [US5] Add merge-order, worktree-cleanup, and run-log-fields rules to section 11 of `instructions.md`: dependency order over completion order, worktree removed after merge or when unchanged, run log records unit/worktree/branch/status (D76–D78, FR-020)
- [ ] T032o [US5] Write pull request organization into section 8 of `instructions.md`: one PR per independently testable story declaring base and dependency position, review chain per PR rather than per batch, no PR from a branch with no common ancestor, stacked work declares its parent (D79–D82, FR-021)
- [ ] T032p [US5] Add the parallel-execution degradation rows to section 14 of `instructions.md`: no repository, no remote, and no parallel dispatch, each with its stated fallback and reporting obligation (D83, FR-020, FR-021)

**Checkpoint**: US5 delivers a self-describing, self-updating instruction surface that can
materialize its own agent set.

---

## Phase 6: User Story 4 — The file is navigable and self-locating for machines (Priority: P3)

**Goal**: A tool with limited context finds the governing rule without reading unrelated sections.

**Independent Test**: For 5 sampled situations, a tool asked "which rule applies" names the correct
section on the first attempt (SC-005).

- [ ] T033 [US4] Verify section order in `instructions.md` matches the Target Section Order in `specs/001-instructions-quality-revision/plan.md` exactly across sections 2–14, and that no section retains the empty body scaffolded by T005 (Section entity rule in `specs/001-instructions-quality-revision/data-model.md`)
- [ ] T034 [US4] Normalize headings in `instructions.md` so each is stable, unique, and citable, since `specs/001-instructions-quality-revision/contracts/instructions-file-contract.md` permits consumers to cite them
- [ ] T035 [US4] Run the locatability probe against `instructions.md` for 5 sampled situations — destructive command, new Markdown file, multi-step feature, model selection, missing git remote — recording which section each tool names in `.specify/workflows/runs/001-instructions-quality-revision.md`
- [ ] T036 [US4] Fix any section in `instructions.md` whose scope was ambiguous in the T035 probe by tightening its heading or opening trigger sentence

**Checkpoint**: SC-005 met.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [ ] T037 Remove from `instructions.md` any content added during the revision that restates an existing rule without removing ambiguity (FR-011)
- [ ] T038 Run the full Quickstart Steps 1–5 sweep against `instructions.md` and record every result in `.specify/workflows/runs/001-instructions-quality-revision.md`
- [ ] T039 Run Quickstart Step 6 probes across all installed tools against `instructions.md`, requiring at least 3 of 3 to pass, and record outcomes in `.specify/workflows/runs/001-instructions-quality-revision.md` (SC-004)
- [ ] T040 [P] Delete `specs/001-instructions-quality-revision/instructions.pre-revision.md` once the register walk has passed, so no stale fork of the source survives (Principle I)
- [ ] T041 Confirm `CLAUDE.md` managed SPECKIT region still points at `specs/001-instructions-quality-revision/plan.md` and contains no hand-edited instruction content (Principle I)
- [ ] T041a Record in `.specify/workflows/runs/001-instructions-quality-revision.md` that zero adapters exist today, so the constitutional "regenerate all adapter outputs" gate has no targets in this change set (resolves finding F3)
- [ ] T041b Cross-walk every directive in `instructions.md` that assumes a harness capability against section 14, confirming each names a fallback — invariant I6 requires total coverage, not four fixed rows (resolves finding F5)
- [ ] T041c Verify `instructions.md` is loadable as a single artifact with no includes, no companion file, and no tool-specific preprocessing (FR-009, resolves finding F7)

---

## Phase 8: Mandatory Post-Implementation Review (Principle VI)

**Purpose**: Implementation is complete only when review has closed. This phase MUST run
automatically at the end of the implementation unit — the operator does not have to ask.

- [ ] T042 Run `/pr-reviewer` against the local diff of `instructions.md` (no git remote exists, so the local-diff degradation applies) and record the severity-ranked verdict in `.specify/workflows/runs/001-instructions-quality-revision.md`
- [ ] T043 Resolve every CRITICAL finding from T042 in `instructions.md` before proceeding; CRITICAL findings freeze the change
- [ ] T044 Run `/pr-shepherd` only after the T042 review has closed; with no remote, record the shepherd step as deferred and pending in `.specify/workflows/runs/001-instructions-quality-revision.md`

---

## Dependencies & Execution Order

**Phase order**: Phase 1 → Phase 2 (blocking) → Phase 3 (US1) → Phase 4 (US2) → Phase 5 (US3) → Phase 5B (US5) → Phase 6 (US4) → Phase 7 → Phase 8.

**Story dependencies**:

- US1 depends on Phase 2 only. It is the MVP and ships alone.
- US2 verifies the file US1 produced — it cannot start before US1's sections exist. Its own tasks are independent of US3, US4, and US5.
- US3 depends on US1 (section 11 must exist before section 12 can map its roles) but not on US2.
- US5 depends on US3: the version bump it writes must reflect the final directive set, and section 13 provisioning references the catalog US3 reconciled.
- US4 depends on all sections existing, so it runs last of the five.

**Within-phase order**: T006 before T007 (bootstrap references the ladder). T016 before T024 (section 12 maps roles the catalog defines). T019 before T020 and T021. T032a and T032b before T032c — the version must be bumped only once the catalog is final. T042 before T044 — running the shepherd before the review closes is prohibited.

## Parallel Opportunities

The single-file deliverable serializes most work. Genuinely parallel:

- T002 and T003 (different files, after T001)
- T040 (deletes a different file) alongside T041
- Nothing inside Phase 2 through Phase 6 — every task there edits `instructions.md`

Probe tasks (T018, T035, T039) parallelize across tools, not across files: run one probe per tool
concurrently, then merge outcomes into the run log.

## Implementation Strategy

**MVP**: Phase 1 + Phase 2 + Phase 3 (US1). That alone yields a restructured, unambiguous
instruction file that any tool applies correctly on first read.

**Increment 2**: Phase 4 (US2) — proves nothing was lost. Required before the change can be
considered safe to keep.

**Increment 3**: Phase 5 (US3) — corrects stale identifiers and closes governance gaps.

**Increment 4**: Phase 5B (US5) — versioned title, managed region, provisioning, global targeting.

**Increment 5**: Phase 6 (US4) + Phase 7 — navigability and cleanup.

**Gate**: `/speckit-analyze` MUST report convergence before T004, the first task that edits
`instructions.md` (Principle V).
