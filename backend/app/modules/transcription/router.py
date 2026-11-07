from __future__ import annotations
from fastapi import APIRouter, Depends, UploadFile, File, Form, status, HTTPException
from typing import List, Optional
from uuid import UUID
from app.core.dependencies import get_current_user
from app.modules.transcription.schemas import (
    TranscriptionSessionResponse,
    TranscriptionUploadResponse,
    TranscriptionResultResponse,
    TranscriptionListResponse
)
from app.modules.transcription.service import TranscriptionService

router = APIRouter()


def _extract_user_id(user) -> UUID:
    if hasattr(user, "id"):
        return user.id if isinstance(user.id, UUID) else UUID(str(user.id))
    sub = user.get("sub") if isinstance(user, dict) else str(user)
    return UUID(str(sub))


@router.post("/start", response_model=TranscriptionSessionResponse)
async def start_session(current_user: dict = Depends(get_current_user)):
    user_id = _extract_user_id(current_user)
    return await TranscriptionService.start_session(user_id)


@router.post("/upload", response_model=TranscriptionUploadResponse, status_code=status.HTTP_201_CREATED)
async def upload_audio(
    file: UploadFile = File(...),
    language: Optional[str] = Form("ml"),
    current_user: dict = Depends(get_current_user)
):
    """Upload recorded voice note/audio for low-latency transcription."""
    user_id = _extract_user_id(current_user)
    return await TranscriptionService.upload_audio(user_id, file, language=language or "ml")


@router.get("", response_model=TranscriptionListResponse)
async def list_transcriptions(current_user: dict = Depends(get_current_user)):
    """List all audio transcriptions for current user."""
    user_id = _extract_user_id(current_user)
    items = await TranscriptionService.list_transcriptions(user_id)
    return TranscriptionListResponse(transcriptions=items, total=len(items))


@router.get("/{transcription_id}", response_model=TranscriptionResultResponse)
async def get_transcription(transcription_id: UUID, current_user: dict = Depends(get_current_user)):
    """Get single transcription by ID."""
    user_id = _extract_user_id(current_user)
    result = await TranscriptionService.get_transcription(user_id, transcription_id)
    if not result:
        raise HTTPException(status_code=404, detail="Transcription not found")
    return result


@router.delete("/{transcription_id}", status_code=status.HTTP_200_OK)
async def delete_transcription(transcription_id: UUID, current_user: dict = Depends(get_current_user)):
    """Delete transcription."""
    user_id = _extract_user_id(current_user)
    success = await TranscriptionService.delete_transcription(user_id, transcription_id)
    if not success:
        raise HTTPException(status_code=404, detail="Transcription not found")
    return {"message": "Transcription deleted successfully"}
