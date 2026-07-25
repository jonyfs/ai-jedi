---
Summary: Implementation plan adding the merge check gate, standing merge authorization, and skip-shepherd rule to instructions.md section 8, bumping the instruction surface to 0.1.0.
Tags: [#plan #instructions #review-loop #check-gate]
---

# Implementation Plan: Review Loop Check Gate

**Branch**: `002-review-loop-check-gate` | **Date**: 2026-07-25 | **Spec**: [[spec]] — `specs/002-review-loop-check-gate/spec.md`

**Input**: Feature specification from `specs/002-review-loop-check-gate/spec.md`

## Summary

Extend section 8 of `instructions.md` with the three rules the constitution mandates but the file
never states: the five-state check gate, the operator's standing merge authorization with its
exclusion list, and the rule that a finding-free review skips the shepherd. Bump the instruction title
to `0.1.0` and re-evaluate the frontmatter in the same change set. No existing directive is touched.

## Technical Context

**Language/Version**: Markdown (CommonMark); no runtime language

**Primary Dependencies**: None. `.specify/memory/constitution.md` v1.14.0 is the read-only source of
truth for the rules being transcribed.

**Storage**: Plain files in the repository root

**Testing**: Document-level verification via [[quickstart]] — presence greps, state-mapping probes,
refusal probes, and a register check that nothing was lost

**Target Platform**: Any AI coding tool that loads a Markdown instruction file

**Project Type**: Documentation / instruction control plane

**Performance Goals**: File stays under the 800-line ceiling; section 8 stays scannable

**Constraints**: No directive may be lost or weakened (FR-009); every added directive carries
trigger/obligation/exception (FR-008); English only (Principle III); additions must remove ambiguity
rather than restate (Principle IV token discipline)

**Scale/Scope**: One file, one section. 375 lines today; roughly 40 added. Adapters remain out of
scope — none exists.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|---|---|---|
| I. Single Source of Truth | Change made in `instructions.md` first; no projection hand-edited | PASS — no projections exist |
| II. Multi-Tool Portability | Content tool-neutral; vendor values isolated | PASS — added rules name no vendor and no literal command form; the reviewer and shepherd are referred to by role noun, which Principle II does not constrain |
| III. Language Duality | Artifacts in English | PASS |
| IV. Token Density with Auto-Clarity | Additions earn their tokens | PASS — each added directive closes a stated gap; none restates an existing rule |
| V. Spec-Driven Change | specify → plan → tasks → implement → converge | PASS — spec exists, this is the plan step, analyze runs before implementation |
| VI. Automated Post-Implementation Review | Loop, round limit, check gate, post-merge cleanup | PASS — round limit is the constitutional default of 3, not overridden. The loop governs this feature's own pull request |
| VII. Versioned Instruction Surface | Title carries the version; bump declared before implementation | PASS — see the bump declaration below |
| VIII. Executable Agent Provisioning | Catalog agrees with the availability source of record | PASS — no catalog change; section 11 untouched |
| IX. Delimited Managed Region | Marker pair present; global-only projection | PASS — edits land inside the existing marker pair; the start marker's version is updated with the title |
| X. Capability-Tiered Agent Materialization | Tier vocabulary only | PASS — no catalog or tier change |
| XI. Isolated Parallel Execution | Worktree isolation; dependency-order merge; PR-per-story | PASS — see the Parallel Execution Plan below |
| XII. Operator-Facing README | README covers every capability, claims directive-backed | PASS — the README's review-chain section gains the check gate and standing authorization; task-tracked |
| Authoring constraints | Accurate frontmatter, wiki links, ≤800 lines, no secrets | PASS |

**Instruction Version Bump**

- Current version: `0.0.1`
- Declared bump: **MINOR** → `0.1.0`
- Justification: directives are added and none is removed or redefined, so no previously compliant
  agent behavior becomes non-compliant. That is the MINOR case.
- Not PATCH: new obligations are introduced, not clarifications of existing ones.
- Not MAJOR: MAJOR stays `0` until the operator declares the surface stable, which is itself a
  constitutional amendment.

**Parallel Execution Plan** (Principle XI)

- Units eligible for parallel dispatch: **none.** Every writing task edits `instructions.md`, so they
  contend. Per Principle XI, isolation does not manufacture parallelism here, and marking them
  parallel would be a false promise.
- Worktree/branch per unit: not applicable. Single branch `002-review-loop-check-gate`.
- Serialization justification: write contention on `instructions.md`. The README task and the run-log
  task are the only ones touching different files, so they are the only genuinely parallel pair.
- Merge order: single branch; dependency order is task order.
- PR granularity: one pull request. All three stories mutate the same section and cannot merge
  independently — the documented exception to PR-per-story, stated here rather than left to a
  reviewer to infer.

Post-Phase 1 re-check: PASS. No violations; no Complexity Tracking entries required.

## Design Decisions

**Where the rules go.** All three land in section 8, which already holds the loop. The check gate
becomes a subsection between the loop steps and the autonomy bounds, matching the constitution's own
ordering so a reader comparing the two documents finds them in the same sequence.

**How the roles are named.** The constitution names `/pr-reviewer` and `/pr-shepherd`.
`instructions.md` MUST NOT carry those literal command forms — Principle II forbids them in shared
content and Principle VIII requires invocation syntax derived from the integration separator. But the
BAN IS ON THE COMMAND FORM, NOT THE ROLE NOUN. Section 8 already says **the reviewer** and **the
shepherd**, and this feature keeps exactly those words.

An earlier draft of this plan claimed the file said "the fixer" and proposed standardizing on it. That
was wrong on both counts: the file says "shepherd" (5 occurrences, zero of "fixer"), and Principle II
never constrained the noun. Introducing "fixer" would have put a second name for one role into a single
section — a readability defect invented out of a misreading. Recorded here so the mistake is not
repeated.

**Standing consent removes the confirmation, not the mechanism.** Section 8 step 4 already says "arm
automerge and let the change land through the pull request". FR-009 forbids weakening an existing
directive, so the standing authorization MUST NOT replace that mechanism with a direct merge. It
removes the *request for confirmation* before arming it. Tasks and quickstart wording follow this
reading.

**Five states, not four.** The constitution's prose describes four check states plus the absent case.
The file states five explicitly, because absent is the state this repository is actually in, and
leaving it implicit is exactly what would make an agent treat it as a failure and stall.

## Project Structure

### Documentation (this feature)

```text
specs/002-review-loop-check-gate/
├── plan.md              # This file
├── quickstart.md        # Phase 1 output — validation guide
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (/speckit-tasks)
```

Deliberately absent: `research.md` — there are no unknowns, the rules are transcribed from a known
source. `data-model.md` — no entities to model. `contracts/` — feature 001's contract already governs
the file and gains no new invariant.

### Source Code (repository root)

```text
instructions.md          # THE deliverable — section 8 extended, title bumped to 0.1.0
README.md                # Review-chain section gains the check gate and standing authorization
.specify/
├── memory/constitution.md                # Read-only source of the rules
└── workflows/runs/002-review-loop-check-gate.md   # Run log
```

**Structure Decision**: No source tree. Same instruction control plane as feature 001: the deliverable
is the root `instructions.md`, with `README.md` updated to match per Principle XII.

## Complexity Tracking

No Constitution Check violations. Section not applicable.
