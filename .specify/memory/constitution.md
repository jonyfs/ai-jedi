<!--
Sync Impact Report
- Version change: 1.13.0 → 1.14.0
- Ratification date unchanged: 2026-07-24
- Modified principles:
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

Implementation is not complete when code is written; it is complete when the change has merged.
The review chain MUST run automatically, without the operator asking for it, and MUST drive the
change to merge autonomously.

**Trigger**: opening a pull request. The chain also triggers at the end of an implementation unit
when no pull request exists yet. Both entry points are automatic.

**The loop**, repeated until the change merges or the chain halts:

1. `/pr-reviewer` produces a severity-ranked, evidence-based verdict.
2. If findings exist, `/pr-shepherd` runs — only after the review closes — and resolves review
   comments, merge conflicts, and failing checks.
3. **The shepherd's own diff MUST be re-reviewed.** Its edits are code no reviewer has seen; merging
   them on the strength of the previous review would defeat the chain. Return to step 1.
4. When a review closes with **no findings**, the shepherd has nothing to resolve and MUST be
   skipped entirely — invoking it to do nothing wastes a round and produces a diff to re-review. The
   merge is armed directly, and the change lands on `main` through the pull request, subject to the
   check gate below.
5. **After the merge completes**, the pull request's branch MUST be deleted — remote first, then any
   local copy — and its worktree removed per Principle XI.

Branch deletion is triggered by the MERGE, never by the approval. Approval is not integration: a
branch deleted between approval and merge closes the pull request without landing anything, because
the branch is what the merge consumes. An approved-but-unmerged branch MUST survive.

- Deletion MUST NOT run while the pull request is open, whatever its review state.
- A branch that failed to merge MUST be preserved along with its pull request, so the work is
  recoverable.
- `main`, and any long-lived branch the operator designates, MUST NEVER be deleted by this step.

**Standing merge authorization.** The operator has granted standing consent for the loop to complete
the merge whenever every gate is clear — review closed with no blocking findings, the check gate
satisfied, and branch protection intact. No per-merge confirmation is required or MUST be requested.
Asking again each time converts an automation into a prompt, which is the failure mode this principle
exists to prevent.

The consent covers the merge step only. It does NOT extend to: weakening branch protection, force
pushing, deleting an unmerged branch, or merging with a blocking finding open. Those remain gated on
explicit per-instance consent regardless of this authorization.

Running the shepherd before the review has closed is prohibited — it would shepherd an unreviewed
change. CRITICAL findings freeze the branch: automerge MUST NOT be armed until they are resolved.
The operator MAY skip the chain only by saying so explicitly for that specific change; silence is
consent to run it.

**Check gate.** The merge is conditioned on the repository's automated checks. The four states mean
different things and MUST be treated differently:

- **All required checks green** — merge proceeds. Normal path.
- **Any check pending or queued** — WAIT. Do not merge; do not treat pending as passing. A merge armed
  before checks settle is a merge that never saw them.
- **A check failing because of the change** — that is a finding. It returns to the loop: the shepherd
  fixes it, and the fix is re-reviewed per step 3.
- **A check failing or erroring for reasons unrelated to the change** — infrastructure outage, expired
  credentials, a runner that never started, a workflow already broken on `main`. This MUST halt and
  report. It MUST NOT be merged past, and it MUST NOT be handed to the shepherd as a code defect:
  there is no code defect to fix, and "fixing" it would mean editing unrelated infrastructure, which
  is exactly the scope expansion these bounds prohibit.

Distinguishing the last two is a judgment call. It MUST be stated explicitly in the run log with the
evidence behind it. Guessing wrong permissively merges an unverified change; guessing wrong
restrictively only costs a halt.

**No workflows configured at all** is a distinct case and MUST NOT be treated as a blocker: there is
nothing to wait for, so the merge proceeds on review approval alone. The absence MUST be recorded in
the run log, because a reader must be able to distinguish "checks passed" from "no checks existed".
Treating an absent workflow as a blocker would leave the loop permanently unable to merge in any
repository that has none.

**Autonomy bounds.** Autonomous merge is a real delegation, so it is bounded rather than open-ended:

- The loop MUST halt and report after a maximum number of review-shepherd rounds. **The default limit
  is 3.** A feature MAY set a different limit in its `plan.md`; absent an explicit choice, 3 applies.
  Convergence is expected in one or two rounds; reaching the third is a signal the change is wrong,
  not a signal to keep iterating. A limit that is merely "stated somewhere" is not a limit — the
  number MUST be resolvable before the loop starts.
