<!--
Sync Impact Report
- Version change: 1.0.0 → 1.1.0
- Ratification date unchanged: 2026-07-24
- Modified principles: none renamed or redefined
- Added sections:
  - Principle VI. Automated Post-Implementation Review
- Removed sections: none
- Templates requiring updates:
  - ✅ .specify/templates/plan-template.md (Constitution Check gates resolve to
    this file; no structural edit required)
  - ✅ .specify/templates/spec-template.md (no constitution-mandated section added)
  - ⚠ .specify/templates/tasks-template.md — Principle VI adds a mandatory
    post-implementation review/shepherd task category not yet reflected in the
    template's task groupings
  - ✅ .specify/templates/checklist-template.md (no change required)
  - ⚠ instructions.md — (a) model IDs in the SpecKit Skill Catalog reference
    retired `claude-3-*` names; Principle II requires vendor-current identifiers,
    (b) Execution Guardrails do not yet mention the Principle VI review chain
- Deferred TODOs: none
- Operational note: the repository is not yet a git repository and has no GitHub
  remote. Principle VI's PR-scoped automation activates once one exists; until
  then its local-review fallback applies.

Prior version history
- 1.0.0 (2026-07-24): initial adoption; Principles I–V, Tool Adapter &
  Authoring Constraints, Development Workflow & Quality Gates, Governance.
-->

# AI Jedi Constitution

AI Jedi maintains `instructions.md`: a single, portable, global instruction set that
configures every AI coding tool installed on the operator's machine.

## Core Principles

### I. Single Source of Truth

`instructions.md` at the repository root is the ONLY authoritative instruction text.
Every tool-specific artifact (`CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`,
`opencode.json`, and any future equivalent) MUST be a generated or explicitly linked
projection of `instructions.md` — never a hand-edited fork. Behavior changes MUST be made
in `instructions.md` first and then propagated. Any projection that has drifted from the
source is a defect and MUST be regenerated, not patched in place.

Rationale: N hand-maintained copies guarantee N divergent behaviors; one source with
mechanical projection guarantees identical behavior across tools.

### II. Multi-Tool Portability

Instruction content MUST be expressed in tool-neutral terms and MUST be adaptable to every
installed AI tool — Claude Code, Codex, GitHub Copilot, OpenCode, and any tool added later.
Adding support for a new tool MUST NOT require rewriting instruction content, only adding an
adapter that knows that tool's file path, format, and size limits. Vendor-specific values
(model identifiers, slash-command syntax, config keys) MUST be current and MUST be isolated
in adapter-scoped sections so they can be updated without touching shared content.

Rationale: A global instruction set that only works in one harness is a local instruction set.

### III. Language Duality (NON-NEGOTIABLE)

Conversational replies MUST use the language the operator wrote in. Every persisted artifact
— instruction files, specs, plans, tasks, code, comments, commit messages, documentation —
MUST be written in English. Translation happens at the conversation boundary, never in the
repository.

Rationale: Operator comfort in dialogue and machine/collaborator portability in storage are
different requirements; conflating them corrupts one or the other.

### IV. Token Density with Auto-Clarity

Output MUST drop articles, filler, pleasantries, and hedging while preserving all technical
substance; code blocks, error strings, API names, and CLI commands MUST be reproduced
verbatim. Never invent new abbreviations. Compression MUST be suspended and full, precise
prose used for: security warnings, irreversible-action confirmations, and any ordered
sequence where fragments create execution ambiguity. Compression resumes once the high-risk
block ends.

Rationale: Density is free until it costs correctness; the exceptions mark exactly where it
starts costing correctness.

### V. Spec-Driven Change (NON-NEGOTIABLE)

Changes to `instructions.md` or to any adapter MUST progress through the SDD lifecycle:
specify → clarify → plan → tasks → implement → converge. Ad-hoc edits to instruction content
outside this lifecycle are prohibited for anything beyond a typo fix. Multi-step milestones
MUST be delegated to sub-agents with isolated context. `/speckit-analyze` MUST run and report
convergence before implementation of any large feature begins.

