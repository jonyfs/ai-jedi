---
Summary: Propagates the constitution v1.18.0 merge-authorization scope into instructions.md section 8 and closes four grounded defects found in the same assessment, bumping the instruction surface to v0.2.0.
Tags: [#spec #instructions #merge-authorization #scope #orchestrator-trigger #degradation #versioning]
---

# Feature Specification: Merge-Scope Propagation

**Feature Branch**: `006-merge-scope-propagation`

**Created**: 2026-07-25

**Status**: Draft

**Input**: Constitution v1.18.0 bounded the standing merge authorization to the granting repository.
`instructions.md` section 8 still carries the unscoped version, and section 8 is what every installed
tool actually loads — so until this propagates, the amendment governs nothing outside the constitution
file itself. Four companion defects surfaced in the same assessment and are cheap to close in the same
pass.

## Why this feature exists at all

The amendment is currently inert. Principle I makes `instructions.md` the only authoritative
instruction text and every tool config a projection of it. An agent in another repository reads the
projection, never the constitution. So a governance rule that lives only in
`.specify/memory/constitution.md` changes no behaviour anywhere.

This is the reverse of the drift Principle I usually guards against: not a projection that diverged
from the source, but a source that has not yet received a decision recorded elsewhere.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - An agent in an unauthorized repository stops at the merge (Priority: P1)

An agent loads the global instruction surface in a repository that is not AI Jedi. It runs the review
chain in full and then halts at the merge, reporting rather than merging, because that repository's
working tree carries no constitution granting the authorization.

**Why this priority**: This is the entire point. Without it, eight repositories on this machine with
no CI and no branch protection are exposed to merge-on-self-approval, where reviewer, author and
merger are one agent. Every other item in this feature is hygiene by comparison.

**Independent Test**: Read section 8 in isolation and answer: "I am in repository X. May I merge?"
The text must resolve that from the working tree, not from the reader's location, and must reach the
same answer wherever it is read from.

**Acceptance Scenarios**:

1. **Given** section 8 as projected into a tool's global config, **When** an agent reads it while in a
   repository with no `.specify/memory/constitution.md`, **Then** the text directs it to run the chain
   and halt at the merge with a report.
2. **Given** the same text, **When** an agent reads it while in AI Jedi, **Then** the text directs it
   to complete the merge without confirmation.
3. **Given** the same text, **When** an agent reads it in any repository, **Then** the rule for
   deciding which case applies is a lookup against the working tree and contains no deictic reference
   that changes meaning with the reader's position.
4. **Given** an authorized repository whose merge would land with neither checks nor branch
   protection, **When** the merge proceeds under the grant, **Then** the text requires the run log to
   record which protection was absent.

---

### User Story 2 - Orchestrator Mode stops firing on any stray tasks.md (Priority: P2)

An agent working in a repository that happens to contain a `tasks.md` — a three-line TODO, say — is
not forced into Orchestrator Mode and told never to edit code directly.

**Why this priority**: Real friction in every session outside a SpecKit project, and verified to have
no constitutional basis: no principle asks for that breadth. But it degrades productivity rather than
risking a bad merge, so it ranks below US1.

**Independent Test**: Read section 11's trigger and check it against a repository holding only a
`tasks.md`. The trigger must not fire on that alone.

**Acceptance Scenarios**:

1. **Given** section 11, **When** a repository contains a `tasks.md` but no SpecKit installation,
   **Then** the trigger does not fire.
2. **Given** section 11, **When** a repository contains `.specify/` with a feature directory, **Then**
   the trigger fires as before.

---

### User Story 3 - No unverified number is stated as fact (Priority: P3)

Section 6 claims `~65% token reduction` for the `full` intensity level. Nobody measured it.

**Why this priority**: Costs nothing to fix and matters for a reason bigger than the number itself —
this file is read by agents that will repeat what it says. It ranks last because no behaviour depends
on the figure.

**Independent Test**: Grep section 6 for a quantitative claim and confirm each either carries a
measurement or is marked unmeasured.

**Acceptance Scenarios**:

1. **Given** section 6, **When** an agent reads the `full` row, **Then** it finds either a measured
   figure with its method or an explicit statement that the reduction is unmeasured.

---

### User Story 4 - Degradation covers the absent integration file (Priority: P3)

Section 12 derives the invocation separator from `.specify/integration.json`. Outside a SpecKit
repository that file does not exist, and section 14's degradation table has no row for it.

**Independent Test**: Read sections 12 and 14 together and answer "the file is absent — now what?"
The answer must be present and must not be invention.

**Acceptance Scenarios**:

1. **Given** sections 12 and 14, **When** `.specify/integration.json` is absent, **Then** a stated
   fallback exists and the absence is reported rather than silently absorbed.

---

### Edge Cases

- A repository with a constitution that is NOT AI Jedi's and does not carry the grant: unauthorized.
  Presence of a constitution is not the test; presence of the grant in it is.
- A repository with the grant but with branch protection removed since: the grant still authorizes,
  but the missing protection must be recorded. Silent merge into an unprotected branch is what the
  logging requirement exists to surface.
- AI Jedi's own `CLAUDE.md` carries no `AI-JEDI:INSTRUCTIONS` region per Principle IX, so an agent
  working in this repository reads the scope rule from the global projection, not from a local copy.
  The lookup must therefore work when the reader's config and the working tree are different places.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Section 8's standing merge authorization MUST state that it applies only to a repository
  whose own `.specify/memory/constitution.md` records the grant.
- **FR-002**: Section 8 MUST express the scope test as a lookup against the working tree. It MUST NOT
  use a deictic form ("this repository") whose meaning depends on where the reader is.
- **FR-003**: Section 8 MUST state that outside an authorized repository the review chain runs in full
  and halts at the merge with a report — the review work is not withheld, only the merge.
- **FR-004**: Section 8 MUST state that consent for another repository is granted per repository,
  explicitly, and is standing for it thereafter; and that silence is NOT consent for this, in
  deliberate contrast to the chain-level rule where silence IS consent to run the chain.
- **FR-005**: Section 8 MUST require the run log to record which protection was absent when a merge
  proceeds under the grant with neither checks nor branch protection configured.
- **FR-006**: Section 11's Orchestrator Mode trigger MUST require a SpecKit installation, not the mere
  presence of a `tasks.md`.
- **FR-007**: Section 6 MUST NOT state an unmeasured reduction figure as fact.
- **FR-008**: Section 14 MUST carry a degradation row for an absent `.specify/integration.json`.
- **FR-009**: The wiki links in section 9 MUST NOT dangle once projected into a global config, or MUST
  state that they resolve only in the source repository.
- **FR-010**: The instruction surface version MUST bump from `0.1.0` to `0.2.0` — a new directive with
  no removal is MINOR under Principle VII — in the title, the frontmatter `Summary`, and the managed
  region's start marker.
- **FR-011**: The frontmatter `Summary` and `Tags` MUST be re-evaluated so they describe the
  directives actually carried, per section 1's own obligation.
- **FR-012**: All five projections MUST be regenerated to `v0.2.0`, and each foreign region present
  MUST remain byte-identical.

### Key Entities

- **Authorized repository** — a working tree containing `.specify/memory/constitution.md` whose
  Principle VI carries the standing merge authorization.
- **Scope lookup** — the check an agent performs against the working tree to classify the repository.
  Distinct from the reader's own location, which is what the defective first draft used.

## Success Criteria *(mandatory)*

- **SC-001**: An agent reading only the projected section 8, in a repository with no constitution,
  reaches "halt at the merge and report" without needing any other INSTRUCTION file. It does consult
  the working tree for `.specify/memory/constitution.md` — that lookup is the rule, not a gap in it. An
  earlier draft of this criterion said "without consulting any other file", which contradicted FR-001.
- **SC-002**: Section 8 contains zero deictic references to the authorized repository.
- **SC-003**: Section 11's trigger does not fire on a `tasks.md` alone.
- **SC-004**: Section 6 carries no unmeasured quantitative claim presented as fact.
- **SC-005**: Every capability sections 12 and 13 assume has a degradation row in section 14.
- **SC-006**: All five targets report `current (v0.2.0)`, the content between markers is byte-identical
  across them, and OpenCode's caveman region is unchanged from before the run.
- **SC-007**: The adapter suite passes against every target with no new failures, and the version bump
  requires no change to adapter code — confirming the version is read from source rather than
  hardcoded.

## Assumptions

- The scope rule belongs in section 8 beside the authorization rather than in a new section. Section 8
  is already flagged in the backlog as carrying six concerns and 118 of 420 lines; adding a seventh is
  a real cost, but splitting section 8 is a separate structural change and doing it inside this feature
  would be the scope expansion the constitution prohibits. Recorded rather than silently absorbed.
- `v0.2.0` rather than `v1.0.0`: Principle VII reserves `1.0.0` for the operator declaring the surface
  stable, which has not happened.
- Section 10's thinness, raised in the same assessment, is deliberately NOT in scope. It is a quality
  judgment about content value, not a defect against any requirement, and rewriting it needs its own
  spec.

## Dependencies

- Constitution v1.18.0, merged. The rule being propagated must exist before it can propagate.
- Feature 005's five adapters, merged. FR-012 regenerates all five.
