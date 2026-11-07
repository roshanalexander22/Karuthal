from __future__ import annotations

import io
from fastapi import FastAPI, UploadFile, File, Form, HTTPException, Response, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional

from speech_recognition.asr_service import ASRService
from text_to_speech.tts_service import TTSService
from intent_detection.intent_service import IntentDetectionService

app = FastAPI(
    title="Sahaayi AI Engine",
    version="0.2.0",
    description="Microservice for ASR, TTS, OCR, and LLM-driven accessibility reasoning"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

asr_service = ASRService()
tts_service = TTSService()
intent_service = IntentDetectionService()


class TTSRequest(BaseModel):
    text: str
    language: str = "ml"
    speed: float = 0.85


class IntentRequest(BaseModel):
    text: str


@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "sahaayi-ai-engine",
        "models": {
            "ocr": "Tesseract 5 (mal+eng)",
            "asr": "AI4Bharat IndicConformer / Whisper",
            "tts": "Indic-TTS / Acoustic WAV Synthesizer",
            "llm": "Google Gemini"
        }
    }


@app.post("/asr/transcribe")
async def transcribe_speech(
    file: UploadFile = File(...),
    language: str = Form("ml")
):
    """Transcribe speech audio bytes into Malayalam or English text."""
    try:
        audio_bytes = await file.read()
        result = await asr_service.transcribe(audio_bytes, language=language)
        return result
    except ValueError as val_err:
        raise HTTPException(status_code=400, detail=str(val_err))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"ASR error: {exc}")


@app.post("/tts/synthesize")
async def synthesize_speech(payload: TTSRequest):
    """Synthesize speech into 16kHz mono WAV audio."""
    try:
        wav_bytes = await tts_service.synthesize(
            text=payload.text,
            language=payload.language,
            speed=payload.speed,
        )
        return Response(content=wav_bytes, media_type="audio/wav")
    except ValueError as val_err:
        raise HTTPException(status_code=400, detail=str(val_err))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"TTS synthesis error: {exc}")


@app.post("/intent/detect")
async def detect_intent(payload: IntentRequest):
    """Classify user utterance into actionable intents with slot filling."""
    return await intent_service.detect_intent(payload.text)
