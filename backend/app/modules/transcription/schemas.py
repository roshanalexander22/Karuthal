from __future__ import annotations
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from uuid import UUID

class TranscriptionSessionResponse(BaseModel):
    session_id: UUID
    stream_url: str
    status: str

class TranscriptionUploadResponse(BaseModel):
    id: UUID
    filename: str
    language: str
    status: str

class TranscriptSegment(BaseModel):
    start_time: float
    end_time: float
    text: str
    speaker: Optional[str] = None

class TranscriptionResultResponse(BaseModel):
    id: UUID
    status: str
    language: str
    full_text: str
    summary: Optional[str] = None
    segments: List[TranscriptSegment] = []
