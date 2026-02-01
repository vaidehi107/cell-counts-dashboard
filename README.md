# Cell Counts Dashboard

A lightweight, end-to-end “data → database → API → dashboard” app for exploring immune cell-count data from clinical samples.

**Live dashboard:** https://cell-counts-dashboard.vercel.app  
**Live API:** https://cell-counts-dashboard.onrender.com (see `/api/v1/health`)

This repo is designed to be runnable in **GitHub Codespaces** with minimal setup. It implements:

- **Part 1 (Data Management):** SQLite schema + CSV loader to a materialized analytics DB  
- **Part 2 (Data Overview):** per-sample population frequencies (table)  
- **Part 3 (Statistical Analysis):** responder vs non-responder comparison + boxplots + p/q values  
- **Part 4 (Data Subset Analysis):** baseline melanoma PBMC miraclib subset counts (grouped summaries)

---

## Repository layout

```
cell-counts-dashboard/
  backend/                 # FastAPI + SQLite DB + loader + tests
  frontend/                # Vite + React + TypeScript dashboard
  data/                    # Input CSV (cell-count.csv)
  docs/                    # Detailed documentation (design, schema, usage, deploy)
```

Start here, then refer to the detailed docs:

- **Architecture & design rationale:** `docs/01-ARCHITECTURE.md`
- **Database schema:** `docs/02-SCHEMA.md`
- **How to run & reproduce outputs:** `docs/03-USAGE.md`
- **Deployments (Render/Vercel) + env vars:** `docs/04-DEPLOYMENT.md`
- **Analytics endpoints & expected outputs:** `docs/05-ANALYSES.md`

---

## Quickstart (GitHub Codespaces)

> Run backend and frontend in two terminals:
> - backend serves the API
> - frontend renders the dashboard

### 1) Backend (FastAPI)

In a Codespaces terminal:

```bash
cd backend

# If you're using micromamba (recommended for this repo)
eval "$(micromamba shell hook --shell bash)"
micromamba activate cell-counts-dashboard

# Run the API
./start.sh
```

Verify:

```bash
curl -s http://localhost:8000/api/v1/health
```

### 2) Frontend (Vite + React)

In a second Codespaces terminal:

```bash
cd frontend
npm install
npm run dev -- --host 0.0.0.0 --port 5173
```

Open the forwarded port **5173** in your browser.

---

## Reproducing the database build (Part 1)

The repository contains a materialized SQLite DB at `backend/data/app.db`.
If you want to rebuild it from the CSV:

```bash
cd backend
python -m backend.app.load_db --csv ../data/cell-count.csv --db data/app.db --replace
```

---

## Running tests

From the backend directory:

```bash
cd backend
pytest -v
```

---

## Notes on hosting choices (Render + Vercel)

- **Backend on Render:** simple Python web service hosting for FastAPI; supports free tier and GitHub-based deploys.
- **Frontend on Vercel:** fast static hosting optimized for Vite/React; simple GitHub deploys and previews.
- **Cold start warning:** both free tiers may “sleep” after inactivity, so the first request can be slower.

Full details (including environment variables and how the dev proxy avoids CORS during local/Codespaces development) are in `docs/04-DEPLOYMENT.md`.

---

## System design (high level)

```
                ┌───────────────────────────┐
                │         Browser           │
                │  Vercel-hosted React UI   │
                └─────────────┬─────────────┘
                              │ HTTPS
                              │ /api/* (prod) or via Vite proxy (dev)
                              ▼
                ┌───────────────────────────┐
                │        FastAPI API         │
                │   Render / Codespaces      │
                │  /api/v1/... endpoints     │
                └─────────────┬─────────────┘
                              │ SQLite queries
                              ▼
                ┌───────────────────────────┐
                │        SQLite DB           │
                │  backend/data/app.db       │
                │  (built from data CSV)     │
                └───────────────────────────┘
```

More detailed design decisions (scaling, schema rationale, analytics extensibility, and deployment tradeoffs) are documented in `docs/`.

---

## License

This repository is intended as a take-home / demonstration project.