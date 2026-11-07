from __future__ import annotations
from pydantic import BaseModel, Field, ConfigDict
from typing import List, Optional
from datetime import datetime
from uuid import UUID

class ReminderCreate(BaseModel):
    title: str
    description: Optional[str] = None
    dosage: Optional[str] = "1 ഗുളിക (1 Tablet)"
    instructions_ml: Optional[str] = "ഭക്ഷണത്തിന് ശേഷം (After food)"
    reminder_type: str = "MEDICINE"
    scheduled_time: datetime
    recurrence_rule: Optional[str] = "DAILY"

class ReminderUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    dosage: Optional[str] = None
    instructions_ml: Optional[str] = None
    scheduled_time: Optional[datetime] = None
    recurrence_rule: Optional[str] = None
    is_active: Optional[bool] = None

class ReminderResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    user_id: UUID
    title: str
    description: Optional[str] = None
    dosage: Optional[str] = None
    instructions_ml: Optional[str] = None
    reminder_type: str
    scheduled_time: datetime
    recurrence_rule: Optional[str] = None
    is_active: bool
    created_at: datetime
    last_acknowledged_at: Optional[datetime] = None

class ReminderListResponse(BaseModel):
    reminders: List[ReminderResponse]
    total: int

class ReminderAcknowledgeResponse(BaseModel):
    reminder_id: UUID
    acknowledged_at: datetime
    message: str
    status: str = "TAKEN"
