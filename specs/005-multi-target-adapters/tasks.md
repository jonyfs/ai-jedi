---
Summary: Test-first task list generalizing the adapter to per-target declarations and shipping five declared targets, four of which have an existing file.
Tags: [#tasks #adapter #multi-target #tdd]
---

# Tasks: Multi-Target Adapters

**Input**: Design documents from `specs/005-multi-target-adapters/`

**Prerequisites**: [[plan]], [[spec]]

**Tests**: REQUIRED and test-first. The deliverable is executable.

**Organization**: by user story, failing tests before implementation.

## Path Conventions

`.specify/adapters/` with one `project.sh`, one `tests/`, and `targets/<tool>.yml` per tool.

**Safety rule**: no task writes any real global config. T016 is the single real-write phase — it performs
five writes, one per declaration — and runs only after every fixture group is green for every target. Four live tool configurations are at stake, not one — the fifth declared
target has no file yet, so it is created rather than overwritten.

---

## Phase 1: Setup

- [X] T001 [P] Create `.specify/workflows/runs/005-multi-target-adapters.md` with frontmatter for orchestration and review state
- [X] T002 [P] Capture the current Claude Code success-path output as the regression reference: run the existing adapter against a temp fixture and record its cksum in `.specify/workflows/runs/005-multi-target-adapters.md`
- [X] T003 [P] Back up the four target files that EXIST to the system temp directory — Codex has none to back up, recording each path and cksum in `.specify/workflows/runs/005-multi-target-adapters.md`, so T016 can be verified and reverted

---

## Phase 2: Foundational — restructure (Blocking)

- [X] T004 Move `.specify/adapters/claude-code/adapter.yml` to `.specify/adapters/targets/claude-code.yml`, and `project.sh` plus `tests/` up to `.specify/adapters/`, with `git mv` so history follows
- [X] T004a Bring `.specify/adapters/targets/claude-code.yml` up to the normative field list T012 defines — it predates the schema and lacks `missing_directory` and `speckit_integration`. FR-001 requires EVERY target's declaration to carry its policy, so leaving the original behind would end the feature with its first target non-conforming to the schema its siblings use (FR-001, C1)
- [X] T005 Change `.specify/adapters/project.sh` to take its declaration from a `--target <name>` argument resolving to `targets/<name>.yml`, defaulting to `claude-code` so existing invocations keep working (FR-002)
- [X] T006 Make `.specify/adapters/project.sh` READ the `foreign_markers` key its declaration already carries, instead of the `SPECKIT` literals hardcoded at the awk block around lines 150 and 153. The declaration is not missing — the script ignores it, which is a different defect from the one an earlier draft of this task described. The hardcoded pair cannot recognise OpenCode's `caveman-begin`/`caveman-end` syntax, and failing to recognise a foreign region means overwriting a working tool's configuration (FR-003)
- [X] T006b Add a `speckit_integration` key to the declaration schema read by `.specify/adapters/project.sh`: `claude` for the existing target, `none` for the four new ones. When it is `none`, the skill-provisioning and invocation fields resolve to Principle VIII's manual-execution degradation rather than to absent keys — there is no `integration_settings` entry or manifest for those tools, and fabricating one would invent data (FR-001, Principle VIII)
- [X] T007 Run `.specify/adapters/tests/run-tests.sh`, RECORD the observed pass count in `.specify/workflows/runs/005-multi-target-adapters.md` rather than restating a remembered figure, and confirm it has not dropped for the Claude Code target after the restructure AND after T006b's schema change — the gate must run last in this phase, not before the change it is meant to guard


**Checkpoint**: one script, declaration-driven, existing target unaffected.

---

## Phase 3: User Story 2 — Foreign regions survive (Priority: P1) 🎯 MVP

**Why before US1**: the OpenCode target is occupied end-to-end by a foreign region. Getting projection
working before foreign-region safety works would risk destroying a live configuration on first run.

- [ ] T008 [US2] Give `.specify/adapters/tests/run-tests.sh` a `--target <name>` flag so a group can be run against a chosen declaration, defaulting to every declared target. Then write failing cases for a `foreign-multi` group: a target whose entire content is a foreign region using non-`SPECKIT` syntax keeps it byte-identical and gains the instruction region alongside; fork detection excludes the foreign interior; a target with two different foreign syntaxes leaves both alone. Run and watch them fail (FR-003, SC-003)
- [ ] T009 [US2] Implement per-declaration foreign-marker recognition in `.specify/adapters/project.sh` so the region scan and the fork scan both consult the target's declared list (FR-003)
- [ ] T010 [US2] Run `.specify/adapters/tests/run-tests.sh --target opencode foreign-multi` and confirm all cases pass (SC-003)

---

## Phase 4: User Story 1 — Every capable tool is reached (Priority: P1)

- [X] T011 [US1] Write failing cases in `.specify/adapters/tests/run-tests.sh` for a `multi-target` group: every declared target projects, creates a missing file, is idempotent, and the content between markers is byte-identical across all of them. Include the three live edge conditions. An EMPTY target writes the region with no leading blank-line artefact (two real targets are 0 bytes today). A target whose DIRECTORY does not exist follows its declared `missing_directory` policy — assert the DECLARED value, not the disjunction, since "either creates or refuses" passes for any behavior. And the FILENAME COLLISION: Codex and OpenCode both use `AGENTS.md` in different directories, so project one then the other into fixtures and assert neither file's region came from the other's declaration — this is the only edge here with a live data-loss consequence. Run and watch them fail (FR-001, FR-004, FR-005, SC-001, SC-002)
- [X] T012 [US1] Write `.specify/adapters/targets/opencode.yml`. **This task defines the NORMATIVE field list every declaration must carry, and T013/T014 reference it rather than re-enumerating**: `path_pattern`, `format`, own `markers`, `foreign_markers` (here the `caveman-begin`/`caveman-end` pair), `size_limit` with `applies_to` and `over_limit`, `backup` with `pattern`/`suffix`/`retain`, `fork_patterns` and `fork_bounding`, `missing_directory` policy with its value CHOSEN and stated rather than left open,
  `agent_definition` with its location and format, `speckit_integration`, and Principle X's `tier_map` plus `tier_map_verify_before_use` and `tier_collapse`. When `speckit_integration` is `none`, the `skill_install`, `skill_verify` and `invoke_separator_source` fields are subsumed by it and MUST NOT be fabricated — constitution v1.17.0 requires the absence be declared, not papered over (FR-001)
- [X] T013 [US1] Write `.specify/adapters/targets/gemini.yml` and `.specify/adapters/targets/copilot.yml` carrying the complete normative field list defined in T012 — every field, no subset. Both targets are empty files today and neither has a foreign region, so `foreign_markers` is an empty list rather than an omitted key (FR-001)
- [X] T014 [US1] Write `.specify/adapters/targets/codex.yml` carrying the complete normative field list defined in T012. Its target file is absent — the adapter creates it, which is the documented behavior for a declared path with no file yet, and `missing_directory` records what to do if `~/.codex/` itself were gone (FR-001, D6)
- [X] T015 [US1] Run `.specify/adapters/tests/run-tests.sh` in full against EVERY target and confirm all 13 groups pass for each, not only the first (SC-005)
- [X] T015a [US1] Verify SC-004 mechanically: confirm `git diff` for T012–T014 touches ONLY files under `.specify/adapters/targets/`. If adding a declaration required editing shared logic, the generalization did not actually work and FR-002 is unmet regardless of the tests passing

**Checkpoint**: every fixture group green for every target. Only now is a real write safe.

---

## Phase 5: Real Projection

- [X] T016 Run `.specify/adapters/project.sh --target <name>` for ALL FIVE declarations in `.specify/adapters/targets/`, confirming per target: region present at the current version, foreign regions byte-identical, operator content byte-identical, backup on disk where a file existed. Codex is included explicitly — its file is absent, so this is the only real-world execution of the create-missing-file behavior (US1 AS3), which four-target wording would have skipped. Compare against the T003 snapshots (SC-001, SC-003)
- [X] T017 Verify SC-002 against the real targets named in each `.specify/adapters/targets/*.yml`: extract the region from every projected file and confirm the content between markers is byte-identical across all five, Claude Code included
- [X] T018 Record the T016 and T017 outcomes in `.specify/workflows/runs/005-multi-target-adapters.md`, including each backup filename

---

## Phase 6: Parity & Regression

- [X] T019 [P] Update `README.md` on two fronts: the tool table lists every installed tool as either projected or uncovered-with-reason — Cursor and Windsurf expose no global instruction surface and MUST say so rather than being omitted — AND every `adapters/claude-code/` path reference is corrected, since T004 moves the script and the documented run command would otherwise ship stale in the operator's face (FR-006, FR-007, Principle XII)
- [X] T019b [P] Correct the `README.md` Status block, which is factually wrong today and gets worse after this feature: it says constitution v1.16.0 (actual 1.17.0), "Ten test groups, 49 assertions" (actual 13 and 64), and "it needs adapters for the other three, which do not exist". The section is titled "Honest current state rather than an aspirational one", which makes a stale one worse than none (Principle XII)
- [X] T019a Verify SC-006 mechanically: cross-check the `README.md` tool table against the seven-tool survey in `specs/005-multi-target-adapters/plan.md` and confirm every surveyed tool appears as either projected or uncovered-with-reason — zero silent omissions. SC-002 and SC-004 each have a verification step; this one had only its authoring task
- [X] T020 [P] Re-evaluate `README.md` frontmatter after T019, or record the reviewed no-change decision in `.specify/workflows/runs/005-multi-target-adapters.md` (Authoring Constraints)
- [X] T021 Verify the Claude Code regression reference from T002: run `.specify/adapters/project.sh` against a temp fixture and confirm the success path is byte-identical to before the restructure
- [X] T022 Confirm `shellcheck -s sh` reports zero findings across `.specify/adapters/project.sh` and `.specify/adapters/tests/run-tests.sh`
- [X] T023 Confirm no committed file under `.specify/adapters/` contains an absolute home path, a username, or a credential-shaped string (Principle IX)

---

## Phase 7: Autonomous Review-to-Merge Loop (Principle VI)

**Round limit: 3.**

- [ ] T024 Open a pull request from `005-multi-target-adapters` to `main` covering `.specify/adapters/`, `README.md`, and the feature artifacts, declaring the Principle XI single-PR exception
- [ ] T025 Run the reviewer and record the verdict with its round number in `.specify/workflows/runs/005-multi-target-adapters.md`
- [ ] T026 If findings exist, run the shepherd only after the review closes, fixing ONLY what review raised in `.specify/adapters/` or `README.md`. If the review closed clean, SKIP the shepherd entirely
- [ ] T027 If the shepherd ran, re-review its own diff and record the round in `.specify/workflows/runs/005-multi-target-adapters.md`
- [ ] T028 Repeat T026–T027 until a review closes clean or round 3, recording each round in `.specify/workflows/runs/005-multi-target-adapters.md`
- [ ] T029 Evaluate the check gate and record the OBSERVED state in `.specify/workflows/runs/005-multi-target-adapters.md`
- [ ] T030 Complete the merge into `main` without requesting confirmation per the standing authorization, recording the outcome in `.specify/workflows/runs/005-multi-target-adapters.md`
- [ ] T031 AFTER the merge, confirm the platform removed the remote ref, delete the LOCAL branch `005-multi-target-adapters`, confirm no worktree remains, verify branch protection on `main` is byte-identical to before the loop, and record it all in `.specify/workflows/runs/005-multi-target-adapters.md`

---

## Dependencies & Execution Order

**Phase order**: 1 → 2 (blocking) → 3 (US2) → 4 (US1) → 5 → 6 → 7.

**US2 before US1 deliberately.** Foreign-region safety must work before projection does, because one
live target is occupied end-to-end by a foreign region and a first run without that safety would destroy
a working configuration.

**Within Phase 2**: T004 → T004a → T005 → T006 → T006b → T007. T007 is the regression gate and must run
LAST, after every restructure and schema change in the phase — an earlier draft placed T006b after it,
which would have gated on a state the phase then left behind.

**TDD ordering is mandatory**: T008 before T009, T011 before T012–T014. Observe each failing first.

**T015a** verifies FR-002 mechanically and runs after T012–T014, since it inspects their diff.

**T003 before T016** — snapshots of four live files must exist before the only task that writes them.
**T007, T010, T015 all green before T016** — a real configuration is never the first target.

**Within Phase 7**: T025 before T026, T026 before T027, T030 before T031.

## Parallel Opportunities

T001–T003 (different files). T012–T014 write separate declarations but land after T011's tests exist.
T019 and T020 both touch `README.md` — serialize if they conflict. Everything editing `project.sh` or
`run-tests.sh` contends.

## Implementation Strategy

**MVP**: Phases 1–3. Foreign-region safety generalized is the part that prevents damage.

**Increment 2**: Phase 4 — the four new declarations.

**Increment 3**: Phases 5–6 — real projection and honest documentation.

**Gate**: `/speckit-analyze` MUST report convergence before T004, the first task that writes a deliverable.
