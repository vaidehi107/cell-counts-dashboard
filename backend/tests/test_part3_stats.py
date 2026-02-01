from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_part3_stats_structure():
    resp = client.get("/api/v1/part3/stats")
    assert resp.status_code == 200

    stats = resp.json()
    assert isinstance(stats, list)
    assert len(stats) > 0

    row = stats[0]
    expected_keys = {
        "population",
        "n_yes",
        "n_no",
        "median_yes",
        "median_no",
        "p_value",
        "q_value",
        "significant_fdr_0_05",
    }

    assert expected_keys.issubset(row.keys())