- The shepherd MUST fix only what review raised. Expanding scope — adding features, refactoring
  beyond the findings, or "improving" untouched code — is prohibited, because that work would itself
  be unreviewed.
- Branch protection MUST NOT be weakened to let a merge through. Removing required reviews, disabling
  required conversation resolution, or force-pushing to `main` to complete the loop is prohibited
  without explicit per-instance operator consent. If protection blocks the merge, the chain halts and
  reports; it does not route around the guardrail.
- If the chain cannot converge, it MUST leave the pull request open with its state recorded, never
  merge something whose review did not close.
- Every round — verdict, findings, shepherd actions, and merge outcome — MUST be recorded in the run
  log under `.specify/workflows/runs/`, so an interrupted loop resumes without re-reviewing what
  already passed.

When no pull request exists (no remote, or work still local), the chain degrades rather than being
skipped: `/pr-reviewer` runs against the local diff, and the shepherd step is deferred and recorded
as pending in the run log.

Rationale: An automation that must be remembered is an automation that gets skipped exactly on the
rushed changes that most needed it. And an autonomous loop without bounds converts a review gate
into a merge rubber stamp — the bounds are what keep the delegation honest.

### VII. Versioned Instruction Surface

`instructions.md` MUST declare its own version in its H1 title, as an explicit
`MAJOR.MINOR.PATCH` semantic version. A bare generation marker (`V4`) is insufficient: any
agent reading the file MUST be able to state exactly which instruction version it is operating
under, and two agents reading different revisions MUST be able to tell that they differ.

- The title is the authoritative version location. Format: `# <Name> vMAJOR.MINOR.PATCH: <subtitle>`.
- The frontmatter `Summary:` MUST NOT contradict the title's version. Where a projection format
  cannot carry an H1, the adapter MUST surface the same version string in that format's
  equivalent header region.
- **The first versioned release is `0.0.1`.** The pre-revision content never carried a semantic
  version — `V4` was a generation marker, not a version — so there is nothing to bump from and
  nothing to renumber. The `V4` marker is retired rather than mapped onto the MAJOR component.
- A `0.y.z` version is a deliberate statement under semantic versioning: the instruction set is in
  initial development and any directive may change. `1.0.0` MUST NOT be declared until the operator
  states the instruction surface is stable, at which point the declaration is itself an amendment
  to this constitution.
- While MAJOR is `0`, the bump semantics below still apply to MINOR and PATCH, and a
  directive-removing change increments MINOR rather than MAJOR — the standard `0.y.z` convention.

Bump semantics are the same as this constitution's, applied to instruction content:

- MAJOR: a directive is removed, or its obligation is redefined so that previously compliant
  agent behavior becomes non-compliant.
- MINOR: a directive or section is added, or existing guidance is materially expanded.
- PATCH: clarification, rewording, or vendor-value refresh with no change to any obligation.

Alignment with the SDD lifecycle (Principle V) is mandatory and determines who may bump:

- `/speckit-specify`, `/speckit-clarify`, `/speckit-plan`, and `/speckit-tasks` MUST NOT change
  the version. They produce artifacts, not instruction content.
- `/speckit-implement` MUST bump the version in the SAME change set that edits instruction
  content. A diff touching `instructions.md` without a version change is incomplete and MUST be
  rejected in review.
- `/speckit-analyze` MUST verify that the proposed bump type matches the actual diff, and MUST
  report a mismatch as a finding before implementation proceeds.
- `/speckit-converge` MUST verify that the shipped title version matches the bump the plan
  declared.
- The bump type MUST be stated in the feature's `plan.md` before implementation begins, so the
  review chain in Principle VI has a declared expectation to audit the diff against.

Rationale: Instructions are the control plane for every downstream agent, and they are consumed
by tools that cannot ask which revision they loaded. An unversioned control plane makes drift
undetectable and rollback unspecifiable.

### VIII. Executable Agent Provisioning

`instructions.md` MUST NOT merely name the SpecKit skills it orchestrates; it MUST carry the
instructions an agent needs to make those skills actually available in the harness it is running
in. Naming a skill the agent cannot invoke is a dead reference, and a dead reference in the
control plane produces a silently skipped lifecycle phase.

The file MUST contain a provisioning section covering, for every skill in its catalog:

- **Detection** — how the agent determines whether the skill is already installed, by reading
  the integration manifests under `.specify/integrations/` rather than guessing from filesystem
  layout.
