---
Summary: Operator guide to AI Jedi — what the single global instruction set gives you across every installed AI coding tool, how its five adapters install it, and what the project deliberately does not claim.
Tags: [#readme #onboarding #instructions #operator-guide #adapter #projection]
---

# AI Jedi

**Instruction version: `0.1.0`**

One file — [`instructions.md`](instructions.md) — configures every AI coding tool on your machine.
Write a rule once; every tool that loads the file behaves the same way.

`0.y.z` is deliberate: this surface is in initial development and any rule may change. It is not
`1.0.0` and does not pretend to be.

## What you get

Each benefit below is backed by a directive in `instructions.md`. Nothing here describes behavior the
file does not actually mandate.

### Shorter answers that stay correct

Replies drop articles, filler, pleasantries, and hedging — roughly 65% fewer tokens at the default
level. What does **not** get shortened is the part that would cost you: security warnings,
irreversible-action confirmations, ordered sequences where fragment order changes meaning, and any
code block, error string, API name, or CLI command, which are reproduced exactly.

You choose the level: `lite` keeps full sentences, `full` is the default, `ultra` is keywords only.

→ [Output Compression Protocol](instructions.md#5-output-compression-protocol), [Auto-Clarity Exceptions](instructions.md#4-auto-clarity-exceptions),
[Intensity Levels](instructions.md#6-intensity-levels)

### No rule ever collides with another

A single precedence ladder — safety, then clarity, then lifecycle, then density — resolves any
conflicting pair. The tool never has to guess which rule wins, so two sessions reading the same file
resolve the same conflict the same way.

→ [Precedence Ladder](instructions.md#3-precedence-ladder)

### Work routes through a lifecycle instead of ad-hoc edits

Anything beyond a typo goes brainstorm → plan → incremental execution → test-first → review. Plans
break into 2–5 minute tasks with exact paths and verification steps. Unchanged files are never
rewritten. Review findings are severity-ranked, and CRITICAL findings freeze the branch.

→ [Engineering Lifecycle](instructions.md#7-engineering-lifecycle)

### Review runs itself, all the way to merge

Open a pull request and the chain starts without being asked: review, fix, then **re-review the
shepherd's own changes** — because those edits are content no reviewer has seen. It loops until a
review closes clean, then merges and deletes the branch. A review that finds nothing skips the fix
step entirely, so a clean change does not burn a round on an empty diff.

**It does not stop to ask.** When every gate is clear the merge completes without a confirmation
prompt — an automation that asks each time is just a prompt with extra steps. The grant covers merging
and nothing else: weakening branch protection, force pushing, deleting an unmerged branch, and merging
over an open blocking finding each still require your explicit say-so.

**Automated checks are read, not guessed at.** Five states, five actions: green merges, pending waits
(never counted as passing), a failure caused by your change goes back through the loop, and a failure
caused by something else — an outage, expired credentials, a runner that never started — halts and
reports instead of being handed to the shepherd as a phantom bug. A repository with no checks configured
is not treated as broken: the merge proceeds on review approval and the absence is recorded, so later
you can tell "checks passed" from "there were no checks".

The autonomy is bounded on purpose. Three rounds maximum. Fixes stay inside what review raised. An
unconverged change is left open, never merged.

→ [Post-Implementation Review Chain](instructions.md#8-post-implementation-review-chain)

### Files an AI can actually navigate

Every document opens with an accurate one-line summary and tags, so a tool with limited context can
decide whether to load it. Files stay atomic — 200–400 lines typical, 800 maximum. Dependencies are
explicit wiki links.

→ [File Architecture](instructions.md#9-file-architecture)

### Rules that know where they apply

Frontend, backend/data, and config/infra paths each carry their own constraints, applied when the
edited path matches.

→ [Path-Scoped Rules](instructions.md#10-path-scoped-rules)

### Parallel work that does not corrupt itself

Independent units run in parallel, each in its own worktree on its own branch. Two agents never share
a working tree — that is how one agent's edits silently overwrite another's.

The honest caveat is stated in the file itself: **isolation does not create parallelism when the work
contends for a single file.** Such units are marked serial rather than advertising speed that cannot
be delivered.

→ [Orchestration](instructions.md#11-orchestration)

### Model choice that survives vendor renames

The skill catalog names a capability tier — `deep-reasoning`, `balanced-coding`, `fast-lightweight` —
never a vendor model name. Concrete identifiers live in one tool-scoped block, so a rename is a
one-block edit. A harness with fewer tiers collapses **upward**: your deep-reasoning work is never
silently downgraded to save cost.

→ [Tool-Scoped Values](instructions.md#12-tool-scoped-values)

### Tooling that installs and verifies itself

Rather than naming skills and leaving you to wire them up, the file explains how to detect what is
installed, install what is missing, and verify it against per-file checksums. Agent definitions are
created idempotently and never overwrite an agent you wrote yourself — a name collision is reported,
not clobbered.

→ [Agent Provisioning](instructions.md#13-agent-provisioning)

### Updates that cannot damage your config

The instruction content sits between explicit markers carrying the version. Ask any tool to refresh
your AI Jedi instructions and it replaces only that span — everything you wrote outside it stays
byte-identical. If the markers are missing or malformed, it reports and stops instead of guessing.

Updates target each tool's **global** configuration, never a project-local file, so one instruction
set really does apply everywhere.

→ [Managed region update](instructions.md#managed-region-update)

### Nothing fails silently

Every rule that assumes a capability names its fallback: no sub-agents, no slash commands, no git
remote, no run-log directory, a skill missing from the harness. The phase degrades and reports. It is
never skipped.

→ [Degradation Paths](instructions.md#14-degradation-paths)

## Governance

`instructions.md` is the only authoritative instruction text. Every tool-specific file is a generated
or linked projection of it — never a hand-edited fork. Changes progress through the spec-driven
lifecycle in [`.specify/memory/constitution.md`](.specify/memory/constitution.md), which currently
defines 12 principles and outranks the instruction file wherever they disagree.

Conversation happens in your language. Every persisted artifact is written in English.

## Tools exercised

The instruction set is written to be tool-neutral, and the constitution requires an adapter per tool
rather than a rewrite. Being precise about what has actually been tested:

| Tool | Status |
|---|---|
| Claude Code | **Projected** — `~/.claude/CLAUDE.md` |
| OpenCode | **Projected** — `~/.config/opencode/AGENTS.md`, alongside an untouched caveman region |
| Gemini | **Projected** — `~/.gemini/GEMINI.md` |
| GitHub Copilot | **Projected** — `~/.config/github-copilot/intellij/global-copilot-instructions.md` |
| Codex | **Projected** — `~/.codex/AGENTS.md`, created by the adapter |
| Cursor | **Not covered** — no global instruction file found; its config directory holds only agent definitions placed by other tooling |
| Windsurf | **Not covered** — same |

Five adapters live at `.specify/adapters/`: one `project.sh` and one declaration per tool under
`targets/`. Adding a tool means adding a declaration, not copying a script.

```sh
sh .specify/adapters/project.sh --target opencode          # project
sh .specify/adapters/project.sh --target opencode --check  # is it current?
```

Omit `--target` and it defaults to Claude Code.

Two of your installed tools are listed as not covered rather than omitted. Neither exposes a global
instruction file this project could find, and inventing a plausible path would produce an adapter writing
somewhere the tool never reads — a claim of coverage that does not exist.

## Status

Honest current state rather than an aspirational one:

- Instruction set: `0.1.0`. First release was `0.0.1`.
- Constitution: 12 principles, v1.17.0.
- Adapters: five, sharing one script. 14 test groups run against every target: 72 assertions for
  Claude Code and OpenCode, 65 plus one honest SKIP for Gemini, Copilot and Codex — those three
  declare `foreign_markers: []`, so there is no other tool's region to preserve and the group says so
  rather than reporting a green it did not earn. 339 assertions in total, all passing. Zero
  `shellcheck` findings.
- Behavioral verification: not yet performed. The projections exist and are verified byte-for-byte, but
  nobody has yet opened a fresh session in Codex, Copilot, Gemini or OpenCode to confirm each actually
  applies the rules it now carries.
- Model identifiers: verified for Claude Code only. The other four declarations carry
  `tier_map_verified: false` — their identifiers were written from plausibility, not from a vendor
  document, and each should be resolved before anything dispatches against it.
