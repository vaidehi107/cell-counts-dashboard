from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_part4_summary_structure():
    resp = client.get("/api/v1/part4/summary")
    assert resp.status_code == 200

    data = resp.json()

    # top-level keys
    assert "filter" in data
    assert "totals" in data
    assert "samples_by_project" in data
    assert "subjects_by_response" in data
    assert "subjects_by_sex" in data

def test_part4_summary_counts_consistency():
    data = client.get("/api/v1/part4/summary").json()

    n_subjects = data["totals"]["n_subjects"]

    # responders + non-responders = total subjects
    resp_counts = sum(x["n"] for x in data["subjects_by_response"])
    assert resp_counts == n_subjects

    # males + females = total subjects
    sex_counts = sum(x["n"] for x in data["subjects_by_sex"])
    assert sex_counts == n_subjects