- **Installation** — the concrete command that installs or refreshes the skill set for the
  detected harness, with the SpecKit version pinned to the value recorded in
  `.specify/integration.json`.
- **Verification** — how the agent confirms the installed files match the manifest. Manifests
  carry a SHA256 per file; a mismatch is drift and MUST be reported, never silently accepted.

Invocation syntax MUST be derived, never hardcoded. The separator between the `speckit` prefix
and the skill name is per-integration configuration, read from
`integration_settings.<integration>.invoke_separator` in `.specify/integration.json`. Writing a
literal `/speckit.plan` or `/speckit-plan` into shared content violates Principle II; the
concrete form belongs in a tool-scoped section derived from that setting.

The catalog and the manifests MUST agree. Before dispatching any phase, the agent MUST confirm
the skill appears in the manifest for the active integration. Two failure modes are explicitly
prohibited:

- Referencing a skill absent from every manifest (a phase that can never run).
- Omitting an installed skill from the catalog (capability the operator paid for and cannot reach).

A skill that is genuinely unavailable in the active harness MUST resolve to its Principle VI /
Principle II degradation path — the phase's obligations are followed manually, in order. Absence
MUST NOT silently drop the phase.

Rationale: A control plane that assumes its own tooling is present works only on the machine
where it was written. Provisioning instructions are what make a global instruction set portable
in practice rather than in aspiration.

### IX. Delimited Managed Region

The AI Jedi instruction content MUST be enclosed in explicit start and end markers, in
`instructions.md` itself and in every projection written into an installed tool's configuration
file. The markers exist so an operator can say "update my AI Jedi instructions" and any agent can
locate, replace, and verify exactly the right span — without reading the operator's own content
and without guessing where the managed text begins.

**Projection target is the GLOBAL configuration, never a project-local one.** AI Jedi configures
every tool on the operator's machine, so its managed region belongs in each tool's user-level
configuration — the file that applies to all projects. Writing the region into a repository-local
config file is prohibited: it would scope a global instruction set to one project and silently
commit the operator's machine-wide configuration into that project's history.

- Each adapter MUST declare the user-level path it targets for its tool, and MUST refuse to write
  if the resolved path falls inside a project working tree.
- Project-local config files — this repository's own `CLAUDE.md` included — MUST NOT receive an
  `AI-JEDI:INSTRUCTIONS` region. `CLAUDE.md` here carries only the SpecKit pointer region.
- Adapters MUST NOT assume a path exists. Absent user-level config for an installed tool means
  the adapter creates it at the documented location or reports that the tool is unconfigured; it
  MUST NOT fall back to a project-local file.
- The user-level path is vendor-specific and therefore tool-scoped (Principle II). It MUST NOT be
  hardcoded into shared instruction content.
- `instructions.md` in this repository is the SOURCE, not a projection. It carries the marker pair
  so the region is unambiguous, and it is exempt from the global-path rule.

Canonical form in comment-capable formats (Markdown, HTML):

```text
<!-- AI-JEDI:INSTRUCTIONS:START v<MAJOR.MINOR.PATCH> -->
...managed content...
<!-- AI-JEDI:INSTRUCTIONS:END -->
```

Rules:

- The namespace is `AI-JEDI:INSTRUCTIONS`. It MUST NOT collide with markers owned by other
  tooling; the pre-existing `SPECKIT START` / `SPECKIT END` region is a separate, independently
  managed span and MUST be left untouched.
- The start marker MUST carry the source version (Principle VII). An agent compares that value
  against the source title to detect a stale projection without diffing content.
- The end marker MUST NOT carry a version. One authoritative version location per region.
- Both markers MUST be present. A file with one marker, or with markers out of order, is
  corrupt: the agent MUST report it and MUST NOT attempt a partial replacement.
- Content outside the markers is operator-authored and MUST NEVER be read for decisions, moved,
  reordered, or rewritten. Updating means replacing the span between markers, nothing else.
- Where the target format cannot carry comments (for example a JSON config), the adapter MUST
  define an equivalent explicit delimiter for that format — a dedicated key holding the managed
  string, or a documented sentinel line — and MUST record which mechanism it uses. Silently
  writing unmarked content into a format that cannot hold markers is prohibited.

Update protocol an agent MUST follow when asked to refresh instructions in an installed tool:

1. Resolve the tool's user-level config path from its adapter declaration. If the resolved path
   is inside a project working tree, refuse and report — never write there.
