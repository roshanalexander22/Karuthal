from __future__ import annotations
from pydantic import BaseModel, ConfigDict
from typing import Optional, List, Dict, Any
from datetime import datetime
from uuid import UUID

class FallEventPayload(BaseModel):
    confidence_score: float = 0.95
    sensor_summary: Optional[Dict[str, Any]] = None
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
    location_lat: Optional[float] = None
    location_lng: Optional[float] = None
    sos_dispatched: bool = False

class FallEventListResponse(BaseModel):
    events: List[FallEventResponse]
    total: int

class FallDetectionSettingsResponse(BaseModel):
    is_enabled: bool = True
    sensitivity: str = "MEDIUM"  # LOW, MEDIUM, HIGH
    countdown_seconds: int = 30
    auto_sos_enabled: bool = True

class FallDetectionSettingsUpdate(BaseModel):
    is_enabled: Optional[bool] = None
    sensitivity: Optional[str] = None
    countdown_seconds: Optional[int] = None
    auto_sos_enabled: Optional[bool] = None
