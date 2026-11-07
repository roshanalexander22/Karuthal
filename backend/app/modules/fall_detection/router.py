from __future__ import annotations
from fastapi import APIRouter, Depends, status
from uuid import UUID
from app.core.dependencies import get_current_user
from app.modules.fall_detection.schemas import FallEventPayload, FallEventResponse, FallEventListResponse
from app.modules.fall_detection.service import FallDetectionService

router = APIRouter()

@router.post("/events", response_model=FallEventResponse, status_code=status.HTTP_201_CREATED)
async def report_fall_event(payload: FallEventPayload, current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    return await FallDetectionService.report_event(user_id, payload)

@router.get("/events", response_model=FallEventListResponse)
async def list_fall_events(current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    events = await FallDetectionService.list_events(user_id)
    return FallEventListResponse(events=events)
