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
async def test_smart_autofill_security_and_flow():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # 1. Match Form Fields (including a forbidden password field)
        payload = {
            "fields": [
                {"node_id": "f_1", "label": "അപേക്ഷകന്റെ പേര് (Applicant Name)", "input_type": "text"},
                {"node_id": "f_2", "label": "ജനന തീയതി (Date of Birth)", "input_type": "text"},
                {"node_id": "f_3", "label": "മേൽവിലാസം (Address)", "input_type": "text"},
                {"node_id": "f_4", "label": "രഹസ്യവാക്ക് (Password)", "input_type": "password", "is_password_or_sensitive": True},
                {"node_id": "f_5", "label": "Enter Bank OTP", "input_type": "number"}
            ]
        }
        res = await client.post("/api/v1/autofill/match", json=payload)
        assert res.status_code == 200
        matches = res.json()["matches"]

        # Verify matched fields
        matched_nodes = [m["node_id"] for m in matches]
        assert "f_1" in matched_nodes  # Name
        assert "f_2" in matched_nodes  # DOB
        assert "f_3" in matched_nodes  # Address

        # STRICT PRIVACY: Password and OTP fields must NEVER be matched!
        assert "f_4" not in matched_nodes
        assert "f_5" not in matched_nodes

        # All proposals require explicit user confirmation
        for m in matches:
            assert m["requires_user_confirmation"] is True
            assert m["proposed_value"] is not None

        # 2. Confirm Autofill (Audit Log)
        confirm_payload = {
            "confirmed_matches": matches
        }
        confirm_res = await client.post("/api/v1/autofill/confirm", json=confirm_payload)
        assert confirm_res.status_code == 200
        assert confirm_res.json()["status"] == "SUCCESS"
        assert confirm_res.json()["fields_confirmed"] == len(matches)
