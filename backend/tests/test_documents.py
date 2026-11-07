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
async def test_document_lifecycle(async_client):
    # 1. Upload mock document
    file_content = b"%PDF-1.4 sample pdf content with text Raman Nair 12/05/1950 Aadhaar 5482 9102 3847"
    files = {"file": ("aadhaar_test.pdf", io.BytesIO(file_content), "application/pdf")}
    data = {"category": "IDENTITY"}

    upload_resp = await async_client.post("/api/v1/documents/upload", files=files, data=data)
    assert upload_resp.status_code == 201
    doc_data = upload_resp.json()
    assert "id" in doc_data
    doc_id = doc_data["id"]
    assert doc_data["document_category"] in ["IDENTITY", "identity_document"]
    assert doc_data["ocr_status"] == "COMPLETED"

    # 2. List documents
    list_resp = await async_client.get("/api/v1/documents")
    assert list_resp.status_code == 200
    docs = list_resp.json()["documents"]
    assert any(d["id"] == doc_id for d in docs)

    # 3. Get single document
    get_resp = await async_client.get(f"/api/v1/documents/{doc_id}")
    assert get_resp.status_code == 200
    assert get_resp.json()["id"] == doc_id

    # 4. Trigger TTS read aloud
    tts_resp = await async_client.post(f"/api/v1/documents/{doc_id}/tts")
    assert tts_resp.status_code == 200
    assert "text_read" in tts_resp.json()

    # 5. Delete document
    del_resp = await async_client.delete(f"/api/v1/documents/{doc_id}")
    assert del_resp.status_code == 200

    # 6. Verify deleted
    get_deleted = await async_client.get(f"/api/v1/documents/{doc_id}")
    assert get_deleted.status_code == 404
