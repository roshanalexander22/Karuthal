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
async def test_personal_memory_full_flow():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # 1. Initially profile is empty
        resp = await client.get("/api/v1/profile")
        assert resp.status_code == 200
        data = resp.json()
        assert data["user_id"] == str(dummy_user_id)

        # 2. Add a verified field (e.g. Full Name)
        add_resp = await client.post("/api/v1/profile", json={
            "field_name": "Full Name",
            "field_value": "Madhavan Nair",
            "is_verified": True
        })
        assert add_resp.status_code == 201
        assert add_resp.json()["is_verified"] is True

        # 3. Import draft fields from OCR text (e.g., Aadhaar card scan)
        import_resp = await client.post("/api/v1/profile/import-draft", json={
            "raw_ocr_text": "GOVERNMENT OF INDIA\n9847 1234 5678\nDOB: 12/04/1952\nPhone: 9847123456",
            "document_type": "AADHAAR"
        })
        assert import_resp.status_code == 200
        drafts = import_resp.json()
        assert len(drafts) > 0
        # Check all imported drafts have is_verified == False
        for d in drafts:
            assert d["is_verified"] is False

        # 4. Check profile contains both verified and draft counts
        full_profile_resp = await client.get("/api/v1/profile")
        assert full_profile_resp.status_code == 200
        full_data = full_profile_resp.json()
        assert full_data["verified_count"] >= 1
        assert full_data["draft_count"] >= 1

        # 5. Check verified profile only contains verified fields
        verified_resp = await client.get("/api/v1/profile/verified")
        assert verified_resp.status_code == 200
        v_data = verified_resp.json()
        for f in v_data["fields"]:
            assert f["is_verified"] is True

        # 6. Verify one draft field (e.g., Aadhaar Number)
        verify_resp = await client.post("/api/v1/profile/verify/Aadhaar Number")
        assert verify_resp.status_code == 200
        assert verify_resp.json()["is_verified"] is True

        # 7. Delete a field
        del_resp = await client.delete("/api/v1/profile/field/Phone Number")
        assert del_resp.status_code == 200
