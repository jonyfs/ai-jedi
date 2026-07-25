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

Six tasks across features 001 and 003 are genuinely unfinished. Every other task in every shipped
feature is now marked, after an audit found 44 completed tasks still showing as open — the repository was
recording finished work as pending, which makes the task lists useless as a signal.

| Task | Feature | Why it cannot be closed here |
|---|---|---|
| T018, T035, T038, T039 | 001 | Behavioral probes needing fresh sessions of Codex, Copilot or OpenCode loading the instruction set as their global config. Blocked until feature 005 projects to them. |
| T036 | 001 | Depends on T035's probe output; nothing to act on until it runs. |
| T043 | 003 | Cross-tool confirmation that a fresh session applies a v0.1.0-only rule. Cannot be self-administered by the session that ran the projection, which still holds the instructions it loaded at start. |

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
instruction set as their global configuration. **Blocked on adapters**: with no projection, there is
nothing for those tools to load. Unblocked by 003 for Claude Code and by 004 for the rest.

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
