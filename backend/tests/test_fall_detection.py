import pytest
import uuid
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.core.dependencies import get_current_user, get_db

dummy_user_id = uuid.uuid4()

async def mock_get_current_user():
    return {"sub": str(dummy_user_id), "role": "USER"}

async def mock_get_db():
    class DummyDB:
        async def commit(self): pass
        async def rollback(self): pass
        async def close(self): pass
        async def execute(self, *args, **kwargs): return None
    yield DummyDB()

@pytest.fixture(autouse=True)
def override_deps():
    app.dependency_overrides[get_current_user] = mock_get_current_user
    app.dependency_overrides[get_db] = mock_get_db
    yield
    app.dependency_overrides.clear()

@pytest.mark.asyncio
async def test_fall_detection_and_emergency_flow():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # 1. Report Fall Event (Confirmed -> Auto SOS)
        report_payload = {
            "confidence_score": 0.94,
            "sensor_summary": {"peak_impact_g": 3.2, "free_fall_duration_ms": 320},
            "location_lat": 9.5916,
            "location_lng": 76.5222,
            "was_cancelled_by_user": False
        }
        res = await client.post("/api/v1/fall/report", json=report_payload)
        assert res.status_code == 201
        data = res.json()
        event_id = data["id"]
        assert data["confirmed"] is True
        assert data["false_alarm"] is False
        assert data["sos_dispatched"] is True

        # 2. Cancel a Fall Event (False alarm)
        cancel_res = await client.post(f"/api/v1/fall/events/{event_id}/cancel")
        assert cancel_res.status_code == 200
        assert cancel_res.json()["false_alarm"] is True
        assert cancel_res.json()["confirmed"] is False

        # 3. List Fall Events
        list_res = await client.get("/api/v1/fall/events")
        assert list_res.status_code == 200
        assert list_res.json()["total"] >= 1

        # 4. Settings GET and PATCH
        settings_res = await client.get("/api/v1/fall/settings")
        assert settings_res.status_code == 200
        assert "sensitivity" in settings_res.json()

        update_settings_res = await client.patch("/api/v1/fall/settings", json={"sensitivity": "HIGH"})
        assert update_settings_res.status_code == 200
        assert update_settings_res.json()["sensitivity"] == "HIGH"

        # 5. Direct Emergency SOS Trigger
        sos_res = await client.post("/api/v1/emergency/sos", json={"reason": "MANUAL_SOS_PANIC"})
        assert sos_res.status_code == 200
        assert sos_res.json()["status"] == "DISPATCHED"

        # 6. Emergency Contacts
        contacts_res = await client.get("/api/v1/emergency/contacts")
        assert contacts_res.status_code == 200
        assert contacts_res.json()["total"] >= 1
