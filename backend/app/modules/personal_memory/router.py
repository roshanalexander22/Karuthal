from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID

from app.core.dependencies import get_current_active_user, get_db
from app.models.user import User
from app.modules.personal_memory.schemas import (
    UserProfileResponse,
    ProfileUpdatePayload,
    ProfileFieldItem,
)
from app.modules.personal_memory.service import PersonalMemoryService

router = APIRouter()


@router.get("", response_model=UserProfileResponse)
async def get_profile(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve verified personal profile memory bank."""
    return await PersonalMemoryService.get_profile(current_user.id, db)


@router.patch("", response_model=ProfileFieldItem)
async def update_profile_field(
    payload: ProfileUpdatePayload,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Add or update a verified personal memory field."""
    return await PersonalMemoryService.update_field(current_user.id, payload, db)


@router.delete("/field/{field_name}", status_code=status.HTTP_200_OK)
async def delete_profile_field(
    field_name: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Remove a field from personal memory."""
    await PersonalMemoryService.delete_field(current_user.id, field_name, db)
    return {"message": f"Field '{field_name}' removed"}
