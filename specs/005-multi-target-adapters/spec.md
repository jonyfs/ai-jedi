---
Summary: Specification for extending the projection mechanism to the operator's other installed tools, with per-tool declarations and honest exclusion of tools that expose no global instruction surface.
Tags: [#spec #adapter #multi-target #projection]
---

# Feature Specification: Multi-Target Adapters

**Feature Branch**: `005-multi-target-adapters`

**Created**: 2026-07-25

**Status**: Draft

**Input**: One adapter exists and is hardened. The operator has other AI tools installed, and the
instruction set should reach the ones that can actually load it.

A survey of the machine found **five declared targets, four of which have an existing file**; the fifth
is a documented path with no file yet, which the adapter creates. Two further installed tools hold only
agent definitions placed there by other tooling — no global instruction surface was found for either, so
this feature does not invent one.

That vocabulary is used consistently below: *declared targets* is five, *existing files* is four.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The instruction set reaches every tool that can load it (Priority: P1)

The operator installs their instructions once and every tool with a global instruction file carries the
same content, each wrapped in its own marked region.

**Why this priority**: this is the whole point of a single source of truth. One tool configured is a
proof of concept; five declared targets is the product.

**Independent Test**: run each adapter, then confirm every target carries a region with the current
version and identical content between markers.

**Acceptance Scenarios**:

1. **Given** a declared target with no region, **When** its adapter runs, **Then** the region is created
   with the current version.
2. **Given** all declared targets projected, **When** their regions are compared, **Then** the content
   between markers is identical across every one.
3. **Given** a target whose file does not exist, **When** its adapter runs, **Then** the file is created
   at the declared location.
4. **Given** a target that is already current, **When** its adapter runs, **Then** nothing is written.

---

### User Story 2 - Another tool's managed region is never disturbed (Priority: P1)

A target already contains a marked region belonging to different tooling. After projection, that region
is byte-identical and the instruction region sits alongside it.

**Why this priority**: equal to US1, and no longer hypothetical — one target is currently occupied
end-to-end by a foreign region. Damaging it would break a tool the operator uses, in a file this project
has no claim over.

**Independent Test**: project into a target holding a foreign region and confirm that region is
unchanged byte-for-byte.

**Acceptance Scenarios**:

1. **Given** a target whose entire content is a foreign region, **When** the adapter runs, **Then** that
   region is byte-identical afterward and the instruction region is appended.
2. **Given** a foreign region using a marker syntax unlike this project's, **When** the adapter runs,
   **Then** it is still recognised as foreign and left alone.
3. **Given** a foreign region, **When** fork detection scans, **Then** its interior is excluded from the
   scan exactly as the adapter's own region is.

---

### User Story 3 - A tool without a global instruction surface is excluded, not faked (Priority: P2)

The operator can see which tools are covered and which are not, and why.

**Why this priority**: below the projection stories because nothing breaks without it. But a project
whose README claims coverage it does not have is worse than one that covers less.

**Independent Test**: read the tool table and confirm every uncovered tool states the reason.

**Acceptance Scenarios**:

1. **Given** a tool with no discoverable global instruction file, **When** the tool table is read,
   **Then** it is listed as uncovered with the reason stated.
2. **Given** a tool later gains such a surface, **When** a declaration is added for it, **Then** no
   existing declaration and no shared logic changes — adding a tool is adding a declaration, which is
   what FR-002 makes structural.

---

### Edge Cases

- A target is empty: the region is written into it without a leading blank line artefact.
- Two targets share a filename convention (`AGENTS.md` for both Codex and OpenCode) but different
  directories: each adapter resolves its own path and neither writes the other's.
- A target's directory does not exist: created, or refused with a clear reason — never silently skipped.
  Which of the two is a declared policy per target, not a silent choice, mirroring the rule that the
  summarize-versus-refuse decision must be recorded. Every declaration states its own; none inherits a
  default that would make the behavior invisible.
- A foreign region's markers are not the pair this project uses: recognised from the target's own
  declaration rather than from a global constant.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Each target MUST have its own declaration carrying that tool's path, format, markers, and
  the foreign markers it must not disturb. No target's values may be hardcoded in shared logic.
- **FR-002**: The projection logic MUST be shared across targets. Adding a tool MUST mean adding a
  declaration, not copying a script.
- **FR-003**: Foreign-region recognition MUST come from the target's declaration, because marker syntax
  differs between tools and a global constant cannot cover them.
- **FR-004**: Every existing guarantee MUST hold for every new target: refusal inside a working tree,
  byte-identity outside the region, backup before write, post-write verification with rollback, bounded
  retention, and idempotency.
- **FR-005**: Content between markers MUST be identical across all projected targets, since all derive
  from one source.
- **FR-006**: A tool with no discoverable global instruction surface MUST be recorded as uncovered with
  the reason, and MUST NOT have an adapter invented for it.
- **FR-007**: The operator-facing documentation MUST distinguish tools that are projected from tools that
  are merely installed.

### Key Entities

- **Target declaration**: one per tool — path, format, own markers, foreign markers, size limit, backup
  policy.
- **Shared projection logic**: the behavior every target gets, parameterized by declaration.
- **Foreign region**: a marked span owned by other tooling, recognised per-target and never touched.
- **Uncovered tool**: installed, but exposing no global instruction file. Recorded, not adapted.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every declared target carries a region at the current version after its adapter runs.
- **SC-002**: The content between markers is byte-identical across all projected targets.
- **SC-003**: A foreign region is byte-identical before and after projection: 1 of 1 real target that
  has one, plus every fixture case. The number is one because exactly one target carries a foreign region
  today — an earlier draft claimed three, which was invented rather than surveyed.
- **SC-004**: Adding a target requires no change to shared projection logic — demonstrated by the last
  target added touching only a declaration.
- **SC-005**: Every existing test group passes for every target, not only the first.
- **SC-006**: The tool table lists every installed tool as either projected or uncovered-with-reason, with
  zero silent omissions.

## Assumptions

- Four targets have a verified global instruction file; two installed tools do not, and are excluded with
  the reason recorded rather than guessed at.
- One target is currently occupied end-to-end by a foreign region using a marker syntax unlike this
  project's, which is why FR-003 exists.
- The existing adapter's guarantees are the baseline; this feature generalizes them rather than
  re-deriving them.
- No instruction content changes, so no instruction version bump applies.
- English for all persisted artifacts.
