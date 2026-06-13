# Agent orchestration loop

How multi-agent work is structured in this repo: one orchestrator, one subagent per PR.

## Roles

**Orchestrator** (strongest available model — currently Fable) acts as tech lead:
- Writes verbose per-PR specs before dispatching any subagent.
- Reviews every diff against the spec before merging.
- Owns all architecture, merge, and judgment decisions.
- Does not implement token-heavy code itself.

**Implementation subagents** — one per PR, model chosen by task profile:

| Model | Task profile |
|---|---|
| **opus** | Fiddly integration and pattern-setting work: build systems, CI workflows, concurrency bridging, native SDK integration, the first screen that sets project patterns. |
| **sonnet** | Contract-pinned or test-pinned translation and boilerplate: model layers from a written API contract, porting logic that existing tests pin down, docs from a fully-specified outline. |
| **haiku** | Trivial mechanical edits only. |

## The loop (per PR)

1. **Orchestrator confirms a clean base** — `git checkout dev && git pull origin dev`.
2. **Orchestrator writes the spec handoff** — exact files, behaviors, oracle references (file paths into existing code/tests), commit breakdown, PR title/body/label/assignee, and the explicit instruction: _"STOP after CI passes; do not self-merge."_
3. **Orchestrator dispatches ONE general-purpose subagent** with the appropriate model override.
4. **Subagent executes**:
   - Branch off `dev`.
   - Atomic conventional commits (one concern per commit).
   - Open PR with Summary/Test plan body, ≥1 label, assignee `rajanmali`.
   - `gh pr checks <number> --watch` until all checks complete.
   - Stop — do not merge.
5. **Orchestrator reviews** `gh pr diff` against the spec: contract fidelity, test-assertion parity, design-token values, no scope creep. Fixes are requested via a follow-up message to the same subagent (its context stays intact).
6. **Orchestrator squash-merges**, pulls `dev`, dispatches the next PR.

## Coding ideology

- **Test-oracle-first**: behavioral pins (ported/unit tests) land before any consumer code.
- **One concern per PR**: CI must be green at every step of the sequence.
- **Specs are the contract**: subagents implement; the orchestrator owns judgment (architecture, review, merge).
- **Deterministic codegen over hand-maintained artifacts**: e.g., XcodeGen project generation over a checked-in `pbxproj`.
- **Deliberate deviations from a port oracle** must be named in the spec and carried into the parity checklist — never silently "fixed."
