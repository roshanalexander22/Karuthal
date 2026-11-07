from __future__ import annotations
from fastapi import APIRouter, Depends, status
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user, get_db
from app.modules.emergency.schemas import (
    EmergencyTriggerRequest,
    EmergencyTriggerResponse,
    EmergencyContactCreate,
    EmergencyContactResponse,
    EmergencyContactListResponse
)
from app.modules.emergency.service import EmergencyService

router = APIRouter()


def _extract_user_id(user) -> UUID:
    if hasattr(user, "id"):
        return user.id if isinstance(user.id, UUID) else UUID(str(user.id))
    sub = user.get("sub") if isinstance(user, dict) else str(user)
    return UUID(str(sub))


@router.post("/trigger", response_model=EmergencyTriggerResponse, status_code=status.HTTP_200_OK)
@router.post("/sos", response_model=EmergencyTriggerResponse, status_code=status.HTTP_200_OK)
async def trigger_emergency_sos(
    payload: EmergencyTriggerRequest,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Trigger high-priority Emergency SOS alert to registered caregivers."""
    user_id = _extract_user_id(current_user)
    return await EmergencyService.trigger_emergency(user_id, payload, db=db)


@router.get("/contacts", response_model=EmergencyContactListResponse)
async def get_emergency_contacts(
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """List designated caregiver and family emergency contacts."""
    user_id = _extract_user_id(current_user)
    contacts = await EmergencyService.list_contacts(user_id, db=db)
    return EmergencyContactListResponse(contacts=contacts, total=len(contacts))


@router.post("/contacts", response_model=EmergencyContactResponse, status_code=status.HTTP_201_CREATED)
async def add_emergency_contact(
    payload: EmergencyContactCreate,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Add a new emergency contact."""
    user_id = _extract_user_id(current_user)
    return await EmergencyService.add_contact(user_id, payload, db=db)
