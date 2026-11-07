from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_active_user, get_db
from app.modules.reminders.schemas import (
    ReminderCreate,
    ReminderUpdate,
    ReminderResponse,
    ReminderListResponse,
    ReminderAcknowledgeResponse
)
from app.modules.reminders.service import ReminderService

router = APIRouter()


def _extract_user_id(user) -> UUID:
    if hasattr(user, "id"):
        return user.id if isinstance(user.id, UUID) else UUID(str(user.id))
    if isinstance(user, dict):
        val = user.get("sub") or user.get("id")
        return UUID(str(val))
    return UUID(str(user))


@router.post("", response_model=ReminderResponse, status_code=status.HTTP_201_CREATED)
async def create_reminder(
    payload: ReminderCreate,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Create a new medicine or appointment reminder."""
    user_id = _extract_user_id(current_user)
    return await ReminderService.create_reminder(user_id, payload, db=db)


@router.get("", response_model=ReminderListResponse)
async def list_reminders(
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """List all scheduled reminders for the authenticated user."""
    user_id = _extract_user_id(current_user)
    reminders = await ReminderService.list_reminders(user_id, db=db)
    return ReminderListResponse(reminders=reminders, total=len(reminders))


@router.get("/{reminder_id}", response_model=ReminderResponse)
async def get_reminder(
    reminder_id: UUID,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve details of a single reminder."""
    user_id = _extract_user_id(current_user)
    rem = await ReminderService.get_reminder(user_id, reminder_id, db=db)
    if not rem:
        raise HTTPException(status_code=404, detail="Reminder not found")
    return rem


@router.patch("/{reminder_id}", response_model=ReminderResponse)
async def update_reminder(
    reminder_id: UUID,
    payload: ReminderUpdate,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Update title, time, recurrence, or active status of a reminder."""
    user_id = _extract_user_id(current_user)
    rem = await ReminderService.update_reminder(user_id, reminder_id, payload, db=db)
    if not rem:
        raise HTTPException(status_code=404, detail="Reminder not found")
    return rem


@router.delete("/{reminder_id}", status_code=status.HTTP_200_OK)
async def delete_reminder(
    reminder_id: UUID,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Delete a reminder schedule."""
    user_id = _extract_user_id(current_user)
    success = await ReminderService.delete_reminder(user_id, reminder_id, db=db)
    if not success:
        raise HTTPException(status_code=404, detail="Reminder not found")
    return {"message": "Reminder deleted successfully"}


@router.post("/{reminder_id}/acknowledge", response_model=ReminderAcknowledgeResponse)
async def acknowledge_dose(
    reminder_id: UUID,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """User acknowledged taking scheduled medication dose."""
    user_id = _extract_user_id(current_user)
    result = await ReminderService.acknowledge_dose(user_id, reminder_id, db=db)
    if not result:
        raise HTTPException(status_code=404, detail="Reminder not found")
    return result
