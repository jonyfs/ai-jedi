---
Summary: The observable contract instructions.md offers any consuming AI tool — required structure, guaranteed invariants, and what a tool may rely on.
Tags: [#contract #instructions #portability]
---

# Contract: `instructions.md` as consumed by an AI tool

Plan: [[plan]] · Data model: [[data-model]]

The consumer is any AI coding tool that loads a single global Markdown instruction file. The
contract is what that tool may rely on without inspecting the repository.

## Interface

**Artifact**: one file, `instructions.md`, at the repository root.
**Format**: CommonMark with YAML-style frontmatter delimited by `---`.
**Load semantics**: read whole file once per session; no preprocessing, no includes, no companion
file required.

## Required structure

Sections appear in this order. Headings are stable identifiers — a consumer may cite them.

| # | Section | Consumer obligation |
|---|---|---|
| 1 | Frontmatter | Read `Summary:` and `Tags:`; do not act on them |
| 2 | First-Read Bootstrap | Apply on load, before answering anything |
| 3 | Precedence Ladder | Consult whenever two rules collide |
| 4 | Auto-Clarity Exceptions | Check before compressing any block |
| 5 | Output Compression Protocol | Apply to every reply |
| 6 | Intensity Levels | Switch on explicit operator command; persist until changed |
| 7 | Engineering Lifecycle | Route all non-trivial change through it |
| 8 | Post-Implementation Review Chain | Run automatically after each implementation unit |
| 9 | File Architecture | Apply when creating or modifying any Markdown artifact |
| 10 | Path-Scoped Rules | Apply when the edited path matches a glob |
| 11 | Orchestration | Apply when orchestration triggers are present |
| 12 | Tool-Scoped Values | Read for vendor values; re-verify before use |
| 13 | Degradation Paths | Consult when a required capability is unavailable |

A consumer that cannot find section 3 or section 4 MUST treat the file as invalid rather than
guessing precedence.

## Guaranteed invariants

- **I1 — Total precedence.** Any two directives are ordered by the ladder in section 3. No
  collision is left unresolved.
- **I2 — Safety supremacy.** Safety and irreversibility outrank every other concern, including
  density. Compression is never a reason to shorten a destructive-action warning.
- **I3 — Verbatim floor.** Code blocks, error strings, API names, and CLI commands are reproduced
  exactly, regardless of intensity level.
- **I4 — Stated exceptions.** Every directive carries a trigger, an obligation, and an explicit
  exception field. An absent exception is written as `none`, never omitted.
- **I5 — Vendor isolation.** No vendor-specific literal (model identifier, slash-command syntax,
  config key) appears outside section 12.
- **I6 — Total degradation.** Every directive that assumes a tool capability names its fallback in
  section 13. No directive fails silently on a tool lacking that capability.
- **I7 — Language split.** Conversation follows the operator's language; every persisted artifact
  is English.
- **I8 — No secrets.** The file contains no credentials, no operator-identifying data, and no
  machine-local absolute paths.
- **I9 — Size bound.** The file stays within 800 lines so size-limited consumers can load it whole.
- **I10 — Losslessness.** Every directive in the register ([[data-model]]) is present. Removal
  requires a spec change, not an edit.

## Consumer-visible behaviors (acceptance surface)

A conforming consumer, given only this file:

1. Compresses a short technical reply with no filler and no tool-call narration.
2. Switches to full precise prose for a destructive or security-relevant block, then resumes.
3. Refuses ad-hoc multi-file code edits in favor of the lifecycle in section 7.
4. Writes compliant frontmatter on any new Markdown file.
5. Runs the review chain in section 8 in the correct order, without being asked.
6. Names the governing section when asked which rule applies to a given situation.

## Non-goals

- Generating tool-specific projections (`CLAUDE.md`, `AGENTS.md`, `opencode.json`) — adapters own
  that and are out of scope for this feature.
- Enforcement. This contract is advisory to the consumer; nothing in the repository can compel a
  third-party tool to honor it.
