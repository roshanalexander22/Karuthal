from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from uuid import UUID
from app.core.dependencies import get_current_user
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
    sub = user.get("sub") if isinstance(user, dict) else str(user)
    return UUID(str(sub))


@router.post("", response_model=ReminderResponse, status_code=status.HTTP_201_CREATED)
async def create_reminder(payload: ReminderCreate, current_user: dict = Depends(get_current_user)):
    """Create medicine or appointment reminder."""
    user_id = _extract_user_id(current_user)
    return await ReminderService.create_reminder(user_id, payload)


@router.get("", response_model=ReminderListResponse)
async def list_reminders(current_user: dict = Depends(get_current_user)):
    """List reminders for the authenticated user."""
    user_id = _extract_user_id(current_user)
    reminders = await ReminderService.list_reminders(user_id)
    return ReminderListResponse(reminders=reminders, total=len(reminders))


@router.get("/{reminder_id}", response_model=ReminderResponse)
async def get_reminder(reminder_id: UUID, current_user: dict = Depends(get_current_user)):
    """Get single reminder details."""
    user_id = _extract_user_id(current_user)
    rem = await ReminderService.get_reminder(user_id, reminder_id)
    if not rem:
        raise HTTPException(status_code=404, detail="Reminder not found")
    return rem


@router.patch("/{reminder_id}", response_model=ReminderResponse)
async def update_reminder(reminder_id: UUID, payload: ReminderUpdate, current_user: dict = Depends(get_current_user)):
    """Update reminder properties."""
    user_id = _extract_user_id(current_user)
    rem = await ReminderService.update_reminder(user_id, reminder_id, payload)
    if not rem:
        raise HTTPException(status_code=404, detail="Reminder not found")
    return rem


@router.delete("/{reminder_id}", status_code=status.HTTP_200_OK)
async def delete_reminder(reminder_id: UUID, current_user: dict = Depends(get_current_user)):
    """Delete a reminder."""
    user_id = _extract_user_id(current_user)
    success = await ReminderService.delete_reminder(user_id, reminder_id)
    if not success:
        raise HTTPException(status_code=404, detail="Reminder not found")
    return {"message": "Reminder deleted successfully"}


@router.post("/{reminder_id}/acknowledge", response_model=ReminderAcknowledgeResponse)
async def acknowledge_reminder(reminder_id: UUID, current_user: dict = Depends(get_current_user)):
    """Acknowledge reminder (mark as taken or completed)."""
    user_id = _extract_user_id(current_user)
    return await ReminderService.acknowledge_reminder(user_id, reminder_id)
