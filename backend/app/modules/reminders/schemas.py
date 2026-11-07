from __future__ import annotations
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from uuid import UUID

class ReminderCreate(BaseModel):
    title: str
    description: Optional[str] = None
    reminder_type: str = "MEDICINE"
    scheduled_time: datetime
    recurrence_rule: Optional[str] = None

class ReminderUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    scheduled_time: Optional[datetime] = None
    is_active: Optional[bool] = None

class ReminderResponse(BaseModel):
    id: UUID
    user_id: UUID
    title: str
    description: Optional[str] = None
    reminder_type: str
    scheduled_time: datetime
    recurrence_rule: Optional[str] = None
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

class ReminderListResponse(BaseModel):
    reminders: List[ReminderResponse]
    total: int
