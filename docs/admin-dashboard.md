# ScanLeno Admin Dashboard

The project includes two admin foundations:

1. Flutter in-app admin page for controlled internal access.
2. `admin/index.html` static admin shell for a self-hosted dashboard.

Backend APIs are provided under `backend/server.js`:

- `GET /api/settings`
- `GET /api/feature-flags`
- `GET /api/stats`
- `GET /api/users`
- `POST /api/support-tickets`
- `POST /api/app-errors`
- `POST /api/subscription/verify`

Protected routes use `Authorization: Bearer <SCANLENO_API_TOKEN>`.

The admin system must never display or fetch user document contents.

