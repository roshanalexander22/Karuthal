import pytest
from app.main import app
from app.core.dependencies import get_current_user

@pytest.fixture(autouse=True)
def override_auth():
    app.dependency_overrides[get_current_user] = lambda: {"sub": "00000000-0000-0000-0000-000000000001"}
    yield
    app.dependency_overrides.clear()

@pytest.mark.asyncio
async def test_voice_chat_text(async_client):
    response = await async_client.post(
        "/api/v1/voice/chat",
        json={"text": "സഹായി, വൈകിട്ട് 7 മണിക്ക് മരുന്ന് കഴിക്കാൻ ഓർമ്മിപ്പിക്കണം.", "language": "ml"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "user_query" in data
    assert "intent" in data
    assert "response_text" in data
    assert data["intent"] == "SET_REMINDER"

@pytest.mark.asyncio
async def test_voice_chat_history(async_client):
    response = await async_client.get("/api/v1/voice/history")
    assert response.status_code == 200
    history = response.json()
    assert isinstance(history, list)
    assert len(history) >= 1

@pytest.mark.asyncio
async def test_tts_convert(async_client):
    response = await async_client.post(
        "/api/v1/tts/convert",
        json={"text": "നമസ്കാരം, സുഖമാണോ?", "language": "ml", "speed": 0.85}
    )
    assert response.status_code == 200
    data = response.json()
    assert "audio_base64" in data
    assert data["language"] == "ml"
