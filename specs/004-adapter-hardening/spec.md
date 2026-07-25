---
Summary: Specification for hardening the live Claude Code adapter — bounded backup retention, checked failure paths, and static linting — before the mechanism is replicated to other tools.
Tags: [#spec #adapter #hardening #retention #linting]
---

# Feature Specification: Adapter Hardening

**Feature Branch**: `004-adapter-hardening`

**Created**: 2026-07-25

**Status**: Draft

**Input**: Three findings from the PR #5 review were deliberately deferred rather than patched inside a
review loop: unbounded backup retention, unchecked failure paths in the compose block, and a shell
script that has never been linted. The adapter is now live in the operator's global configuration, so
these are risks in production rather than hypotheticals — and replicating the mechanism to six more
installed tools would multiply any defect in it.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Backups stay bounded (Priority: P1)

The operator runs the adapter across many version bumps. Their tool configuration directory does not
accumulate an unbounded pile of full instruction-set copies.

**Why this priority**: this one is already accruing. Every non-current run writes a timestamped full copy
into the directory the tool reads from, and nothing removes any of them. Left alone it grows for as long
as the project ships versions.

**Independent Test**: run the adapter more times than the retention limit against a fixture and confirm
the number of backups stops growing, with the newest kept.

**Acceptance Scenarios**:

1. **Given** fewer backups than the limit, **When** the adapter writes, **Then** a new backup is added
   and none is removed.
2. **Given** exactly the limit, **When** the adapter writes, **Then** the oldest is removed and the count
   stays at the limit.
3. **Given** a pruning failure, **When** the adapter runs, **Then** the projection still succeeds — a
   housekeeping failure MUST NOT block the operation it was housekeeping for.
4. **Given** backups belonging to other tooling in the same directory, **When** pruning runs, **Then**
   only files matching this adapter's own pattern are considered.

---

### User Story 2 - A silent failure cannot produce a valid-looking projection (Priority: P1)

If a step inside the adapter fails without being noticed, the operator's configuration is not left
holding a truncated instruction set that passes every structural check.

**Why this priority**: the existing post-write verification checks markers, ordering, and version — all
of which a truncated file retains. Structural validity is not content validity, and the gap is invisible
by construction.

**Independent Test**: inject a failure into a compose step and confirm the adapter refuses or rolls back
rather than writing a structurally valid but incomplete region.

**Acceptance Scenarios**:

1. **Given** a compose step that fails, **When** the adapter runs, **Then** it refuses before writing and
   the target is byte-unchanged.
2. **Given** a truncated composition that would still carry valid markers and the right version,
   **When** verification runs, **Then** it is rejected on content grounds, not accepted on structural
   ones.
3. **Given** every step succeeding, **When** the adapter runs, **Then** behavior is unchanged from today
   — hardening MUST NOT alter the success path.

---

### User Story 3 - The shell is statically checked (Priority: P2)

The adapter's shell files are linted, and the lint runs wherever the suite runs.

**Why this priority**: below the others because it finds classes of defect rather than a known live one.
Still real: this project has already shipped two shell bugs that a linter would plausibly have caught —
an assignment to a reserved variable name, and a platform-specific flag.

**Independent Test**: run the suite on a machine with the linter and confirm the lint group reports
findings; run it without and confirm the group reports skipped, not passed.

**Acceptance Scenarios**:

1. **Given** the linter is installed, **When** the suite runs, **Then** the lint group executes and its
   result is part of the suite's verdict.
2. **Given** the linter is absent, **When** the suite runs, **Then** the group reports SKIPPED explicitly
   and is not counted as a pass.
3. **Given** a lint finding, **When** it is a false positive for this codebase, **Then** it is suppressed
   with an inline justification rather than by disabling the check globally.

---

### Edge Cases

- The retention limit is reached on the very first run because backups already exist from before the
  policy: pruning applies to what it finds, not only to what it created.
- A backup is unreadable or undeletable: report and continue — never abort the projection.
- The linter is installed but a different major version reports different rules: the suite records the
  version it ran so a differing result is attributable.
- Pruning must never consider the live target itself, only files matching the backup pattern.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The adapter MUST retain a bounded number of backups, with the limit declared in the adapter
  declaration rather than hardcoded.
- **FR-002**: Pruning MUST remove the oldest backups first and MUST consider only files matching this
  adapter's declared backup pattern — never the live target, never another tool's files.
- **FR-003**: A pruning failure MUST NOT fail the projection. Housekeeping is subordinate to the
  operation it serves.
- **FR-004**: The adapter MUST verify that its composed output actually carries the projected content,
  not merely that the result is structurally well-formed. A truncated composition MUST be rejected.
- **FR-005**: The hardening MUST NOT change behavior on the success path — a run that succeeds today
  MUST produce byte-identical output afterward.
- **FR-006**: The test suite MUST include a static-analysis group that executes when the linter is
  present and reports SKIPPED, never PASSED, when it is absent.
- **FR-007**: Suppressing a lint finding MUST be inline and justified at the site, never a global
  disabling of the rule. **Deferred, with reason**: the linter is not installed on this machine, so no
  task in this feature can produce a finding to suppress. The rule is stated now so it governs whoever
  first runs the linter; a task that pretended to triage findings it could not generate would be worse
  than an honest deferral.
- **FR-008**: The suite MUST record which linter version produced a result, so a differing result on
  another machine is attributable.

### Key Entities

- **Backup set**: files in the target's directory matching the declared pattern. Ordered by age.
  Pruned from the oldest.
- **Retention limit**: a declared count, not a hardcoded one.
- **Composition check**: content-based verification, distinct from the structural verification that
  already exists.
- **Lint group**: a suite group with three outcomes — pass, fail, skipped — where skipped is not pass.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After running the adapter more times than the retention limit, the backup count equals the
  limit and the newest is present.
- **SC-002**: A pruning failure leaves the projection successful, across all three injected failure
  modes: an undeletable backup, an unreadable backup, and a pruning step that exits non-zero.
- **SC-003**: A rejected composition leaves the target byte-unchanged, across all three injected modes:
  truncation, empty output, and a compose step exiting non-zero.
- **SC-004**: Output on the success path is byte-identical before and after this feature.
- **SC-005**: With the linter absent, the lint group reports SKIPPED and the suite's pass count does not
  include it.
- **SC-006**: Zero lint findings remain unaddressed — each is either fixed or suppressed inline with a
  stated reason. **Deferred alongside FR-007**: unmeasurable until the linter runs. Tracked in
  `specs/BACKLOG.md` rather than left as a success criterion no task can satisfy.

## Assumptions

- The declaration already records the backup filename pattern, so pruning has a pattern to match without
  inventing one.
- `shellcheck` is the linter. It is not installed on this machine, so the skipped path is the one that
  will actually be exercised here, and the executing path is verified wherever it is installed.
- The existing post-write verification stays as it is; the content check is added alongside rather than
  replacing it.
- No instruction content changes, so no instruction version bump applies.
- English for all persisted artifacts.
