---
Summary: Amendment history for the AI Jedi Constitution — one line per ratified version, newest first, with the full Sync Impact Report of each superseded amendment.
Tags: [#governance #constitution #history #amendments #versioning]
---

# Constitution Amendment History

Extracted from [[constitution]]. Its header comment had reached 214 of 800 lines — 27% of a file
whose own File Architecture rule says to split rather than grow, and the growth was a changelog
rather than governance. Nothing was dropped; it moved here.

The constitution header now carries only the CURRENT amendment's Sync Impact Report. Superseded
reports live below in full, so the reasoning behind every past amendment stays recoverable.

## Version list

- 1.16.0 (2026-07-25): the over-limit clause gained REFUSE as a sanctioned alternative
  to summarizing.
- 1.15.0 (2026-07-25): Principle IX gained the one-time fork migration exception;
  Principle XI sanctioned the PR-per-story exception.
- 1.14.0 (2026-07-25): Principle VI recorded the standing merge authorization.
- 1.13.0 (2026-07-25): Principle VI gained the merge check gate; clean review skips
  the shepherd.
- 1.12.0 (2026-07-25): Principle VI round limit given a concrete default of 3.
- 1.11.0 (2026-07-25): frontmatter fidelity and post-merge branch cleanup folded
  into existing sections.
- 1.10.0 (2026-07-25): Principle VI became an autonomous review-to-merge loop with
  shepherd-diff re-review and explicit autonomy bounds.
- 1.9.0 (2026-07-25): added Principle XII. Operator-Facing README.
- 1.8.0 (2026-07-25): Principle VII baseline corrected — first instruction release
  is 0.0.1; the `V4` generation marker retired.
- 1.7.0 (2026-07-25): added Principle XI. Isolated Parallel Execution.
- 1.6.0 (2026-07-24): added Principle X. Capability-Tiered Agent Materialization.
- 1.5.0 (2026-07-24): Principle IX scope expanded — projections target global
  user-level config only; project-local writes prohibited.
- 1.4.0 (2026-07-24): added Principle IX. Delimited Managed Region.
- 1.3.0 (2026-07-24): added Principle VIII. Executable Agent Provisioning.
- 1.2.0 (2026-07-24): added Principle VII. Versioned Instruction Surface.
- 1.1.0 (2026-07-24): added Principle VI. Automated Post-Implementation Review.
- 1.0.0 (2026-07-24): initial adoption; Principles I–V, Tool Adapter &
  Authoring Constraints, Development Workflow & Quality Gates, Governance.

## Superseded Sync Impact Reports

### v1.17.0 (2026-07-24)

Sync Impact Report
- Version change: 1.16.0 → 1.17.0
- Ratification date unchanged: 2026-07-24
- Modified principles:
  - Tool Adapter & Authoring Constraints — the skill-install/verify and derived-syntax
    obligations gain an explicit no-integration case. Raised by /speckit-analyze against
    feature 005 as CRITICAL: the plan had qualified an unqualified MUST inside a table
    cell and then asserted "no violations" in Complexity Tracking. Four of that feature's
    five targets have no SpecKit integration, so there is no install procedure, no
    manifest, and no separator to derive — the requirement is meaningless for them rather
    than merely inconvenient. That is a gap in the rule, not a justified deviation, and
    Principle VIII already carried the corresponding degradation for an unavailable skill
    while these constraints did not. The adapter must now DECLARE the absence; fabricating
    an integration entry to satisfy the letter of the rule is prohibited, and so is
    silently omitting the fields.
- Superseded report for v1.16.0 — modified principles:
  - Tool Adapter & Authoring Constraints — the over-limit clause required content
    exceeding a target's limit to be SUMMARIZED. It now permits either summarizing or
    REFUSING, with the adapter's declaration required to record which, and states that
    refusing is correct whenever the projection must be verbatim. Raised by
    /speckit-analyze against feature 003 as a CRITICAL conflict: FR-001b had specified
    refusal, which contradicted a constitutional MUST. The reasoning that produced
    FR-001b turned out to be constitution-grade rather than feature-local — a
    summarized region carries the source version while holding different content, so
    the drift check, which compares version strings alone, would report current on a
    region that is not. Summarizing stays available to adapters whose target genuinely
    cannot hold the full content and whose contract does not promise fidelity.
- Superseded report for v1.15.0 — modified principles:
  - Principle IX. Delimited Managed Region — adds the ONE-TIME FORK MIGRATION
    exception, the only permitted reading or rewriting of unmarked operator content.
    Raised by /speckit-analyze against feature 003 as a CRITICAL principle-vs-principle
    conflict: Principle I calls a hand-maintained drifted projection a defect that MUST
    be regenerated, while IX forbade touching anything outside the markers. Unresolved,
    an adapter run would leave the operator holding two copies of the instruction set,
    one stale. The exception is narrow and spent-on-use: report the exact span and the
    signal matched, obtain explicit per-migration operator confirmation, back up first —
    absent any of the three, refuse. An adapter MUST NOT decide autonomously that
    operator content is a fork.
  - Principle XI. Isolated Parallel Execution — the PR-per-story rule gains an explicit
    exception for stories that mutate one artifact or describe one executable's behavior
    and therefore cannot be split. This SANCTIONS a rule that instructions.md line 216
    already carried without constitutional backing — a governance inversion caught by the
    same analyze pass. Invoking it for splittable stories is prohibited.
- Superseded report for v1.14.0 — modified principles:
  - Principle VI. Automated Post-Implementation Review — records the operator's
    STANDING merge authorization: when every gate is clear (review closed with no
    blocking findings, check gate satisfied, branch protection intact) the loop
    completes the merge without asking. Requesting per-merge confirmation is now
    prohibited — asking each time converts the automation into a prompt, the exact
    failure mode this principle exists to prevent. The consent is scoped to the
    merge step ONLY: weakening branch protection, force pushing, deleting an
    unmerged branch, and merging over a blocking finding all remain gated on
    explicit per-instance consent. Bump is MINOR: authorization recorded, no
    existing rule redefined.
- Superseded report for v1.13.0 — modified principles:
  - Principle VI. Automated Post-Implementation Review — two additions. (a) A review
    closing with NO findings now skips the shepherd entirely rather than invoking it
    to do nothing, since a no-op invocation wastes a round and produces a diff that
    step 3 would have to re-review. (b) A Check gate conditions the merge on the
    repository's automated checks, distinguishing four states: green (merge),
    pending (wait, never treat as passing), failing because of the change (a
    finding, back into the loop), and failing for reasons unrelated to the change
    (halt and report — not a code defect, and "fixing" it would mean editing
    unrelated infrastructure, the scope expansion these bounds prohibit). Absent
    workflows are explicitly NOT a blocker: nothing to wait for, so the merge
    proceeds on review approval, with the absence recorded so a reader can tell
    "checks passed" from "no checks existed". Bump is MINOR — guidance materially
    expanded; no existing rule redefined.
- Superseded report for v1.12.0 — modified principles:
  - Principle VI. Automated Post-Implementation Review — the review-shepherd round
    limit now has a concrete default of 3, overridable per feature in plan.md.
    Previously the principle required "a stated maximum" without stating one,
    which made the bound unenforceable and SC-016 unverifiable. Bump is MINOR:
    a number was added where none existed, so guidance is materially expanded
    rather than merely clarified.
- Superseded report for v1.11.0 — modified principles:
  - Principle VI. Automated Post-Implementation Review — gains step 5: after the
    MERGE completes, the pull request's branch is deleted (remote then local) and
    its worktree removed. Explicitly NOT triggered by approval — a branch deleted
    between approval and merge closes the request without landing anything, since
    the branch is what the merge consumes. `main` and operator-designated
    long-lived branches are never deleted by this step.
  - Principle XI. Isolated Parallel Execution — worktree cleanup now also covers
    deleting the merged branch itself.
  - Tool Adapter & Authoring Constraints — frontmatter must be ACCURATE, not merely
    present. `Summary:` must describe what the file currently contains and `Tags:`
    must reflect its actual subject matter, both re-evaluated in the same change
    set as any content change. For `instructions.md`, `Summary:` must agree with
    the directives carried and `Tags:` must cover every capability area present.
  - Structural note: both requests were folded into existing sections rather than
    ratified as Principles XIII and XIV. The constitution is already at ~620 lines
    against a self-imposed 200–400 typical range, and these rules belong to
    sections that already exist. Principle inflation would worsen the atomicity
    tension without adding governance.
- Added sections: none
- Removed sections: none
- Superseded report for v1.10.0 — Principle VI. Automated Post-Implementation
  Review — scope materially expanded
    (not renamed). Trigger becomes pull-request creation as well as end-of-unit.
    The chain becomes an autonomous LOOP that drives the change to merge on `main`
    rather than stopping at "arming automerge". Adds the requirement that the
    shepherd's own diff be re-reviewed before merge, and adds explicit autonomy
    bounds: round limit, no scope expansion, no weakening branch protection, halt
    rather than merge an unconverged change. Bump is MINOR: the chain's ordering
    and freezing rules are unchanged, so nothing previously compliant becomes
    non-compliant.
- Added sections: none
- Removed sections: none
- Standing violation from v1.9.0 CLOSED: `README.md` was created at `b5badcb`.
- Templates requiring updates:
  - ✅ .specify/templates/spec-template.md (no constitution-mandated section added)
  - ✅ .specify/templates/tasks-template.md — Phase N+1 renamed to "Instruction
    Version, Catalog & Region Integrity" and extended with marker-pair presence,
    marker-version match, and outside-region byte-identity verification
    (Principle IX), on top of the Principle VIII catalog/manifest and
    derived-syntax checks. Phase N+2 (Principle VI) unchanged.
  - ✅ .specify/templates/plan-template.md — Constitution Check requires an
    explicit Instruction Version Bump declaration for /speckit-analyze and
    /speckit-converge to audit against (added at v1.2.0; no change needed for
    Principle VIII, whose gate is task-level rather than plan-level)
  - ✅ .specify/templates/checklist-template.md (no change required)
  - ✅ instructions.md — RESOLVED at v0.0.1 (commit `b5badcb`). All 10 previously
    open items closed: tier vocabulary replaces the retired `claude-3-*` identifiers
    (and section 12 now states resolution RULES rather than naming models at all),
    the Principle VI review chain is section 8, the title carries `v0.0.1` with the
    `V4` marker retired, section 13 carries provisioning, invocation syntax is
    derived from `invoke_separator`, the catalog is reconciled against the
    availability source of record with `baseline` formally retired and
    `taskstoissues` plus `agent-context-update` added, the
    `AI-JEDI:INSTRUCTIONS` marker pair wraps the content, section 13 covers agent
    materialization, and section 11 carries worktree isolation and PR organization.
  - ⚠ instructions.md — ONE new pending item from v1.13.0: the check gate added to
    Principle VI is not yet reflected in section 8. Deferred deliberately rather
    than edited now: PR #2 is mid-review-loop and Principle VI prohibits scope
    expansion during it. Carry into a follow-up feature, which will bump the
    instruction version to `0.1.0` (a directive added → MINOR).
  - ✅ README.md — CREATED at `b5badcb`. The Principle XII violation standing since
    v1.9.0 is closed: 155 lines, all 14 capability areas covered, every claim traced
    to a directive, and the untested tools stated as untested.
  - ✅ CLAUDE.md — correctly carries ONLY the `SPECKIT START`/`SPECKIT END`
    pointer region. Principle IX as amended at v1.5.0 prohibits an
    `AI-JEDI:INSTRUCTIONS` region in project-local config, so no change is
    required. This REVERSES the ⚠ item raised at v1.4.0, which had wrongly
    called for adding the region here.
  - ⚠ No adapter exists yet for any installed tool. Global targets observed on
    the operator's machine, for whichever adapter is written first:
    `~/.claude/CLAUDE.md` (exists, currently has no marker pair),
    `~/.config/opencode/opencode.json` (exists, JSON — needs the
    Principle IX non-comment delimiter mechanism), `~/.gemini/GEMINI.md`
    (exists), `~/.config/github-copilot/` (exists),
    `~/.cursor/` (exists), `~/.codex/AGENTS.md` (absent — adapter must create
    or report unconfigured, never fall back to project-local).
  - ✅ specs/001-instructions-quality-revision/ — reconciled against the expanded
    Principle VI: spec.md gained FR-023 and SC-016; data-model.md gained D87…D94;
    tasks.md gained T032q/T032r; quickstart.md Step 8 rewritten as the autonomous
    loop with its bounds. Reconciled against Principle XII
    as well: spec.md gained FR-022 and SC-015; data-model.md gained D84…D86;
    tasks.md gained T041d…T041f creating and auditing the README; quickstart.md
    gained Step 6C. Earlier reconciliation against Principles X
    and XI: spec.md gained FR-018…FR-021 and SC-011…SC-014; data-model.md gained
    directives D64…D83; tasks.md gained T032i…T032p in Phase 5B; plan.md gained the
    Parallel Execution Plan (declaring zero parallel implementation units, since
    the single-file deliverable makes them contend); quickstart.md Step 6B gained
    the tier-vocabulary, agent-materialization, and parallel-rule checks.
  - Detail of the v1.5.0 reconciliation: spec.md gained FR-013…FR-017,
    SC-008…SC-010, and User Story 5;
    plan.md gained the Instruction Version Bump declaration (corrected at v1.8.0
    to the initial release 0.0.1) and
    sections 13–14 of the target order; data-model.md gained directives D55–D63;
    tasks.md gained Phase 5B (US5) plus the catalog-migration and
    finding-resolution tasks; quickstart.md gained Step 6B.
- Deferred TODOs: none
- Operational note: this repository has NO GitHub workflows configured and
  `required_status_checks` on `main` is null. Under the v1.13.0 check gate that is
  the absent-workflows case: not a blocker, merge proceeds on review approval, and
  the absence is recorded in the run log.
- Operational note: `delete_branch_on_merge` is now enabled on the GitHub
  repository, so the remote branch is removed by the platform at merge time.
  Principle VI step 5 still governs the LOCAL branch and the worktree, which the
  platform setting does not touch.
- Operational note: repository now has a GitHub remote
  (github.com/jonyfs/ai-jedi) with `main` protected behind pull requests.
  Principle VI's PR-scoped automation is therefore live; its local-diff
  fallback no longer applies to work pushed to that remote.

Prior version history
