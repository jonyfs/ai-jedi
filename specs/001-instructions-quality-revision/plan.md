---
Summary: Implementation plan for revising instructions.md into a lossless, self-locating, tool-portable instruction set.
Tags: [#plan #instructions #portability]
---

# Implementation Plan: Instructions Quality Revision

**Branch**: none (repository is not yet under version control) | **Date**: 2026-07-24 | **Spec**: [[spec]] — `specs/001-instructions-quality-revision/spec.md`

**Input**: Feature specification from `specs/001-instructions-quality-revision/spec.md`

## Summary

Rewrite `instructions.md` in place so any AI tool loading it as a global instruction set
applies every rule correctly on first read, while preserving 100% of the 41 directives present
today. Approach: build a directive register from the current file, restructure the file into
urgency-ordered sections with each rule phrased as trigger → obligation → exception, add an
explicit precedence ladder, isolate vendor-specific values into a tool-scoped block with
current model identifiers, add the Principle VI review chain to the guardrails, add stated
degradation paths for tools lacking sub-agents / slash commands / a git remote, and verify the
register maps 1:1 onto the result.

## Technical Context

**Language/Version**: Markdown (CommonMark); no runtime language

**Primary Dependencies**: None. `.specify/` templates and `.specify/memory/constitution.md` are
read-only inputs.

**Storage**: Plain files in the repository root

**Testing**: Manual verification via `specs/001-instructions-quality-revision/quickstart.md` —
directive-register diff, grep-based staleness checks, first-session behavioral probes across
installed tools

**Target Platform**: Any AI coding tool that loads a Markdown instruction file (Claude Code,
Codex, GitHub Copilot, OpenCode)

**Project Type**: Documentation / instruction control plane (single portable artifact)

**Performance Goals**: File stays well under the 800-line ceiling; every rule locatable without
reading unrelated sections

**Constraints**: No directive may be lost (FR-001); no secrets, operator-identifying data, or
machine-local absolute paths (FR-012); English only (Principle III); token additions must remove
ambiguity, not restate (FR-011)

**Scale/Scope**: One file, 82 lines today, 41 directives, 11 sections. Adapters and projections
explicitly out of scope.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|---|---|---|
| I. Single Source of Truth | Change is made in `instructions.md` first; no projection is hand-edited | PASS — feature touches only the source file; no projections exist yet |
| II. Multi-Tool Portability | Content stays tool-neutral; vendor values isolated in adapter-scoped sections | PASS — FR-004 and FR-009 encode this; tool-scoped block is a design output |
| III. Language Duality | All persisted artifacts in English | PASS — spec, plan, and revised file are English |
| IV. Token Density with Auto-Clarity | Compression preserved; clarity exceptions explicit | PASS — FR-003 precedence ladder strengthens the existing switch |
| V. Spec-Driven Change | specify → clarify → plan → tasks → implement → converge | PASS — spec exists; this is the plan step; `/speckit-analyze` runs before implementation |
| VI. Automated Post-Implementation Review | Review chain runs after the implementation unit | PASS — quickstart records the chain; no git remote yet, so the local-diff degradation applies and the shepherd step is logged pending |
| Authoring constraints | Frontmatter, wiki links, ≤800 lines, no secrets | PASS — FR-007 and FR-012 |

Post-Phase 1 re-check: PASS. No new violations; no Complexity Tracking entries required.

## Project Structure

### Documentation (this feature)

```text
specs/001-instructions-quality-revision/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output — directive register + entity definitions
├── quickstart.md        # Phase 1 output — validation guide
├── contracts/
│   └── instructions-file-contract.md   # Phase 1 output — the contract instructions.md offers any AI tool
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
instructions.md          # THE deliverable — revised in place
CLAUDE.md                # Managed SPECKIT region only; plan pointer
.specify/
├── memory/constitution.md   # Read-only input (governs the revision)
└── templates/               # Read-only inputs
specs/001-instructions-quality-revision/   # This feature's artifacts
```

**Structure Decision**: No source tree. The repository is an instruction control plane: the
single deliverable is the root `instructions.md`, with `specs/` holding lifecycle artifacts and
`CLAUDE.md` carrying only a managed pointer region. No `src/` or `tests/` directory is created —
verification is document-level and lives in `quickstart.md`.

## Target Section Order (urgency-first, per FR-008)

1. Frontmatter (`Summary:`, `Tags:`)
2. **First-Read Bootstrap** — what a tool does on load (FR-010)
3. **Precedence Ladder** — safety > clarity > lifecycle > density (FR-003)
4. **Auto-Clarity Exceptions** — when compression is suspended (moved ahead of the compression
   rules so the exception is read before the rule it constrains)
5. **Output Compression Protocol** — persistence, grammar drops, tokenizer guardrails,
   formatting limits
6. **Intensity Levels** — `lite` / `full` / `ultra`
7. **Engineering Lifecycle** — brainstorm → plan → incremental execution → TDD → review
8. **Post-Implementation Review Chain** — Principle VI, with ordering constraint (FR-005)
9. **File Architecture** — frontmatter, atomic files, wiki links, inbox triage
10. **Path-Scoped Rules** — frontend / backend-data / config-infra globs
11. **Orchestration** — activation triggers, technical-director protocol, guardrails
12. **Tool-Scoped Values** — model identifiers and slash-command syntax, isolated (FR-004)
13. **Degradation Paths** — no sub-agents / no slash commands / no git remote (FR-006)

Every one of the 41 registered directives maps into exactly one of sections 2–13. See
[[data-model]] for the register and its mapping column.

## Phase 0: Research

See [[research]]. Resolved: current vendor model identifiers, precedence ordering, degradation
semantics, and the decision to keep rewrite-in-place rather than split into multiple files.

## Phase 1: Design & Contracts

- [[data-model]] — Directive register (41 entries), plus the Section, Tool-scoped block, and
  Degradation path entities from the spec.
- [[contracts/instructions-file-contract]] — the observable contract `instructions.md` offers a
  consuming tool: required sections, precedence guarantee, and the invariants a tool may rely on.
- [[quickstart]] — runnable validation: register diff, staleness greps, behavioral probes.
- `CLAUDE.md` managed region updated to point at this plan.

## Complexity Tracking

No Constitution Check violations. Section not applicable.
