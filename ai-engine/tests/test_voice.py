import pytest
from starlette.testclient import TestClient
from main import app

client = TestClient(app)

def test_asr_empty():
    response = client.post("/asr/transcribe", data={"language": "ml"})
    assert response.status_code == 200
    assert response.json()["status"] == "EMPTY_AUDIO"

def test_tts_synthesize():
    payload = {
        "text": "നമസ്കാരം, മരുന്ന് കഴിക്കാൻ സമയമായി.",
        "language": "ml",
        "speed": 0.85
    }
    response = client.post("/tts/synthesize", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "audio_base64" in data
    assert data["language"] == "ml"
    assert data["duration_seconds"] > 0

def test_intent_detection():
    # Emergency SOS
    sos_res = client.post("/intent/detect", json={"utterance": "അയ്യോ എന്നെ സഹായിക്കൂ ഞാൻ താഴെ വീണു"})
    assert sos_res.status_code == 200
    assert sos_res.json()["intent"] == "EMERGENCY_SOS"

    # Reminder
    rem_res = client.post("/intent/detect", json={"utterance": "രാവിലെ 8 മണിക്ക് ബിപി ഗുളിക ഓർമ്മിപ്പിക്കുക"})
    assert rem_res.status_code == 200
    assert rem_res.json()["intent"] == "SET_REMINDER"

def test_unified_voice_process():
    payload = {
        "text": "ഗുളിക കഴിക്കാൻ ഓർമ്മിപ്പിക്കൂ"
    }
    response = client.post("/voice/process", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["intent"] == "SET_REMINDER"
    assert "audio_base64" in data
    assert len(data["response_text"]) > 0
