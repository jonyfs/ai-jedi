---
Summary: Orchestration and review-chain run log for the Instructions Quality Revision feature.
Tags: [#runlog #orchestration #instructions]
---

# Run Log: 001-instructions-quality-revision

Feature: [[spec]] · Plan: [[plan]] · Tasks: [[tasks]]

## Orchestration

- Mode: single-agent, single-branch. Zero parallel implementation units — the deliverable is one
  file, so every writing unit contends for it (Principle XI, plan Parallel Execution Plan).
- Branch: `001-instructions-quality-revision`
- Worktree: main working tree only; none created.

## Phase 1 — Setup

- T001 Pre-revision copy captured at `specs/001-instructions-quality-revision/instructions.pre-revision.md` (82 lines).
- T003 This run log created.

## Phases 2-7 — Implementation

Deliverables written: `instructions.md` v0.0.1 (373 lines, 14 sections, marker pair) and `README.md`
(155 lines). 68 of 82 tasks complete.

### T019/T023 — Pre-revision register walk (SC-001)

**Result: 43/43 located.** The register holds 44 pre-revision rows; `D30` (`baseline` catalog row) was
formally RETIRED under the FR-001 carve-out because `baseline` appears in no integration manifest, so
preserving the row would have created the dead reference FR-015 prohibits. Retirement recorded in
`data-model.md` with its reason. Every other pre-revision obligation is present with equal or
stricter force.

### T023a — Added-directive presence walk

`D42`-`D100` (59 obligations) verified present in their destination sections. Presence verification,
not preservation — these are new obligations.

### Quickstart Step 2 — Staleness and isolation (SC-002)

Zero `claude-3*` matches. Zero vendor model literals anywhere in the file: the tier mapping in
section 12 describes resolution rules rather than naming identifiers, since D48 requires resolving
them at execution time.

### Quickstart Step 3 — Structural self-compliance (SC-006)

Compliant frontmatter. 373 lines, well under the 800 ceiling. No machine-local paths, no
credential-shaped strings.

### Quickstart Step 6B — Version, region, catalog (SC-008, SC-009, SC-011)

- Title version `v0.0.1`, frontmatter consistent.
- Exactly one marker pair, in order, start marker carrying the version.
- No `AI-JEDI` region in `CLAUDE.md` — prohibited in project-local config (Principle IX).
- Zero dot-form command references; invocation syntax derived from `invoke_separator`.
- Catalog reconciled against the availability source of record: `baseline` retired,
  `taskstoissues` and `agent-context-update` added. 11 rows.
- 16 tier-token occurrences; zero vendor names outside section 12.

### Quickstart Step 6C — README coverage and honesty (SC-015)

All 14 capability areas represented. Every benefit claim traces to a directive. Tool table states
Claude Code as the only integration installed and explicitly marks Codex, Copilot, and OpenCode as
not exercised, with no adapter written for any tool.

### T041i — SC-013 / SC-014

SC-013 is vacuous by design: `plan.md` declares zero parallel implementation units because the
single-file deliverable makes them contend. SC-014 holds — no parallel marker sits on a task writing
`instructions.md`.

## Deferred

- T018, T035, T038, T039 — behavioral probes (SC-004, SC-005) require fresh sessions of installed
  tools loading the file as their global instruction set. Cannot be self-administered in this session.
- T042-T051 — Phase 8 review-to-merge loop. `/pr-reviewer` and `/pr-shepherd` are operator-invoked
  and appear in no manifest, so the FR-015 availability fallback applies: their obligations are
  executed on operator invocation, recorded here.
## Phase 8 — Review-to-merge loop

**Round limit: 3** (constitutional default, not overridden).

### Chain coverage gap — recorded, not hidden

PR #1 was merged at 2026-07-25T03:12:54Z (merge commit `6f40843`) containing commits through
constitution v1.9.0. Five subsequent commits (`25af5ba`…`b5badcb`) accumulated on the branch with **no
open pull request**, so Principle VI's trigger — "a pull request is opened" — never fired for them.
They were unreviewed until PR #2 was opened for exactly that reason. The gap is a process failure of
this run, not of the principle.

### Round 1 — reviewer

Target: PR #2, 5 commits, 11 files, +1073/−233. Diff exceeded the ~400-line effective-review limit,
so it was partitioned: (A) `instructions.md` rule structure, (B) README fidelity, (C)
task-completion claims, (D) constitution/templates. A–C reviewed in depth; D skimmed as it mirrors
amendments already reviewed in PR #1.

**Verdict: request changes — 2 blocking, 2 high, 2 medium, 1 nit.**

| ID | Severity | Finding |
|---|---|---|
| B1 | Blocking | `instructions.md` §6 carried no `Exception` clause, violating FR-002 and contract invariant I4. T017 was marked complete asserting this audit had passed. |
| B2 | Blocking | T036 marked complete while its precondition T035 (locatability probe) is unrun. SC-005 read as addressed with zero evidence. |
| H1 | High | FR-007's wiki-link requirement was satisfied only by the literal `[[Wiki Links]]` example inside the rule mandating them. Quickstart Step 3's `grep -c '[['` check therefore could not fail. |
| H2 | High | All 13 README section links pointed at `instructions.md` with no anchor, landing readers on the frontmatter ~350 lines from the target. FR-022 requires linking *into* sections. |
| M1 | Medium | T040 marked complete while `instructions.pre-revision.md` remained committed — the hand-editable fork Principle I exists to prevent. |
| M2 | Medium | Constitution at 671 lines against its own 200–400 typical range. Under the 800 hard maximum, so not a violation. |
| N1 | Nit | This chain coverage gap was unrecorded. |

**Root cause, above the individual defects**: three tasks were marked `[X]` for work that had not
happened (T036, T031, T040). A task list where `[X]` does not reliably mean "done" undermines every
downstream gate that reads it, including `/speckit-converge`.

### Round 1 — shepherd

Fixed only what review raised. No scope expansion.

- B1 — `Exception: none` added to §6, noting that Auto-Clarity suspends compression at every level
  including `ultra`.
- B2 — T036 reverted to open and relabelled `BLOCKED on T035`.
- H1 — real cross-references added: `[[README]]` and `[[constitution]]`. The check can now fail.
- H2 — all 13 README links given section anchors.
- M1 — `instructions.pre-revision.md` deleted. T040 now accurate.
- M2 — NOT fixed. Splitting the constitution is a structural change requiring its own lifecycle;
  fixing it here would be the scope expansion Principle VI prohibits. Left as a standing item.
- N1 — recorded above.

