---
Summary: Technical plan for propagating the v1.18.0 merge-authorization scope into instructions.md section 8, closing four companion defects, bumping the surface to v0.2.0 and regenerating all five projections.
Tags: [#plan #instructions #merge-authorization #scope #versioning #projection #degradation]
---

# Implementation Plan: Merge-Scope Propagation

**Branch**: `006-merge-scope-propagation` | **Spec**: [spec.md](spec.md)

## Technical Context

**Language/Version**: Markdown instruction content; POSIX shell adapters already built and merged.
**Primary dependency**: `.specify/adapters/project.sh` with five target declarations.
**Testing**: `.specify/adapters/tests/run-tests.sh --target <name>` — 14 groups. Instruction content
itself has no executable surface, so its verification is a documented grep procedure in
[quickstart.md](quickstart.md), per Principle IV's exception for non-executable changes.
**Target**: five global tool configs, machine-wide, per Principle IX.
**Scale**: `instructions.md` currently 420 lines; expected ~445 after this feature, against the
800-line ceiling in section 9.

### Clarification pass

Run, with no questions raised. Three decisions were open and all three resolve from the constitution
without operator input, so asking would have manufactured ceremony:

| Open question | Resolution | Source |
|---|---|---|
| Name AI Jedi explicitly as the authorized repository, or express it purely as a lookup? | Lookup only. Naming a repository inside portable content is the vendor-literal defect Principle II prohibits, one category up. | Principle II |
| `0.2.0` or `1.0.0`? | `0.2.0`. `1.0.0` is reserved for the operator declaring the surface stable, which has not happened. | Principle VII |
| Section 9's wiki links: remove or annotate? | Annotate. They carry real information in the source; removing them loses it, and the defect is only that they silently dangle once projected. | Principle I |

## Constitution Check

| Principle | Status | Note |
|---|---|---|
| I. Single Source of Truth | PASS | Edit lands in `instructions.md` first; all five projections regenerated from it in the same feature. |
| II. Multi-Tool Portability | PASS | No vendor literal added. The scope rule names a path (`.specify/memory/constitution.md`) that is tool-neutral, not a model identifier or command syntax. |
| III. Language Duality | PASS | Artifacts English; conversation Portuguese. |
| IV. Token Density | PASS | ~25 lines added to a 420-line file. The added text is a safety rule, so section 4's Auto-Clarity exception applies and full prose is correct here rather than compressed. |
| V. Spec-Driven Change | PASS | This is the lifecycle. The amendment deliberately did NOT edit `instructions.md` for exactly this reason. |
| VI. Automated Review | PASS | Chain runs on the PR. This repository is authorized under the rule being propagated — self-consistent. |
| VII. Versioned Surface | PASS | `0.1.0` → `0.2.0`, MINOR: new directive, nothing removed. |
| VIII. Agent Provisioning | N/A | No skill catalog change. |
| IX. Delimited Managed Region | PASS | Region markers and version rewritten by the adapter, not by hand. |
| X. Capability Tiers | N/A | No tier map change. |
| XI. Isolated Parallel Execution | PASS with stated exception | Single PR. Every user story mutates `instructions.md`, so they contend for one artifact and cannot merge independently — the exception Principle XI names explicitly. Marked serial rather than advertising a parallel marker that cannot be honored. |
| XII. Operator-Facing README | PASS | README's version and test-count claims updated in the same feature. |

**Complexity Tracking**: no deviations. One stated exception (Principle XI, single PR) recorded above
rather than left for a reviewer to infer.

## Phase 0: Research

No unknowns requiring investigation. Two facts were measured rather than assumed, and both are already
recorded in `.specify/workflows/runs/constitution-v1.18.0.md`:

- 8 of 11 repositories on this machine carrying `.specify/` have zero CI workflows.
- The adapter reads the surface version from the source at run time
  (`project.sh:103`, `SRC_VERSION=$(grep -oE 'AI-JEDI:INSTRUCTIONS:START v...')`), so bumping the
  version requires no adapter change. SC-007 asserts this rather than trusting it.

One coupling was checked and found benign: `targets/claude-code.yml:61` mentions `v0.1.0`, but only
inside a comment illustrating the title format. No code path reads it.

## Phase 1: Design

### Edit map

| Section | Change | FR |
|---|---|---|
| 1 Frontmatter | Title `v0.1.0` → `v0.2.0`; `Summary` and `Tags` re-evaluated | FR-010, FR-011 |
| 6 Intensity Levels | `~65% token reduction` → marked unmeasured | FR-007 |
| 8 Review Chain | New **Scope of the standing authorization** block after the existing carve-out list | FR-001…FR-005 |
| 9 File Architecture | Wiki links annotated as source-only | FR-009 |
| 11 Orchestration | Trigger requires a SpecKit installation | FR-006 |
| 14 Degradation Paths | New row: absent `.specify/integration.json` | FR-008 |

### The scope block

Wording constraint that drove the amendment's own round-1 defect, restated so it is not repeated: the
block MUST express the test as a lookup against the working tree. The first draft in the constitution
said "THIS repository", which resolves correctly only in the file where the rule is not applied. In
`instructions.md` — machine-wide by Principle IX — that form would let an agent in an unauthorized
repository conclude it is authorized. **Any reviewer of this feature should grep for the deictic form
before approving.**

### Verification approach

Instruction content has no executable surface, so RED-GREEN-REFACTOR does not apply literally.
Principle IV's exception routes it to a documented procedure: [quickstart.md](quickstart.md) carries
greps mapping one-to-one onto SC-001…SC-005, runnable before and after the edit. The adapter suite and
the five real projections cover SC-006 and SC-007 executably.

## Phase 2: Task Generation Approach

Ordered by risk, not by section number: the version bump last among content edits, because it is what
makes every projection stale and forces the regeneration. Projection and verification after all content
is final, so no target is written twice.
