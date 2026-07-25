---
Summary: Runnable grep-based verification procedure for the merge-scope propagation, one step per success criterion, usable before and after the edit.
Tags: [#quickstart #verification #instructions #merge-authorization #greps]
---

# Quickstart: Verifying Merge-Scope Propagation

Instruction content has no executable surface, so this procedure IS the test suite for SC-001 through
SC-005. Run from the repository root. Each step states its expectation, so a step that passes for the
wrong reason is visible.

## Step 1 — SC-002: no deictic reference to the authorized repository

```sh
sed -n '/^## 8\./,/^## 9\./p' instructions.md | grep -ic 'this repository'
```

**Expect `0`.** This is the defect that reached round 1 of the constitution amendment: a rule whose
meaning changes with the reader's position.

**This step is a REGRESSION GUARD, not a RED test.** It already returns `0` before the edit, because
section 8 says nothing about scope yet. It earns its place by failing the moment the wrong wording is
introduced — which is exactly what happened one feature ago. Do not read its passing at baseline as
evidence the requirement is met.

## Step 2 — SC-001: the scope test is a working-tree lookup

```sh
sed -n '/^## 8\./,/^## 9\./p' instructions.md | grep -c '\.specify/memory/constitution\.md'
```

**Expect at least `1`.** The rule must name the file whose presence-and-content decides authorization.
Absent that, an agent has no procedure and will fall back to its location.

## Step 3 — SC-001: the halt behaviour is stated, not implied

A bare `grep -c halt` is useless here: section 8 already contains six occurrences, all about
unrelated-check failures. It would pass before any edit — the vacuous assertion this project keeps
relearning. Scope the grep to the scope block itself:

```sh
sed -n '/^\*\*Scope of the standing authorization/,/^\*\*Autonomy bounds/p' instructions.md \
  | grep -ci 'halt'
```

**Expect at least `1`, and `0` before the edit** — the range does not exist yet, so this one IS a real
RED test. Read the match: it must say the chain runs in full and stops at the merge. "Do not merge"
alone would leave an agent unsure whether to review at all.

## Step 4 — SC-003: Orchestrator Mode does not fire on a stray tasks.md

```sh
sed -n '/^## 11\./,/^## 12\./p' instructions.md | sed -n '1,6p'
```

**Expect** the trigger to require a SpecKit installation. A bare `tasks.md` must not be sufficient.
Read it rather than grepping for a token — the defect here is breadth of wording, not a missing string.

## Step 5 — SC-004: no unmeasured figure stated as fact

```sh
sed -n '/^## 6\./,/^## 7\./p' instructions.md | grep -n '%'
```

**Expect** every match to be either accompanied by its measurement method or explicitly marked
unmeasured. A bare `~65%` fails.

## Step 6 — SC-005: every assumed capability has a degradation row

```sh
sed -n '/^## 14\./,/INSTRUCTIONS:END/p' instructions.md | grep -c 'integration\.json'
```

**Expect at least `1`.** Section 12 derives the invocation separator from that file; outside a SpecKit
repository it is absent, which is the normal case for a machine-wide surface.

## Step 7 — version and frontmatter agree

```sh
grep -c 'v0\.2\.0' instructions.md
grep -m1 'INSTRUCTIONS:START' instructions.md
```

**Expect** the title, the frontmatter `Summary`, and the start marker to all read `v0.2.0`, and no
`v0.1.0` to remain.

## Step 8 — SC-006 / SC-007: projections and suite

```sh
for t in claude-code opencode gemini copilot codex; do
  sh .specify/adapters/tests/run-tests.sh --target "$t" | tail -1
done
for t in claude-code opencode gemini copilot codex; do
  sh .specify/adapters/project.sh --target "$t" --
done
for t in claude-code opencode gemini copilot codex; do
  sh .specify/adapters/project.sh --target "$t" --check | tail -1
done
```

**Expect** 72/0/0 for claude-code and opencode, 65/0/1 for the other three; then all five reporting
`current (v0.2.0)`.

**Also confirm the content is identical across targets** — one cksum for five files:

```sh
for f in ~/.claude/CLAUDE.md ~/.config/opencode/AGENTS.md ~/.gemini/GEMINI.md \
         ~/.config/github-copilot/intellij/global-copilot-instructions.md ~/.codex/AGENTS.md; do
  sed -n '/AI-JEDI:INSTRUCTIONS:START/,/AI-JEDI:INSTRUCTIONS:END/p' "$f" | cksum
done | sort -u | wc -l
```

**Expect `1`.**

**And confirm the foreign region survived**, comparing OpenCode's caveman span to its pre-run backup:

```sh
grep -c 'caveman-begin' ~/.config/opencode/AGENTS.md
```

**Expect `1`.** Zero means the projection destroyed another tool's configuration, which is the worst
outcome this adapter can produce.

## Step 9 — the ceiling

```sh
wc -l < instructions.md
```

**Expect under 800.** Section 9 sets 200–400 typical and 800 maximum. Crossing it would make the file
violate its own rule, which is exactly the situation the constitution hit at 800/800 before this
feature's predecessor split it.