2. If the file does not exist, create it containing only the marker pair and the managed content.
3. Locate both markers. Absent or malformed in an existing file → report and stop.
4. Compare the start marker's version to the source title version. Equal → already current;
   report and make no write.
5. Replace only the span between the markers, and rewrite the start marker's version to match
   the source.
6. Verify the result: both markers present, in order, version matching, content outside the
   region byte-identical to before, and the written path still user-level.

Rationale: Automated updating is only safe when the boundary is unambiguous. A marker pair turns
a risky "find my instructions somewhere in this file" heuristic into a mechanical, verifiable,
idempotent replacement. Targeting the global config is what makes the instruction set global at
all — a per-project copy is the exact duplication Principle I exists to prevent.

### X. Capability-Tiered Agent Materialization

`instructions.md` MUST describe how to select, configure, and automatically create an agent
definition for every skill in its catalog, in whatever harness the operator is running. A catalog
that lists a skill and a model but leaves the operator to hand-build the agent is documentation,
not a control plane.

**The Model Selection column MUST express a capability tier, never a vendor model name.** The
tier vocabulary is fixed and closed:

- `deep-reasoning` — hardest analysis, architecture, and governance judgment. Highest capability
  tier the harness offers.
- `balanced-coding` — primary implementation and orchestration work. The harness's default
  general-purpose coding tier.
- `fast-lightweight` — high-frequency, low-judgment work. The cheapest tier that still completes
  the task.

Rules on the vocabulary:

- Shared instruction content MUST use only these three tokens. A vendor model identifier appearing
  in the catalog is a defect (Principle II).
- The tier → concrete model mapping MUST live in the tool-scoped section (Principle VIII), one
  mapping per integration, so a vendor rename touches one block.
- A harness exposing fewer than three tiers MUST collapse them upward, never downward: an absent
  `fast-lightweight` resolves to `balanced-coding`, and an absent `deep-reasoning` resolves to the
  highest tier available. Silently downgrading a `deep-reasoning` phase is prohibited.
- The Effort column is already harness-neutral and MUST remain so.

Agent materialization requirements:

- The file MUST state, per harness, where agent definitions live, what format they take, and which
  fields are required. That location and format are vendor-specific and therefore tool-scoped.
- Creation MUST be idempotent: re-running it with an unchanged catalog MUST produce byte-identical
  definitions and MUST NOT duplicate an existing agent.
- Creation MUST NOT overwrite an operator-authored agent that happens to share a name. Collision
  MUST be reported, not resolved by clobbering.
- An agent MUST NOT be created for a skill absent from the active integration's manifest
  (Principle VIII). Materializing an agent that dispatches to an uninstallable skill produces a
  phase that fails at run time rather than at setup time.
- Every materialized agent MUST carry the tier, the effort, and the scope statement recorded for
  its skill in the catalog, so the definition is traceable back to a catalog row.
- Where the harness has no sub-agent concept at all, materialization resolves to the Principle
  VIII degradation path: the phase's obligations are followed in the main session, in order, and
  the absence is reported. It MUST NOT be silently skipped.

Rationale: Tier names survive vendor churn; model identifiers do not. And an agent set the
operator must assemble by hand will drift from the catalog immediately, which reintroduces exactly
the divergence Principle I exists to eliminate.

### XI. Isolated Parallel Execution

Independent work MUST be dispatched in parallel, and every parallel implementation unit MUST run in
its own git worktree on its own branch. Two agents MUST NEVER hold the same working tree: their
edits interleave, the loser's work is silently overwritten, and neither diff is trustworthy
afterward.

Parallelism rules:

- Parallel is the DEFAULT for units with no dependency between them. Serial execution MUST be
  justified by a real dependency or by write contention on the same file, and the reason MUST be
  stated in `tasks.md`.
- **A worktree does not create parallelism where the deliverable is a single file.** When multiple
  units write the same artifact, they contend regardless of isolation, and `tasks.md` MUST mark them
  serial rather than advertising a `[P]` that cannot be honored.
- One worktree per unit, one branch per worktree. The branch name MUST derive from the feature
  directory and the unit it implements, so a stray worktree is traceable to its origin.
- Sub-agents receive isolated context — only the relevant `spec.md`, `plan.md`, and their own task
  slice — so parallel units cannot inherit each other's assumptions.
- Merge order MUST follow the dependency graph in `tasks.md`, never completion order. A unit that
  finishes first does not thereby earn the right to land first.
- A worktree MUST be removed once its branch has merged, or immediately if it produced no change.
  Abandoned worktrees are state that outlives its run log and MUST NOT accumulate.
