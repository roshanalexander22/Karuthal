from __future__ import annotations
from pydantic import BaseModel, ConfigDict
from typing import Optional, List
from datetime import datetime
from uuid import UUID

class EmergencyContactCreate(BaseModel):
    name: str
    phone: str
    relationship: Optional[str] = "Caregiver"
    is_primary: bool = True

class EmergencyContactResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    user_id: UUID
    name: str
    phone: str
    relationship: Optional[str] = None
    is_primary: bool = False

class EmergencyContactListResponse(BaseModel):
    contacts: List[EmergencyContactResponse]
    total: int

class EmergencyTriggerRequest(BaseModel):
    reason: str = "SOS_BUTTON_PRESSED"
    location_lat: Optional[float] = None
    location_lng: Optional[float] = None

class EmergencyTriggerResponse(BaseModel):
    alert_id: UUID
    dispatched_contacts_count: int
    status: str
    message: str
    timestamp: datetime
