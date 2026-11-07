from __future__ import annotations
import logging
from datetime import datetime
from typing import List, Optional, Dict
from uuid import UUID, uuid4
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete

from app.models.reminder import Reminder, ReminderLog
from app.modules.reminders.schemas import (
    ReminderCreate,
    ReminderUpdate,
    ReminderResponse,
    ReminderAcknowledgeResponse
)

logger = logging.getLogger(__name__)

# In-memory fallback per user
_user_reminders: Dict[UUID, Dict[UUID, ReminderResponse]] = {}
_reminder_acknowledgements: Dict[UUID, datetime] = {}


class ReminderService:
    """Manages scheduled medicine and appointment reminders."""

    @classmethod
    async def create_reminder(
        cls,
        user_id: UUID,
        data: ReminderCreate,
        db: Optional[AsyncSession] = None
    ) -> ReminderResponse:
        rem_id = uuid4()
        now = datetime.utcnow()

        item = ReminderResponse(
            id=rem_id,
            user_id=user_id,
            title=data.title,
            description=data.description,
            dosage=data.dosage,
            instructions_ml=data.instructions_ml,
            reminder_type=data.reminder_type,
            scheduled_time=data.scheduled_time,
            recurrence_rule=data.recurrence_rule,
            is_active=True,
            created_at=now,
            last_acknowledged_at=None
        )

        if user_id not in _user_reminders:
            _user_reminders[user_id] = {}
        _user_reminders[user_id][rem_id] = item

        if db is not None:
            try:
                db_item = Reminder(
                    id=rem_id,
                    user_id=user_id,
                    title=data.title,
                    description=data.description,
                    reminder_type=data.reminder_type,
                    scheduled_time=data.scheduled_time,
                    recurrence_rule=data.recurrence_rule,
                    is_active=True,
                    created_at=now
                )
                db.add(db_item)
                await db.commit()
            except Exception as exc:
                logger.debug("Database reminder create fallback: %s", exc)

        return item

    @classmethod
    async def list_reminders(
        cls,
        user_id: UUID,
        db: Optional[AsyncSession] = None
    ) -> List[ReminderResponse]:
        results: List[ReminderResponse] = []

        if db is not None:
            try:
                stmt = select(Reminder).where(Reminder.user_id == user_id).order_by(Reminder.scheduled_time.asc())
                res = await db.execute(stmt)
                db_rems = res.scalars().all()
                for r in db_rems:
                    ack_time = _reminder_acknowledgements.get(r.id)
                    results.append(ReminderResponse(
                        id=r.id,
                        user_id=r.user_id,
                        title=r.title,
                        description=r.description,
                        dosage="1 ഗുളിക",
                        instructions_ml="ഭക്ഷണത്തിന് ശേഷം",
                        reminder_type=r.reminder_type,
                        scheduled_time=r.scheduled_time,
                        recurrence_rule=r.recurrence_rule,
                        is_active=r.is_active,
                        created_at=r.created_at,
                        last_acknowledged_at=ack_time
                    ))
            except Exception as exc:
                logger.debug("Database reminder list fallback: %s", exc)

        if not results and user_id in _user_reminders:
            results = list(_user_reminders[user_id].values())

        return results

    @classmethod
    async def get_reminder(
        cls,
        user_id: UUID,
        reminder_id: UUID,
        db: Optional[AsyncSession] = None
    ) -> Optional[ReminderResponse]:
        if user_id in _user_reminders and reminder_id in _user_reminders[user_id]:
            return _user_reminders[user_id][reminder_id]

        if db is not None:
            try:
                stmt = select(Reminder).where(Reminder.id == reminder_id, Reminder.user_id == user_id)
                res = await db.execute(stmt)
                r = res.scalar_one_or_none()
                if r:
                    return ReminderResponse(
                        id=r.id,
                        user_id=r.user_id,
                        title=r.title,
                        description=r.description,
                        reminder_type=r.reminder_type,
                        scheduled_time=r.scheduled_time,
                        recurrence_rule=r.recurrence_rule,
                        is_active=r.is_active,
                        created_at=r.created_at,
                        last_acknowledged_at=_reminder_acknowledgements.get(r.id)
                    )
            except Exception as exc:
                logger.debug("Database reminder get fallback: %s", exc)

        return None

    @classmethod
    async def update_reminder(
        cls,
        user_id: UUID,
        reminder_id: UUID,
        data: ReminderUpdate,
        db: Optional[AsyncSession] = None
    ) -> Optional[ReminderResponse]:
        item = await cls.get_reminder(user_id, reminder_id, db=db)
        if not item:
            return None

        if data.title is not None:
            item.title = data.title
        if data.description is not None:
            item.description = data.description
        if data.dosage is not None:
            item.dosage = data.dosage
        if data.instructions_ml is not None:
            item.instructions_ml = data.instructions_ml
        if data.scheduled_time is not None:
            item.scheduled_time = data.scheduled_time
        if data.recurrence_rule is not None:
            item.recurrence_rule = data.recurrence_rule
        if data.is_active is not None:
            item.is_active = data.is_active

        if user_id in _user_reminders:
            _user_reminders[user_id][reminder_id] = item

        if db is not None:
            try:
                stmt = select(Reminder).where(Reminder.id == reminder_id, Reminder.user_id == user_id)
                res = await db.execute(stmt)
                db_rem = res.scalar_one_or_none()
                if db_rem:
                    if data.title is not None: db_rem.title = data.title
                    if data.description is not None: db_rem.description = data.description
                    if data.scheduled_time is not None: db_rem.scheduled_time = data.scheduled_time
                    if data.recurrence_rule is not None: db_rem.recurrence_rule = data.recurrence_rule
                    if data.is_active is not None: db_rem.is_active = data.is_active
                    await db.commit()
            except Exception as exc:
                logger.debug("Database reminder update fallback: %s", exc)

        return item

    @classmethod
    async def delete_reminder(
        cls,
        user_id: UUID,
        reminder_id: UUID,
        db: Optional[AsyncSession] = None
    ) -> bool:
        if user_id in _user_reminders and reminder_id in _user_reminders[user_id]:
            del _user_reminders[user_id][reminder_id]

        if db is not None:
            try:
                stmt = delete(Reminder).where(Reminder.id == reminder_id, Reminder.user_id == user_id)
                await db.execute(stmt)
                await db.commit()
            except Exception as exc:
                logger.debug("Database reminder delete fallback: %s", exc)

        return True

    @classmethod
    async def acknowledge_reminder(
        cls,
        user_id: UUID,
        reminder_id: UUID,
        db: Optional[AsyncSession] = None
    ) -> ReminderAcknowledgeResponse:
        now = datetime.utcnow()
        _reminder_acknowledgements[reminder_id] = now

        if user_id in _user_reminders and reminder_id in _user_reminders[user_id]:
            _user_reminders[user_id][reminder_id].last_acknowledged_at = now

        if db is not None:
            try:
                log_entry = ReminderLog(
                    id=uuid4(),
                    reminder_id=reminder_id,
                    triggered_at=now,
                    acknowledged_at=now,
                    was_missed=False
                )
                db.add(log_entry)
                await db.commit()
            except Exception as exc:
                logger.debug("Database reminder log fallback: %s", exc)

        return ReminderAcknowledgeResponse(
            reminder_id=reminder_id,
            acknowledged_at=now,
            message="മരുന്ന് കഴിച്ചത് രേഖപ്പെടുത്തി (Dose recorded)",
            status="TAKEN"
        )