- The branch itself MUST be deleted after its merge completes, per Principle VI step 5 — remote copy
  first, then any local copy. Merged branches that linger make the branch list a poor signal of what
  work is actually open.
- Orchestration state — which unit, which worktree, which branch, which status — MUST be recorded in
  the run log under `.specify/workflows/runs/` so an interrupted parallel run resumes without
  re-dispatching completed units.

Pull request organization, when git and a remote are configured:

- One pull request per independently testable user story, matching the story decomposition in
  `tasks.md`. A PR spanning several stories defeats the independent-testability property the story
  decomposition exists to create.
- Each PR MUST state its base branch, the story it implements, and its position in the dependency
  graph.
- The Principle VI review chain applies per PR, not per parallel batch. A batch of five parallel
  units produces five reviews.
- A PR MUST NOT be opened from a worktree whose branch shares no ancestor with its declared base.
  Unrelated histories cannot merge, and discovering this at merge time wastes the entire review.
- Stacked work MUST declare its parent PR explicitly rather than relying on the reviewer to infer
  the order.

Degradation, per Principle VIII's rules:

- No git repository → no worktrees. Units run serially in the single working tree, and the loss of
  parallelism MUST be reported, not silently absorbed.
- Git but no remote → no pull requests. Branches remain local, review runs against the local diff,
  and the shepherd step is recorded as pending.
- Harness without parallel dispatch → units run sequentially in dependency order, and the absence
  is reported.

Rationale: Parallelism is the only lever that changes wall-clock time on multi-unit work, and
worktrees are what make it safe. Without isolation, concurrency is not speed — it is data loss with
a progress bar.

### XII. Operator-Facing README

`README.md` MUST exist at the repository root and MUST explain, in operator-facing terms, every
capability `instructions.md` provides and what the operator gains from it. It is the only artifact
written for a human deciding whether to adopt the instruction set, and it MUST be updated in the
same change set as any instruction content change.

- The README MUST state **benefits**, not restate directives. `instructions.md` says what an agent
  MUST do; the README says what the operator gets. Copying directive text into the README creates a
  second source of truth and violates Principle I.
- Every capability in the instruction set MUST be represented. A capability the operator cannot
  discover from the README is a capability they will not use.
- **No benefit may be claimed that no directive backs.** The README MUST NOT describe behavior the
  instruction set does not actually mandate. Aspirational claims are prohibited — a reader adopting
  the set on the strength of a benefit that does not exist has been misled.
- The README MUST state the current instruction version, matching the `instructions.md` title
  (Principle VII). A README quoting a stale version misrepresents what the reader is getting.
- The README MUST link into `instructions.md` sections rather than duplicating them, so detail lives
  in one place and the README stays short enough to be read.
- The README MUST state which tools the instruction set has actually been exercised against, and
  MUST NOT imply coverage of tools it has not been tested on.
