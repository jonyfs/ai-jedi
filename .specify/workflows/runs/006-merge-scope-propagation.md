---
Summary: Run log for the merge-scope propagation feature — baseline, analyze findings, implementation, projection and review loop.
Tags: [#runlog #instructions #merge-authorization #scope #projection #versioning]
---

# Run Log: 006-merge-scope-propagation

## Gate — analyze

Coverage mechanical and clean: all 12 FRs and all 7 SCs map to tasks, no orphans. Two content defects
found, both in my own artifacts, both the vacuous-assertion pattern this project keeps relearning:

| ID | Finding |
|---|---|
| A1 | Quickstart Step 1 PASSES at baseline, and tasks.md asserted that any passing step meant a misread requirement. It is a regression guard, not a RED test — section 8 carries no scope wording yet, so there is no deictic form to find. Reframed, and the expected baseline in T002 now names which steps fail rather than claiming all six do. |
| A2 | Step 3 grepped section 8 for `halt` and matched **6** occurrences already present, all about unrelated-check failures. It would have passed before any edit. Scoped to the new block's own range, where it correctly returns 0 at baseline. |
| A3 | SC-001 said the agent reaches its answer "without consulting any other file" — contradicting FR-001, which requires consulting `.specify/memory/constitution.md`. Corrected to "any other INSTRUCTION file". |

## Phase 1 — Baseline

Reference captured before any edit, so unintended change to untouched content is detectable.

cksum regiao ANTES: 1058269096 25084
linhas ANTES: 420

Quickstart baseline (T002), measured not assumed:

| Step | Baseline | Meaning |
|---|---|---|
| 1 deictic form | 0 — passes | Regression guard, by design |
| 2 lookup present | 0 — FAILS | Rule absent |
| 3 halt in scope block | 0 — FAILS | Block absent |
| 4 Orchestrator trigger | fires on `tasks.md` alone — FAILS | Confirmed by reading the trigger |
| 5 unmeasured percentage | 1 match — FAILS | The `~65%` claim |
| 6 integration.json row | 0 — FAILS | No degradation row |
| 9 ceiling | 420/800 — passes | Headroom for ~25 lines |

## Phases 2–4 — Content

The regression guard earned its place on the first run. Quickstart Step 1 FAILED immediately after
T003–T007, with one match — inside my own explanatory sentence, which quoted the forbidden phrasing to
explain why it is forbidden.

Reworded to describe the form rather than quote it, keeping the guard exemption-free. An exemption
would have been the cheaper fix and the wrong one: a grep with a carve-out is how a real occurrence
eventually hides behind a legitimate one. This project has spent the session removing exactly that
class of assertion.

| Task | Result |
|---|---|
| T008 Steps 1–3 | 0 deictic / 1 lookup / 1 halt-in-block — pass |
| T010 Step 4 | Trigger requires a SpecKit directory; a bare `tasks.md` explicitly excluded |
| T014 Steps 5–6 | 0 unmeasured percentages in section 6; degradation row present |

## Phase 5 — Version bump

`0.1.0` → `0.2.0`, MINOR under Principle VII: a new directive, nothing removed. Title, frontmatter
`Summary`, the `0.0.1` provenance line and the start marker all rewritten. Zero `0.1.0` strings remain.
File at 459/800 lines.

## Phase 6 — Projection

| Check | Result |
|---|---|
| T019 suite BEFORE writing any real config | 72/0/0 claude-code and opencode, 65/0/1 the other three |
| T020/T021 five targets | all `current (v0.2.0)` |
| T022 SC-006 content identical | one cksum, `61663166 28510`, five files |
| T023 OpenCode caveman region | both markers present after the run that rewrote every region |
| T024 SC-007 adapter unchanged | `git diff .specify/adapters/` empty — the version is read from source at run time, confirmed rather than trusted |

Region cksum: `1058269096 25084` before, `61663166 28510` after. The change is the 39 added lines and
the version strings; nothing else moved.
