# X46 LIMS

Laboratory Information Management System (lab / hospital / diagnostic center
back office) — patient registration, billing, sample accessioning, results,
reporting, and finance, built module by module against a fixed set of API
contracts and a fixed DB schema.

## Repo layout

| Path | What |
|---|---|
| `backend/` | Spring Boot 4 backend (Java 21, Spring Data JPA, Flyway, PostgreSQL). See `backend/plan.md` for the implementation blueprint and `backend/progress.md` for chunk-by-chunk status. |
| `database/` | Schema source of truth (`database/schema/`), API contracts (`database/api_contracts_json/`), and validation/seed scripts. |
| `Screens/` | Frontend prototype reference (no backend attached) used to derive contract conventions. |
| `frontend/` | Next.js 16 platform-admin app (org/branch creation, monitoring dashboard, org-scoped user login). |
| `scripts/` | Reserved, currently empty. |

## Governing docs

- `CLAUDE.md` — coding standards, architecture constraints, and rules for
  code generation in this repo. Read this first.
- `AGENTS.md` — agent execution instructions.
- `backend/plan.md` — the 13-module, 53-chunk implementation blueprint and
  every API contract mapping.
- `backend/progress.md` — chunk-by-chunk status tracker and build log.
- `database/schema/CHANGELOG.md` — authoritative incremental schema history.

## Backend quick start

```bash
docker compose up -d          # starts Postgres (x46-postgres, volume x46-postgres-data)
cd backend
./mvnw test                   # runs unit + integration tests against the dockerized Postgres
./mvnw spring-boot:run         # starts the API on :8080
```

Postgres listens on `localhost:5434` (see `docker-compose.yml`); connection
details are in `backend/src/main/resources/application.properties`.

## Frontend quick start

```bash
cd frontend
npm install
npm run dev                   # starts the app on :3000, talks to the backend on :8081
```

Copy `frontend/.env.example` to `frontend/.env.local` to configure
`NEXT_PUBLIC_API_BASE_URL` if the backend isn't on the default port.

## Status

Backend build is in progress, chunk by chunk, per `backend/plan.md`'s
execution order (`M0 → M1 → M2 → ... → M12`). Current state:
`backend/progress.md`.
