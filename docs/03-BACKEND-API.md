# Backend API Design

## Overview
The backend is implemented using **FastAPI** and serves as the analytical engine for the dashboard.
It exposes read-only endpoints that query a pre-loaded SQLite database and return JSON responses
consumed by the React frontend.

The backend is intentionally designed to be:
- Deterministic and reproducible
- Stateless (no session state)
- Read-only after data load
- Easy to extend with additional analytics

---

## Entry Point

**File:** `backend/app/main.py`

This file:
- Creates the FastAPI app
- Configures CORS for Codespaces, Render, and Vercel
- Defines all API routes
- Opens SQLite connections per request

---

## API Endpoints

### Health Check

```
GET /api/v1/health
```

**Purpose**
- Simple liveness check
- Used by Render, Vercel, and tests

**Response**
```json
{ "status": "ok" }
```

---

### Part 2 — Data Overview

```
GET /api/v1/frequency?limit=N
```

**Purpose**
- Computes relative frequencies of immune cell populations per sample
- Implements Part 2 of the assignment

**Logic**
- Uses CTEs to:
  - Aggregate total cell counts per sample
  - Join with long-format `cell_counts`
  - Compute percentages

**Response Schema**
```json
{
  "sample": "sample00001",
  "total_count": 100824,
  "population": "b_cell",
  "count": 6777,
  "percentage": 6.72
}
```

---

### Part 3 — Statistical Analysis

#### Frequencies for Analysis

```
GET /api/v1/part3/frequencies
```

Returns relative frequencies filtered to:
- melanoma
- PBMC samples
- miraclib treatment
- responders vs non-responders

Used by the frontend boxplots.

---

#### Statistical Tests

```
GET /api/v1/part3/stats
```

**Statistics**
- Mann–Whitney U test (non-parametric)
- Median comparison
- Benjamini–Hochberg FDR correction

**Response Example**
```json
{
  "population": "cd4_t_cell",
  "n_yes": 993,
  "n_no": 975,
  "median_yes": 30.221,
  "median_no": 29.658,
  "p_value": 0.0133,
  "q_value": 0.0667,
  "significant_fdr_0_05": false
}
```

---

### Part 4 — Data Subset Analysis

```
GET /api/v1/part4/summary
```

**Filters Applied**
- condition = melanoma
- treatment = miraclib
- sample_type = PBMC
- time_from_treatment_start = 0

**Aggregations Returned**
- Samples per project
- Subjects by response
- Subjects by sex

**Response**
```json
{
  "totals": { "n_samples": 656, "n_subjects": 656 },
  "samples_by_project": [...],
  "subjects_by_response": [...],
  "subjects_by_sex": [...]
}
```

---

## Database Access Pattern

- SQLite connection opened per request
- `sqlite3.Row` used for dict-like access
- No ORM to keep queries explicit and inspectable
- Heavy use of CTEs for readability and correctness

---

## Error Handling

- Invalid requests return HTTP 400/500
- Failures surface clearly in logs (important for Codespaces)
- No silent data coercion

---

## Testing Strategy

- FastAPI `TestClient`
- Structure-based tests for JSON schemas
- No snapshot tests (data is deterministic)

---

## Why This Design?

- Clear separation between analytics logic and presentation
- Easy for reviewers to inspect SQL and statistics
- Matches how scientists typically reason about data
- Scales to additional endpoints without refactoring