from __future__ import annotations
from fastapi import APIRouter, Depends, status
from uuid import UUID
from app.core.dependencies import get_current_user
from app.modules.fall_detection.schemas import (
    FallEventPayload,
    FallEventResponse,
    FallEventListResponse,
    FallSettingsPayload,
    FallSettingsResponse
)
from app.modules.fall_detection.service import FallDetectionService

router = APIRouter()


def _extract_user_id(user) -> UUID:
    if hasattr(user, "id"):
        return user.id if isinstance(user.id, UUID) else UUID(str(user.id))
    sub = user.get("sub") if isinstance(user, dict) else str(user)
    return UUID(str(sub))


@router.post("/events", response_model=FallEventResponse, status_code=status.HTTP_201_CREATED)
@router.post("/report", response_model=FallEventResponse, status_code=status.HTTP_201_CREATED)
async def report_fall_event(payload: FallEventPayload, current_user: dict = Depends(get_current_user)):
    """Report fall detection event from native accelerometer/gyroscope algorithm."""
    user_id = _extract_user_id(current_user)
    return await FallDetectionService.report_event(user_id, payload)


@router.get("/events", response_model=FallEventListResponse)
async def list_fall_events(current_user: dict = Depends(get_current_user)):
    """List historical fall events for user."""
    user_id = _extract_user_id(current_user)
    events = await FallDetectionService.list_events(user_id)
    return FallEventListResponse(events=events)


@router.get("/settings", response_model=FallSettingsResponse)
async def get_fall_settings(current_user: dict = Depends(get_current_user)):
    """Retrieve user fall sensitivity and countdown preferences."""
    user_id = _extract_user_id(current_user)
    return await FallDetectionService.get_settings(user_id)


@router.patch("/settings", response_model=FallSettingsResponse)
async def update_fall_settings(payload: FallSettingsPayload, current_user: dict = Depends(get_current_user)):
    """Update fall detection sensitivity or alert preferences."""
    user_id = _extract_user_id(current_user)
    return await FallDetectionService.update_settings(user_id, payload)
