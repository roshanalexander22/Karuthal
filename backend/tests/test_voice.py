import pytest
import uuid
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.core.dependencies import get_current_user

dummy_user_id = uuid.uuid4()

async def mock_get_current_user():
    return {"sub": str(dummy_user_id), "role": "USER"}

@pytest.fixture(autouse=True)
def override_deps():
    app.dependency_overrides[get_current_user] = mock_get_current_user
    yield
    app.dependency_overrides.clear()

@pytest.mark.asyncio
async def test_voice_chat_flow():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # 1. Voice chat message
        req = {
            "message": "രാവിലെ 8 മണിക്ക് ബിപി ഗുളിക ഓർമ്മിപ്പിക്കുക",
            "language": "ml"
        }
        res = await client.post("/api/v1/voice/chat", json=req)
        assert res.status_code == 200
        data = res.json()
        assert data["intent"] == "SET_REMINDER"
        assert len(data["assistant_reply"]) > 0

        # 2. Voice history
        hist_res = await client.get("/api/v1/voice/history")
        assert hist_res.status_code == 200
        history_data = hist_res.json()
        assert history_data["total"] >= 1
        assert history_data["history"][0]["intent"] == "SET_REMINDER"

        # 3. TTS Direct conversion
        tts_req = {
            "text": "നമസ്കാരം, സുഖമാണോ?",
            "language": "ml",
            "speed": 0.85
        }
        tts_res = await client.post("/api/v1/tts/convert", json=tts_req)
        assert tts_res.status_code == 200
        assert "audio_base64" in tts_res.json()
