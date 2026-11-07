from __future__ import annotations
from pydantic import BaseModel, ConfigDict
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
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    user_id: UUID
    detected_at: datetime
    confidence_score: float
    confirmed: bool
    false_alarm: bool

class FallEventListResponse(BaseModel):
    events: List[FallEventResponse]
