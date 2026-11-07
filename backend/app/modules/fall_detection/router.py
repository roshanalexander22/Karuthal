from __future__ import annotations
from fastapi import APIRouter, Depends, status, HTTPException
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user, get_db
from app.modules.fall_detection.schemas import (
    FallEventPayload,
    FallEventResponse,
    FallEventListResponse,
    FallDetectionSettingsResponse,
    FallDetectionSettingsUpdate
)
from app.modules.fall_detection.service import FallDetectionService

router = APIRouter()


def _extract_user_id(user) -> UUID:
    if hasattr(user, "id"):
        return user.id if isinstance(user.id, UUID) else UUID(str(user.id))
    sub = user.get("sub") if isinstance(user, dict) else str(user)
    return UUID(str(sub))


@router.post("/report", response_model=FallEventResponse, status_code=status.HTTP_201_CREATED)
@router.post("/events", response_model=FallEventResponse, status_code=status.HTTP_201_CREATED)
async def report_fall_event(
    payload: FallEventPayload,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Report fall detection sensor event and trigger caregiver distress alert if not cancelled."""
    user_id = _extract_user_id(current_user)
    return await FallDetectionService.report_event(user_id, payload, db=db)


@router.post("/events/{event_id}/cancel", response_model=FallEventResponse)
async def cancel_fall_event(
    event_id: UUID,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """User marked the fall detection as a false alarm within countdown."""
    user_id = _extract_user_id(current_user)
    res = await FallDetectionService.cancel_event(user_id, event_id, db=db)
    if not res:
        raise HTTPException(status_code=404, detail="Fall event not found")
    return res


@router.get("/events", response_model=FallEventListResponse)
async def list_fall_events(
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """List historical fall events and false alarms."""
    user_id = _extract_user_id(current_user)
    events = await FallDetectionService.list_events(user_id, db=db)
    return FallEventListResponse(events=events, total=len(events))


@router.get("/settings", response_model=FallDetectionSettingsResponse)
async def get_fall_settings(
    current_user: dict = Depends(get_current_user)
):
    """Get fall detection sensitivity and countdown settings."""
    user_id = _extract_user_id(current_user)
    return FallDetectionService.get_settings(user_id)


@router.patch("/settings", response_model=FallDetectionSettingsResponse)
async def update_fall_settings(
    payload: FallDetectionSettingsUpdate,
    current_user: dict = Depends(get_current_user)
):
    """Update fall detection sensitivity or toggle sensor monitoring."""
    user_id = _extract_user_id(current_user)
    return FallDetectionService.update_settings(user_id, payload)