Rationale: Instructions are the control plane for every downstream agent; an unreviewed edit
here silently changes every future session.

### VI. Automated Post-Implementation Review

Implementation is not complete when code is written; it is complete when review has closed
and the change is mergeable. As soon as an implementation unit lands, the review chain MUST
run automatically, without the operator asking for it:

1. `/pr-reviewer` MUST run first and produce a severity-ranked, evidence-based verdict.
2. `/pr-shepherd` MUST run only after the review closes, and MUST resolve review comments,
   merge conflicts, and failing checks before arming automerge or handing off.

Running the shepherd before the review has closed is prohibited — it would shepherd an
unreviewed change. CRITICAL findings from `/pr-reviewer` freeze the branch: `/pr-shepherd`
MUST NOT arm automerge until they are resolved. The operator MAY skip the chain only by
saying so explicitly for that specific change; silence is consent to run it.

When no GitHub pull request exists (no remote, or work still local), the chain degrades
rather than being skipped: `/pr-reviewer` runs against the local diff, and the shepherd step
is deferred and recorded as pending in the run log under `.specify/workflows/runs/`.

Rationale: An automation that must be remembered is an automation that gets skipped exactly
on the rushed changes that most needed it.

## Tool Adapter & Authoring Constraints

- Every adapter MUST declare: target tool, output path, format, and any tool-imposed size or
  syntax limits. Content exceeding a target's limit MUST be summarized by the adapter, not
  truncated arbitrarily.
- Adapters MUST be idempotent: re-running an adapter with unchanged source MUST produce a
  byte-identical output file.
- Adapters MUST NOT overwrite operator-authored content outside their managed region. Managed
  regions MUST be delimited by explicit markers.
- Every persisted Markdown artifact MUST open with frontmatter carrying `Summary:` (one
  sentence) and `Tags:`.
- Files MUST stay atomic and focused: 200–400 lines typical, 800 lines maximum. Split rather
  than grow.
- Cross-file dependencies MUST be expressed as `[[Wiki Links]]`.
- Secrets MUST NEVER appear in instruction files or adapter outputs.

## Development Workflow & Quality Gates

- Changes are made incrementally in targeted zones. Unchanged files MUST NOT be rewritten.
- Where a change is executable (scripts, adapters), TDD applies: write the failing test,
  observe the failure, write minimal passing code, commit.
- Code review MUST audit the diff against the task plan and report findings by severity.
  CRITICAL findings freeze the branch until resolved.
- The Principle VI review chain (`/pr-reviewer` then `/pr-shepherd`) MUST be triggered
  automatically at the end of every implementation unit. Its outcome — verdict, findings,
  and shepherd state — MUST be recorded in the run log.
- Orchestration state and logs MUST be persisted under `.specify/workflows/runs/` so an
  interrupted run can resume.
- After any change to `instructions.md`, all adapter outputs MUST be regenerated and verified
  in the same change set. A merge that updates the source without its projections is
  incomplete.

## Governance

This constitution supersedes all other practices in this repository. Where a rule here
conflicts with `instructions.md`, this file wins and `instructions.md` MUST be amended.

Amendments MUST be proposed as a change to this file, MUST state the rationale, and MUST
include the propagation plan for affected templates and adapters.

Versioning follows semantic versioning:

- MAJOR: a principle is removed or redefined in a backward-incompatible way.
- MINOR: a principle or section is added, or guidance is materially expanded.
- PATCH: clarification, wording, or typo fixes with no semantic change.

Compliance review: every pull request MUST verify adherence to Principles I–VI. Complexity
that violates a principle MUST be justified in the plan's Complexity Tracking section or
removed. Runtime development guidance lives in `instructions.md`.

**Version**: 1.1.0 | **Ratified**: 2026-07-24 | **Last Amended**: 2026-07-24
