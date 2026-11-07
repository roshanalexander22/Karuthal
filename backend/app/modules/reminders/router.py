from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from uuid import UUID
from app.core.dependencies import get_current_user
from app.modules.reminders.schemas import ReminderCreate, ReminderUpdate, ReminderResponse, ReminderListResponse
from app.modules.reminders.service import ReminderService

router = APIRouter()

@router.post("", response_model=ReminderResponse, status_code=status.HTTP_201_CREATED)
async def create_reminder(payload: ReminderCreate, current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    return await ReminderService.create_reminder(user_id, payload)

@router.get("", response_model=ReminderListResponse)
async def list_reminders(current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    reminders = await ReminderService.list_reminders(user_id)
    return ReminderListResponse(reminders=reminders, total=len(reminders))

@router.get("/{reminder_id}", response_model=ReminderResponse)
async def get_reminder(reminder_id: UUID, current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    rem = await ReminderService.get_reminder(user_id, reminder_id)
    if not rem:
        raise HTTPException(status_code=404, detail="Reminder not found")
    return rem

@router.patch("/{reminder_id}", response_model=ReminderResponse)
async def update_reminder(reminder_id: UUID, payload: ReminderUpdate, current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    rem = await ReminderService.update_reminder(user_id, reminder_id, payload)
    if not rem:
        raise HTTPException(status_code=404, detail="Reminder not found")
    return rem

@router.delete("/{reminder_id}", status_code=status.HTTP_200_OK)
async def delete_reminder(reminder_id: UUID, current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    success = await ReminderService.delete_reminder(user_id, reminder_id)
    if not success:
        raise HTTPException(status_code=404, detail="Reminder not found")
    return {"message": "Reminder deleted successfully"}
