from __future__ import annotations
from fastapi import APIRouter, Depends, status, HTTPException
from uuid import UUID
from typing import List
from app.core.dependencies import get_current_user
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
async def trigger_emergency(request: EmergencyTriggerRequest, current_user: dict = Depends(get_current_user)):
    """Trigger SOS distress alert and notify emergency contacts."""
    user_id = _extract_user_id(current_user)
    return await EmergencyService.trigger_emergency(user_id, request)


@router.get("/contacts", response_model=EmergencyContactListResponse)
async def list_emergency_contacts(current_user: dict = Depends(get_current_user)):
    """List designated emergency caregiver contacts."""
    user_id = _extract_user_id(current_user)
    contacts = await EmergencyService.list_contacts(user_id)
    return EmergencyContactListResponse(contacts=contacts, total=len(contacts))


@router.post("/contacts", response_model=EmergencyContactResponse, status_code=status.HTTP_201_CREATED)
async def add_emergency_contact(payload: EmergencyContactCreate, current_user: dict = Depends(get_current_user)):
    """Add new emergency contact."""
    user_id = _extract_user_id(current_user)
    return await EmergencyService.add_contact(user_id, payload)


@router.delete("/contacts/{contact_id}", status_code=status.HTTP_200_OK)
async def delete_emergency_contact(contact_id: UUID, current_user: dict = Depends(get_current_user)):
    """Delete emergency contact."""
    user_id = _extract_user_id(current_user)
    success = await EmergencyService.delete_contact(user_id, contact_id)
    if not success:
        raise HTTPException(status_code=404, detail="Contact not found")
    return {"message": "Emergency contact deleted successfully"}
