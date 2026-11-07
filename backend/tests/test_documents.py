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
async def test_document_upload_and_flow():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # 1. Upload Document
        test_file_content = b"%PDF-1.4 mock pdf text content for unit test"
        files = {
            "file": ("sample_test.pdf", io.BytesIO(test_file_content), "application/pdf")
        }
        data = {
            "category": "MEDICAL"
        }
        upload_resp = await client.post("/api/v1/documents/upload", files=files, data=data)
        assert upload_resp.status_code == 201, upload_resp.text
        doc_data = upload_resp.json()
        doc_id = doc_data["id"]
        assert doc_data["document_category"] == "MEDICAL"
        assert "extracted_text" in doc_data

        # 2. List Documents
        list_resp = await client.get("/api/v1/documents")
        assert list_resp.status_code == 200
        docs = list_resp.json()["documents"]
        assert any(d["id"] == doc_id for d in docs)

        # 3. Get Document Details
        get_resp = await client.get(f"/api/v1/documents/{doc_id}")
        assert get_resp.status_code == 200
        assert get_resp.json()["id"] == doc_id

        # 4. Get TTS Audio for Document
        tts_resp = await client.get(f"/api/v1/documents/{doc_id}/tts")
        assert tts_resp.status_code == 200
        tts_data = tts_resp.json()
        assert "audio_base64" in tts_data
        assert tts_data["language"] == "ml"

        # 5. Check Extraction Status
        status_resp = await client.get(f"/api/v1/documents/{doc_id}/status")
        assert status_resp.status_code == 200
        assert status_resp.json()["status"] in ["COMPLETED", "PROCESSING"]

        # 6. Delete Document
        del_resp = await client.delete(f"/api/v1/documents/{doc_id}")
        assert del_resp.status_code in [200, 204]

        # 7. Verify Document is Deleted
        get_deleted = await client.get(f"/api/v1/documents/{doc_id}")
        assert get_deleted.status_code == 404
