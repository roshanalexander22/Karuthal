from __future__ import annotations
from fastapi import APIRouter, Depends, status
from uuid import UUID

from app.core.dependencies import get_current_active_user
from app.models.user import User
from app.modules.emergency.schemas import EmergencyTriggerRequest, EmergencyTriggerResponse
from app.modules.emergency.service import EmergencyService

router = APIRouter()


@router.post("/trigger", response_model=EmergencyTriggerResponse, status_code=status.HTTP_200_OK)
async def trigger_emergency(
    payload: EmergencyTriggerRequest, current_user: User = Depends(get_current_active_user)
):
    return await EmergencyService.trigger_emergency(current_user.id, payload)
