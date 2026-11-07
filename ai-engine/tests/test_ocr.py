import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_ai_health():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "ocr" in data["models"]

def test_ocr_extract_image():
    # 1x1 transparent PNG bytes
    dummy_png = (
        b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01"
        b"\x08\x06\x00\x00\x00\x1f\x15c4\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05"
        b"\x00\x01\r\n-\xb4\x00\x00\x00\x00IEND\xaeB`\x82"
    )
    files = {"file": ("test_card.png", dummy_png, "image/png")}
    response = client.post("/ocr/extract", files=files, data={"language": "mal+eng"})
    assert response.status_code == 200
    data = response.json()
    assert "extracted_text" in data
    assert "character_count" in data
    assert data["filename"] == "test_card.png"

def test_ocr_extract_pdf():
    dummy_pdf = b"%PDF-1.4\n1 0 obj\n<< /Type /Catalog >>\nendobj\ntrailer\n<< /Root 1 0 R >>\n%%EOF"
    files = {"file": ("test_doc.pdf", dummy_pdf, "application/pdf")}
    response = client.post("/ocr/extract", files=files)
    assert response.status_code == 200
    data = response.json()
    assert data["is_pdf"] is True
    assert "extracted_text" in data
