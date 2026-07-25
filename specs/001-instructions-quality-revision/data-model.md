---
Summary: Directive register of all 41 rules present in the pre-revision instructions.md, with destination sections, plus the entity definitions used by the revision.
Tags: [#data-model #directive-register #instructions]
---

# Data Model: Instructions Quality Revision

Plan: [[plan]] · Spec: [[spec]] · Research: [[research]]

## Entities

### Directive

One enforceable rule. The atomic unit that FR-001 protects.

| Field | Meaning | Validation |
|---|---|---|
| `id` | Stable register key (`D01`…`D41`) | Unique; never reused after retirement |
| `trigger` | Condition that activates the rule | Non-empty after revision (FR-002) |
| `obligation` | Required behavior | MUST / MUST NOT / SHOULD; non-empty |
| `exception` | Termination or suspension condition | May be `none`, but never blank/undefined |
| `origin_section` | Section in the pre-revision file | Non-empty |
| `destination_section` | Target section number(s) in the revised file | A non-empty list of sections drawn from 2–14 (FR-008). Usually one; a directive that has both a tool-neutral role and a vendor-specific value is split across two, and each part is a separate register row |
| `precedence_level` | Position on the ladder | 1 safety · 2 clarity · 3 lifecycle · 4 density |

### Section

Grouped directives under a stable heading.

- `number` — 2–14, ordered by decision urgency, immutable once published. Section 1 is
  frontmatter: it holds metadata, not directives, and is exempt from the rules below (resolves
  `/speckit-analyze` finding F8)
- `heading` — stable text; renaming is a breaking change for tools that cite it
- `directives` — one or more; a section with zero directives MUST be removed, not left empty. The
  empty bodies created by task T005 are transient scaffolding and MUST NOT survive the change set

### Tool-scoped block

Region holding vendor-specific values so they can be updated in isolation (FR-004).

- `target_tool` — the tool the values apply to, or `all-claude-models`
- `values` — model identifiers, slash-command syntax, config keys
- `verify_before_use` — MUST be true; values are re-verified against the vendor at use time
- Invariant: no vendor-specific literal may appear outside a tool-scoped block

### Degradation path

Stated fallback when a target tool lacks an assumed capability (FR-006).

- `assumed_capability` — sub-agents, slash commands, git remote, persistent run log
- `fallback_behavior` — non-empty; "fail" is not an acceptable value
- Invariant: every directive whose obligation assumes a capability references a degradation path

## Directive Register (pre-revision inventory)

Origin sections are the headings in the current 82-line `instructions.md`. Destination numbers
refer to the Target Section Order in [[plan]].

| ID | Directive (abbreviated) | Origin section | Dest. | Prec. |
|---|---|---|---|---|
| D01 | Maximize task execution density, minimize token overhead | Meta-objective | 2 | 4 |
| D02 | Execute software lifecycle via strict engineering workflows | Meta-objective | 2 | 3 |
| D03 | Compress output via the verified linguistic rules | Meta-objective | 2 | 4 |
| D04 | Read codebase/docs as a machine-optimized repository | Meta-objective | 2 | 3 |
| D05 | Persistence: active every response, no filler drift across turns | Caveman | 5 | 4 |
| D06 | Grammar drops: articles, filler words, pleasantries, hedging | Caveman | 5 | 4 |
| D07 | Tokenizer guardrails: standard acronyms only, never invent shortcuts | Caveman | 5 | 2 |
| D08 | Formatting limits: no tool narration, no decorative tables/emoji, no raw log dumps | Caveman | 5 | 4 |
| D09a | Auto-clarity: drop compression for security warnings | Caveman | 4 | 1 |
| D09b | Auto-clarity: drop compression for irreversible-action confirmations | Caveman | 4 | 1 |
| D09c | Auto-clarity: drop compression where fragment order risks execution ambiguity | Caveman | 4 | 2 |
| D09d | Resume compression immediately after the high-risk block clears | Caveman | 4 | 4 |
| D10 | `/caveman lite` — no filler/hedging, full sentences | Session intensity | 6 | 4 |
| D11 | `/caveman full` — default, fragments, ~65% token drop | Session intensity | 6 | 4 |
| D12 | `/caveman ultra` — keywords only, maximum density | Session intensity | 6 | 4 |
| D13 | Brainstorm before code: challenge, explore alternatives, save design doc | Superpowers | 7 | 3 |
| D14 | Plans: bite-sized independent tasks with exact paths, logic, verification | Superpowers | 7 | 3 |
| D15 | Incremental execution: targeted zones only, never rewrite unchanged files | Superpowers | 7 | 3 |
| D16 | TDD: RED-GREEN-REFACTOR; delete code written ahead of its tests | Superpowers | 7 | 3 |
| D17 | Code review: audit against plan, report by severity, CRITICAL freezes branch | Superpowers | 7 | 3 |
| D18 | Strict frontmatter: `Summary:` one sentence plus `Tags:` on every document | LLM Wiki | 9 | 3 |
| D19 | Atomic files: flat and focused; split complex specs or logs | LLM Wiki | 9 | 3 |
| D20 | Bidirectional graph: express dependencies as `[[Wiki Links]]` | LLM Wiki | 9 | 3 |
| D21 | Inbox triage: route unformatted input or pasted logs to `/inbox` | LLM Wiki | 9 | 3 |
| D22 | Frontend glob: strict type safety, component isolation, no redundant re-renders | Path scoping | 10 | 3 |
| D23 | Backend/data glob: connection pools, memory efficiency, deterministic execution | Path scoping | 10 | 3 |
| D24 | Config/infra glob: multi-stage minimal layers, secure dependency pinning | Path scoping | 10 | 1 |
| D25 | No intros, no outros, no style labels or recaps — raw solution data | Output formatting | 5 | 4 |
| D26 | Activation: pivot to orchestrator mode when `.specify/`, `spec-kit/`, or `tasks.md` present | Contextual intelligence | 11 | 3 |
| D27 | Protocol: act as technical director; delegate multi-step milestones, never edit directly | Contextual intelligence | 11 | 3 |
| D28 | Catalog: constitution — deepest-reasoning model, high effort, purple | Skill catalog | 11 + 12 | 3 |
| D29 | Catalog: specify — deepest-reasoning model, max effort, pink | Skill catalog | 11 + 12 | 3 |
| D30 | Catalog: baseline — primary coding model, high effort, violet | Skill catalog | 11 + 12 | 3 |
| D31 | Catalog: clarify — primary coding model, medium effort, orange | Skill catalog | 11 + 12 | 3 |
| D32 | Catalog: plan — deepest-reasoning model, max effort, blue | Skill catalog | 11 + 12 | 3 |
| D33 | Catalog: analyze — deepest-reasoning model, high effort, yellow | Skill catalog | 11 + 12 | 3 |
| D34 | Catalog: tasks — primary coding model, high effort, cyan | Skill catalog | 11 + 12 | 3 |
| D35 | Catalog: checklist — lightweight model, low effort, light yellow | Skill catalog | 11 + 12 | 3 |
| D36 | Catalog: implement — primary coding model, medium effort, green | Skill catalog | 11 + 12 | 3 |
| D37 | Catalog: converge — primary coding model, high effort, red | Skill catalog | 11 + 12 | 3 |
| D38 | Parallelization: dispatch multiple implement sessions to cut time-to-done | Guardrails | 11 | 3 |
| D39 | Quality gate: analyze MUST report converged before any code is written | Guardrails | 11 | 3 |
| D40 | Context management: sub-agents receive isolated context to prevent context rot | Guardrails | 11 | 3 |
| D41 | Resilience: persist orchestration logs and state under `.specify/workflows/runs/` | Guardrails | 11 | 3 |

**Count**: 41 directives (D09 counted as four distinct obligations). SC-001 requires all 41 to be
locatable in the revised file.

## Directives added by this revision

New entries extend the register; they do not replace anything above.

| ID | Directive | Section | Source requirement |
|---|---|---|---|
| D42 | First-read bootstrap: on load, apply precedence ladder, then compression, then lifecycle | 2 | FR-010 |
| D43 | Precedence ladder: safety > clarity > lifecycle > density | 3 | FR-003 |
| D44 | Verbatim preservation of code, error strings, API names, CLI commands outranks compression | 3 | FR-003, Principle IV |
| D45 | Review chain: reviewer first, shepherd only after review closes | 8 | FR-005, Principle VI |
| D46 | CRITICAL review findings freeze the branch; automerge MUST NOT be armed | 8 | FR-005, Principle VI |
| D47 | Silence is consent to run the review chain; skipping requires an explicit per-change opt-out | 8 | FR-005, Principle VI |
| D48 | Vendor values live only in the tool-scoped block and MUST be re-verified before use | 12 | FR-004 |
| D49 | Degradation: no sub-agents → sequential single-agent execution of the same phases | 13 | FR-006 |
| D50 | Degradation: no slash commands → follow the phase obligations manually in order | 13 | FR-006 |
| D51 | Degradation: no git remote → review the local diff, log the shepherd step as pending | 13 | FR-006, Principle VI |
| D52 | Degradation: no run-log directory → report state inline, declare resumption unrecoverable | 13 | FR-006 |
| D53 | Conversational language mirrors the operator; every persisted artifact is English | 2 | Principle III |
| D54 | Never emit secrets, operator-identifying data, or machine-local absolute paths | 3 | FR-012, authoring constraints |
| D55 | Title carries an explicit MAJOR.MINOR.PATCH version, baseline 4.0.0 | 1 + 2 | FR-013, Principle VII |
| D56 | Instruction content is wrapped in the `AI-JEDI:INSTRUCTIONS` marker pair; start marker carries the version, end marker does not | 1 | FR-016, Principle IX |
| D57 | Updating an installed tool replaces only the marked span; content outside is never read for decisions, moved, or rewritten | 2 | FR-016, Principle IX |
| D58 | Projections target each tool's global user-level config; writing the region into project-local config is prohibited | 13 | FR-017, Principle IX |
| D59 | Provisioning: detect installed skills by reading the integration manifests, not by guessing filesystem layout | 13 | FR-014, Principle VIII |
| D60 | Provisioning: install with the SpecKit version pinned to the recorded value; verify against the manifest SHA256 and report drift | 13 | FR-014, Principle VIII |
| D61 | Invocation syntax is derived from the active integration's configured separator, never written as a literal in shared content | 12 | FR-015, Principle VIII |
| D62 | Catalog and manifests must agree — no catalogued-but-unavailable skill, no available-but-uncatalogued skill; verify before dispatching a phase | 11 + 13 | FR-015, Principle VIII |
| D63 | A skill unavailable in the active harness resolves to its degradation path; the phase is followed manually, never dropped | 14 | FR-006, Principle VIII |

## State transitions

A directive moves `registered → mapped → written → verified`. Verification is the register walk in
[[quickstart]]; a directive that reaches `written` but fails `verified` blocks the change.
