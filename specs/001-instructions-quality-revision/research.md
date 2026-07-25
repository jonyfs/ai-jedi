---
Summary: Phase 0 research resolving vendor identifiers, rule precedence, degradation semantics, and file-shape decisions for the instructions.md revision.
Tags: [#research #instructions #decisions]
---

# Phase 0 Research: Instructions Quality Revision

Plan: [[plan]] · Spec: [[spec]]

## R1. Current vendor model identifiers

**Decision**: Replace all `claude-3-*` identifiers with the vendor-current set: `claude-opus-5`
(deepest reasoning), `claude-sonnet-5` (primary coding/orchestration), `claude-haiku-4-5-20251001`
(high-frequency lightweight workers). `claude-fable-5` exists but has no role in the current
catalog and is not introduced.

**Rationale**: Principle II requires vendor-current identifiers. `claude-3-opus`,
`claude-3-sonnet`, and `claude-3-haiku` are retired names; a sub-agent dispatched against them
fails or silently falls back, which is worse than failing loudly.

**Alternatives considered**: Keep tier names only ("opus tier", "sonnet tier") with no concrete
IDs — rejected, because the catalog exists precisely so an orchestrator can pass a model
parameter. Mitigation instead: confine IDs to the Tool-Scoped Values section so a future rename
is a one-block edit (FR-004), and state in that block that IDs must be re-verified against the
vendor before use.

## R2. Precedence ordering between conflicting rules

**Decision**: Single ladder, highest first — (1) safety and irreversibility, (2) clarity and
unambiguity, (3) lifecycle compliance, (4) token density. Verbatim reproduction of code, error
strings, API names, and CLI commands sits at level 2 and therefore always outranks compression.

**Rationale**: Today's file states the compression rule and its exceptions but never says which
wins when a rule pair genuinely collides (e.g. an ordered destructive sequence that also happens
to be routine). A single ordered ladder resolves any pair without the tool guessing, satisfying
FR-003 and SC-007.

**Alternatives considered**: Per-rule precedence annotations — rejected as verbose and
combinatorial; violates FR-011 (additions must earn their tokens).

## R3. Degradation semantics for missing capabilities

**Decision**: Each capability-dependent rule gets one stated fallback:

| Assumed capability | Fallback when absent |
|---|---|
| Sub-agents / parallel dispatch | Single-agent sequential execution of the same lifecycle phases; context isolation achieved by reading only the relevant `spec.md`, `plan.md`, and task file |
| Slash commands | Follow the named phase's obligations manually in the same order |
| Git remote / pull request | Review runs against the local diff; the shepherd step is deferred and recorded as pending under `.specify/workflows/runs/` |
| Persistent run log directory | Report state inline in the reply and state that resumption is not recoverable |

**Rationale**: FR-006 and the spec's edge cases. Constitution Principle VI already defines the
no-remote degradation; the other three were previously unstated, so a tool without sub-agents had
no defined behavior and would either fail or improvise.

**Alternatives considered**: Marking orchestration rules "Claude Code only" — rejected; violates
Principle II (a global instruction set that only works in one harness is a local one).

## R4. File shape: rewrite in place vs. split

**Decision**: Keep a single `instructions.md`, rewritten in place. Reorder sections
urgency-first; do not split into multiple files.

**Rationale**: The authoring constraint permits up to 800 lines and the file is 82 today; even
with the added precedence ladder, review chain, tool-scoped block, and degradation table it stays
far under. FR-009 requires a single portable artifact — several tools load exactly one global
instruction file, so a split would be unreadable to them.

**Alternatives considered**: Split into `instructions.md` + `instructions-orchestration.md` linked
by wiki links — rejected: tools that load one file would silently lose the second half, which is
a directive-loss failure under FR-001 in practice even if not on disk.

## R5. Rule phrasing form

**Decision**: Every directive is written as `**Trigger** — obligation. Exception: …`, with MUST /
MUST NOT for hard rules and SHOULD only where genuine latitude exists.

**Rationale**: FR-002. Today several rules state an obligation with no trigger ("Atomic Files:
Enforce flat, highly-focused files") or a trigger with no stop condition, which is what makes
first-read application unreliable (SC-004, SC-005).

**Alternatives considered**: Table-per-section — rejected; the compression protocol forbids
decorative tables, and tables lose the exception clause's nesting.

## R6. Preserving existing content losslessly

**Decision**: Enumerate the current file into a numbered directive register (41 entries) before
editing, and carry a mapping column from each register entry to its destination section. Post-edit
verification walks the register.

**Rationale**: FR-001 and SC-001 demand 100% preservation, and "reads complete" is not evidence.
The register makes the check mechanical. Register lives in [[data-model]].

**Alternatives considered**: `diff` of old vs. new file — rejected; the revision intentionally
rewords and reorders, so a textual diff cannot distinguish a rewording from a deletion.

## Unresolved

None. All Technical Context entries in [[plan]] are resolved; no NEEDS CLARIFICATION remains.
