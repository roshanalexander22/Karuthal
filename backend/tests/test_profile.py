import pytest
import uuid

@pytest.mark.asyncio
async def test_personal_memory_profile_lifecycle(async_client):
    email = f"profile_user_{uuid.uuid4().hex[:8]}@sahaayi.in"
    password = "ProfilePassword123!"

    # 1. Register & login
    await async_client.post(
        "/api/v1/auth/register",
        json={"email": email, "password": password, "full_name": "Profile Elder"},
    )
    login_res = await async_client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": password},
    )
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Get empty profile initially
    get_res = await async_client.get("/api/v1/profile", headers=headers)
    assert get_res.status_code == 200
    data = get_res.json()
    assert "user_id" in data
    assert isinstance(data["fields"], list)

    # 3. Add personal profile field
    patch_res = await async_client.patch(
        "/api/v1/profile",
        headers=headers,
        json={
            "field_name": "full_name",
            "field_value": "Madhavan Nair",
            "is_verified": True,
        },
    )
    assert patch_res.status_code == 200
    field_data = patch_res.json()
    assert field_data["field_name"] == "full_name"
    assert field_data["field_value"] == "Madhavan Nair"
    assert field_data["is_verified"] is True

    # 4. Verify field is now returned in profile
    get_res2 = await async_client.get("/api/v1/profile", headers=headers)
    assert get_res2.status_code == 200
    fields = get_res2.json()["fields"]
    names = [f["field_name"] for f in fields]
    assert "full_name" in names

    # 5. Delete field
    del_res = await async_client.delete("/api/v1/profile/field/full_name", headers=headers)
    assert del_res.status_code == 200

    # 6. Verify field is removed
    get_res3 = await async_client.get("/api/v1/profile", headers=headers)
    assert get_res3.status_code == 200
    fields_after = get_res3.json()["fields"]
    assert "full_name" not in [f["field_name"] for f in fields_after]
