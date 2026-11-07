import pytest
import uuid

@pytest.mark.asyncio
async def test_smart_autofill_matching_and_confirmation(async_client):
    email = f"autofill_user_{uuid.uuid4().hex[:8]}@sahaayi.in"
    password = "AutofillPassword123!"

    # 1. Register & login
    await async_client.post(
        "/api/v1/auth/register",
        json={"email": email, "password": password, "full_name": "Autofill Elder"},
    )
    login_res = await async_client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": password},
    )
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Add verified profile fields
    await async_client.patch(
        "/api/v1/profile",
        headers=headers,
        json={"field_name": "full_name", "field_value": "Kalyani Amma", "is_verified": True},
    )
    await async_client.patch(
        "/api/v1/profile",
        headers=headers,
        json={"field_name": "phone_number", "field_value": "+919847112233", "is_verified": True},
    )

    # 3. Match form fields (English + Malayalam synonyms)
    match_res = await async_client.post(
        "/api/v1/autofill/match",
        headers=headers,
        json={
            "fields": [
                {"node_id": "field_name_01", "label": "Full Name", "input_type": "text", "is_password_or_sensitive": False},
                {"node_id": "field_ml_phone", "label": "ഫോൺ നമ്പർ", "input_type": "tel", "is_password_or_sensitive": False},
                {"node_id": "field_pwd", "label": "Password", "input_type": "password", "is_password_or_sensitive": True},
                {"node_id": "field_otp", "label": "Enter OTP", "input_type": "text", "is_password_or_sensitive": False},
            ]
        },
    )
    assert match_res.status_code == 200
    matches = match_res.json()["matches"]

    # Must match name and phone, strictly rejecting password and OTP
    matched_nodes = {m["node_id"]: m for m in matches}
    assert "field_name_01" in matched_nodes
    assert matched_nodes["field_name_01"]["proposed_value"] == "Kalyani Amma"
    assert "field_ml_phone" in matched_nodes
    assert matched_nodes["field_ml_phone"]["proposed_value"] == "+919847112233"

    # Strictly forbidden
    assert "field_pwd" not in matched_nodes
    assert "field_otp" not in matched_nodes

    # 4. Confirm autofill and verify audit logging
    confirm_res = await async_client.post(
        "/api/v1/autofill/confirm",
        headers=headers,
        json={"confirmed_matches": [matched_nodes["field_name_01"]]},
    )
    assert confirm_res.status_code == 200
    confirm_data = confirm_res.json()
    assert confirm_data["status"] == "SUCCESS"
    assert confirm_data["fields_confirmed"] == 1
