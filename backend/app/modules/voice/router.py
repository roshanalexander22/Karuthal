from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException, status
from uuid import UUID

from app.core.dependencies import get_current_user
from app.modules.voice.schemas import (
    VoiceChatRequest,
    VoiceChatResponse,
    TTSConvertRequest,
    TTSConvertResponse,
    VoiceHistoryResponse
)
from app.modules.voice.service import VoiceService

router = APIRouter()


def _extract_user_id(user) -> UUID:
    if hasattr(user, "id"):
        return user.id if isinstance(user.id, UUID) else UUID(str(user.id))
    sub = user.get("sub") if isinstance(user, dict) else str(user)
    return UUID(str(sub))


@router.post("/chat", response_model=VoiceChatResponse)
async def process_voice_chat(
    payload: VoiceChatRequest,
    current_user: dict = Depends(get_current_user)
):
    """Process user voice or text input, perform intent recognition, and return response + TTS audio."""
    user_id = _extract_user_id(current_user)
    return await VoiceService.process_chat(user_id, payload)


@router.get("/history", response_model=VoiceHistoryResponse)
async def get_voice_history(
    current_user: dict = Depends(get_current_user)
):
    """Retrieve recent voice conversation interactions."""
    user_id = _extract_user_id(current_user)
    return await VoiceService.get_history(user_id)


@router.post("/convert", response_model=TTSConvertResponse)
@router.post("/tts/convert", response_model=TTSConvertResponse)
async def convert_text_to_speech(
    payload: TTSConvertRequest,
    current_user: dict = Depends(get_current_user)
):
    """Directly convert text to Malayalam or English speech WAV audio."""
    return await VoiceService.synthesize_text(payload)
