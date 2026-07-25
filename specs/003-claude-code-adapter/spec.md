---
Summary: Specification for the first adapter — projecting instructions.md into the Claude Code global configuration, replacing an existing hand-maintained fork without disturbing operator-authored content.
Tags: [#spec #adapter #projection #claude-code #managed-region]
---

# Feature Specification: Claude Code Adapter

**Feature Branch**: `003-claude-code-adapter`

**Created**: 2026-07-25

**Status**: Draft

**Input**: Write the first adapter, so the instruction set actually configures an installed tool. Today
`instructions.md` v0.1.0 lives in a repository and configures nothing, while the operator's global
Claude Code configuration carries a hand-maintained fork of the pre-revision content — drifted by two
versions and unmarked.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The instruction set actually reaches an installed tool (Priority: P1)

The operator asks for their AI Jedi instructions to be installed. The current `instructions.md`
content lands in the Claude Code global configuration, wrapped in the managed-region markers carrying
the version, and the next session of that tool behaves according to it.

**Why this priority**: This is the project's entire purpose. Twelve principles govern projections,
markers, global paths, and verification — and no projection has ever been generated. Everything else
is scaffolding until one exists.

**Independent Test**: Run the adapter, then confirm the global configuration carries the managed region
with the current version, and that a fresh session of the tool applies a rule that exists only in the
new content.

**Acceptance Scenarios**:

1. **Given** a global configuration with no managed region, **When** the adapter runs, **Then** the
   region is created with the current instruction version in its start marker.
2. **Given** a global configuration whose region version already matches the source, **When** the
   adapter runs, **Then** it reports the projection current and writes nothing.
3. **Given** a global configuration whose region version trails the source, **When** the adapter runs,
   **Then** only the span between markers is replaced and the start marker's version advances.
4. **Given** the adapter has run twice with unchanged source, **When** the two outputs are compared,
   **Then** they are byte-identical.

---

### User Story 2 - Operator-authored content survives untouched (Priority: P1)

The operator's global configuration contains their own content alongside the managed region — imports,
personal sections, tool references. After the adapter runs, every byte of it is exactly as before.

**Why this priority**: Equal to US1 and arguably harder. A projection that overwrites the operator's own
configuration is worse than no projection: it destroys work the operator cannot recover, in a file they
did not expect a repository to touch.

**Independent Test**: Capture the global configuration before running the adapter, run it, then confirm
every line outside the managed region is byte-identical.

**Acceptance Scenarios**:

1. **Given** operator-authored content above the managed region, **When** the adapter runs, **Then**
   that content is byte-identical afterward.
2. **Given** operator-authored content below the managed region, **When** the adapter runs, **Then**
   that content is byte-identical afterward.
3. **Given** an existing hand-maintained fork of instruction content with NO markers, **When** the
   adapter runs, **Then** the fork is replaced by a marked region and the operator is told which span
   was replaced, rather than the fork being silently duplicated or left alongside.
4. **Given** a configuration with only one marker, or markers out of order, **When** the adapter runs,
   **Then** it reports the corruption and writes nothing.

---

### User Story 3 - The adapter refuses to write where it must not (Priority: P1)

The adapter targets the tool's global, user-level configuration. Asked to write anywhere else — most
importantly inside a project working tree — it refuses.

**Why this priority**: A projection written into a project scopes a global instruction set to one
repository and commits the operator's machine-wide configuration into that project's history. Both are
hard to undo and easy to do by accident.

**Independent Test**: Point the adapter at a path inside a project working tree and confirm it refuses
and reports, without writing.

**Acceptance Scenarios**:

1. **Given** a resolved target path inside a project working tree, **When** the adapter runs, **Then**
   it refuses and reports, and no file is written.
2. **Given** the tool's global configuration file does not exist, **When** the adapter runs, **Then**
   it creates it at the documented location containing only the markers and the content — never falling
   back to a project-local file.
3. **Given** a target file the adapter cannot read, **When** the adapter runs, **Then** it reports and
   writes nothing rather than overwriting an unread file.

---

### User Story 4 - Drift is detectable without diffing content (Priority: P2)

An agent or operator can tell whether the projection is current by comparing one version string, rather
than by comparing the whole content.

**Why this priority**: Detection is what makes the projection maintainable. Ranked below the writing
stories because a correct projection with awkward drift detection still works.

**Independent Test**: Change the source version, then confirm a drift check reports the projection stale
without reading the projected content.

**Acceptance Scenarios**:

1. **Given** a source version newer than the region's, **When** drift is checked, **Then** it reports
   stale and names both versions.
2. **Given** matching versions, **When** drift is checked, **Then** it reports current.
3. **Given** a missing region, **When** drift is checked, **Then** it reports not-installed, which is
   distinct from stale.

---

### Edge Cases

- **The adapter rewrites the configuration of the agent running it.** Editing the global instruction
  file changes the instructions governing the current session. The adapter must state that its effect
  applies from the next session, and must not assume its own behavior changed mid-run.
- The target file contains a managed region belonging to different tooling: that region is left
  untouched, and its presence is not mistaken for this one.
- The source contains its own markers, since it is the source: the adapter must project the content
  between them, not the markers-within-markers.
- The operator's content contains text resembling a marker: exact-match on the full marker line is
  required, not a substring search.
- No backup exists and the write fails midway: the operator's configuration must not be left in a
  partially written state.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The adapter MUST declare its target tool, the user-level configuration path it writes, the
  file format, and any size limit that tool imposes.
- **FR-001a**: The adapter MUST also declare the four fields the authoring constraints require of every
  adapter: how its harness installs and verifies the skill set, the invocation separator its integration
  uses, its harness's agent-definition location and format, and its capability-tier to concrete-model
  mapping. An adapter declaring only its path and format is incomplete.
- **FR-001b**: The adapter MUST act on the declared size limit rather than merely recording it. Content
  exceeding the target's limit MUST NOT be truncated arbitrarily. **This adapter REFUSES rather than
  summarizes**, and the declaration records that choice. Summarizing is rejected for two concrete
  reasons: it would break the verbatim span projection FR-004 and FR-005 require, and a summarized region
  carrying the source version would make the drift check lie — two regions could report the same version
  while holding different content.
- **FR-015**: After writing, the adapter MUST verify its own output: both markers present and in order,
  the start marker's version matching the source, content outside the region byte-identical to before,
  and the written path still user-level. A write that fails verification MUST be rolled back from the
  backup. **Boundary with FR-011**: FR-011 owns taking the backup and keeping the write atomic; FR-015
  owns checking the result and triggering the restore. Neither duplicates the other.
- **FR-016**: Fork migration MUST be gated on explicit operator confirmation for that specific span. The
  adapter MUST report the exact span and the signal it matched, and MUST refuse when the span is not
  bounded by exactly one heading matching the instruction title's shape extending to end-of-file.
- **FR-002**: The adapter MUST refuse to write when the resolved target path falls inside a project
  working tree, and MUST report the refusal.
- **FR-003**: The adapter MUST create the target file at the documented location when it does not exist,
  and MUST NOT fall back to any project-local path.
- **FR-004**: The adapter MUST wrap projected content in the managed-region markers, with the source
  version carried in the start marker and absent from the end marker.
- **FR-005**: The adapter MUST replace only the span between markers. Every byte outside that span MUST
  be identical after the run.
- **FR-006**: When the target contains unmarked instruction content — a hand-maintained fork — the
  adapter MUST replace that span with a marked region and MUST report which span it replaced, rather
  than duplicating the content or leaving the fork in place.
- **FR-007**: The adapter MUST report and write nothing when the target has one marker, markers out of
  order, or cannot be read.
- **FR-008**: The adapter MUST be idempotent: running it twice against unchanged source MUST produce
  byte-identical output and MUST NOT duplicate the region.
- **FR-009**: When the region's version already matches the source, the adapter MUST report the
  projection current and write nothing.
- **FR-010**: The adapter MUST support a check that reports current, stale, or not-installed by
  comparing version strings alone, without reading projected content.
- **FR-011**: The adapter MUST back up the target before writing, and MUST leave the target unmodified
  if the write cannot complete.
- **FR-012**: The adapter MUST state that its effect applies from the tool's next session, not to the
  session that ran it.
- **FR-013**: The adapter MUST leave any managed region owned by other tooling untouched, and MUST NOT
  treat such a region as its own.
- **FR-014**: Marker detection MUST be an exact match on the full marker line, so operator content
  resembling a marker is not mistaken for one.

### Key Entities

- **Adapter declaration**: target tool, user-level path, format, size limit. The contract a projection
  makes with its tool.
- **Managed region**: the marked span the adapter owns, delimited by a start marker carrying the version
  and an end marker carrying none.
- **Operator-authored content**: everything outside the region. Read-only to the adapter, always.
- **Projection state**: current, stale, not-installed, or corrupt.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After the adapter runs, the tool's global configuration carries the managed region with a
  start-marker version matching the source, and a fresh session of that tool applies a rule present only
  in the new content.
- **SC-002**: Every byte of operator-authored content outside the region is identical before and after —
  zero unintended changes across 3 consecutive runs per fixture, measured rather than assumed.
- **SC-003**: The pre-existing hand-maintained fork is gone from the global configuration, replaced by
  exactly one marked region, with zero duplicated instruction content.
- **SC-004**: Running the adapter twice with unchanged source produces byte-identical output and exactly
  one region.
- **SC-005**: The adapter refuses in 6 of 6 hostile cases: target inside a project tree, single marker,
  markers reversed, unreadable target, a fork span bounded by two or more title-shaped headings, and a
  fork migration without explicit operator confirmation.
- **SC-006**: The drift check correctly reports current, stale, and not-installed across all three
  states, using version strings alone.
- **SC-007**: A backup of the prior configuration exists after any run that wrote, and the target is
  unmodified after any run that failed.

## Assumptions

- The only integration installed today is Claude Code, so it is the first and only adapter this feature
  delivers. Others follow the same declaration shape.
- The tool's global configuration is a Markdown file that accepts HTML comments, so the canonical
  comment-based markers apply and no alternate delimiter mechanism is needed for this target.
- The operator's existing global configuration contains both their own content and an unmarked fork of
  the pre-revision instruction text; replacing the fork while preserving their content is in scope.
- The governing constitution defines the marker format, the update protocol, and the global-only rule;
  this feature implements them rather than restating them.
- Behavioral verification in tools other than Claude Code stays out of scope — their adapters do not
  exist yet.
- English for all persisted artifacts.