- The README is a persisted artifact and therefore English (Principle III), free of secrets,
  operator-identifying data, and machine-local paths (Principle IX's authoring constraints), and
  carries frontmatter like every other Markdown artifact.
- When instruction content changes but no operator-visible benefit changes, the README MUST still be
  reviewed and the no-change decision recorded. Skipping the review is how drift starts.

Rationale: An instruction set nobody can evaluate is an instruction set nobody adopts. The README is
the adoption surface, and an adoption surface that overstates or lags the product costs more trust
than having no README at all.

## Tool Adapter & Authoring Constraints

- Every adapter MUST declare: target tool, output path, format, and any tool-imposed size or
  syntax limits. Content exceeding a target's limit MUST be summarized by the adapter, not
  truncated arbitrarily.
- The declared output path MUST be the tool's user-level (global) configuration location
  (Principle IX). An adapter that resolves to a path inside a project working tree MUST refuse to
  write.
- Adapters MUST be idempotent: re-running an adapter with unchanged source MUST produce a
  byte-identical output file.
- Adapters MUST NOT overwrite operator-authored content outside their managed region. Managed
  regions MUST be delimited by the `AI-JEDI:INSTRUCTIONS` marker pair defined in Principle IX,
  or by that principle's documented equivalent for formats that cannot carry comments.
- Every adapter output MUST carry the source instruction version verbatim (Principle VII). An
  output whose version string differs from the source's title version is drifted and MUST be
  regenerated.
- Every adapter MUST declare how its target harness installs and verifies the SpecKit skill set,
  and MUST derive invocation syntax from that integration's `invoke_separator` (Principle VIII).
  An adapter that emits a hardcoded slash-command form is defective.
- Every adapter MUST declare its harness's agent-definition location and format, and MUST carry the
  capability-tier → concrete-model mapping for that harness (Principle X). An adapter that emits a
  vendor model identifier into shared content, or that collapses a tier downward, is defective.
- Every persisted Markdown artifact MUST open with frontmatter carrying `Summary:` (one
  sentence) and `Tags:`.
- Frontmatter MUST be accurate, not merely present. `Summary:` MUST describe what the file actually
  contains as of this revision, and `Tags:` MUST reflect its actual subject matter. Both MUST be
  re-evaluated in the same change set as any content change, and corrected when the content moved on.
  Stale frontmatter is worse than absent frontmatter: an agent that reads `Summary:` to decide
  whether to load the file will skip a file that no longer matches its own description.
- For `instructions.md` specifically, `Summary:` MUST agree with the directives the file actually
  carries, and `Tags:` MUST cover every capability area present in it. A capability added without a
  corresponding tag is undiscoverable to any agent that filters by tag.
- Frontmatter MUST NOT contradict the title version (Principle VII) and MUST NOT claim scope the
  file does not have.
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
  automatically when a pull request is opened, and at the end of every implementation unit when no
  pull request exists yet. It loops — review, shepherd, re-review the shepherd's own diff — until the
  change merges or the loop's round limit is reached. Every round's verdict, findings, shepherd
  actions, and merge outcome MUST be recorded in the run log.
- Orchestration state and logs MUST be persisted under `.specify/workflows/runs/` so an
  interrupted run can resume. For parallel runs this MUST include the unit, worktree, branch, and
  status of each dispatched agent (Principle XI).
- Parallel implementation units MUST each run in their own worktree and branch, and MUST merge in
  the dependency order declared in `tasks.md` rather than completion order (Principle XI).
- After any change to `instructions.md`, all adapter outputs MUST be regenerated and verified
  in the same change set. A merge that updates the source without its projections is
  incomplete.
- Any change set that edits instruction content MUST also bump the `instructions.md` title
  version per Principle VII, and the bump type MUST match the one declared in the feature's
  `plan.md`. Review MUST reject an instruction-content diff carrying no version change.
- Any change set that adds, removes, or renames a skill in the `instructions.md` catalog MUST
  reconcile it against `.specify/integrations/*.manifest.json` in the same change set
  (Principle VIII). A catalog entry with no manifest backing, or an installed skill with no
  catalog entry, is a defect.
- Any change set that alters a catalog row's tier, effort, or scope MUST regenerate the
  corresponding agent definitions in the same change set (Principle X). A materialized agent whose
  tier no longer matches its catalog row is drifted.
- Any change set that bumps the instruction version MUST also update the version carried by every
  `AI-JEDI:INSTRUCTIONS:START` marker in the repository and in generated projections
  (Principle IX). A projection whose marker version trails the source title is stale by
  definition.
- Any change set that edits instruction content MUST update `README.md` in the same change set, or
  record the reviewed no-change decision (Principle XII). Review MUST verify that every README
  benefit claim is still backed by a directive and that the stated version matches the title.
- Any change set that alters a file's content MUST re-evaluate that file's `Summary:` and `Tags:` and
  correct them where the content moved on. Review MUST reject frontmatter that no longer describes
  the file.
- After a pull request merges, its branch MUST be deleted and its worktree removed. A merged branch
  left in place is stale state; an unmerged branch MUST NOT be deleted.

## Governance

This constitution supersedes all other practices in this repository. Where a rule here
conflicts with `instructions.md`, this file wins and `instructions.md` MUST be amended.

Amendments MUST be proposed as a change to this file, MUST state the rationale, and MUST
include the propagation plan for affected templates and adapters.

Versioning follows semantic versioning:

- MAJOR: a principle is removed or redefined in a backward-incompatible way.
- MINOR: a principle or section is added, or guidance is materially expanded.
- PATCH: clarification, wording, or typo fixes with no semantic change.

This constitution's version and the `instructions.md` version (Principle VII) are independent
counters and MUST NOT be conflated. Amending this file does not bump the instruction version,
and vice versa.

Compliance review: every pull request MUST verify adherence to Principles I–XII. Complexity
that violates a principle MUST be justified in the plan's Complexity Tracking section or
removed. Runtime development guidance lives in `instructions.md`.

**Version**: 1.14.0 | **Ratified**: 2026-07-24 | **Last Amended**: 2026-07-25
