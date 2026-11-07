from __future__ import annotations
from pydantic import BaseModel, ConfigDict
from typing import Optional, List
from datetime import datetime
from uuid import UUID

class TranscriptSegment(BaseModel):
    start_time: float
    end_time: float
    text: str
    speaker: Optional[str] = "സ്പീക്കർ"

class TranscriptionUploadResponse(BaseModel):
    id: UUID
    filename: str
    language: str
    status: str
    duration_seconds: float = 0.0

class TranscriptionResultResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    status: str
    language: str
    full_text: str
    summary: Optional[str] = None
    duration_seconds: float = 0.0
    segments: List[TranscriptSegment] = []
    created_at: Optional[datetime] = None

class TranscriptionListResponse(BaseModel):
    transcriptions: List[TranscriptionResultResponse]
    total: int

class TranscriptionSummarizeRequest(BaseModel):
    language: Optional[str] = "ml"
