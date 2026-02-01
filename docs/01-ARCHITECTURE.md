# System Architecture & Design

## High-level Overview

This project is a full-stack analytics dashboard designed for exploratory and statistical analysis of immune cell populations in clinical trial data.

It is composed of four main layers:

1. **Data Layer (SQLite)**
2. **Backend API (FastAPI)**
3. **Frontend Dashboard (React + Typescript + Vite)**
4. **Deployment & Infrastructure (Render + Vercel)**

The system is intentionally simple, reproducible, and optimized for read-heavy analytical workloads.

---

## Architecture Diagram (ASCII)

```
+---------------------+
|  cell-count.csv     |
|  (raw input data)   |
+----------+----------+
           |
           | load_db.py
           v
+---------------------+
|  SQLite Database    |
|  (analytics-ready) |
|                     |
|  projects            |
|  subjects            |
|  treatment_courses   |
|  samples             |
|  populations         |
|  cell_counts         |
+----------+----------+
           |
           | SQL / CTEs
           v
+---------------------+
|  FastAPI Backend    |
|  (REST API)         |
|                     |
|  /health             |
|  /frequency          |
|  /part3/*            |
|  /part4/*            |
+----------+----------+
           |
           | HTTPS (JSON)
           v
+---------------------+
|  React Frontend     |
|  (Vite + TS)        |
|                     |
|  Tables             |
|  Boxplots           |
|  Tabs               |
+----------+----------+
           |
           v
+---------------------+
|  Users / Reviewers  |
+---------------------+
```

---

## Data Layer Design (SQLite)

### Why SQLite?

- Zero operational overhead
- Deterministic and reproducible
- Excellent for analytical reads
- Perfect fit for take-home / Codespaces evaluation
- Easy migration path to Postgres / DuckDB if needed

### Schema Philosophy

The schema is **fully normalized** and modeled around clinical trial concepts:

- Projects
- Subjects
- Treatment courses
- Samples
- Cell populations
- Cell counts (long format)

This avoids wide tables and supports:

- Flexible joins
- Arbitrary population expansion
- Efficient aggregation with SQL

### Scaling Considerations

If scaled to:
- **100s of projects**
- **10,000s of subjects**
- **Millions of samples**

This design scales by:
- Migrating SQLite → Postgres / DuckDB
- Adding indexes on:
  - `subjects.condition`
  - `treatment_courses.treatment`
  - `samples.sample_type`
  - `samples.time_from_treatment_start`
- Precomputing materialized views for heavy analytics

---

## Backend Design (FastAPI)

### Why FastAPI?

- Native OpenAPI support
- Type-safe endpoints
- Excellent performance
- Clean separation of concerns
- Simple testability with `TestClient`

### Endpoint Design

Endpoints are grouped by analytical task:

- **Part 2**: Data overview (frequencies)
- **Part 3**: Statistical analysis (Mann–Whitney U, FDR)
- **Part 4**: Subset summaries (counts by project, response, sex)

Each endpoint:
- Executes a single SQL query (often with CTEs)
- Returns analysis-ready JSON
- Performs no frontend-specific formatting

### SQL-first Analytics

All heavy lifting happens in SQL:
- CTEs for clarity and correctness
- Aggregations pushed to the database
- Minimal Python post-processing

This keeps logic transparent and auditable.

---

## Frontend Design (React + Vite)

### Why React + Vite?

- Fast local iteration (Codespaces-friendly)
- Simple production build
- Native TypeScript support
- Easy deployment to Vercel

### UI Philosophy

- Tabs map directly to task parts
- Tables for auditability
- Boxplots for distribution comparison
- Minimal interactivity (as per task wording)

No unnecessary filters or controls were added beyond task requirements.

---

## Deployment Choices

### Backend: Render

- Simple GitHub integration
- Free tier suitable for demo
- Automatic HTTPS
- Clear logs

Note: Free tier has cold starts.

### Frontend: Vercel

- Best-in-class frontend hosting
- Automatic preview builds
- Zero-config Vite support
- Global CDN

---

## Environment Separation

- **Local / Codespaces**:
  - Vite dev proxy
  - Same-origin API calls
- **Production**:
  - `VITE_API_BASE_URL` injected by Vercel
  - CORS enforced at backend

This avoids environment-specific code branches.

---

## Why This Architecture Works for the Task

- Transparent analytics
- Reproducible results
- Minimal operational complexity
- Easy to review and reason about
- Scales conceptually to real-world datasets

This design prioritizes **scientific clarity and correctness** over unnecessary abstraction.