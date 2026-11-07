import pytest
from starlette.testclient import TestClient
from main import app
from document_extraction.document_service import DocumentExtractionService

client = TestClient(app)

@pytest.mark.asyncio
async def test_document_extraction_service():
    sample_text = """
    GOVERNMENT OF INDIA
    UNIQUE IDENTIFICATION AUTHORITY OF INDIA
    Name: Madhavan Nair മാധവൻ നായർ
    DOB: 12/04/1952
    Male
    9847 1234 5678
    Phone: 9847123456
    PIN: 686001
    Blood Group: O+ve
    """
    res = await DocumentExtractionService.extract_structured_entities(sample_text)
    assert res["document_type"] == "AADHAAR"
    entities = res["entities"]
    assert "Aadhaar Number" in entities
    assert entities["Aadhaar Number"] == "9847 1234 5678"
    assert entities["Date of Birth"] == "12/04/1952"
    assert entities["Phone Number"] == "9847123456"
    assert entities["PIN Code"] == "686001"
    assert entities["Blood Group"] == "O+"
    assert "Full Name" in entities

def test_extraction_endpoint():
    payload = {
        "raw_ocr_text": "INCOME TAX DEPARTMENT\nPAN CARD\nName: RAMAN PILLAI\nABCDE1234F\nDOB: 15-08-1947",
        "document_type": "AUTO"
    }
    response = client.post("/extraction/extract", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["document_type"] == "PAN"
    assert data["entities"]["PAN Number"] == "ABCDE1234F"
