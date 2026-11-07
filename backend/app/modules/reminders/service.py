from __future__ import annotations
import uuid
from typing import List, Optional, Dict, Any
from uuid import UUID
from datetime import datetime, timezone
from app.modules.reminders.schemas import (
    ReminderCreate,
    ReminderUpdate,
    ReminderResponse,
    ReminderAcknowledgeResponse
)

# User-isolated in-memory store: {reminder_id: dict}
_reminders_db: Dict[UUID, Dict[str, Any]] = {}


class ReminderService:
    @classmethod
    async def create_reminder(cls, user_id: UUID, data: ReminderCreate) -> ReminderResponse:
        """Create new medicine or appointment reminder."""
        reminder_id = uuid.uuid4()
        now = datetime.now(timezone.utc)

        record = {
            "id": reminder_id,
            "user_id": user_id,
            "title": data.title,
            "description": data.description,
            "reminder_type": data.reminder_type.upper(),
            "scheduled_time": data.scheduled_time,
            "recurrence_rule": data.recurrence_rule or "DAILY",
            "dosage": data.dosage,
            "doctor_name": data.doctor_name,
            "hospital_name": data.hospital_name,
            "is_active": True,
            "status": "PENDING",
            "last_acknowledged_at": None,
            "created_at": now
        }
        _reminders_db[reminder_id] = record
        return ReminderResponse(**record)

    @classmethod
    async def list_reminders(cls, user_id: UUID) -> List[ReminderResponse]:
        """List all reminders for user."""
        user_items = [
            ReminderResponse(**r)
            for r in _reminders_db.values()
            if r["user_id"] == user_id
        ]
        return sorted(user_items, key=lambda x: x.scheduled_time)

    @classmethod
    async def get_reminder(cls, user_id: UUID, reminder_id: UUID) -> Optional[ReminderResponse]:
        record = _reminders_db.get(reminder_id)
        if record and record["user_id"] == user_id:
            return ReminderResponse(**record)
        return None

    @classmethod
    async def update_reminder(cls, user_id: UUID, reminder_id: UUID, data: ReminderUpdate) -> Optional[ReminderResponse]:
        record = _reminders_db.get(reminder_id)
        if not record or record["user_id"] != user_id:
            return None

        update_data = data.model_dump(exclude_unset=True)
        record.update(update_data)
        return ReminderResponse(**record)

    @classmethod
    async def delete_reminder(cls, user_id: UUID, reminder_id: UUID) -> bool:
        record = _reminders_db.get(reminder_id)
        if not record or record["user_id"] != user_id:
            return False
        del _reminders_db[reminder_id]
        return True

    @classmethod
    async def acknowledge_reminder(cls, user_id: UUID, reminder_id: UUID) -> ReminderAcknowledgeResponse:
        """Mark a reminder as taken or attended."""
        record = _reminders_db.get(reminder_id)
        if not record or record["user_id"] != user_id:
            from fastapi import HTTPException
            raise HTTPException(status_code=404, detail="Reminder not found")

        now = datetime.now(timezone.utc)
        record["status"] = "TAKEN"
        record["last_acknowledged_at"] = now

        return ReminderAcknowledgeResponse(
            reminder_id=reminder_id,
            status="TAKEN",
            acknowledged_at=now,
            message="മരുന്ന് കഴിച്ചതായി അടയാളപ്പെടുത്തി (Marked as taken)"
        )
