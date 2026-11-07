from __future__ import annotations
from fastapi import APIRouter, Depends, UploadFile, File, status
from uuid import UUID
from app.core.dependencies import get_current_user
from app.modules.transcription.schemas import (
    TranscriptionSessionResponse,
    TranscriptionUploadResponse,
    TranscriptionResultResponse
)
from app.modules.transcription.service import TranscriptionService

router = APIRouter()

@router.post("/start", response_model=TranscriptionSessionResponse)
async def start_session(current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    return await TranscriptionService.start_session(user_id)

@router.post("/upload", response_model=TranscriptionUploadResponse, status_code=status.HTTP_202_ACCEPTED)
async def upload_audio(file: UploadFile = File(...), current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    return await TranscriptionService.upload_audio(user_id, file)

@router.get("/{transcription_id}", response_model=TranscriptionResultResponse)
async def get_transcription(transcription_id: UUID, current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    return await TranscriptionService.get_transcription(user_id, transcription_id)
