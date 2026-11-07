from __future__ import annotations
from pydantic import BaseModel
from typing import List, Optional
from uuid import UUID
from datetime import datetime

class CaregiverInvite(BaseModel):
    caregiver_email: str
    relationship: str
    can_view_reminders: bool = True
    can_view_location: bool = False

class CaregiverResponse(BaseModel):
    id: UUID
    caregiver_email: str
    relationship: str
    consent_given: bool
    can_view_reminders: bool
    can_view_location: bool
    created_at: datetime
