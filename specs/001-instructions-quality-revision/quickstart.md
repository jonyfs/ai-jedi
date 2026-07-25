---
Summary: Validation guide proving the revised instructions.md is lossless, current, self-locating, and correctly applied by real AI tools.
Tags: [#quickstart #validation #instructions]
---

# Quickstart: Validating the Instructions Quality Revision

Plan: [[plan]] · Contract: [[contracts/instructions-file-contract]] · Register: [[data-model]]

## Prerequisites

- Working directory: the repository root
- A pre-revision copy of `instructions.md` preserved for the register walk (the register in
  [[data-model]] is itself sufficient; a file copy is optional convenience)
- At least one installed AI coding tool available for behavioral probes

## Step 1 — Losslessness (SC-001, FR-001)

Walk the register. For each of `D01`…`D41`, locate the surviving directive in the revised file and
record its destination section.

```bash
grep -n '^#\{1,3\} ' instructions.md   # confirm sections 2-14 exist in order
```

**Expected**: 41 of 41 register entries located, each in the destination section named in
[[data-model]], each with equal or stricter force. Any entry that cannot be located is a blocking
defect — restore it before proceeding.

## Step 2 — Staleness and isolation (SC-002, FR-004)

```bash
grep -n 'claude-3' instructions.md          # expected: no output
grep -c 'claude-opus-5\|claude-sonnet-5\|claude-haiku-4-5' instructions.md
```

**Expected**: zero `claude-3*` matches. All current identifiers appear only inside the
Tool-Scoped Values section — verify by line number that every match falls between that section's
heading and the next heading (invariant I5).

## Step 3 — Structural self-compliance (SC-006, FR-007)

```bash
head -4 instructions.md      # expected: --- / Summary: ... / Tags: [...] / ---
wc -l instructions.md        # expected: well under 800
grep -c '\[\[' instructions.md   # expected: >= 1 wiki link
grep -nE '/Users/|/home/|ghp_|sk-' instructions.md   # expected: no output
```

**Expected**: compliant frontmatter, under the line ceiling, wiki links present, no
machine-local absolute paths and no credential-shaped strings (invariants I8, I9, FR-012).

## Step 4 — Governance coverage (SC-003, FR-005)

For each constitutional principle that imposes runtime behavior (I through XII), confirm at
least one directive in the revised file carries the obligation. Principle VI specifically requires
the reviewer-then-shepherd ordering, the CRITICAL-freezes-branch rule, and the
silence-is-consent rule to be stated.

```bash
grep -ni 'review chain\|shepherd\|CRITICAL' instructions.md
```

**Expected**: matches present, ordering constraint explicit.

## Step 5 — Precedence completeness (SC-007, FR-003)

Read the Precedence Ladder section. For each of these pairs, confirm the ladder resolves it without
interpretation:

1. Compression vs. a destructive-action warning
2. Compression vs. verbatim reproduction of an error string
3. Density vs. an ordered multi-step sequence
4. Lifecycle routing vs. an operator asking for a one-line fix now

**Expected**: all four resolved by the ladder alone; zero pairs requiring a judgment call.

## Step 6 — Behavioral probes across tools (SC-004)

For each installed tool, start a fresh session loading only the revised `instructions.md`, then run
the six acceptance surfaces from [[contracts/instructions-file-contract]]:

| Probe | Prompt | Expected |
|---|---|---|
| Compression | A short technical question | Compressed reply, no filler, no tool narration |
| Auto-clarity | Ask for a destructive command | Full precise prose for that block, then resumes |
| Lifecycle | Ask for a multi-step feature | Routes through the lifecycle, no ad-hoc edits |
| Frontmatter | Ask it to create a Markdown note | Compliant `Summary:` / `Tags:` frontmatter |
| Review chain | Ask it to finish an implementation unit | Reviewer runs first, unprompted |
| Locatability | "Which rule governs X?" | Names the correct section, first attempt |

**Expected**: passes in at least 3 of 3 tools tested (SC-004); locatability correct on the first
attempt for at least 5 sampled situations (SC-005).

## Step 6B — Version, region, and provisioning (SC-008, SC-009, SC-010)

```bash
head -1 instructions.md | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+'   # esperado: v0.0.1
grep -c 'AI-JEDI:INSTRUCTIONS:START\|AI-JEDI:INSTRUCTIONS:END' instructions.md   # esperado: 2
grep -n 'AI-JEDI' CLAUDE.md   # esperado: sem saída — região proibida em config local
grep -oE '/speckit\.[a-z]+' instructions.md   # esperado: sem saída — forma com ponto foi migrada
```

Catalog vs. manifest (SC-009): compare the section 11 catalog against
`.specify/integrations/claude.manifest.json`. Every catalogued skill must appear in the manifest
and vice versa — `baseline` must be gone, `taskstoissues` must be present.

Refresh trial (SC-010): copy a global config file carrying the region to a scratch path, ask an
agent to refresh it, then confirm only the marked span changed, the start marker's version
advanced, and content outside the region is byte-identical. Repeat the three failure cases: version
already current (no write), single marker (refuses), path inside a project tree (refuses).

Tier vocabulary (SC-011):

```bash
grep -cE 'deep-reasoning|balanced-coding|fast-lightweight' instructions.md   # esperado: >= 10
grep -nE 'claude-[a-z0-9.-]+' instructions.md   # esperado: apenas dentro da seção 12
```

Agent materialization (SC-012): ask an agent to set up the tooling, then confirm one definition per
available catalogued skill, each carrying the tier, effort, and scope of its catalog row. Run it a
second time — nothing changes. Plant an operator-authored agent sharing a catalogued name and
confirm the collision is reported, not overwritten.

Parallel execution rules (SC-013, SC-014):

```bash
grep -cE 'worktree' instructions.md          # esperado: >= 1 na seção 11
git worktree list                            # esperado: só o principal — nenhum órfão
```

Confirm section 11 states parallel-by-default, one worktree and branch per unit, no two agents in
one working copy, dependency-order merging, and worktree cleanup. Confirm section 8 states
PR-per-story with base and dependency position, and that no `[P]` marking in `tasks.md` sits on a
task writing `instructions.md`.

**Expected**: version present and consistent, exactly one marker pair, no region in project-local
config, zero dot-form command references, catalog reconciled, all three refusal cases honored, tier
tokens only outside section 12, agent set idempotent and collision-safe, parallel and PR rules
stated, zero orphaned worktrees, zero false `[P]` markings.

## Step 6C — README coverage and honesty (SC-015)

```bash
head -4 README.md                     # esperado: frontmatter com Summary e Tags
grep -oE 'v?0\.0\.1' README.md        # esperado: versão presente e igual ao título
grep -nE '/Users/|/home/|ghp_|sk-' README.md   # esperado: sem saída
```

Coverage: list every capability in the shipped `instructions.md` and confirm each is represented in
the README. A capability absent from the README is a capability the operator will not find.

Honesty: for each benefit claim in the README, name the directive in [[data-model]] that backs it. A
claim with no backing directive MUST be removed — not softened. Confirm the tools listed are only
those actually exercised in Step 6.

**Expected**: zero missing capabilities, zero unbacked claims, zero version mismatch, zero implied
coverage of untested tools.

## Step 7 — Constitution gate before implementation (Principle V)

Run `/speckit-analyze` and confirm it reports convergence across `spec.md`, `plan.md`, and
`tasks.md` before any edit to `instructions.md` is made.

## Step 8 — Autonomous review-to-merge loop (Principle VI, SC-016)

The chain runs automatically when the pull request is opened — no one asks for it:

1. `/pr-reviewer` against the pull request.
2. `/pr-shepherd` only after the review closes; resolves comments, conflicts, and checks, fixing
   only what review raised.
3. `/pr-reviewer` again, against the shepherd's own diff. Those edits are code no reviewer has seen.
4. Repeat until a review closes clean, then automerge lands the change on `main`.

CRITICAL findings freeze the change until resolved.

Verify the bounds hold (SC-016):

- The loop halts and reports at the round limit rather than iterating indefinitely.
- The shepherd's diff contains nothing beyond the findings it was resolving.
- Branch protection on `main` is unchanged after the loop — required pull requests, required
  conversation resolution, and `enforce_admins` all still set.
- An unconverged change is left open with its state recorded, not merged.
- Every round appears in `.specify/workflows/runs/001-instructions-quality-revision.md`.

## Definition of done

- Steps 1–5 pass with zero blocking defects
- Step 6 passes across the tools tested
- Step 6B passes: version consistent, one marker pair, no project-local region, catalog reconciled,
  all three refusal cases honored
- Step 6C passes: README covers every capability, every claim is directive-backed, version matches
- Step 7 reports converged
- Step 8 recorded in the run log
