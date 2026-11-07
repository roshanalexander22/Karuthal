from __future__ import annotations
from fastapi import FastAPI, UploadFile, File, Form, Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, Dict, Any, List
import base64

from ocr.ocr_service import OCRService
from document_extraction.document_service import DocumentExtractionService
from speech_recognition.asr_service import ASRService
from text_to_speech.tts_service import TTSService
from intent_detection.intent_service import IntentDetectionService
from transcription.transcription_service import AudioTranscriptionService
from fall_detection.fall_detector import FallDetector

app = FastAPI(
    title="Sahaayi AI Engine",
    version="0.1.0",
    description="Microservice for ASR, TTS, OCR, Transcription, Fall Detection, and LLM-driven accessibility reasoning"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "http://localhost:8000",
        "http://127.0.0.1:8000",
        "http://localhost:8001",
        "http://127.0.0.1:8001",
    ],
    allow_origin_regex=r"^https?://(localhost|127\.0\.0\.1)(:[0-9]+)?$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Services
asr_service = ASRService()
tts_service = TTSService()

# Schemas
class ExtractionRequest(BaseModel):
    raw_ocr_text: str
    document_type: Optional[str] = "AUTO"

class ExtractionResponse(BaseModel):
    success: bool
    fields: Dict[str, Any]
    detected_type: str

class IntentRequest(BaseModel):
    utterance: str
    language: Optional[str] = "ml"

class TTSRequest(BaseModel):
    text: str
    language: Optional[str] = "ml"
    speed: Optional[float] = 0.85

class TTSResponse(BaseModel):
    audio_base64: str
    duration_seconds: float
    language: str
    text: str

class VoiceProcessRequest(BaseModel):
    text: Optional[str] = None
    audio_base64: Optional[str] = None
    language: Optional[str] = "ml"

class VoiceProcessResponse(BaseModel):
    recognized_text: str
    intent: str
    confidence: float
    response_text: str
    action: str
    target_route: Optional[str] = None
    audio_base64: Optional[str] = None

class SummarizeRequest(BaseModel):
    full_text: str

class TranscriptionProcessResponse(BaseModel):
    status: str
    language: str
    duration_seconds: float
    full_text: str
    summary: str
    segments: List[Dict[str, Any]]

class TelemetryPayload(BaseModel):
    readings: List[Dict[str, float]]

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "sahaayi-ai-engine",
        "models": {
            "ocr": "Tesseract 5 (mal+eng)",
            "extraction": "Rule-based & Regex NER",
            "asr": "IndicConformer / Whisper",
            "tts": "Indic-TTS / DhVaani",
            "transcription": "Malayalam Conformer / Whisper Audio",
            "summarizer": "Indic-BART / Gemini",
            "fall_detection": "3-Phase Biomechanical Threshold Analyzer",
            "llm": "Google Gemini"
        }
    }

# Document OCR
@app.post("/ocr/extract")
async def extract_document_ocr(
    file: UploadFile = File(...),
    language: Optional[str] = Form("mal+eng")
):
    """Extract Malayalam & English text from image or PDF document."""
    file_bytes = await file.read()
    result = OCRService.process_document(
        file_bytes=file_bytes,
        filename=file.filename or "upload.bin",
        lang=language or "mal+eng"
    )
    return result

# Document Extraction
@app.post("/extraction/extract")
async def extract_document_entities(payload: ExtractionRequest):
    result = await DocumentExtractionService.extract_structured_entities(
        raw_ocr_text=payload.raw_ocr_text,
        document_type=payload.document_type or "AUTO"
    )
    return result

# ASR
@app.post("/asr/transcribe")
async def transcribe_audio(
    file: Optional[UploadFile] = File(None),
    language: str = Form("ml")
):
    audio_bytes = b""
    if file:
        audio_bytes = await file.read()
    return await asr_service.transcribe(audio_bytes, language=language)

# TTS
@app.post("/tts/synthesize", response_model=TTSResponse)
async def synthesize_speech(payload: TTSRequest):
    wav_bytes = await tts_service.synthesize(
        text=payload.text,
        language=payload.language or "ml",
        speed=payload.speed or 0.85
    )
    b64 = base64.b64encode(wav_bytes).decode("utf-8")
    return TTSResponse(
        audio_base64=b64,
        duration_seconds=round(len(wav_bytes) / 32000.0, 2),
        language=payload.language or "ml",
        text=payload.text
    )

@app.post("/tts/wav")
async def synthesize_wav_direct(payload: TTSRequest):
    wav_bytes = await tts_service.synthesize(
        text=payload.text,
        language=payload.language or "ml",
        speed=payload.speed or 0.85
    )
    return Response(content=wav_bytes, media_type="audio/wav")

# Intent Detection
@app.post("/intent/detect")
async def detect_intent_endpoint(payload: IntentRequest):
    return await IntentDetectionService.detect_intent(
        user_utterance=payload.utterance,
        language=payload.language or "ml"
    )

# Unified Voice Processing
@app.post("/voice/process", response_model=VoiceProcessResponse)
async def process_voice_interaction(payload: VoiceProcessRequest):
    transcript = payload.text or ""
    if not transcript and payload.audio_base64:
        try:
            raw_audio = base64.b64decode(payload.audio_base64)
            asr_res = await asr_service.transcribe(raw_audio, language=payload.language or "ml")
            transcript = asr_res.get("transcript", "")
        except Exception:
            transcript = ""

    if not transcript:
        transcript = "നമസ്കാരം"

    intent_res = await IntentDetectionService.detect_intent(transcript, language=payload.language or "ml")
    resp_text = intent_res.get("response_text", "")

    # Synthesize reply audio
    wav_bytes = await tts_service.synthesize(resp_text, language=payload.language or "ml", speed=0.85)
    audio_b64 = base64.b64encode(wav_bytes).decode("utf-8")

    return VoiceProcessResponse(
        recognized_text=transcript,
        intent=intent_res.get("intent", "GENERAL_ASSISTANCE"),
        confidence=intent_res.get("confidence", 0.9),
        response_text=resp_text,
        action=intent_res.get("action", "NONE"),
        target_route=intent_res.get("target_route"),
        audio_base64=audio_b64
    )

# Transcription Processing
@app.post("/transcription/process", response_model=TranscriptionProcessResponse)
async def process_audio_transcription(
    file: Optional[UploadFile] = File(None),
    language: str = Form("ml")
):
    audio_bytes = b""
    filename = "recording.wav"
    if file:
        audio_bytes = await file.read()
        filename = file.filename or filename

    return await AudioTranscriptionService.transcribe_and_segment(
        audio_bytes=audio_bytes,
        language=language,
        filename=filename
    )

@app.post("/transcription/summarize")
async def summarize_text(payload: SummarizeRequest):
    summary = AudioTranscriptionService.generate_summary(payload.full_text)
    return {"summary": summary}

# Fall Telemetry Analysis
@app.post("/fall/analyze")
async def analyze_fall_telemetry(payload: TelemetryPayload):
    return FallDetector.evaluate_telemetry(payload.readings)
