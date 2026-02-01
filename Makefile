# =========================
# Configuration
# =========================

ENV_NAME := cell-counts-dashboard
PYTHON := micromamba run -n $(ENV_NAME) python
PIP := micromamba run -n $(ENV_NAME) pip

BACKEND_DIR := backend
FRONTEND_DIR := frontend
DB_PATH := backend/data/app.db
CSV_PATH := backend/data/cell-counts.csv

# =========================
# Help
# =========================

.PHONY: help
help:
	@echo ""
	@echo "Cell Counts Dashboard – Makefile"
	@echo ""
	@echo "Available targets:"
	@echo ""
	@echo "  make env           Create micromamba env and install backend deps"
	@echo "  make db            Rebuild SQLite DB from CSV"
	@echo "  make backend       Run FastAPI backend (localhost:8000)"
	@echo "  make frontend      Run Vite frontend (localhost:5173)"
	@echo "  make test          Run backend tests"
	@echo "  make dev           Run backend + frontend instructions"
	@echo ""

# =========================
# Environment
# =========================

.PHONY: env
env:
	micromamba create -y -n $(ENV_NAME) python=3.11
	$(PIP) install -r $(BACKEND_DIR)/requirements.txt
	$(PIP) install pytest httpx

# =========================
# Database
# =========================

.PHONY: db
db:
	$(PYTHON) -m backend.app.load_db \
		--csv $(CSV_PATH) \
		--db $(DB_PATH) \
		--replace

# =========================
# Backend
# =========================

.PHONY: backend
backend:
	cd $(BACKEND_DIR) && \
	micromamba run -n $(ENV_NAME) \
	uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# =========================
# Frontend
# =========================

.PHONY: frontend
frontend:
	cd $(FRONTEND_DIR) && npm install && npm run dev -- --host 0.0.0.0

# =========================
# Tests
# =========================

.PHONY: test
test:
	cd $(BACKEND_DIR) && \
	micromamba run -n $(ENV_NAME) pytest -v

# =========================
# Dev helper
# =========================

.PHONY: dev
dev:
	@echo ""
	@echo "Run backend in one terminal:"
	@echo "  make backend"
	@echo ""
	@echo "Run frontend in another terminal:"
	@echo "  make frontend"
	@echo ""