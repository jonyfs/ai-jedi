---
Summary: Implementation plan generalizing the adapter to per-target declarations and shipping four verified targets, with two installed tools excluded for a stated reason.
Tags: [#plan #adapter #multi-target]
---

# Implementation Plan: Multi-Target Adapters

**Branch**: `005-multi-target-adapters` | **Date**: 2026-07-25 | **Spec**: [[spec]] — `specs/005-multi-target-adapters/spec.md`

**Input**: Feature specification from `specs/005-multi-target-adapters/spec.md`

## Summary

Turn the single Claude Code adapter into a target-parameterized one: `project.sh` takes a declaration,
and each tool ships only a declaration. **Five declared targets, four of which have an existing file.**
Two further installed tools excluded because no global instruction surface was found for either.

## Technical Context

**Language/Version**: POSIX shell, as the existing adapter. No new dependency.

**Primary Dependencies**: `git`, POSIX text tools, `shellcheck` (optional, as established).

**Storage**: files.

**Testing**: TDD. The existing **13** groups and 64 assertions must pass for EVERY target, not only the
first — that is the real assertion this feature makes. An earlier draft said ten, which was a guess.

**Target Platform**: the operator's machine.

**Project Type**: adapter generalization.

**Constraints**: every guarantee the hardened adapter already provides must hold per target. The
success path for the Claude Code target must stay byte-identical — the same discipline as feature 004's FR-005 — a
different requirement from this feature's FR-005, which is why it is qualified — now with more ways to
break it.

**Scale/Scope**: one script generalized, four declarations, one shared test harness run per target.

## Survey — what is actually on this machine

Verified by inspection, not assumed:

| Tool | Global instruction file | State |
|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` | projected at v0.1.0 (feature 003) |
| OpenCode | `~/.config/opencode/AGENTS.md` | 17 lines, **entirely** a `caveman-begin`/`caveman-end` foreign region |
| Gemini | `~/.gemini/GEMINI.md` | exists, empty |
| Copilot | `~/.config/github-copilot/intellij/global-copilot-instructions.md` | exists, empty |
| Codex | `~/.codex/AGENTS.md` | absent — the adapter creates it |
| Cursor | none found | holds only `agents/*.md` placed by other tooling |
| Windsurf | none found | same |

## Constitution Check

| Principle | Gate | Status |
|---|---|---|
| I. Single Source of Truth | Projections generated, never hand-edited | PASS — four more generated projections |
| II. Multi-Tool Portability | Adding a tool = adding an adapter, not rewriting content | PASS — this is the principle's first real test. FR-002 makes it structural: a new tool is a declaration |
| III. Language Duality | English artifacts | PASS |
| IV. Token Density | N/A to code | PASS |
| V. Spec-Driven Change | Full lifecycle | PASS |
| VI. Review Chain | Loop, limit 3, check gate | PASS — governs this PR |
| VII. Versioned Instruction Surface | Bump declared | PASS — **N/A**, no instruction content edited |
| VIII. Executable Agent Provisioning | Per-adapter declaration completeness | PASS — each new declaration carries the required fields |
| IX. Delimited Managed Region | Markers, global-only, foreign untouched | PASS — FR-003 generalizes foreign-marker recognition, which the hardcoded `SPECKIT` pair could not cover |
| X. Capability Tiers | Tier vocabulary | PASS — each declaration carries its own tier map |
| XI. Isolated Parallel Execution | Worktree, merge order, PR granularity | PASS — see below |
| XII. Operator-Facing README | Claims directive-backed, no implied coverage | PASS — FR-007. The table must distinguish projected from merely installed |
| Authoring constraints | Declaration completeness, idempotency | PASS |

**Instruction Version Bump**: N/A. No instruction content is edited.

**Parallel Execution Plan** (Principle XI)

- Eligible for parallel dispatch: the four declarations are genuinely independent files. In practice the
  generalization of `project.sh` must land first, so they serialize behind it rather than by contention.
- PR granularity: one pull request. The stories describe one mechanism and cannot merge independently —
  the Principle XI exception.

## Design Decisions

**Declarations move to `targets/`, the script stays one.** `.specify/adapters/claude-code/` becomes
`.specify/adapters/` with `project.sh`, `tests/`, and `targets/<tool>.yml`. Keeping four copies of a
hardened script would guarantee they drift — the whole argument for Principle II.

**Foreign markers become per-target, and this is not theoretical.** The OpenCode target is occupied
end-to-end by `<!-- caveman-begin -->` / `<!-- caveman-end -->` — a different syntax from the `SPECKIT`
pair currently hardcoded. A global constant cannot recognise both, and failing to recognise one means
overwriting a working tool's configuration.

**Cursor and Windsurf are excluded, and the exclusion is the honest outcome.** Both directories hold
`agents/*.md` placed by unrelated tooling, and neither exposes a global instruction file this survey
could find. Inventing a plausible path would produce an adapter that writes somewhere the tool never
reads — worse than no adapter, because the README would then claim coverage that does not exist.

**Codex is included despite its file being absent.** The path is a documented convention and the adapter
creates missing targets by design. This is the difference between "no file yet" and "no mechanism" —
Cursor and Windsurf are the second case.

## Project Structure

```text
.specify/adapters/
├── project.sh              # generalized: takes a target declaration
├── targets/
│   ├── claude-code.yml     # moved from claude-code/adapter.yml
│   ├── opencode.yml
│   ├── gemini.yml
│   ├── copilot.yml
│   └── codex.yml
└── tests/run-tests.sh      # runs every group against every target
```

**Structure Decision**: one script, N declarations. The previous layout put the script inside a
tool-named directory, which only works for one tool.

## Complexity Tracking

No violations.
