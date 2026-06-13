# AGENTS.md

Tool-agnostic agent entry point for this repository.

## Project

**Smash** — badminton court finder. Monorepo: `apps/`, `packages/`, `services/`, `docs/`.

## Git workflow

- **Never commit directly to `main` or `dev`.**
- Branch off `dev` using one of these prefixes: `feature/`, `fix/`, `chore/`, `docs/`, `refactor/`, `test/`, `style/`, `perf/`.
- **Hotfixes** (`hotfix/`) branch off `main` and merge into both `main` and `dev`.
- All commits must be atomic and use conventional commit format: `type(scope): description`.
- PRs require:
  - Conventional commit title (e.g. `feat: venue list screen`)
  - Body with `## Summary` (bullet points) and `## Test plan` (checklist)
  - At least one label: `feature`, `fix`, `chore`, `docs`, `refactor`, `test`, `style`, `perf`
  - Assignee: `rajanmali`
- Squash-merge after CI passes.

## Key references

| Resource | Path |
|---|---|
| Full project and workflow instructions | `CLAUDE.md` |
| Domain vocabulary and invariants | `CONTEXT.md` |
| Architecture decisions | `docs/adr/` |
| Issue tracker conventions | `docs/agents/issue-tracker.md` |
| Triage label vocabulary | `docs/agents/triage-labels.md` |
| Domain doc consumption guide | `docs/agents/domain.md` |
| Multi-agent orchestration loop | `docs/agents/orchestration.md` |

Read `CONTEXT.md` and the relevant `docs/adr/` files before working in any area of the codebase.

## Multi-agent orchestration

Multi-agent work (orchestrator + per-PR implementation subagents) follows the loop defined in `docs/agents/orchestration.md`.
