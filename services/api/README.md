# @smash/api

NestJS backend for Smash. Part of the monorepo (`npm` workspaces); run from the repo root with Turborepo (`npx turbo build typecheck lint test`) for normal development.

## Railway deployment

The backend deploys to Railway from this directory.

- **Root Directory** — set the Railway service Root Directory to `services/api`. That is where `railway.json` lives and what `startCommand: node dist/main.js` assumes.
- **Build** — `railway.json` uses the NIXPACKS builder. NIXPACKS auto-runs `npm install` followed by `npm run build` (`nest build` → `dist/main.js`), then starts the app with `node dist/main.js`.
- **No service-level lockfile** — there is intentionally no `services/api/package-lock.json`; the only lockfile is the monorepo root's. With the service root set to `services/api`, Railway has no local lockfile, so it installs with `npm install` (rather than `npm ci`). That is expected and fine — do **not** add a second lockfile to this directory.
- **Healthcheck path** — `/api/v1/health`. The app sets a global `api/v1` prefix in `main.ts`, and the health controller is `@Controller('health')`, so the live endpoint is `/api/v1/health` (not `/health`). `railway.json` must point its `healthcheckPath` here, or every deploy fails the healthcheck.

### Required environment variables

| Variable | Required | Notes |
|---|---|---|
| `SUPABASE_URL` | yes | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | yes | Supabase service role key |
| `PORT` | provided by Railway | App reads `process.env.PORT`; Railway injects it |
| `SENTRY_DSN` | optional | Enables Sentry error tracking |
| `NODE_ENV` | optional | Set to `production` |
