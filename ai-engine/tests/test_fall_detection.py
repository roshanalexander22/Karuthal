import pytest
from starlette.testclient import TestClient
from main import app
from fall_detection.fall_detector import FallDetector

client = TestClient(app)

def test_fall_telemetry_normal():
    # Normal walking: acceleration stays near ~9.8 m/s^2
    normal_data = [{"x": 0.5, "y": 0.3, "z": 9.8} for _ in range(10)]
    res = FallDetector.evaluate_telemetry(normal_data)
    assert res["is_fall_suspected"] is False
    assert res["confidence"] < 0.5

def test_fall_telemetry_fall_event():
    # Phase 1: Free fall (~2.0 m/s^2)
    free_fall = [{"x": 0.0, "y": 0.0, "z": 2.0} for _ in range(4)]
    # Phase 2: Impact spike (32.0 m/s^2)
    impact = [{"x": 5.0, "y": 10.0, "z": 30.0}]
    # Phase 3: Lying inactive (~9.8 m/s^2)
    rest = [{"x": 0.1, "y": 0.1, "z": 9.8} for _ in range(8)]

    readings = free_fall + impact + rest
    res = FallDetector.evaluate_telemetry(readings)
    assert res["is_fall_suspected"] is True
    assert res["confidence"] >= 0.88
    assert res["has_free_fall"] is True
    assert res["has_impact"] is True

def test_fall_analyze_endpoint():
    dummy = [{"x": 0.0, "y": 0.0, "z": 1.5}, {"x": 10.0, "y": 15.0, "z": 25.0}, {"x": 0.0, "y": 0.0, "z": 9.8}]
    resp = client.post("/fall/analyze", json={"readings": dummy})
    assert resp.status_code == 200
    assert "is_fall_suspected" in resp.json()
