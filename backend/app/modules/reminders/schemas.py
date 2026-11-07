from __future__ import annotations
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from uuid import UUID

class ReminderCreate(BaseModel):
    title: str
    description: Optional[str] = None
    reminder_type: str = "MEDICINE"  # MEDICINE, APPOINTMENT, GENERAL
    scheduled_time: datetime
    recurrence_rule: Optional[str] = None  # DAILY, WEEKLY, NONE
    dosage: Optional[str] = None
    doctor_name: Optional[str] = None
    hospital_name: Optional[str] = None

class ReminderUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    reminder_type: Optional[str] = None
    scheduled_time: Optional[datetime] = None
    recurrence_rule: Optional[str] = None
    dosage: Optional[str] = None
    doctor_name: Optional[str] = None
    hospital_name: Optional[str] = None
    is_active: Optional[bool] = None
    status: Optional[str] = None

class ReminderResponse(BaseModel):
    id: UUID
    user_id: UUID
    title: str
    description: Optional[str] = None
    reminder_type: str
    scheduled_time: datetime
    recurrence_rule: Optional[str] = None
    dosage: Optional[str] = None
    doctor_name: Optional[str] = None
    hospital_name: Optional[str] = None
    is_active: bool = True
    status: str = "PENDING"  # PENDING, TAKEN, MISSED
    last_acknowledged_at: Optional[datetime] = None
    created_at: datetime

    model_config = {"from_attributes": True}

class ReminderListResponse(BaseModel):
    reminders: List[ReminderResponse]
    total: int

class ReminderAcknowledgeResponse(BaseModel):
    reminder_id: UUID
    status: str
    acknowledged_at: datetime
    message: str
