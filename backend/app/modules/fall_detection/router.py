from __future__ import annotations
from fastapi import APIRouter, Depends, status
from uuid import UUID

from app.core.dependencies import get_current_active_user
from app.models.user import User
from app.modules.fall_detection.schemas import (
    FallEventPayload,
    FallEventResponse,
    FallEventListResponse,
)
from app.modules.fall_detection.service import FallDetectionService

router = APIRouter()


@router.post("/events", response_model=FallEventResponse, status_code=status.HTTP_201_CREATED)
async def report_fall_event(
    payload: FallEventPayload, current_user: User = Depends(get_current_active_user)
):
    return await FallDetectionService.report_event(current_user.id, payload)


@router.get("/events", response_model=FallEventListResponse)
async def list_fall_events(current_user: User = Depends(get_current_active_user)):
    events = await FallDetectionService.list_events(current_user.id)
    return FallEventListResponse(events=events)
