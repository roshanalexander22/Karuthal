from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException, status
from uuid import UUID
from app.core.dependencies import get_current_user
from app.modules.personal_memory.schemas import UserProfileResponse, ProfileUpdatePayload, ProfileFieldItem
from app.modules.personal_memory.service import PersonalMemoryService

router = APIRouter()

@router.get("", response_model=UserProfileResponse)
async def get_profile(current_user: dict = Depends(get_current_user)):
    """Retrieve verified personal profile memory bank."""
    user_id = UUID(current_user["sub"])
    return await PersonalMemoryService.get_profile(user_id)

@router.patch("", response_model=ProfileFieldItem)
async def update_profile_field(payload: ProfileUpdatePayload, current_user: dict = Depends(get_current_user)):
    """Add or update a verified personal memory field."""
    user_id = UUID(current_user["sub"])
    return await PersonalMemoryService.update_field(user_id, payload)

@router.delete("/field/{field_name}", status_code=status.HTTP_200_OK)
async def delete_profile_field(field_name: str, current_user: dict = Depends(get_current_user)):
    """Remove a field from personal memory."""
    user_id = UUID(current_user["sub"])
    await PersonalMemoryService.delete_field(user_id, field_name)
    return {"message": f"Field '{field_name}' removed"}
