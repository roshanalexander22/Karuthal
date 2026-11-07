import pytest
from app.main import app
from app.core.dependencies import get_current_user

@pytest.fixture(autouse=True)
def override_auth():
    app.dependency_overrides[get_current_user] = lambda: {"sub": "00000000-0000-0000-0000-000000000001"}
    yield
    app.dependency_overrides.clear()

@pytest.mark.asyncio
async def test_personal_memory_and_autofill(async_client):
    # 1. Add verified memory fields
    p1 = await async_client.post(
        "/api/v1/profile",
        json={"field_name": "full_name", "field_value": "Raman Nair", "is_verified": True}
    )
    assert p1.status_code == 201

    p2 = await async_client.post(
        "/api/v1/profile",
        json={"field_name": "phone_number", "field_value": "9847123456", "is_verified": True}
    )
    assert p2.status_code == 201

    # Add unverified draft field
    p3 = await async_client.post(
        "/api/v1/profile",
        json={"field_name": "draft_income", "field_value": "25000", "is_verified": False}
    )
    assert p3.status_code == 201

    # 2. Check full profile list (contains all)
    all_resp = await async_client.get("/api/v1/profile")
    assert all_resp.status_code == 200
    all_fields = all_resp.json()["fields"]
    assert len(all_fields) >= 3

    # 3. Check verified-only endpoint (eligible for autofill)
    verified_resp = await async_client.get("/api/v1/profile/verified")
    assert verified_resp.status_code == 200
    verified_fields = verified_resp.json()
    assert all(f["is_verified"] for f in verified_fields)
    assert any(f["field_name"] == "full_name" for f in verified_fields)
    assert not any(f["field_name"] == "draft_income" for f in verified_fields)

    # 4. Smart Autofill match
    match_payload = {
        "fields": [
            {"node_id": "name_field", "label": "Applicant Name", "input_type": "text", "is_password_or_sensitive": False},
            {"node_id": "phone_field", "label": "Contact Phone Number", "input_type": "text", "is_password_or_sensitive": False},
            {"node_id": "pwd_field", "label": "Password", "input_type": "password", "is_password_or_sensitive": True}
        ]
    }
    match_resp = await async_client.post("/api/v1/autofill/match", json=match_payload)
    assert match_resp.status_code == 200
    matches = match_resp.json()["matches"]
    assert len(matches) >= 1
    # Password must never be matched
    assert not any(m["node_id"] == "pwd_field" for m in matches)

    # 5. Confirm autofill (audit log)
    confirm_resp = await async_client.post(
        "/api/v1/autofill/confirm",
        json={"confirmed_matches": matches}
    )
    assert confirm_resp.status_code == 200
    assert confirm_resp.json()["status"] == "SUCCESS"
