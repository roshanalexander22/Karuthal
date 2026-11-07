from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, Dict, Any, List

from transcription.transcription_service import AudioTranscriptionService

app = FastAPI(
    title="Sahaayi AI Engine",
    version="0.1.0",
    description="Microservice for ASR, TTS, OCR, and LLM-driven accessibility reasoning"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class SummarizeRequest(BaseModel):
    full_text: str

class TranscriptionProcessResponse(BaseModel):
    status: str
    language: str
    duration_seconds: float
    full_text: str
    summary: str
    segments: List[Dict[str, Any]]

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "sahaayi-ai-engine",
        "models": {
            "transcription": "Malayalam Conformer / Whisper Audio",
            "summarizer": "Indic-BART / Gemini"
        }
    }

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
