from __future__ import annotations
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, List, Dict, Any
from datetime import datetime
from uuid import UUID

class VoiceChatRequest(BaseModel):
    message: Optional[str] = None
    audio_base64: Optional[str] = None
    language: Optional[str] = "ml"

class VoiceChatResponse(BaseModel):
    user_message: str
    assistant_reply: str
    intent: str
    confidence: float
    action: str = "NONE"
    target_route: Optional[str] = None
    audio_base64: Optional[str] = None
    language: str = "ml"
    timestamp: datetime

class TTSConvertRequest(BaseModel):
    text: str
    language: Optional[str] = "ml"
    speed: Optional[float] = 0.85

class TTSConvertResponse(BaseModel):
    audio_base64: str
    duration_seconds: float
    language: str
    text: str

class VoiceHistoryItem(BaseModel):
    id: str
    user_message: str
    assistant_reply: str
    intent: str
    created_at: datetime

class VoiceHistoryResponse(BaseModel):
    history: List[VoiceHistoryItem]
    total: int
