from __future__ import annotations
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, List
from datetime import datetime


class VoiceChatRequest(BaseModel):
    text: Optional[str] = None
    language: str = "ml"


class VoiceChatResponse(BaseModel):
    user_query: str
    intent: str
    confidence: float
    entities: Dict[str, Any] = Field(default_factory=dict)
    response_text: str
    audio_base64: Optional[str] = None
    action_executed: Optional[str] = None


class VoiceHistoryItem(BaseModel):
    id: str
    timestamp: datetime
    user_query: str
    intent: str
    response_text: str


class TTSConvertRequest(BaseModel):
    text: str
    language: str = "ml"
    speed: float = 0.85


class TTSConvertResponse(BaseModel):
    audio_base64: str
    sample_rate: int = 16000
    text: str
    language: str
