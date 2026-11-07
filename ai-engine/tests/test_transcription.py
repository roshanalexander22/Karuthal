import pytest
import io
from starlette.testclient import TestClient
from main import app
from transcription.transcription_service import AudioTranscriptionService

client = TestClient(app)

def test_transcription_service_summary():
    text = "ബിപി 130/85 ആണ്. ഗുളിക കൃത്യമായി കഴിക്കണം. ഭക്ഷണത്തിൽ ഉപ്പ് കുറയ്ക്കണം. അടുത്ത മാസം കാണാം."
    summary = AudioTranscriptionService.generate_summary(text)
    assert "ബിപി" in summary
    assert "ഗുളികകൾ" in summary
    assert "ഉപ്പിന്റെ" in summary

def test_transcription_process_endpoint():
    dummy_wav = b"RIFF" + b"\x00" * 36 + b"data" + b"\x00" * 100
    files = {"file": ("doctor_visit.wav", io.BytesIO(dummy_wav), "audio/wav")}
    response = client.post("/transcription/process", files=files, data={"language": "ml"})
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "COMPLETED"
    assert len(data["segments"]) > 0
    assert "summary" in data

def test_summarize_endpoint():
    res = client.post("/transcription/summarize", json={"full_text": "ഡോക്ടർ പറഞ്ഞു ഗുളിക കൃത്യമായി കഴിക്കണമെന്ന്."})
    assert res.status_code == 200
    assert "summary" in res.json()
