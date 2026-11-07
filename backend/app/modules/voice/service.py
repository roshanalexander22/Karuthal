from __future__ import annotations
import base64
import logging
import httpx
from datetime import datetime
from typing import Optional, List, Dict, Any
from uuid import UUID, uuid4

from app.core.config import settings
from app.modules.voice.schemas import (
    VoiceChatRequest,
    VoiceChatResponse,
    TTSConvertRequest,
    TTSConvertResponse,
    VoiceHistoryItem,
    VoiceHistoryResponse
)

logger = logging.getLogger(__name__)

# In-memory history cache per user
_user_voice_history: Dict[UUID, List[VoiceHistoryItem]] = {}


class VoiceService:
    """Coordinates voice interaction, speech recognition, intent routing, and TTS."""

    @classmethod
    async def process_chat(
        cls,
        user_id: UUID,
        payload: VoiceChatRequest
    ) -> VoiceChatResponse:
        ai_url = getattr(settings, "AI_ENGINE_URL", "http://localhost:8001")
        req_text = payload.message or ""
        req_audio = payload.audio_base64
        lang = payload.language or "ml"

        recognized = req_text
        reply = "നമസ്കാരം, ഞാൻ സഹായിക്കാൻ തയ്യാറാണ്."
        intent = "GENERAL_ASSISTANCE"
        confidence = 0.9
        action = "NONE"
        target_route = None
        audio_b64: Optional[str] = None

        # 1. Attempt AI Engine processing
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                res = await client.post(
                    f"{ai_url}/voice/process",
                    json={
                        "text": req_text,
                        "audio_base64": req_audio,
                        "language": lang
                    }
                )
                if res.status_code == 200:
                    data = res.json()
                    recognized = data.get("recognized_text", recognized)
                    reply = data.get("response_text", reply)
                    intent = data.get("intent", intent)
                    confidence = data.get("confidence", confidence)
                    action = data.get("action", action)
                    target_route = data.get("target_route")
                    audio_b64 = data.get("audio_base64")
                else:
                    raise RuntimeError(f"AI engine returned {res.status_code}")
        except Exception as exc:
            logger.debug("AI Engine voice call failed: %s; using local heuristic intent", exc)
            # Local fallback intent classification
            if not recognized and req_audio:
                recognized = "സഹായം വേണം"
            
            lower_text = (recognized or "").lower()
            if any(w in lower_text for w in ["സഹായിക്കൂ", "help", "emergency", "രക്ഷിക്കൂ"]):
                intent = "EMERGENCY_SOS"
                reply = "അടിയന്തര സഹായ വിഭാഗത്തിലേക്ക് ബന്ധപ്പെടുന്നു. പരിഭ്രാന്തരാകേണ്ട."
                action = "TRIGGER_EMERGENCY_SOS"
                target_route = "/emergency"
            elif any(w in lower_text for w in ["മരുന്ന്", "ഗുളിക", "reminder", "alarm"]):
                intent = "SET_REMINDER"
                reply = "ശരി, മരുന്ന് ഓർമ്മിപ്പിക്കാനുള്ള റിമൈൻഡർ ക്രമീകരിക്കാം."
                action = "OPEN_REMINDER_FORM"
                target_route = "/reminders/new"
            elif any(w in lower_text for w in ["വായിക്കൂ", "ഡോക്യുമെന്റ്", "read"]):
                intent = "READ_DOCUMENT"
                reply = "ഡോക്യുമെന്റ് തുറക്കാം, ഞാൻ വായിച്ചു കേൾപ്പിക്കാം."
                action = "OPEN_DOCUMENT_READER"
                target_route = "/documents"

        now = datetime.utcnow()
        # Save to history
        hist_item = VoiceHistoryItem(
            id=str(uuid4()),
            user_message=recognized or "ശബ്ദ സന്ദേശം",
            assistant_reply=reply,
            intent=intent,
            created_at=now
        )
        if user_id not in _user_voice_history:
            _user_voice_history[user_id] = []
        _user_voice_history[user_id].insert(0, hist_item)

        return VoiceChatResponse(
            user_message=recognized or "ശബ്ദ സന്ദേശം",
            assistant_reply=reply,
            intent=intent,
            confidence=confidence,
            action=action,
            target_route=target_route,
            audio_base64=audio_b64,
            language=lang,
            timestamp=now
        )

    @classmethod
    async def get_history(cls, user_id: UUID) -> VoiceHistoryResponse:
        items = _user_voice_history.get(user_id, [])
        return VoiceHistoryResponse(history=items, total=len(items))

    @classmethod
    async def synthesize_text(cls, payload: TTSConvertRequest) -> TTSConvertResponse:
        ai_url = getattr(settings, "AI_ENGINE_URL", "http://localhost:8001")
        try:
            async with httpx.AsyncClient(timeout=8.0) as client:
                res = await client.post(
                    f"{ai_url}/tts/synthesize",
                    json={
                        "text": payload.text,
                        "language": payload.language or "ml",
                        "speed": payload.speed or 0.85
                    }
                )
                if res.status_code == 200:
                    data = res.json()
                    return TTSConvertResponse(
                        audio_base64=data.get("audio_base64", ""),
                        duration_seconds=data.get("duration_seconds", 1.0),
                        language=data.get("language", "ml"),
                        text=payload.text
                    )
        except Exception as exc:
            logger.debug("AI Engine TTS call failed: %s; returning empty base64", exc)

        return TTSConvertResponse(
            audio_base64="",
            duration_seconds=0.0,
            language=payload.language or "ml",
            text=payload.text
        )
