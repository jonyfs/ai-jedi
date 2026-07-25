---
Summary: Validation guide proving instructions.md v0.1.0 states the check gate, standing merge authorization, and skip-fixer rule without losing prior directives.
Tags: [#quickstart #validation #review-loop]
---

# Quickstart: Validating the Review Loop Check Gate

Plan: [[plan]] · Spec: [[spec]]

## Prerequisites

- Working directory: the repository root
- `main` carries `instructions.md` v0.0.1 as the pre-change reference (`git show main:instructions.md`)

## Step 1 — Version and region integrity (SC-007)

```bash
head -1 instructions.md | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+'          # expected: v0.1.0
grep -oE 'AI-JEDI:INSTRUCTIONS:START v[0-9.]+' instructions.md         # expected: v0.1.0
grep -c 'AI-JEDI:INSTRUCTIONS' instructions.md                         # expected: 2
head -3 instructions.md | grep -c 'v0.1.0'                             # frontmatter agrees with title
```

**Expected**: title and start marker both `v0.1.0`, exactly one marker pair, frontmatter not
contradicting the title.

## Step 2 — Five check states present (SC-001, FR-001…FR-004)

```bash
sed -n '/^## 8\./,/^## 9\./p' instructions.md | grep -ciE 'green|pending|unrelated|absent'
grep -ci 'never treat pending as passing\|pending as passing' instructions.md
grep -ci 'not a blocker\|no checks existed' instructions.md
```

Read the check-gate subsection and confirm each of the five states maps to exactly one action:

| State | Required action |
|---|---|
| Green | Merge |
| Pending or queued | Wait; never treated as passing |
| Failing from the change | Return to the loop as a finding |
| Failing unrelated to the change | Halt and report; never handed to the fixer |
| No checks configured | Not a blocker; merge on review approval; absence recorded |

**Expected**: all five present, each with one unambiguous action, and the judgment-call rule (FR-003)
stated with its evidence requirement.

## Step 3 — Standing authorization and its boundary (SC-002, SC-003, FR-005, FR-006)

```bash
grep -ci 'standing' instructions.md
grep -ci 'without asking\|does not request confirmation\|no confirmation' instructions.md
```

Confirm the exclusion list is explicit and complete — the consent must NOT cover:

- weakening branch protection
- force pushing
- deleting an unmerged branch
- merging over an open blocking finding

**Expected**: standing consent stated, requesting confirmation prohibited, and all four exclusions
named. A missing exclusion is a blocking defect: it would let a standing grant leak into a
destructive action.

## Step 4 — Skip-fixer rule (SC-004, FR-007)

```bash
sed -n '/^## 8\./,/^## 9\./p' instructions.md | grep -ci 'no findings'
```

**Expected**: the file states that a review closing with no findings skips the fixer entirely, and
says why — a no-op invocation produces a diff the re-review step must then examine.

## Step 5 — Directive form (FR-008)

```bash
sed -n '/^## 8\./,/^## 9\./p' instructions.md | grep -c '\*\*Trigger\*\*'
sed -n '/^## 8\./,/^## 9\./p' instructions.md | grep -c 'Exception'
```

**Expected**: every added directive carries a trigger, an obligation, and an exception field, with
`Exception: none` written explicitly where none exists. Trigger and exception counts must both be
non-zero and consistent.

## Step 6 — Nothing lost (SC-006, FR-009)

```bash
git show main:instructions.md > /tmp/pre.md
diff <(grep -oE '^\s*- \*\*[A-Za-z-]+\.\*\*' /tmp/pre.md) \
     <(grep -oE '^\s*- \*\*[A-Za-z-]+\.\*\*' instructions.md)
wc -l instructions.md    # expected: under 800
```

Walk every directive present in the pre-change file and locate it in the revised one.

**Expected**: zero directives missing, none weakened, file under the line ceiling. Any loss is a
blocking defect.

## Step 7 — Governance coverage (SC-005)

Compare section 8 against Principle VI in `.specify/memory/constitution.md`. Every constitutional
obligation about the review loop must have a corresponding directive.

Known and accepted divergence: the constitution names the reviewer and fixer skills literally; the
instruction file refers to them by role, because Principle II forbids literal command forms in shared
content. This is intentional — see the Design Decisions in [[plan]].

**Expected**: zero gaps other than that recorded divergence.

## Step 8 — README parity (Principle XII)

```bash
grep -ci 'check gate\|pending\|standing' README.md
```

**Expected**: the README's review-chain section describes the check gate and the standing
authorization in operator terms, with every claim backed by a directive now in the file. A README that
still describes only the pre-change loop is stale.

## Step 9 — Review-to-merge loop (Principle VI)

The loop runs automatically on the pull request. Round limit 3. This repository has no configured
checks, so the check gate resolves to the absent case: merge proceeds on review approval, and the
absence is recorded in the run log.

## Definition of done

- Steps 1–8 pass with zero blocking defects
- Step 9 recorded in `.specify/workflows/runs/002-review-loop-check-gate.md`
