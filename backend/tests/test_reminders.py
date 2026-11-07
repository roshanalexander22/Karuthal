import pytest
from datetime import datetime, timezone, timedelta
from app.main import app
from app.core.dependencies import get_current_user

@pytest.fixture(autouse=True)
def override_auth():
    app.dependency_overrides[get_current_user] = lambda: {"sub": "00000000-0000-0000-0000-000000000001"}
    yield
    app.dependency_overrides.clear()

@pytest.mark.asyncio
async def test_reminders_crud(async_client):
    scheduled = (datetime.now(timezone.utc) + timedelta(hours=3)).isoformat()
    # 1. Create medicine reminder
    create_payload = {
        "title": "Paracetamol",
        "description": "After food",
        "reminder_type": "MEDICINE",
        "scheduled_time": scheduled,
        "recurrence_rule": "DAILY",
        "dosage": "500mg, 1 tablet"
    }
    resp = await async_client.post("/api/v1/reminders", json=create_payload)
    assert resp.status_code == 201
    data = resp.json()
    rem_id = data["id"]
    assert data["title"] == "Paracetamol"
    assert data["status"] == "PENDING"

    # 2. List reminders
    list_resp = await async_client.get("/api/v1/reminders")
    assert list_resp.status_code == 200
    reminders = list_resp.json()["reminders"]
    assert any(r["id"] == rem_id for r in reminders)

    # 3. Acknowledge reminder (mark taken)
    ack_resp = await async_client.post(f"/api/v1/reminders/{rem_id}/acknowledge")
    assert ack_resp.status_code == 200
    assert ack_resp.json()["status"] == "TAKEN"

    # 4. Get updated reminder
    get_resp = await async_client.get(f"/api/v1/reminders/{rem_id}")
    assert get_resp.status_code == 200
    assert get_resp.json()["status"] == "TAKEN"

    # 5. Delete reminder
    del_resp = await async_client.delete(f"/api/v1/reminders/{rem_id}")
    assert del_resp.status_code == 200
