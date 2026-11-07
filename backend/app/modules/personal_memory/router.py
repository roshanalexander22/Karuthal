from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from uuid import UUID
from app.core.dependencies import get_current_user
from app.modules.personal_memory.schemas import (
    UserProfileResponse,
    ProfileUpdatePayload,
    ProfileFieldItem
)
from app.modules.personal_memory.service import PersonalMemoryService

router = APIRouter()


def _extract_user_id(user) -> UUID:
    if hasattr(user, "id"):
        return user.id if isinstance(user.id, UUID) else UUID(str(user.id))
    sub = user.get("sub") if isinstance(user, dict) else str(user)
    return UUID(str(sub))


@router.get("", response_model=UserProfileResponse)
async def get_profile(current_user: dict = Depends(get_current_user)):
    """Retrieve personal memory bank (both verified and unverified draft fields)."""
    user_id = _extract_user_id(current_user)
    return await PersonalMemoryService.get_profile(user_id)


@router.get("/verified", response_model=List[ProfileFieldItem])
async def get_verified_profile(current_user: dict = Depends(get_current_user)):
    """Retrieve only verified personal memory fields eligible for smart autofill."""
    user_id = _extract_user_id(current_user)
    return await PersonalMemoryService.get_verified_memory(user_id)


@router.post("", response_model=ProfileFieldItem, status_code=status.HTTP_201_CREATED)
async def create_profile_field(payload: ProfileUpdatePayload, current_user: dict = Depends(get_current_user)):
    """Add a new verified personal memory field."""
    user_id = _extract_user_id(current_user)
    return await PersonalMemoryService.update_field(user_id, payload)


@router.patch("", response_model=ProfileFieldItem)
async def update_profile_field(payload: ProfileUpdatePayload, current_user: dict = Depends(get_current_user)):
    """Update or verify a personal memory field."""
    user_id = _extract_user_id(current_user)
    return await PersonalMemoryService.update_field(user_id, payload)


@router.delete("/field/{field_name}", status_code=status.HTTP_200_OK)
@router.delete("/{field_name}", status_code=status.HTTP_200_OK)
async def delete_profile_field(field_name: str, current_user: dict = Depends(get_current_user)):
    """Remove a field from personal memory."""
    user_id = _extract_user_id(current_user)
    success = await PersonalMemoryService.delete_field(user_id, field_name)
    if not success:
        raise HTTPException(status_code=404, detail=f"Field '{field_name}' not found")
    return {"message": f"Field '{field_name}' removed"}
