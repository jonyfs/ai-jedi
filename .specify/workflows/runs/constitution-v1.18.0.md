---
Summary: Review-to-merge run log for constitution amendment v1.18.0, which bounded the standing merge authorization to the granting repository.
Tags: [#runlog #constitution #governance #review-chain #merge-scope]
---

# Run Log: Constitution v1.18.0

Amendment source: an assessment of `instructions.md` as a global surface, requested by the operator.

## What the assessment got right, wrong, and what changed

| Finding | Outcome |
|---|---|
| Standing merge authorization is unscoped | **CONFIRMED and elevated.** Not a drafting slip in one file — an emergent product of Principle VI × Principle IX, neither wrong alone. Became this amendment. |
| Section 11 catalog omits installed skills | **RETRACTED.** Counted afterwards: `.claude/skills/` holds exactly the 11 `speckit-*` skills the catalog names. The 26 `specjedi-*` cited were a declaration in the PARENT directory's `CLAUDE.md` — a sibling project, not an installation here. Asserting before counting, again. |
| Orchestrator Mode trigger too broad | Confirmed, but **no constitutional basis exists for that breadth** — it is an `instructions.md` invention, so it needs no amendment. Backlog. |
| `~65% token reduction` unverified | Confirmed. `instructions.md` only. Backlog. |
| `.specify/integration.json` degradation gap | Confirmed. `instructions.md` only. Backlog. |
| Size complaint | **Withdrawn as stated.** 25 KB against 155 KB already loaded from `~/.claude/rules/` — the instruction file is 14% of the load, not the problem. |

## Structural precondition

The constitution stood at exactly 800/800 lines — its own stated maximum — so no amendment could land
without splitting first, which its File Architecture rule prescribes. The header comment was 214 lines,
27% of the file, and the growth was changelog rather than governance: 189 lines were v1.17.0's single
Sync Impact Report. Superseded reports and the version list moved to `constitution-history.md` in full.
800 → 645 → 664 lines. 12 principles intact.

## Round 1 — reviewer

**Verdict: request changes — 1 blocking.**

| ID | Severity | Finding |
|---|---|---|
| B1 | Blocking | The clause bounded the authorization to "THIS repository" while the same Sync Impact Report requires it to propagate into `instructions.md` section 8 — a machine-wide surface loaded everywhere. The deictic resolves correctly only in the file where the rule is not applied. Failure scenario: a fresh session in `barbearia-2.0` loads the propagated clause, reads it while sitting in `barbearia-2.0`, concludes it is authorized, and merges. The amendment would have produced the behaviour it forbids. |

## Round 1 — shepherd

Scope is now a **lookup against the working tree**: a repository is authorized when its own
`.specify/memory/constitution.md` records the grant. Not where the reading agent happens to be. The
rationale states why the deictic form was rejected, so the next author does not reintroduce it.

Also corrected the no-gate bullet, which read as a further halt condition when it describes behaviour
inside an authorized repository: the merge proceeds under the grant, but the run log must record which
protection was absent, so the operator sees that the grant, not a gate, is what allowed it.

## Round 2 — re-review of the shepherd's own diff

30 insertions, 11 deletions, one file. Zero normative deictic uses remain; 664/800 lines; 12/12
principles; no unresolved bracket tokens; version consistent between report and footer; history file
intact at 232 lines.

**Approve — 0 findings.** Rounds used: 2 of 3.

## Check gate

`required_status_checks: null`, zero workflow files — the **no-checks-configured** case. Recorded here
so a later reader can tell "checks passed" from "no checks existed". Merge proceeds on review approval.

Merge authorization: this IS the granting repository under the rule just written — its constitution
records the grant, and `main` carries enforced branch protection (`enforce_admins: true`). The
amendment is self-consistent with the merge that lands it.
