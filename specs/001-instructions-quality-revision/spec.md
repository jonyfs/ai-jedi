---
Summary: Specification for revising instructions.md so any AI tool reading it extracts maximum, unambiguous, productive value without losing existing content.
Tags: [#spec #instructions #portability #quality]
---

# Feature Specification: Instructions Quality Revision

**Feature Branch**: `001-instructions-quality-revision`

**Created**: 2026-07-24

**Status**: Draft

**Input**: User description: "revise a qualidade de instructions.md para que toda IA que use estas instruções globais saibam tirar o melhor proveito das instruções contidas neste arquivo. Ajuste o que for necessário porém sem perder contexto algum do que está já descrito. Revise para ver o que pode trazer ainda mais ganho e produtividade e benefícios ao usar estas instruções de forma global em IAs"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Any AI tool applies the rules correctly on first read (Priority: P1)

An operator installs `instructions.md` as the global instruction set for an AI coding tool
(Claude Code, Codex, Copilot, OpenCode, or a tool added later). On the very first session,
the tool applies compression, workflow, and file-architecture rules correctly without the
operator restating them, because every rule states its trigger, its required behavior, and
its stop condition explicitly.

**Why this priority**: The file's entire purpose is cross-tool behavioral control. If a rule
is ambiguous, every downstream session inherits the ambiguity. This is the base value.

**Independent Test**: Give the revised file to a fresh session of each installed tool with a
representative task and confirm the tool (a) compresses output per the protocol, (b) refuses
ad-hoc code edits in favor of the lifecycle, (c) writes frontmatter on new Markdown, without
being reminded.

**Acceptance Scenarios**:

1. **Given** a fresh session loading only the revised `instructions.md`, **When** the operator
   asks a short technical question, **Then** the reply is compressed per the protocol and
   contains no filler or tool-call narration.
2. **Given** a fresh session, **When** the operator requests a destructive or security-relevant
   action, **Then** the tool switches to full precise prose for that block and resumes
   compression afterward.
3. **Given** a fresh session, **When** the operator requests a multi-step feature, **Then** the
   tool routes through the lifecycle instead of editing code ad hoc.

---

### User Story 2 - No existing directive is lost or weakened (Priority: P1)

The operator compares the revised file against the current one and confirms every rule,
threshold, catalog row, guardrail, and path-scoped constraint that exists today is still
present — reworded or reorganized, never dropped.

**Why this priority**: Explicit operator constraint. A quality revision that silently deletes
context is a regression regardless of how clean the result reads.

**Independent Test**: Produce a directive inventory of the current file and check each entry
against the revised file; every entry maps to a surviving directive.

**Acceptance Scenarios**:

1. **Given** the pre-revision file, **When** each of its directives is looked up in the revised
   file, **Then** every one is found, with equal or stricter force.
2. **Given** a directive that was merged with another, **When** it is inspected, **Then** the
   merged text still carries both original obligations.

---

### User Story 3 - Stale and conflicting content is corrected (Priority: P2)

The revised file no longer instructs tools using retired vendor identifiers or omits
governance rules the constitution already mandates, so tools do not act on invalid values.

**Why this priority**: Wrong vendor values cause failed sub-agent dispatch; missing governance
rules cause silent non-compliance. High impact, but the file is still usable without the fix.

**Independent Test**: Scan the revised file for retired model identifiers and for coverage of
every constitutional principle that imposes runtime behavior; both checks come back clean.

**Acceptance Scenarios**:

1. **Given** the skill catalog, **When** its model identifiers are read, **Then** all are
   vendor-current.
2. **Given** the execution guardrails, **When** they are read, **Then** the mandatory
   post-implementation review chain and its ordering constraint are stated.
3. **Given** the file's own frontmatter and cross-references, **When** they are inspected,
   **Then** they satisfy the authoring constraints the file itself imposes.

---

### User Story 4 - The file is navigable and self-locating for machines (Priority: P3)

An AI tool with limited context can locate the rule governing its current action quickly,
because sections are ordered by decision urgency, each carries a stable heading, and rules are
phrased as trigger-plus-obligation rather than prose narrative.

**Why this priority**: Improves productivity and reduces misapplication, but the rules already
work when read in full.

**Independent Test**: Ask a tool to quote the single rule governing a given situation; it
returns the right rule without reading unrelated sections.

**Acceptance Scenarios**:

1. **Given** a specific situation (destructive command, new Markdown file, multi-step feature),
   **When** the tool is asked which rule applies, **Then** it names the correct section.

---

### User Story 5 - The instruction set can update itself in installed tools (Priority: P2)

The operator says "update my AI Jedi instructions" and any agent — in any installed tool — can
state which version is currently in place, locate the managed region in that tool's global
configuration, replace exactly that span, and confirm nothing else moved.

**Why this priority**: This is what makes the instruction set genuinely global rather than a file
the operator copies by hand. Ranked below US1/US2 because the rules must first be correct and
lossless before propagating them is worth automating.

**Independent Test**: In a tool whose global config already carries the region, ask an agent to
refresh it; verify only the marked span changed, the version advanced, and no project-local file
was written.

**Acceptance Scenarios**:

1. **Given** a file carrying the marker pair, **When** an agent is asked to refresh it, **Then**
   only the span between markers changes and the start marker's version matches the source.
2. **Given** a file whose marker version already equals the source, **When** a refresh is asked,
   **Then** the agent reports it is current and writes nothing.
3. **Given** a file with only one marker, **When** a refresh is asked, **Then** the agent reports
   corruption and refuses partial replacement.
4. **Given** a resolved path inside a project working tree, **When** a refresh is asked, **Then**
   the agent refuses and reports, rather than writing a project-local copy.
5. **Given** a catalogued skill that is unavailable in the active harness, **When** its phase is
   reached, **Then** the agent follows the phase's obligations manually rather than skipping it.

---

### Edge Cases

- A target tool imposes a size limit smaller than the revised file: content must be summarized
  by the adapter, never arbitrarily truncated, and the highest-priority sections must survive.
- Two rules appear to conflict (compression vs. precision): the file must state an explicit
  precedence so the tool never has to guess.
- The operator writes in a language other than English: conversational replies follow the
  operator's language while the file and all artifacts stay English.
- A tool does not support sub-agents or slash commands: orchestration rules must degrade to a
  stated single-agent fallback rather than failing.
- No version control or remote exists: review-chain rules must degrade to a local path.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The revised `instructions.md` MUST preserve every directive present in the
  current version; no rule, threshold, catalog row, or scoped constraint may be dropped.
  **Carve-out**: a catalog row naming a skill unavailable in the active harness is exempt, because
  preserving it would violate FR-015 — the row would be a dead reference. Such a row MUST be
  formally RETIRED, not silently dropped: recorded in the register with its reason and logged in the
  run log. This is the only permitted preservation exception, and it applies to catalog rows alone.
- **FR-002**: Every rule MUST state its activation trigger, the required behavior, and its
  termination or exception condition in explicit terms.
- **FR-003**: The file MUST declare an explicit precedence order for conflicting rules, with
  clarity and safety outranking compression.
- **FR-004**: All vendor-specific values MUST be current and MUST be confined to clearly
  marked, tool-scoped sections so they can be updated without touching shared content.
- **FR-005**: The file MUST cover every constitutional principle that imposes runtime behavior,
  including the mandatory post-implementation review chain and its ordering constraint.
- **FR-006**: The file MUST state a degradation path for every capability that a target tool
  may lack (sub-agents, slash commands, version control remote).
- **FR-007**: The file MUST comply with the authoring constraints it imposes on others:
  frontmatter with a one-sentence summary and tags, cross-references as wiki links, and size
  within the stated file-length ceiling.
- **FR-008**: Section order MUST place rules that gate immediate action before background or
  reference material.
- **FR-009**: The file MUST remain a single portable artifact readable by any AI tool without
  tool-specific preprocessing.
- **FR-010**: The file MUST state, in one place, what a tool should do on first read to
  bootstrap correct behavior.
- **FR-011**: Additions MUST earn their tokens: any new content must remove ambiguity or add a
  missing obligation, not restate an existing rule.
- **FR-012**: The revision MUST NOT introduce secrets, operator-identifying data, or
  machine-local absolute paths.
- **FR-013**: The file's title MUST carry an explicit `MAJOR.MINOR.PATCH` version, baselined at
  `0.0.1` as the first versioned release, so any agent can state which instruction version it is
  operating under.
- **FR-014**: The file MUST contain a provisioning section telling an agent how to detect,
  install, and verify the orchestrated skills in whatever harness it is running in — a named
  skill the agent cannot invoke is a dead reference.
- **FR-015**: Invocation syntax MUST be derived from the active integration's configured
  separator rather than written as a literal, and the skill catalog MUST agree with what is
  actually installed: no catalogued skill that is unavailable, no available skill left
  uncatalogued. **Availability source of record**: the union of the integration manifests under
  `.specify/integrations/` and the installed extensions declared in `.specify/extensions.yml`.
  On-disk presence alone is NOT authoritative — a file can exist without being installed.
- **FR-016**: The instruction content MUST be enclosed in an explicitly named start/end marker
  pair, with the start marker carrying the version, so an agent can locate and replace exactly
  that span without reading or disturbing operator-authored content.
- **FR-017**: Guidance for updating installed tools MUST target each tool's global, user-level
  configuration and MUST prohibit writing the managed region into any project-local
  configuration file.
- **FR-018**: The catalog's model column MUST express a capability tier drawn from a closed
  three-token vocabulary rather than any vendor model name, and the tier-to-concrete-model mapping
  MUST live in the tool-scoped section. A harness offering fewer tiers MUST collapse them upward,
  never downward.
- **FR-019**: The file MUST describe how to select, configure, and automatically create an agent
  definition for every catalogued skill in the active harness — including where definitions live,
  what fields they require, that creation is idempotent, that name collisions with
  operator-authored agents are reported rather than overwritten, and that no agent is created for
  a skill unavailable in that harness.
- **FR-020**: The file MUST state that independent work is dispatched in parallel by default, that
  every parallel implementation unit runs in its own isolated working copy on its own branch, that
  two agents never share a working copy, and that merging follows the declared dependency order
  rather than completion order. It MUST also state that isolation does not create parallelism when
  units contend for the same artifact.
- **FR-021**: The file MUST state how to organize pull requests when version control and a remote
  are configured — one per independently testable story, each declaring its base and its position in
  the dependency graph — and MUST state the fallbacks when no repository or no remote exists.
- **FR-022**: A `README.md` MUST exist at the repository root explaining, in operator-facing terms,
  every capability the instruction set provides and what the operator gains from it. It MUST state
  the current instruction version, MUST link into the instruction sections rather than duplicating
  them, MUST NOT claim a benefit no directive backs, and MUST NOT imply coverage of tools the set has
  not been exercised against.
- **FR-023**: The file MUST state that the review chain triggers automatically on pull request
  creation and loops — review, fix, re-review the fixer's own changes — until the change merges,
  and MUST state its autonomy bounds: a round limit of 3, no scope expansion beyond the findings, no
  weakening of branch protection, and halting with the request left open rather than merging an
  unconverged change.
- **FR-024**: The file's own `Summary:` MUST describe the directives it actually carries and its
  `Tags:` MUST cover every capability area present in it, with both re-evaluated whenever content
  changes. Frontmatter MUST NOT contradict the title version or claim scope the file lacks.
- **FR-025**: The file MUST state that a pull request's branch is deleted after its MERGE completes —
  remote copy first, then local — and MUST state that approval alone never triggers deletion, that an
  unmerged branch is preserved, and that the default branch is never deleted by this step.

### Key Entities

- **Directive**: One enforceable rule — trigger, obligation, exception. The unit that must be
  preserved across the revision.
- **Section**: A grouped set of directives under a stable heading, ordered by decision urgency.
- **Tool-scoped block**: A region holding vendor-specific values, isolated so updates do not
  disturb shared content.
- **Degradation path**: The stated fallback when a target tool lacks a capability a rule
  assumes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of the 44 pre-revision obligations inventoried from the current file are present
  in the revised file, except rows formally retired under the FR-001 carve-out, each recorded with
  its reason.
- **SC-002**: Zero retired vendor identifiers remain in the file.
- **SC-003**: Every constitutional principle imposing runtime behavior is represented by at
  least one directive in the file.
- **SC-004**: In a first-session test, every tool actually exercised applies compression, lifecycle
  routing, and frontmatter rules without being reminded — 100% of tools tested, with at least 3
  tools exercised out of the 4 assumed installed.
- **SC-005**: For each of at least 5 sampled situations, a tool asked "which rule applies"
  names the correct section on the first attempt.
- **SC-006**: The file stays within the stated file-length ceiling and opens with compliant
  frontmatter.
- **SC-007**: Zero conflicting rule pairs remain without a stated precedence.
- **SC-008**: An agent asked "which instruction version are you operating under" answers with a
  full three-part version, correct on the first attempt.
- **SC-009**: Every skill named in the catalog is confirmed available in the active harness, and
  every available skill appears in the catalog — zero discrepancies in either direction.
- **SC-010**: An agent asked to refresh the instructions in an installed tool replaces only the
  marked span, leaves all content outside it byte-identical, and writes to a global configuration
  path in 3 of 3 trials.
- **SC-011**: Zero vendor model names appear in the catalog; every row's model column holds one of
  the three tier tokens.
- **SC-012**: An agent asked to set up the tooling produces one agent definition per available
  catalogued skill, with tier, effort, and scope traceable to its catalog row; a second run changes
  nothing, and a pre-existing operator-authored agent of the same name is reported, not replaced.
- **SC-013**: In a multi-unit run, every unit works in its own isolated copy, no two units share
  one, merges occur in declared dependency order, and zero isolated copies remain after completion.
- **SC-014**: Every task marked parallel writes a distinct artifact — zero parallel markings on
  units that contend for the same file.
- **SC-015**: Every capability in the shipped instruction set is represented in the README, every
  README benefit claim traces to a directive, and the README's stated version matches the title —
  zero unbacked claims, zero missing capabilities, zero version mismatch.
- **SC-016**: A pull request opened without the operator asking for review receives one
  automatically, and the loop either merges the change or halts with the request left open and its
  state recorded — never merging a change whose review did not close, and never weakening branch
  protection to do so.
- **SC-017**: The file's `Summary:` and `Tags:` match its shipped content — every capability area
  present is covered by a tag, and the summary describes the directives actually carried.
- **SC-018**: After a merge, zero merged branches and zero worktrees remain for that change; after an
  approval that has not yet merged, the branch still exists.

## Assumptions

- The operator's installed AI tools are Claude Code, Codex, GitHub Copilot, and OpenCode; any
  future tool is served by the same file plus an adapter.
- The project constitution outranks `instructions.md`; where they disagree today, the file is
  corrected to match the constitution.
- Adapter and projection generation is out of scope for this feature; this feature revises the
  source file only.
- The current file's overall structure is sound; the revision reorganizes and tightens rather
  than rewrites from scratch.
- Vendor-current model identifiers are those published by the vendor at implementation time and
  are verified then, not frozen from this spec.
- English is the language of the file and of all artifacts, per the constitution.
