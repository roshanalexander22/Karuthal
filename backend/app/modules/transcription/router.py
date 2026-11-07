from __future__ import annotations
from fastapi import APIRouter, Depends, UploadFile, File, status
from uuid import UUID

from app.core.dependencies import get_current_active_user
from app.models.user import User
from app.modules.transcription.schemas import (
    TranscriptionSessionResponse,
    TranscriptionUploadResponse,
    TranscriptionResultResponse,
)
from app.modules.transcription.service import TranscriptionService

router = APIRouter()


@router.post("/start", response_model=TranscriptionSessionResponse)
async def start_session(current_user: User = Depends(get_current_active_user)):
    return await TranscriptionService.start_session(current_user.id)


@router.post("/upload", response_model=TranscriptionUploadResponse, status_code=status.HTTP_202_ACCEPTED)
async def upload_audio(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_active_user),
):
    return await TranscriptionService.upload_audio(current_user.id, file)


@router.get("/{transcription_id}", response_model=TranscriptionResultResponse)
async def get_transcription(
    transcription_id: UUID, current_user: User = Depends(get_current_active_user)
):
    return await TranscriptionService.get_transcription(current_user.id, transcription_id)
