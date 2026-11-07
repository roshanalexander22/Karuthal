from __future__ import annotations
import uuid
import logging
from typing import List, Dict, Any, Optional
from uuid import UUID
from datetime import datetime, timezone
from app.modules.fall_detection.schemas import (
    FallEventPayload,
    FallEventResponse,
    FallSettingsPayload,
    FallSettingsResponse
)

logger = logging.getLogger(__name__)

_fall_events_db: Dict[UUID, Dict[str, Any]] = {}
_fall_settings_db: Dict[UUID, Dict[str, Any]] = {}


class FallDetectionService:
    @classmethod
    async def report_event(cls, user_id: UUID, payload: FallEventPayload) -> FallEventResponse:
        """Record fall event from sensor algorithm; dispatch emergency alert if uncancelled."""
        event_id = uuid.uuid4()
        now = datetime.now(timezone.utc)
        confirmed = not payload.was_cancelled_by_user
        false_alarm = payload.was_cancelled_by_user

        record = {
            "id": event_id,
            "user_id": user_id,
            "detected_at": now,
            "confidence_score": payload.confidence_score,
            "sensor_summary": payload.sensor_summary,
            "location_lat": payload.location_lat,
            "location_lng": payload.location_lng,
            "confirmed": confirmed,
            "false_alarm": false_alarm
        }
        _fall_events_db[event_id] = record

        if confirmed:
            logger.warning("CRITICAL: Confirmed Fall Detected for User %s! Dispatching Emergency Broadcast.", user_id)
            from app.modules.emergency.service import EmergencyService
            await EmergencyService.trigger_broadcast(
                user_id=user_id,
                reason="FALL_DETECTED",
                location={"lat": payload.location_lat, "lng": payload.location_lng}
            )

        return FallEventResponse(
            id=event_id,
            user_id=user_id,
            detected_at=now,
            confidence_score=payload.confidence_score,
            confirmed=confirmed,
            false_alarm=false_alarm
        )

    @classmethod
    async def list_events(cls, user_id: UUID) -> List[FallEventResponse]:
        items = [
            FallEventResponse(
                id=r["id"],
                user_id=r["user_id"],
                detected_at=r["detected_at"],
                confidence_score=r["confidence_score"],
                confirmed=r["confirmed"],
                false_alarm=r["false_alarm"]
            )
            for r in _fall_events_db.values()
            if r["user_id"] == user_id
        ]
        return sorted(items, key=lambda x: x.detected_at, reverse=True)

    @classmethod
    async def get_settings(cls, user_id: UUID) -> FallSettingsResponse:
        s = _fall_settings_db.get(user_id, {})
        return FallSettingsResponse(
            user_id=user_id,
            sensitivity=s.get("sensitivity", "MEDIUM"),
            countdown_seconds=s.get("countdown_seconds", 30),
            auto_sos_enabled=s.get("auto_sos_enabled", True),
            audible_siren=s.get("audible_siren", True)
        )

    @classmethod
    async def update_settings(cls, user_id: UUID, payload: FallSettingsPayload) -> FallSettingsResponse:
        s = _fall_settings_db.setdefault(user_id, {})
        if payload.sensitivity is not None:
            s["sensitivity"] = payload.sensitivity
        if payload.countdown_seconds is not None:
            s["countdown_seconds"] = payload.countdown_seconds
        if payload.auto_sos_enabled is not None:
            s["auto_sos_enabled"] = payload.auto_sos_enabled
        if payload.audible_siren is not None:
            s["audible_siren"] = payload.audible_siren

        return await cls.get_settings(user_id)
