# Bakery POS

Point of sale for a Mexican bakery with 2 branches: offline-first Flutter tills, a Flutter web back office, and a NestJS + PostgreSQL server.

| Folder | What it is | Owner |
| --- | --- | --- |
| `contracts/openapi.yaml` | API contract both sides build against | Architect |
| `server/` | NestJS API and database migrations | Server developer |
| `app/` | Flutter till (`lib/main_till.dart`) and back office (`lib/main_backoffice.dart`) | App developer |
| `docs/` | Milestone briefs, architecture notes, wireframes | Architect |
| `legacy/` | The original template, kept for reference only. Do not build on it. | — |

Current milestone: [M1 brief](docs/milestones/M1-brief.md).

## Local setup

```bash
docker compose -f docker-compose.dev.yml up -d   # PostgreSQL on 127.0.0.1:5432
cd server && cp .env.example .env && npm install && npm run start:dev
cd app && flutter pub get && flutter run -t lib/main_till.dart        # till
cd app && flutter run -d chrome -t lib/main_backoffice.dart           # back office
```

## Rules

- Work on a branch, open a pull request to `main`, keep it under ~600 changed lines.
- CI must be green and the architect must approve before merge.
- Never edit `contracts/openapi.yaml` in a feature PR; open an issue labelled `contract`.
