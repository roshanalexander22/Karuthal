import pytest
import uuid
from datetime import datetime, timedelta
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
async def test_reminder_crud_and_acknowledge_flow():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # 1. Create Reminder
        sched_time = (datetime.utcnow() + timedelta(hours=2)).isoformat()
        payload = {
            "title": "Amlodipine 5mg (BP Tablet)",
            "description": "പ്രഭാതഭക്ഷണത്തിന് ശേഷം കഴിക്കുക",
            "dosage": "1 ഗുളിക",
            "instructions_ml": "ഭക്ഷണത്തിന് ശേഷം",
            "reminder_type": "MEDICINE",
            "scheduled_time": sched_time,
            "recurrence_rule": "DAILY"
        }
        create_res = await client.post("/api/v1/reminders", json=payload)
        assert create_res.status_code == 201
        rem_data = create_res.json()
        rem_id = rem_data["id"]
        assert rem_data["title"] == "Amlodipine 5mg (BP Tablet)"

        # 2. List Reminders
        list_res = await client.get("/api/v1/reminders")
        assert list_res.status_code == 200
        reminders = list_res.json()["reminders"]
        assert any(r["id"] == rem_id for r in reminders)

        # 3. Get Single Reminder
        get_res = await client.get(f"/api/v1/reminders/{rem_id}")
        assert get_res.status_code == 200
        assert get_res.json()["id"] == rem_id

        # 4. Update Reminder
        update_res = await client.patch(f"/api/v1/reminders/{rem_id}", json={
            "title": "Amlodipine 5mg Updated"
        })
        assert update_res.status_code == 200
        assert update_res.json()["title"] == "Amlodipine 5mg Updated"

        # 5. Acknowledge Dose Taken
        ack_res = await client.post(f"/api/v1/reminders/{rem_id}/acknowledge")
        assert ack_res.status_code == 200
        assert ack_res.json()["status"] == "TAKEN"

        # 6. Delete Reminder
        del_res = await client.delete(f"/api/v1/reminders/{rem_id}")
        assert del_res.status_code == 200

        # 7. Verify deletion
        get_del_res = await client.get(f"/api/v1/reminders/{rem_id}")
        assert get_del_res.status_code == 404
