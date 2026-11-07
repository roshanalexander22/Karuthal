from __future__ import annotations
from pydantic import BaseModel
from typing import Optional, List
from uuid import UUID

class EmergencyTriggerRequest(BaseModel):
    reason: str = "SOS_BUTTON_PRESSED"
    location_lat: Optional[float] = None
    location_lng: Optional[float] = None

class EmergencyTriggerResponse(BaseModel):
    alert_id: UUID
    dispatched_contacts_count: int
    status: str
    message: str
