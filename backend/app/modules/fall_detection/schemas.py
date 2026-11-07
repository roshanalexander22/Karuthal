from __future__ import annotations
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from uuid import UUID

class FallEventPayload(BaseModel):
    confidence_score: float = 0.95
    sensor_summary: Dict[str, Any] = Field(default_factory=dict)
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

    model_config = {"from_attributes": True}

class FallEventListResponse(BaseModel):
    events: List[FallEventResponse]

class FallSettingsPayload(BaseModel):
    sensitivity: Optional[str] = "MEDIUM"  # LOW, MEDIUM, HIGH
    countdown_seconds: Optional[int] = 30
    auto_sos_enabled: Optional[bool] = True
    audible_siren: Optional[bool] = True

class FallSettingsResponse(BaseModel):
    user_id: UUID
    sensitivity: str = "MEDIUM"
    countdown_seconds: int = 30
    auto_sos_enabled: bool = True
    audible_siren: bool = True
