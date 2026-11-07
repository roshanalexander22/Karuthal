from __future__ import annotations
from fastapi import APIRouter, Depends, status
from uuid import UUID
from app.core.dependencies import get_current_user
from app.modules.caregiver.schemas import CaregiverInvite
from app.modules.caregiver.service import CaregiverService

router = APIRouter()

@router.get("")
async def list_caregivers(current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    return await CaregiverService.list_caregivers(user_id)

@router.post("/invite", status_code=status.HTTP_201_CREATED)
async def invite_caregiver(payload: CaregiverInvite, current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    return await CaregiverService.invite_caregiver(user_id, payload)
