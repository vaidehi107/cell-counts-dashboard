# Frontend Dashboard

## Overview

The frontend is a React + TypeScript single-page application built with **Vite**.
It focuses on clarity, auditability, and minimal interactivity, matching the
explicit requirements of the take-home assignment.

The dashboard is read-only: users explore results via clearly separated tabs,
not free-form filters. This was a deliberate design choice to avoid over-
engineering and to keep analytical intent explicit.

---

## Tab Structure

### Part 3 – Statistical Analysis

This tab answers: *Are immune cell populations statistically different between
responders and non-responders?*

Layout (top → bottom):

1. **Summary Table**
   - One row per population
   - Columns:
     - Population
     - N responders / non-responders
     - Median counts (yes / no)
     - p-value
     - q-value (Benjamini–Hochberg FDR)
     - FDR significance flag

2. **Boxplots**
   - One boxplot per population
   - Responders vs non-responders shown side-by-side
   - Color scheme is consistent across all plots
   - No user-controlled filters (results are deterministic)

Data source:
- `/api/v1/part3/stats`
- `/api/v1/part3/frequencies`

---

### Part 4 – Data Subset Analysis

This tab answers *count-based* exploratory questions requested in Part 4.

Important:  
**Part 4 is not interactive by task wording**. The filters are fixed in code and
documented on the page.

Fixed subset definition:
- Condition: melanoma
- Treatment: miraclib
- Sample type: PBMC
- Time from treatment start: 0

Displayed sections:

1. **Filter Summary**
   - Explicitly shows the fixed subset definition

2. **Totals**
   - Number of samples
   - Number of subjects

3. **Grouped Counts**
   - Samples by project
   - Subjects by response (yes / no)
   - Subjects by sex (M / F)

Data source:
- `/api/v1/part4/summary`

---

## API Base URL Handling

The frontend uses a single API base variable:

```ts
const API_BASE = (import.meta.env.VITE_API_BASE_URL ?? "").replace(/\/$/, "");
```

Behavior:
- **Codespaces / local dev**: API requests hit the same domain (`/api/...`)
- **Production (Vercel)**: `VITE_API_BASE_URL` is injected at build time

Local `.env*` files are ignored by git and never committed.

---

## Design Rationale

- **Tabs instead of dropdown filters**
  - Matches assignment wording
  - Prevents ambiguous analysis states
- **Tables before plots**
  - Ensures numerical transparency
- **No client-side statistics**
  - All analytics live in the backend for correctness and testability
- **Minimal dependencies**
  - React, Chart.js, no state-management frameworks

---

## Extensibility

If interactivity were required in the future:
- Filters would be added as query params
- Backend endpoints already support clean extension
- Frontend state management could remain local (no Redux needed)

---

## Deployment

The frontend is deployed on **Vercel**.

Production dashboard:
https://cell-counts-dashboard.vercel.app