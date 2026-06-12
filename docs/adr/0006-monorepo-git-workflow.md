# ADR-0006: Monorepo and git workflow

**Status:** Accepted (git workflow updated post-initial-planning)

## Context

Solo developer with multiple deployable units: mobile app, backend API, sync worker, and shared packages. Need a version control strategy that keeps cross-cutting changes atomic without multi-repo PR coordination overhead.

## Decision

Single monorepo with workspaces (`apps/`, `services/`, `packages/`).

**Branch model:**
- `main` — production. GitHub Pages serves from here. Never commit directly.
- `dev` — default working branch. Never commit directly.
- All changes branch off `dev` using prefixes: `feature/`, `fix/`, `chore/`, `docs/`, `refactor/`, `test/`, `style/`, `perf/` — merged back into `dev` via PR.
- `hotfix/` branches off `main`, merges into both `main` and `dev`.
- `release/vX.Y.Z` branches off `dev`, merges into `main` via PR.

Conventional commits (`feat:`, `fix:`, `chore:`, etc.) on all branches.
CI required to pass on every PR before merge.

## Consequences

- Simpler dependency management between shared types/clients and their consumers.
- CI must be scoped per workspace to stay fast enough not to bottleneck development.
- The `main`/`dev` direct-push prohibition is enforced via GitHub Rulesets (not just convention).
