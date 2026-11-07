import pytest
from app.main import app
from app.core.dependencies import get_current_user

@pytest.fixture(autouse=True)
def override_auth():
    app.dependency_overrides[get_current_user] = lambda: {"sub": "00000000-0000-0000-0000-000000000001"}
    yield
    app.dependency_overrides.clear()

@pytest.mark.asyncio
async def test_fall_and_emergency(async_client):
    # 1. Report fall event (uncancelled - should confirm and trigger emergency)
    fall_payload = {
        "confidence_score": 0.94,
        "sensor_summary": {"sma_spike": 3.2, "free_fall_ms": 420},
        "location_lat": 8.5241,
        "location_lng": 76.9366,
        "was_cancelled_by_user": False
    }
    fall_resp = await async_client.post("/api/v1/fall-detection/events", json=fall_payload)
    assert fall_resp.status_code == 201
    fall_data = fall_resp.json()
    assert fall_data["confirmed"] is True
    assert fall_data["false_alarm"] is False

    # 2. Report cancelled fall (false alarm)
    cancel_payload = {
        "confidence_score": 0.8,
        "sensor_summary": {"action": "CANCEL_COUNTDOWN"},
        "was_cancelled_by_user": True
    }
    cancel_resp = await async_client.post("/api/v1/fall/report", json=cancel_payload)
    assert cancel_resp.status_code == 201
    assert cancel_resp.json()["false_alarm"] is True

    # 3. Direct SOS trigger
    sos_resp = await async_client.post(
        "/api/v1/emergency/sos",
        json={"reason": "SOS_BUTTON_PRESSED", "location_lat": 8.5241, "location_lng": 76.9366}
    )
    assert sos_resp.status_code == 200
    assert sos_resp.json()["status"] == "DISPATCHED"

    # 4. Emergency Contacts CRUD
    contacts_list = await async_client.get("/api/v1/emergency/contacts")
    assert contacts_list.status_code == 200
    assert len(contacts_list.json()["contacts"]) >= 1

    add_contact_resp = await async_client.post(
        "/api/v1/emergency/contacts",
        json={"name": "Dr. Varma", "phone": "+919447111222", "relationship": "Physician"}
    )
    assert add_contact_resp.status_code == 201
    new_contact_id = add_contact_resp.json()["id"]

    del_contact_resp = await async_client.delete(f"/api/v1/emergency/contacts/{new_contact_id}")
    assert del_contact_resp.status_code == 200
