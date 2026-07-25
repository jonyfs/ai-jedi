---
Summary: Implementation plan for the first adapter — a shell script projecting instructions.md into the Claude Code global config, replacing the existing unmarked fork while preserving operator content byte-for-byte.
Tags: [#plan #adapter #projection #claude-code]
---

# Implementation Plan: Claude Code Adapter

**Branch**: `003-claude-code-adapter` | **Date**: 2026-07-25 | **Spec**: [[spec]] — `specs/003-claude-code-adapter/spec.md`

**Input**: Feature specification from `specs/003-claude-code-adapter/spec.md`

## Summary

Deliver `.specify/adapters/claude-code/` — a declaration file plus an idempotent shell script that
projects the content between `instructions.md`'s markers into the operator's global Claude Code
configuration, wrapped in its own marker pair carrying the source version. The target already contains
an unmarked fork of the pre-revision content; the script replaces exactly that span and leaves every
other byte identical, after taking a backup.

This is the first artifact in the project that makes `instructions.md` configure anything.

## Technical Context

**Language/Version**: POSIX shell (`sh`), matching the `script: "sh"` already recorded in
`.specify/init-options.json`. No new runtime dependency.

**Primary Dependencies**: `git` (working-tree detection), standard POSIX text tools. Deliberately no
`jq`, `python`, or `node` — the adapter must run on a machine where the instruction set is being
installed for the first time.

**Storage**: Plain files. Target is the operator's global config; backups sit beside it.

**Testing**: Executable, so TDD applies (constitution: "Where a change is executable, TDD applies").
Test fixtures under `.specify/adapters/claude-code/tests/` covering every FR, run against temporary
files — **never** against the operator's real config.

**Target Platform**: The operator's machine. Claude Code global config is a Markdown file accepting HTML
comments.

**Project Type**: Adapter / projection tool

**Performance Goals**: Irrelevant — a single file rewrite. Correctness is the only axis.

**Constraints**: Byte-identity outside the managed region (FR-005) is the hard constraint everything
else serves. No secrets, no operator-identifying data, no machine-local paths committed (Principle IX
authoring constraints) — the target path is resolved at runtime from the home directory, never hardcoded
into a committed file.

**Scale/Scope**: One adapter, one tool. Thirteen implementation tasks across four phases and ten test groups — the line count is not estimated here, because an early guess of ~150 was already outgrown by the requirements and a stale estimate is worse than none. Other tools' adapters are out of
scope and follow the same declaration shape.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|---|---|---|
| I. Single Source of Truth | Projection generated, never hand-edited | PASS — this feature CREATES the first projection and, in doing so, closes an active violation: the target currently holds a hand-maintained fork |
| II. Multi-Tool Portability | Adding a tool means adding an adapter, not rewriting content | PASS — the adapter reads the source verbatim; all Claude-Code-specific values live in its declaration file |
| III. Language Duality | Artifacts in English | PASS |
| IV. Token Density with Auto-Clarity | N/A to executable code; applies to its output messages | PASS |
| V. Spec-Driven Change | Full lifecycle | PASS — spec exists, this is the plan step, analyze gates implementation |
| VI. Automated Post-Implementation Review | Loop, round limit 3, check gate, post-merge cleanup | PASS — governs this feature's own pull request |
| VII. Versioned Instruction Surface | Bump declared before implementation | PASS — **N/A, and that is the point**: this feature adds no instruction content. See the bump declaration below |
| VIII. Executable Agent Provisioning | Catalog/manifest agreement | PASS — no catalog change |
| IX. Delimited Managed Region | Marker pair, global-only target, exact update protocol | PASS — this feature IMPLEMENTS the principle. FR-002 through FR-014 are its clauses made executable |
| X. Capability-Tiered Agent Materialization | Tier vocabulary | PASS — no catalog or tier change |
| XI. Isolated Parallel Execution | Worktree isolation, dependency-order merge | PASS — see the Parallel Execution Plan below |
| XII. Operator-Facing README | README covers every capability, claims directive-backed | PASS — the README currently says "No adapter has been written for any tool yet". That becomes false on merge and MUST be corrected in the same change set; task-tracked |
| Authoring constraints | Adapter declares target, path, format, limits; idempotent; managed region delimited | PASS — FR-001, FR-004, FR-008 |

**Instruction Version Bump**

- Current version: `0.1.0`
- Declared bump: **N/A — no instruction content is edited.**
- Justification: this feature adds an adapter, not a directive. `instructions.md` is read, not written.
  Principle VII's bump obligation triggers on instruction-content changes; there is none here.
- Consequence worth stating: the projection this adapter writes will carry `v0.1.0`, because that is the
  source version at merge time. The adapter does not choose a version — it copies one.

**Parallel Execution Plan** (Principle XI)

- Units eligible for parallel dispatch: **the test suite and the script are genuinely separable**, but
  TDD forbids running them in parallel — the test must exist and fail before the code. Serial by
  methodology, not by contention.
- Genuinely parallel: the declaration file, the README correction, and the run log all touch different
  files from the script.
- Worktree/branch per unit: not applicable at this size. Single branch.
- Merge order: single branch; dependency order is task order.
- PR granularity: one pull request. The four stories describe one script's behavior and cannot ship
  independently. This invokes the PR-per-story exception in Principle XI — which `instructions.md` line
  216 already carried but the constitution did not sanction until v1.15.0 (current: v1.16.0). That governance inversion was
  caught by `/speckit-analyze` and fixed in the constitution, not papered over here.

Post-Phase 1 re-check: PASS. No violations; no Complexity Tracking entries required.

## Design Decisions

**Shell, not a richer language.** The adapter must run when the instruction set is first installed on a
machine, which is precisely when no project toolchain is guaranteed. POSIX `sh` plus `git` is the
smallest dependency set that can do the job, and `script: "sh"` is already this project's recorded
convention.

**The target path is resolved, never committed.** Principle IX's authoring constraints forbid
machine-local paths in committed files, and the repository is public. The declaration file records the
path as a home-relative pattern; the script expands it at runtime. A committed absolute path would leak
the operator's username.

**Replacing the unmarked fork is the interesting case, not the empty one.** The target today holds
operator content (an import and a personal section) followed by an unmarked copy of the pre-revision
instruction text. The script must recognise that span as replaceable without markers to guide it. The
chosen signal is the source's own H1 title pattern: the fork begins at a heading matching the
instruction title's shape and runs to end-of-file. FR-006 requires reporting the replaced span so the
operator can audit the judgment.

**The title shape, literally.** The signal is an H1 whose text ends in a colon after a semantic version:
the ERE `^# .* v[0-9]+\.[0-9]+\.[0-9]+:` — plus, for the pre-versioned fork already in the target, the
generation-marker form `^# .* V[0-9]+:`. Both are recorded in `adapter.yml` so the script and its fixtures
read one source. Without a literal pattern, "exactly one match" is not a testable predicate and T017's
fixtures could not be written deterministically.

The bounding predicate is concrete rather than a matter of confidence: **exactly one** heading matching
either pattern, extending to end-of-file. Zero matches means there is no fork. Two or more
means the script cannot tell which one is the fork, and refuses. An earlier draft said "cannot bound
confidently", which no fixture could falsify; this version can be tested.

**The fork migration is a sanctioned exception, not a convenience.** Principle IX forbids reading or
rewriting content outside the markers; Principle I calls a hand-maintained drifted projection a defect
that must be regenerated. The fork in the target is both. `/speckit-analyze` raised this as a CRITICAL
conflict, and it was resolved by amending the constitution (v1.15.0) rather than by asserting an
exception in this plan — Governance says the constitution wins, so the plan cannot grant itself relief.
The exception is narrow: report the span and the signal, obtain explicit per-migration confirmation, back
up first. Absent any of the three, refuse. The adapter never decides on its own that operator content is
a fork.

**The size limit has a real source, and it is not the vendor.** Claude Code documents no size limit for
its global configuration file, so declaring one from the vendor is impossible. The limit that actually
applies is the project's own: the authoring constraints cap any file at 800 lines. `adapter.yml` therefore
declares `size_limit: 800` sourced from those constraints rather than from a vendor document, and the
declaration says so — **and declares that the limit applies to the RESULTING FILE TOTAL, not to the
projected content alone**. The two differ by however much operator content the target already holds, and
comparing projected content against a file-derived cap would measure a different quantity than the limit's
source. Today the target would land near 418 lines, so the check is benign; it would still be wrong by
construction.

This choice is sanctioned by constitution v1.16.0, which permits an adapter to refuse rather than
summarize and requires the declaration to record which — see the amendment raised by the pass-4 analyze
finding. A limit declared as unbounded would make FR-001b's refusal branch unreachable and
T018's size case vacuously green — the check would test nothing.

**Backup before write, always.** FR-011. The target is a file the operator owns and did not expect a
repository to modify. A timestamped copy beside it is cheap; losing hand-written global configuration
is not recoverable.

**Self-modification is disclosed, not solved.** Writing the file changes the instructions governing the
session that ran the script. The script cannot avoid this — it can only say so. FR-012 makes the
disclosure an obligation.

## Project Structure

### Documentation (this feature)

```text
specs/003-claude-code-adapter/
├── plan.md              # This file
├── quickstart.md        # Phase 1 output — validation guide
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (/speckit-tasks)
```

Deliberately absent: `research.md` — the protocol is fully specified by Principle IX, nothing to
research. `data-model.md` — the entities are four states and a file span, defined in the spec.
`contracts/` — the adapter declaration file IS the contract, and it ships as code rather than as a spec
artifact.

### Source Code (repository root)

```text
.specify/adapters/claude-code/
├── adapter.yml          # Declaration: target tool, path pattern, format, size limit
├── project.sh           # The projection script
└── tests/
    └── run-tests.sh     # Fixture-driven suite, one case per FR
instructions.md          # Read-only source
README.md                # "No adapter written" claim corrected
.specify/workflows/runs/003-claude-code-adapter.md
```

**Structure Decision**: Adapters live under `.specify/adapters/<tool>/` — one directory per tool, each
self-contained with its declaration, script, and tests. This is the first, and the layout is chosen so
the second requires no restructuring: adding a tool means adding a sibling directory.

## Complexity Tracking

No Constitution Check violations. Section not applicable.
