from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from uuid import UUID

from app.core.dependencies import get_current_active_user
from app.models.user import User
from app.modules.reminders.schemas import (
    ReminderCreate,
    ReminderUpdate,
    ReminderResponse,
    ReminderListResponse,
)
from app.modules.reminders.service import ReminderService

router = APIRouter()


@router.post("", response_model=ReminderResponse, status_code=status.HTTP_201_CREATED)
async def create_reminder(
    payload: ReminderCreate, current_user: User = Depends(get_current_active_user)
):
    return await ReminderService.create_reminder(current_user.id, payload)


@router.get("", response_model=ReminderListResponse)
async def list_reminders(current_user: User = Depends(get_current_active_user)):
    reminders = await ReminderService.list_reminders(current_user.id)
    return ReminderListResponse(reminders=reminders, total=len(reminders))


@router.get("/{reminder_id}", response_model=ReminderResponse)
async def get_reminder(
    reminder_id: UUID, current_user: User = Depends(get_current_active_user)
):
    rem = await ReminderService.get_reminder(current_user.id, reminder_id)
    if not rem:
        raise HTTPException(status_code=404, detail="Reminder not found")
    return rem


@router.patch("/{reminder_id}", response_model=ReminderResponse)
async def update_reminder(
    reminder_id: UUID,
    payload: ReminderUpdate,
    current_user: User = Depends(get_current_active_user),
):
    rem = await ReminderService.update_reminder(current_user.id, reminder_id, payload)
    if not rem:
        raise HTTPException(status_code=404, detail="Reminder not found")
    return rem


@router.delete("/{reminder_id}", status_code=status.HTTP_200_OK)
async def delete_reminder(
    reminder_id: UUID, current_user: User = Depends(get_current_active_user)
):
    success = await ReminderService.delete_reminder(current_user.id, reminder_id)
    if not success:
        raise HTTPException(status_code=404, detail="Reminder not found")
    return {"message": "Reminder deleted successfully"}
