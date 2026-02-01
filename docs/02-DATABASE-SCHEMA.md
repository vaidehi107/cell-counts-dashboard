# Database Schema & Data Model

## Overview
This project uses a **relational SQLite database** to store immune cell count data, metadata, and derived analytics.
The schema is designed to:
- Normalize repeated metadata (subjects, projects, populations)
- Support efficient analytical queries
- Scale to many projects and thousands of samples

The database is materialized at load time from `cell-count.csv`.

---

## Entity Relationship Diagram (Logical)

```
projects ──< subjects ──< treatment_courses ──< samples ──< cell_counts >── populations
```

---

## Tables

### `projects`
Represents independent studies or cohorts.

| Column | Type | Notes |
|------|------|------|
| id | INTEGER PK | Surrogate key |
| name | TEXT | e.g. prj1, prj2 |

---

### `subjects`
One row per biological subject per project.

| Column | Type | Notes |
|------|------|------|
| id | INTEGER PK |
| subject_code | TEXT | Subject identifier from CSV |
| project_id | INTEGER FK → projects |
| condition | TEXT | e.g. melanoma |
| age | INTEGER | Nullable |
| sex | TEXT | M / F |

**Design choice:** Subjects are scoped to projects, allowing the same subject code across projects.

---

### `treatment_courses`
Captures treatment + response per subject.

| Column | Type | Notes |
|------|------|------|
| id | INTEGER PK |
| subject_id | INTEGER FK → subjects |
| treatment | TEXT | e.g. miraclib |
| response | TEXT | yes / no / NULL |

**Design choice:** Response is attached to the treatment course, not the sample.

---

### `samples`
One biological sample per timepoint.

| Column | Type | Notes |
|------|------|
| id | INTEGER PK |
| sample_code | TEXT | Unique sample ID |
| subject_id | INTEGER FK |
| treatment_course_id | INTEGER FK |
| sample_type | TEXT | PBMC / WB |
| time_from_treatment_start | INTEGER | 0 = baseline |

---

### `populations`
Dimension table for immune cell types.

| Column | Type |
|------|------|
| id | INTEGER PK |
| name | TEXT | b_cell, cd4_t_cell, etc. |

---

### `cell_counts`
Long-format fact table.

| Column | Type | Notes |
|------|------|
| sample_id | INTEGER FK |
| population_id | INTEGER FK |
| count | INTEGER |

**Design choice:** Long format enables flexible aggregation and avoids schema changes when adding populations.

---

## Why This Scales

- Adding new projects requires **no schema change**
- New populations are rows, not columns
- Analytics are SQL-based (CTEs), not hardcoded
- SQLite can be swapped for Postgres with minimal changes

---

## Analytics Strategy

- Part 2: CTE-based aggregation for per-sample frequencies
- Part 3: Statistical analysis using pre-aggregated percentages
- Part 4: Subset queries using indexed joins and filters

This schema supports **hundreds of projects and thousands of samples** without denormalization.