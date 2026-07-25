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

- **SC-001**: 100% of directives inventoried from the current file are present in the revised
  file.
- **SC-002**: Zero retired vendor identifiers remain in the file.
- **SC-003**: Every constitutional principle imposing runtime behavior is represented by at
  least one directive in the file.
- **SC-004**: In a first-session test against each installed tool, the tool applies compression,
  lifecycle routing, and frontmatter rules without being reminded, in at least 3 of 3 tools
  tested.
- **SC-005**: For each of at least 5 sampled situations, a tool asked "which rule applies"
  names the correct section on the first attempt.
- **SC-006**: The file stays within the stated file-length ceiling and opens with compliant
  frontmatter.
- **SC-007**: Zero conflicting rule pairs remain without a stated precedence.

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
