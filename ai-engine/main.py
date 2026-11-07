from __future__ import annotations
from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional

from ocr.ocr_service import OCRService

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

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "sahaayi-ai-engine",
        "models": {
            "ocr": "Tesseract 5 (mal+eng)",
            "asr": "IndicConformer / Whisper stub",
            "tts": "Indic-TTS / DhVaani stub",
            "llm": "Google Gemini"
        }
    }

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
