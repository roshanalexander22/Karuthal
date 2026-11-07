from __future__ import annotations
import logging
from datetime import datetime
from typing import List, Optional, Dict
from uuid import UUID, uuid4
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update

from app.models.fall_event import FallEvent
from app.modules.emergency.schemas import EmergencyTriggerRequest
from app.modules.emergency.service import EmergencyService
from app.modules.fall_detection.schemas import (
    FallEventPayload,
    FallEventResponse,
    FallDetectionSettingsResponse,
    FallDetectionSettingsUpdate
)

logger = logging.getLogger(__name__)

# Fallback stores
_user_fall_events: Dict[UUID, Dict[UUID, FallEventResponse]] = {}
_user_fall_settings: Dict[UUID, FallDetectionSettingsResponse] = {}


class FallDetectionService:
    """Processes sensor-detected fall events and automates caregiver distress response."""

    @classmethod
    async def report_event(
        cls,
        user_id: UUID,
        payload: FallEventPayload,
        db: Optional[AsyncSession] = None
    ) -> FallEventResponse:
        event_id = uuid4()
        now = datetime.utcnow()
        is_false_alarm = payload.was_cancelled_by_user
        is_confirmed = not is_false_alarm
        sos_dispatched = False

        # If fall is not cancelled by senior, dispatch SOS alert immediately!
        if is_confirmed:
            sos_dispatched = True
            try:
                await EmergencyService.trigger_emergency(
                    user_id=user_id,
                    request=EmergencyTriggerRequest(
                        reason="FALL_DETECTED_CONFIRMED",
                        location_lat=payload.location_lat,
                        location_lng=payload.location_lng
                    ),
                    db=db
                )
            except Exception as exc:
                logger.error("Failed to auto-dispatch emergency SOS on fall: %s", exc)

        item = FallEventResponse(
            id=event_id,
            user_id=user_id,
            detected_at=now,
            confidence_score=payload.confidence_score,
            confirmed=is_confirmed,
            false_alarm=is_false_alarm,
            location_lat=payload.location_lat,
            location_lng=payload.location_lng,
            sos_dispatched=sos_dispatched
        )

        if user_id not in _user_fall_events:
            _user_fall_events[user_id] = {}
        _user_fall_events[user_id][event_id] = item

        if db is not None:
            try:
                db_event = FallEvent(
                    id=event_id,
                    user_id=user_id,
                    detected_at=now,
                    confidence_score=payload.confidence_score,
                    sensor_data=payload.sensor_summary,
                    confirmed=is_confirmed,
                    false_alarm=is_false_alarm,
                    location_lat=payload.location_lat,
                    location_lng=payload.location_lng
                )
                db.add(db_event)
                await db.commit()
            except Exception as exc:
                logger.debug("Database fall event save fallback: %s", exc)

        return item

    @classmethod
    async def cancel_event(
        cls,
        user_id: UUID,
        event_id: UUID,
        db: Optional[AsyncSession] = None
    ) -> Optional[FallEventResponse]:
        """Senior tapped 'I am safe' within 30 seconds countdown."""
        if user_id in _user_fall_events and event_id in _user_fall_events[user_id]:
            item = _user_fall_events[user_id][event_id]
            item.confirmed = False
            item.false_alarm = True
            item.sos_dispatched = False

        if db is not None:
            try:
                stmt = select(FallEvent).where(FallEvent.id == event_id, FallEvent.user_id == user_id)
                res = await db.execute(stmt)
                db_ev = res.scalar_one_or_none()
                if db_ev:
                    db_ev.confirmed = False
                    db_ev.false_alarm = True
                    await db.commit()
                    return FallEventResponse(
                        id=db_ev.id,
                        user_id=db_ev.user_id,
                        detected_at=db_ev.detected_at,
                        confidence_score=db_ev.confidence_score,
                        confirmed=False,
                        false_alarm=True,
                        location_lat=db_ev.location_lat,
                        location_lng=db_ev.location_lng,
                        sos_dispatched=False
                    )
            except Exception as exc:
                logger.debug("Database fall cancel fallback: %s", exc)

        if user_id in _user_fall_events and event_id in _user_fall_events[user_id]:
            return _user_fall_events[user_id][event_id]

        return None

    @classmethod
    async def list_events(
        cls,
        user_id: UUID,
        db: Optional[AsyncSession] = None
    ) -> List[FallEventResponse]:
        results: List[FallEventResponse] = []
        if db is not None:
            try:
                stmt = select(FallEvent).where(FallEvent.user_id == user_id).order_by(FallEvent.detected_at.desc())
                res = await db.execute(stmt)
                db_items = res.scalars().all()
                for e in db_items:
                    results.append(FallEventResponse(
                        id=e.id,
                        user_id=e.user_id,
                        detected_at=e.detected_at,
                        confidence_score=e.confidence_score,
                        confirmed=e.confirmed,
                        false_alarm=e.false_alarm,
                        location_lat=e.location_lat,
                        location_lng=e.location_lng,
                        sos_dispatched=e.confirmed
                    ))
            except Exception as exc:
                logger.debug("Database fall list fallback: %s", exc)

        if not results and user_id in _user_fall_events:
            results = list(_user_fall_events[user_id].values())

        return results

    @classmethod
    def get_settings(cls, user_id: UUID) -> FallDetectionSettingsResponse:
        return _user_fall_settings.get(user_id, FallDetectionSettingsResponse())

    @classmethod
    def update_settings(
        cls,
        user_id: UUID,
        update_data: FallDetectionSettingsUpdate
    ) -> FallDetectionSettingsResponse:
        current = cls.get_settings(user_id)
        updated = FallDetectionSettingsResponse(
            is_enabled=update_data.is_enabled if update_data.is_enabled is not None else current.is_enabled,
            sensitivity=update_data.sensitivity if update_data.sensitivity is not None else current.sensitivity,
            countdown_seconds=update_data.countdown_seconds if update_data.countdown_seconds is not None else current.countdown_seconds,
            auto_sos_enabled=update_data.auto_sos_enabled if update_data.auto_sos_enabled is not None else current.auto_sos_enabled,
        )
        _user_fall_settings[user_id] = updated
        return updated
