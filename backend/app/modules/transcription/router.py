from __future__ import annotations
from fastapi import APIRouter, Depends, UploadFile, File, Form, status, HTTPException
from typing import List, Optional
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_active_user, get_db
from app.modules.transcription.schemas import (
    TranscriptionSessionResponse,
    TranscriptionUploadResponse,
    TranscriptionResultResponse,
    TranscriptionListResponse,
    TranscriptionSummarizeRequest
)
from app.modules.transcription.service import TranscriptionService

router = APIRouter()


def _extract_user_id(user) -> UUID:
    if hasattr(user, "id"):
        return user.id if isinstance(user.id, UUID) else UUID(str(user.id))
    if isinstance(user, dict):
        val = user.get("sub") or user.get("id")
        return UUID(str(val))
    return UUID(str(user))


@router.post("/start", response_model=TranscriptionSessionResponse)
async def start_session(current_user = Depends(get_current_active_user)):
    user_id = _extract_user_id(current_user)
    return await TranscriptionService.start_session(user_id)


@router.post("/upload", response_model=TranscriptionResultResponse, status_code=status.HTTP_201_CREATED)
async def upload_audio(
    file: UploadFile = File(...),
    language: str = Form("ml"),
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Upload audio file for ASR transcription, segmentation, and automated summarization."""
    user_id = _extract_user_id(current_user)
    return await TranscriptionService.upload_audio(user_id, file, language=language, db=db)


@router.get("", response_model=TranscriptionListResponse)
async def list_transcriptions(
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """List past audio transcription sessions."""
    user_id = _extract_user_id(current_user)
    items = await TranscriptionService.list_transcriptions(user_id, db=db)
    return TranscriptionListResponse(transcriptions=items, total=len(items))


@router.get("/{transcription_id}", response_model=TranscriptionResultResponse)
async def get_transcription(
    transcription_id: UUID,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get details of a transcription session."""
    user_id = _extract_user_id(current_user)
    res = await TranscriptionService.get_transcription(user_id, transcription_id, db=db)
    if not res:
        raise HTTPException(status_code=404, detail="Transcription not found")
    return res


@router.post("/{transcription_id}/summarize", response_model=TranscriptionResultResponse)
async def summarize_transcription(
    transcription_id: UUID,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Generate or refresh structured summary from the transcript."""
    user_id = _extract_user_id(current_user)
    res = await TranscriptionService.summarize_transcription(user_id, transcription_id, db=db)
    if not res:
        raise HTTPException(status_code=404, detail="Transcription not found")
    return res


@router.delete("/{transcription_id}", status_code=status.HTTP_200_OK)
async def delete_transcription(
    transcription_id: UUID,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Delete a transcription session."""
    user_id = _extract_user_id(current_user)
    success = await TranscriptionService.delete_transcription(user_id, transcription_id, db=db)
    if not success:
        raise HTTPException(status_code=404, detail="Transcription not found")
    return {"message": "Transcription deleted successfully"}
