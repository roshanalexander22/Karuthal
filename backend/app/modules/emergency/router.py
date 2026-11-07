from __future__ import annotations
from fastapi import APIRouter, Depends, status
from uuid import UUID
from app.core.dependencies import get_current_user
from app.modules.emergency.schemas import EmergencyTriggerRequest, EmergencyTriggerResponse
from app.modules.emergency.service import EmergencyService

router = APIRouter()

@router.post("/trigger", response_model=EmergencyTriggerResponse, status_code=status.HTTP_200_OK)
async def trigger_emergency(payload: EmergencyTriggerRequest, current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    return await EmergencyService.trigger_emergency(user_id, payload)
