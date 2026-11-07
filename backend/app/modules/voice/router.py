from __future__ import annotations
import uuid
from datetime import datetime, timezone
from typing import List, Optional
from fastapi import APIRouter, Depends, Request, status
from app.core.dependencies import get_current_user
from app.services.ai_service import AIService
from app.modules.voice.schemas import (
    VoiceChatResponse,
    VoiceHistoryItem,
    TTSConvertRequest,
    TTSConvertResponse
)

router = APIRouter()

# In-memory history cache per session/user (for quick retrieval)
_voice_history: List[dict] = []


@router.post("/chat", response_model=VoiceChatResponse)
async def voice_chat(
    request: Request,
    current_user: dict = Depends(get_current_user)
):
    """
    Process voice or text input from user:
    Transcribe audio (if multipart file provided) -> Detect intent -> Synthesize Malayalam TTS audio.
    Supports both JSON payload and multipart/form-data.
    """
    content_type = request.headers.get("content-type", "")
    user_text = None
    lang = "ml"
    audio_bytes = None

    if "application/json" in content_type:
        body = await request.json()
        user_text = body.get("text")
        lang = body.get("language", "ml")
    elif "multipart/form-data" in content_type:
        form = await request.form()
        user_text = form.get("text")
        lang = form.get("language", "ml")
        upload_file = form.get("file")
        if upload_file and hasattr(upload_file, "read"):
            audio_bytes = await upload_file.read()
    else:
        # Fallback query params or empty
        user_text = request.query_params.get("text")
        lang = request.query_params.get("language", "ml")

    result = await AIService.process_voice_interaction(
        text=user_text,
        audio_bytes=audio_bytes,
        language=lang
    )

    def _get_uid(u):
        return str(u.id) if hasattr(u, "id") else str(u.get("sub", "") if isinstance(u, dict) else u)

    # Save to history
    entry = {
        "id": str(uuid.uuid4()),
        "user_id": _get_uid(current_user),
        "timestamp": datetime.now(timezone.utc),
        "user_query": result.get("user_query", ""),
        "intent": result.get("intent", "UNKNOWN"),
        "response_text": result.get("response_text", "")
    }
    _voice_history.insert(0, entry)
    if len(_voice_history) > 50:
        _voice_history.pop()

    return VoiceChatResponse(**result)


@router.get("/history", response_model=List[VoiceHistoryItem])
async def get_voice_history(current_user: dict = Depends(get_current_user)):
    """Retrieve recent voice assistant interactions for the current user."""
    user_id = str(current_user.id) if hasattr(current_user, "id") else str(current_user.get("sub", "") if isinstance(current_user, dict) else current_user)
    user_history = [
        item for item in _voice_history
        if item.get("user_id") == user_id
    ]
    return user_history


# TTS convert router
tts_router = APIRouter()


@tts_router.post("/convert", response_model=TTSConvertResponse)
async def convert_text_to_speech(
    payload: TTSConvertRequest,
    current_user: dict = Depends(get_current_user)
):
    """Convert arbitrary text into spoken Malayalam/English audio wave (base64)."""
    result = await AIService.synthesize_speech(
        text=payload.text,
        language=payload.language,
        speed=payload.speed
    )
    return TTSConvertResponse(
        audio_base64=result.get("audio_base64", ""),
        sample_rate=result.get("sample_rate", 16000),
        text=payload.text,
        language=payload.language
    )
