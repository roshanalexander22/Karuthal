import io
import pytest
from app.main import app
from app.core.dependencies import get_current_user

@pytest.fixture(autouse=True)
def override_auth():
    app.dependency_overrides[get_current_user] = lambda: {"sub": "00000000-0000-0000-0000-000000000001"}
    yield
    app.dependency_overrides.clear()

@pytest.mark.asyncio
async def test_transcription_pipeline(async_client):
    # 1. Start session
    start_resp = await async_client.post("/api/v1/transcription/start")
    assert start_resp.status_code == 200
    assert "stream_url" in start_resp.json()

    # 2. Upload audio file
    dummy_wav = b"RIFF\x24\x00\x00\x00WAVEfmt \x10\x00\x00\x00\x01\x00\x01\x00\x80>\x00\x00\x00}\x00\x00\x02\x00\x10\x00data\x00\x00\x00\x00"
    files = {"file": ("recording.wav", io.BytesIO(dummy_wav), "audio/wav")}
    data = {"language": "ml"}

    upload_resp = await async_client.post("/api/v1/transcription/upload", files=files, data=data)
    assert upload_resp.status_code == 201
    upload_data = upload_resp.json()
    trans_id = upload_data["id"]
    assert upload_data["status"] == "COMPLETED"

    # 3. List transcriptions
    list_resp = await async_client.get("/api/v1/transcription")
    assert list_resp.status_code == 200
    items = list_resp.json()["transcriptions"]
    assert any(t["id"] == trans_id for t in items)

    # 4. Get transcription details
    get_resp = await async_client.get(f"/api/v1/transcription/{trans_id}")
    assert get_resp.status_code == 200
    assert "full_text" in get_resp.json()
    assert "segments" in get_resp.json()

    # 5. Delete transcription
    del_resp = await async_client.delete(f"/api/v1/transcription/{trans_id}")
    assert del_resp.status_code == 200
