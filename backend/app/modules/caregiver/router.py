from __future__ import annotations
from fastapi import APIRouter, Depends, status
from uuid import UUID

from app.core.dependencies import get_current_active_user
from app.models.user import User
from app.modules.caregiver.schemas import CaregiverInvite
from app.modules.caregiver.service import CaregiverService

router = APIRouter()


@router.get("")
async def list_caregivers(current_user: User = Depends(get_current_active_user)):
    return await CaregiverService.list_caregivers(current_user.id)


@router.post("/invite", status_code=status.HTTP_201_CREATED)
async def invite_caregiver(
    payload: CaregiverInvite, current_user: User = Depends(get_current_active_user)
):
    return await CaregiverService.invite_caregiver(current_user.id, payload)
