from __future__ import annotations
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID, uuid4

class EmergencyTriggerRequest(BaseModel):
    reason: str = "SOS_BUTTON_PRESSED"
    location_lat: Optional[float] = None
    location_lng: Optional[float] = None

class EmergencyTriggerResponse(BaseModel):
    alert_id: UUID
    dispatched_contacts_count: int
    status: str
    message: str

class EmergencyContactCreate(BaseModel):
    name: str
    phone: str
    relationship: Optional[str] = "Family"
    is_primary: bool = False

class EmergencyContactResponse(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    user_id: UUID
    name: str
    phone: str
    relationship: Optional[str] = None
    is_primary: bool = False
    created_at: Optional[datetime] = None

    model_config = {"from_attributes": True}

class EmergencyContactListResponse(BaseModel):
    contacts: List[EmergencyContactResponse]
    total: int
