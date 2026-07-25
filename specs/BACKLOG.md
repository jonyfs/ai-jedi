---
Summary: Standing backlog of decided-but-unstarted work and known deferrals, so items agreed in conversation survive the session that agreed them.
Tags: [#backlog #deferred #roadmap]
---

# Backlog

Decisions made and work deferred, recorded because a decision that lives only in a conversation is a
decision that gets re-litigated. Nothing here is in progress; each item names why it is not.

## Decided, not started

### 004 — Multi-target adapter

**Decision**: extend the adapter mechanism to Cursor, Windsurf, Cline, and GitHub Copilot, generating
their instruction files as marked, versioned projections of `instructions.md`.

**Why it is a separate feature**: feature 003 is scoped to one adapter and has already taken three
`/speckit-analyze` passes, each finding CRITICAL defects caused by late insertions into an artifact set
that had grown past the point of staying self-consistent. Adding four targets to it would repeat exactly
that failure. 004 starts after 003 merges.

**Origin**: the operator invoked `caveman-init`, which writes `AGENTS.md`, `.cursorrules`,
`.windsurfrules`, `.clinerules`, and `.github/copilot-instructions.md` as hand-maintained files.
Principle I names `AGENTS.md` and `.github/copilot-instructions.md` explicitly among the artifacts that
MUST be generated projections and never hand-edited forks, so running it here was rejected. The operator
chose to reach the same outcome through the adapter mechanism instead.

**Note on content**: nothing from `caveman-init` is lost by not running it. The caveman compression
protocol and intensity levels are already `instructions.md` sections 5 and 6, so they reach every target
as a consequence of projecting the source.

## Open tasks that remain open, and why

Five tasks across features 001 and 003 are genuinely unfinished. Every other task in every shipped
feature is now marked, after an audit found 44 completed tasks still showing as open — the repository was
recording finished work as pending, which makes the task lists useless as a signal.

| Task | Feature | Why it cannot be closed here |
|---|---|---|
| T018, T035, T039 | 001 | Behavioral probes needing fresh sessions of Codex, Copilot or OpenCode loading the instruction set as their global config. **No longer blocked** — feature 005 projected v0.1.0 into all five targets, so the configs those sessions would load now exist. What remains is that a probe cannot be self-administered: the session running it already holds the instructions it loaded at start. These are the operator's to run. |
| T036 | 001 | Depends on T035's probe output; nothing to act on until it runs. |

An earlier version of this table listed **T038** among the blocked probes. That was wrong and worth
recording: T038 runs Quickstart Steps 1–5, which are greps against `instructions.md` and need no other
tool at all. It was classified as blocked without being read. Run and passed — 14 sections, zero
`claude-3` identifiers, zero vendor literals outside section 12, 420/800 lines, two wiki links, no
secrets, every governance area represented, four collision pairs resolved by the ladder alone.
| T043 | 003 | Cross-tool confirmation that a fresh session applies a v0.1.0-only rule. Cannot be self-administered by the session that ran the projection, which still holds the instructions it loaded at start. |

## Decided, not started — continued

### Propagate the merge-authorization scope into instructions.md section 8

Constitution v1.18.0 bounded the standing merge authorization to this repository. Section 8 of
`instructions.md` still carries the unscoped version, and section 8 is what every tool on the machine
actually loads — so until this propagates, the amendment governs nothing outside this file.

**Why it is not done in the amendment**: Principle V routes instruction-content changes through
specify → clarify → plan → tasks → implement → converge. Editing section 8 ad hoc from a
`/speckit-constitution` run would violate the principle the amendment exists to strengthen.

**Scope when it runs**: section 8's "Standing merge authorization" block gains the repository-scope
clause and the halt-and-report behaviour outside this repository. Candidate companions, all found in
the same assessment and all cheap once a spec is open:

- Section 11's Orchestrator Mode trigger fires on any `tasks.md` anywhere. Verified: no constitutional
  principle asks for that breadth — it is an instructions.md invention.
- Section 6 states `~65% token reduction` as fact. Never measured. Same class as the `tier_map`
  identifiers corrected in feature 005.
- Section 12 derives invocation syntax from `.specify/integration.json`; section 14's degradation
  table has no row for that file being absent, which is the normal case outside a SpecKit repository.
- `[[README]]` and `[[constitution]]` in section 9 resolve to nothing once projected into a global
  config.

**Retracted from the same assessment, recorded so it is not re-raised**: a claim that section 11's
catalog omits installed skills. Counted afterwards — `.claude/skills/` holds exactly the 11
`speckit-*` skills the catalog names. The 26 `specjedi-*` skills cited were a declaration in the
PARENT directory's `CLAUDE.md`, a sibling project, not an installation here.

## Deferred with reasons

### Adapter hardening — from the PR #5 review

Three findings deliberately not fixed inside the review loop, because each needs its own verification
rather than a same-loop patch:

- **Backup retention.** Every non-current run writes a timestamped full copy into the tool's config
  directory and nothing prunes them. After a year of version bumps that is a pile of stale instruction
  sets. Retention is a design decision — keep N, keep by age, or prune on success — not a review finding.
- **`set -e` conversion.** `project.sh` runs under `set -u` only. The compose block's `head`/`tail`/`sed`
  /`awk` are unchecked, and a truncated output would still pass the post-write verification because
  markers and version would be present. A pre-write length assertion now catches the truncation case;
  converting the whole script to `set -e` is riskier than the defect in a script this branch-heavy and
  needs its own test pass.
- ~~**`shellcheck` findings triage.**~~ **DISCHARGED.** The operator installed shellcheck 0.11.0; the
  lint group switched from SKIPPED to executing and all findings were triaged. Notable: `SC2012` flagged
  the exact `ls`-parsing weakness recorded as N2 in the PR #7 review and dismissed there as unreachable.
  The linter was right — robustness should not depend on nobody creating an awkward filename.

### Feature 001 — 12 open tasks

### Feature 001 — 12 open tasks

Behavioral probes (SC-004, SC-005) require fresh sessions of Codex, Copilot, or OpenCode loading the
instruction set as their global configuration. The adapter blocker is **discharged** — 003 projected
to Claude Code and 005 to the other four, so every one of those tools now has a v0.1.0 region to load.
The remaining constraint is not tooling but self-administration: a session cannot probe the
instructions it started with.

### Feature 002 — section 8 carries six concerns

`instructions.md` section 8 is 118 of 420 lines and holds the loop, the check gate, the standing
authorization, the autonomy bounds, PR organization, and the managed-region update protocol. Not a
violation — the atomicity ceiling is per file — but it weakens the urgency-first ordering feature 001
bought. Raised as M1 during the 002 review loop and deliberately not fixed there: splitting a section
mid-review-loop is the scope expansion Principle VI prohibits.

### Constitution size

758 lines against its own stated 200–400 typical range, after 15 amendments in a single session. Under
the 800 hard maximum, so compliant, but the file mandates "split rather than grow". Extracting the
tooling principles (VII–XII) into a wiki-linked file would be a MAJOR structural amendment. Flagged
three times; the operator has not chosen to act on it.

### FR ID renumbering in feature 003

`spec.md` carries FR-001, FR-001a, FR-001b, FR-015, FR-016, then FR-002–FR-014 — insertion order, not
numeric order. Renumbering mid-feature would churn four files and risk breaking the traceability it aims
to improve. Recorded rather than silently left inconsistent.

## Outside the repository

### Author-email rewrite across 8 repositories

Prepared and verified in a session scratchpad: 44 pre-revision rows rewritten across
`spec-kit-extension-*` (4), `trabalho-josiane`, `spec-jedi`, `professional-design-system`, and
`barbearia`, unifying `jony.ferreira@intelie.com.br` and `jonyfs@users.noreply.github.com` into
`jonyfs@gmail.com`. Never published — the force push across 9 repositories is the operator's action, not
an agent's. The scratchpad clones are discardable if the operator has dropped the intent.
