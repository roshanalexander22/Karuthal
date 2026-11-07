from __future__ import annotations
from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, Dict, Any

from ocr.ocr_service import OCRService
from document_extraction.document_service import DocumentExtractionService

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

class ExtractionRequest(BaseModel):
    raw_ocr_text: str
    document_type: Optional[str] = "AUTO"

class ExtractionResponse(BaseModel):
    success: bool
    fields: Dict[str, Any]
    detected_type: str

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "sahaayi-ai-engine",
        "models": {
            "ocr": "Tesseract 5 (mal+eng)",
            "extraction": "Rule-based & Regex NER",
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

@app.post("/extraction/extract", response_model=ExtractionResponse)
async def extract_document_entities(payload: ExtractionRequest):
    result = await DocumentExtractionService.extract_structured_entities(
        raw_ocr_text=payload.raw_ocr_text,
        document_type=payload.document_type or "AUTO"
    )
    return result
