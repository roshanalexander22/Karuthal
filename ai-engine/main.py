from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, Dict, Any

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
    document_type: str
    entities: Dict[str, Any]
    confidence_scores: Dict[str, float]
    raw_text_length: int

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

@app.post("/extraction/extract", response_model=ExtractionResponse)
async def extract_document_entities(payload: ExtractionRequest):
    result = await DocumentExtractionService.extract_structured_entities(
        raw_ocr_text=payload.raw_ocr_text,
        document_type=payload.document_type or "AUTO"
    )
    return result
