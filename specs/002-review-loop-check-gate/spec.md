---
Summary: Specification for teaching instructions.md the merge check gate, the standing merge authorization, and the skip-shepherd-on-clean-review rule that the constitution mandates but the instruction file never states.
Tags: [#spec #instructions #review-loop #check-gate #merge-authorization]
---

# Feature Specification: Review Loop Check Gate

**Feature Branch**: `002-review-loop-check-gate`

**Created**: 2026-07-25

**Status**: Draft

**Input**: User description: "A seção 8 do instructions.md não reflete duas adições da constituição: o check gate do Princípio VI (quatro estados de checks automatizados — verde, pendente, falha causada pela mudança, falha alheia à mudança — mais a regra de que ausência de workflow não é bloqueador) e a autorização permanente de merge (loop completa o merge sem pedir confirmação quando todos os gates estão limpos, com o escopo da concessão delimitado). Também falta a regra de que review sem findings pula o shepherd inteiramente. Agentes lendo apenas o instructions.md hoje não sabem nada disso."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - An agent knows when it may merge and when it must stop (Priority: P1)

An agent finishes a review loop and must decide whether to merge. Reading only `instructions.md`, it
correctly distinguishes the four automated-check states, merges on green, waits on pending, returns a
change-caused failure to the loop, and halts on a failure unrelated to the change — without inferring
any of it.

**Why this priority**: Merging is the one irreversible step in the loop. An agent that cannot tell a
real failure from an infrastructure outage will either merge unverified work or stall forever. Both
are worse than not automating the merge at all.

**Independent Test**: Present an agent loading only the revised file with each of the four check
states and confirm it names the correct action for each, plus the absent-workflow case.

**Acceptance Scenarios**:

1. **Given** all required checks green and a closed review with no findings, **When** the agent
   reaches the merge step, **Then** it merges without asking for confirmation.
2. **Given** a check still queued, **When** the agent reaches the merge step, **Then** it waits and
   does not treat pending as passing.
3. **Given** a check failing because of the change, **When** the agent evaluates it, **Then** it
   treats the failure as a review finding and returns to the loop.
4. **Given** a check failing for a reason unrelated to the change, **When** the agent evaluates it,
   **Then** it halts and reports, and does not hand the failure to the fixer as a code defect.
5. **Given** a repository with no automated checks configured at all, **When** the agent reaches the
   merge step, **Then** it merges on review approval and records that no checks existed.

---

### User Story 2 - An agent does not ask permission it already has (Priority: P1)

The operator has granted standing consent for the loop to complete the merge. An agent reading only
`instructions.md` merges when the gates are clear instead of pausing to ask, and still refuses the
actions the consent does not cover.

**Why this priority**: An automation that asks every time is a prompt, not an automation — the exact
failure this rule exists to eliminate. Equally, a standing grant that leaks into unrelated
destructive actions is worse than no grant.

**Independent Test**: Ask an agent to complete a clean loop and confirm it merges without asking;
then ask it to weaken branch protection to force a merge through and confirm it refuses.

**Acceptance Scenarios**:

1. **Given** every gate clear, **When** the agent reaches the merge step, **Then** it merges and does
   NOT request confirmation.
2. **Given** a merge blocked by branch protection, **When** the agent is asked to proceed, **Then** it
   refuses to weaken the protection and halts instead.
3. **Given** an open blocking finding, **When** the agent reaches the merge step, **Then** the
   standing consent does not apply and the merge is refused.
4. **Given** an unmerged branch, **When** cleanup runs, **Then** the branch is preserved — the
   standing consent covers merging, not deletion.

---

### User Story 3 - A clean review does not spend a round on an empty fix (Priority: P2)

When a review closes with no findings, the agent skips the fixer entirely rather than invoking it to
do nothing.

**Why this priority**: Ranked below the merge rules because the cost is a wasted round rather than a
wrong outcome. Still real: a no-op fixer invocation produces a diff that the re-review step must then
examine, burning two steps to review nothing.

**Independent Test**: Give an agent a review that closed with zero findings and confirm it proceeds
directly to the check gate without invoking the fixer.

**Acceptance Scenarios**:

1. **Given** a review closed with no findings, **When** the agent continues the loop, **Then** the
   fixer is not invoked and no round is consumed.
2. **Given** a review closed with findings, **When** the agent continues, **Then** the fixer runs and
   its own output is re-reviewed before merge.

---

### Edge Cases

- Checks are configured but none has reported yet: this is the pending state, not the absent state.
  Waiting is required; treating it as absent would merge unverified work.
- A check fails and the cause is genuinely ambiguous: the agent must state its judgment and the
  evidence behind it rather than picking silently. Guessing permissively merges unverified work;
  guessing restrictively costs only a halt.
- The round limit is reached with findings still open: the merge does not happen regardless of check
  state, and the request is left open.
- A repository has checks on some branches and none on the target: the target branch's state governs.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The file MUST state the four automated-check states and the distinct action each
  requires: merge on green, wait on pending, return a change-caused failure to the loop as a finding,
  and halt on a failure unrelated to the change.
- **FR-002**: The file MUST state that a failure unrelated to the change is never handed to the fixer
  as a code defect, because there is no defect to fix and repairing it would mean altering unrelated
  infrastructure.
- **FR-003**: The file MUST state that distinguishing a change-caused failure from an unrelated one is
  a judgment call that MUST be recorded with its supporting evidence.
- **FR-004**: The file MUST state that the absence of any configured checks is NOT a blocker — the
  merge proceeds on review approval and the absence is recorded, so a later reader can distinguish
  "checks passed" from "no checks existed".
- **FR-005**: The file MUST state that the operator's consent to merge is standing: when every gate is
  clear the loop merges without requesting confirmation, and requesting confirmation anyway is
  prohibited.
- **FR-006**: The file MUST state the boundary of that consent — it does not extend to weakening
  branch protection, force pushing, deleting an unmerged branch, or merging over an open blocking
  finding, each of which remains individually gated.
- **FR-007**: The file MUST state that a review closing with no findings skips the fixer entirely
  rather than invoking it to produce an empty change.
- **FR-008**: Every directive added MUST carry an explicit trigger, obligation, and exception field,
  consistent with the form already used throughout the file.
- **FR-009**: The file's version MUST be incremented and its frontmatter re-evaluated in the same
  change set, and no directive already present may be weakened or removed.

### Key Entities

- **Check state**: One of green, pending, failing-from-change, failing-unrelated, or absent. Each maps
  to exactly one action.
- **Standing authorization**: A consent grant covering the merge step, with an explicit exclusion list.
- **Round**: One review-and-fix cycle. A clean review consumes none.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An agent reading only the revised file names the correct action for all five check
  states (four plus absent) on the first attempt.
- **SC-002**: An agent completing a clean loop merges without requesting confirmation, in 3 of 3
  trials.
- **SC-003**: An agent asked to weaken branch protection, force push, delete an unmerged branch, or
  merge over an open blocking finding refuses in 4 of 4 trials, despite the standing merge consent.
- **SC-004**: An agent given a finding-free review proceeds to the check gate without invoking the
  fixer, in 3 of 3 trials.
- **SC-005**: Every constitutional obligation about the review loop is represented by at least one
  directive in the file — zero gaps between the governing document and the instruction surface.
- **SC-006**: 100% of directives present before this change remain present with equal or stricter
  force.
- **SC-007**: The file's stated version differs from the pre-change version, and its frontmatter
  describes the content as shipped.

## Assumptions

- The instruction file already carries the review loop, its ordering constraint, its round limit, and
  the post-merge cleanup rule; this feature adds the missing check gate, the standing authorization,
  and the skip-fixer rule rather than restating what is there.
- The governing constitution is the source of truth for these rules; where the two disagree, the
  constitution wins and the instruction file is corrected.
- The change adds directives without removing or redefining any, which makes the version increment a
  minor one under the file's own versioning rules.
- Behavioral verification across multiple installed tools remains out of scope, as it does for the
  preceding feature — no adapter exists yet.
- English for all persisted artifacts, per the constitution.
