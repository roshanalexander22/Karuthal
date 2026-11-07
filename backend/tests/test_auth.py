import pytest
import uuid

@pytest.mark.asyncio
async def test_auth_full_lifecycle(async_client):
    email = f"user_{uuid.uuid4().hex[:8]}@sahaayi.in"
    password = "StrongPassword123!"

    # 1. Register
    reg_res = await async_client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": password,
            "full_name": "Test Elder",
            "phone": "+919876543210",
            "language_preference": "ml",
        },
    )
    assert reg_res.status_code == 201
    reg_data = reg_res.json()
    assert reg_data["user"]["email"] == email
    assert reg_data["user"]["full_name"] == "Test Elder"
    assert "tokens" in reg_data

    # 2. Duplicate registration fails
    dup_res = await async_client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": password,
            "full_name": "Test Elder Duplicate",
        },
    )
    assert dup_res.status_code in [401, 409]

    # 3. Login with wrong password fails
    wrong_login = await async_client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": "WrongPassword!"},
    )
    assert wrong_login.status_code == 401

    # 4. Login with correct password succeeds
    login_res = await async_client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": password},
    )
    assert login_res.status_code == 200
    tokens = login_res.json()
    assert "access_token" in tokens
    assert "refresh_token" in tokens
    access_token = tokens["access_token"]
    refresh_token = tokens["refresh_token"]

    # 5. Access protected /me
    me_res = await async_client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {access_token}"},
    )
    assert me_res.status_code == 200
    me_data = me_res.json()
    assert me_data["email"] == email

    # 6. Refresh token
    refresh_res = await async_client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": refresh_token},
    )
    assert refresh_res.status_code == 200
    new_tokens = refresh_res.json()
    assert "access_token" in new_tokens

    # 7. Unauthenticated request to /me is rejected
    unauth_res = await async_client.get("/api/v1/auth/me")
    assert unauth_res.status_code == 401
