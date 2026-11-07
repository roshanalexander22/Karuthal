from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user, get_db
from app.modules.personal_memory.schemas import (
    UserProfileResponse,
    ProfileUpdatePayload,
    ProfileFieldItem,
    FieldVerificationPayload,
    ProfileDraftImportPayload
)
from app.modules.personal_memory.service import PersonalMemoryService
from app.core.exceptions import ProfileNotFoundError

router = APIRouter()


def _extract_user_id(user) -> UUID:
    if hasattr(user, "id"):
        return user.id if isinstance(user.id, UUID) else UUID(str(user.id))
    sub = user.get("sub") if isinstance(user, dict) else str(user)
    return UUID(str(sub))


@router.get("", response_model=UserProfileResponse)
async def get_profile(
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve full personal profile memory bank (both verified and draft items)."""
    user_id = _extract_user_id(current_user)
    return await PersonalMemoryService.get_profile(user_id, verified_only=False, db=db)


@router.get("/verified", response_model=UserProfileResponse)
async def get_verified_profile(
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve ONLY user-verified profile memory fields (usable by Smart Autofill)."""
    user_id = _extract_user_id(current_user)
    return await PersonalMemoryService.get_profile(user_id, verified_only=True, db=db)


@router.post("", response_model=ProfileFieldItem, status_code=status.HTTP_201_CREATED)
@router.patch("", response_model=ProfileFieldItem)
async def update_profile_field(
    payload: ProfileUpdatePayload,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Add or update a personal profile memory field."""
    user_id = _extract_user_id(current_user)
    return await PersonalMemoryService.update_field(user_id, payload, db=db)


@router.post("/verify", response_model=ProfileFieldItem)
async def verify_field_body(
    payload: FieldVerificationPayload,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Promote a draft entity to USER-VERIFIED status."""
    user_id = _extract_user_id(current_user)
    item = await PersonalMemoryService.verify_field(user_id, payload, db=db)
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Field '{payload.field_name}' not found"
        )
    return item


@router.post("/verify/{field_name}", response_model=ProfileFieldItem)
async def verify_field_path(
    field_name: str,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Promote a draft entity to USER-VERIFIED status by field name."""
    user_id = _extract_user_id(current_user)
    payload = FieldVerificationPayload(field_name=field_name, is_verified=True)
    item = await PersonalMemoryService.verify_field(user_id, payload, db=db)
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Field '{field_name}' not found"
        )
    return item


@router.post("/import-draft", response_model=List[ProfileFieldItem])
async def import_draft_entities(
    payload: ProfileDraftImportPayload,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Extract entities from OCR text and import as unverified drafts for user review."""
    user_id = _extract_user_id(current_user)
    return await PersonalMemoryService.import_draft_from_document(user_id, payload, db=db)


@router.delete("/field/{field_name}", status_code=status.HTTP_200_OK)
async def delete_profile_field(
    field_name: str,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Remove a field from personal memory."""
    user_id = _extract_user_id(current_user)
    await PersonalMemoryService.delete_field(user_id, field_name, db=db)
    return {"message": f"Field '{field_name}' removed"}
