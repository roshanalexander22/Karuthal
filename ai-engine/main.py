from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Any, Optional

from fall_detection.fall_detector import FallDetector

app = FastAPI(
    title="Sahaayi AI Engine",
    version="0.1.0",
    description="Microservice for ASR, TTS, OCR, Fall Detection, and LLM-driven accessibility reasoning"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class TelemetryPayload(BaseModel):
    readings: List[Dict[str, float]]

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "sahaayi-ai-engine",
        "models": {
            "fall_detection": "3-Phase Biomechanical Threshold Analyzer"
        }
    }

@app.post("/fall/analyze")
async def analyze_fall_telemetry(payload: TelemetryPayload):
    return FallDetector.evaluate_telemetry(payload.readings)
