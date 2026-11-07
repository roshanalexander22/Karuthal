from __future__ import annotations
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime
from uuid import UUID

class FallEventPayload(BaseModel):
    confidence_score: float
    sensor_summary: Dict[str, Any]
    location_lat: Optional[float] = None
    location_lng: Optional[float] = None
    was_cancelled_by_user: bool = False

class FallEventResponse(BaseModel):
    id: UUID
    user_id: UUID
    detected_at: datetime
    confidence_score: float
    confirmed: bool
    false_alarm: bool

    class Config:
        from_attributes = True

class FallEventListResponse(BaseModel):
    events: List[FallEventResponse]
