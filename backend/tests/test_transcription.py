import pytest
import io
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
async def test_transcription_full_flow():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # 1. Upload audio
        dummy_wav = b"RIFF" + b"\x00" * 36 + b"data" + b"\x00" * 64
        files = {"file": ("doctor_consult.wav", io.BytesIO(dummy_wav), "audio/wav")}
        data = {"language": "ml"}

        res = await client.post("/api/v1/transcription/upload", files=files, data=data)
        assert res.status_code == 201
        res_data = res.json()
        trans_id = res_data["id"]
        assert res_data["status"] == "COMPLETED"
        assert len(res_data["full_text"]) > 0
        assert "summary" in res_data

        # 2. List transcriptions
        list_res = await client.get("/api/v1/transcription")
        assert list_res.status_code == 200
        items = list_res.json()["transcriptions"]
        assert any(t["id"] == trans_id for t in items)

        # 3. Get single transcription
        get_res = await client.get(f"/api/v1/transcription/{trans_id}")
        assert get_res.status_code == 200
        assert get_res.json()["id"] == trans_id

        # 4. Summarize transcription
        sum_res = await client.post(f"/api/v1/transcription/{trans_id}/summarize")
        assert sum_res.status_code == 200
        assert sum_res.json()["summary"] is not None

        # 5. Delete transcription
        del_res = await client.delete(f"/api/v1/transcription/{trans_id}")
        assert del_res.status_code == 200

        # 6. Verify deleted
        get_del = await client.get(f"/api/v1/transcription/{trans_id}")
        assert get_del.status_code == 404
