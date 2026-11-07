from __future__ import annotations
import uuid
import logging
from typing import List, Optional, Dict, Any
from uuid import UUID
from datetime import datetime, timezone
from fastapi import UploadFile, HTTPException, status
from app.modules.transcription.schemas import (
    TranscriptionSessionResponse,
    TranscriptionUploadResponse,
    TranscriptionResultResponse,
    TranscriptSegment
)
from app.services.ai_service import AIService

logger = logging.getLogger(__name__)

# User-isolated transcription store
_transcriptions_db: Dict[UUID, Dict[str, Any]] = {}


class TranscriptionService:
    @classmethod
    async def start_session(cls, user_id: UUID) -> TranscriptionSessionResponse:
        session_id = uuid.uuid4()
        return TranscriptionSessionResponse(
            session_id=session_id,
            stream_url=f"/api/v1/transcription/ws/{session_id}",
            status="INITIALIZED"
        )

    @classmethod
    async def upload_audio(cls, user_id: UUID, file: UploadFile, language: str = "ml") -> TranscriptionUploadResponse:
        """Process recorded audio, transcribe, summarize, and extract action items."""
        audio_bytes = await file.read()
        transcription_id = uuid.uuid4()
        now = datetime.now(timezone.utc)

        # Transcribe audio via AI service
        asr_res = await AIService.transcribe_speech(
            audio_bytes=audio_bytes,
            filename=file.filename or "audio.wav",
            language=language
        )
        full_text = asr_res.get("transcribed_text", "")

        # Generate timestamps / segments
        words = full_text.split()
        segments = []
        if words:
            chunk_size = max(1, len(words) // 3)
            for i in range(0, len(words), chunk_size):
                sub_text = " ".join(words[i:i + chunk_size])
                start_t = round(i * 0.4, 2)
                end_t = round((i + len(sub_text.split())) * 0.4, 2)
                segments.append(
                    TranscriptSegment(
                        start_time=start_t,
                        end_time=end_t,
                        text=sub_text,
                        speaker="Speaker 1"
                    )
                )

        # Heuristic action items extraction
        action_items = []
        for line in full_text.split("."):
            line_clean = line.strip()
            if any(k in line_clean.lower() for k in ["മരുന്ന്", "ഓർമ്മിപ്പിക്ക", "ഡോക്ടർ", "ആശുപത്രി", "ഫോം", "ചെയ്യണം", "പോണം"]):
                action_items.append(line_clean)

        summary = f"സംഗ്രഹം: {full_text[:120]}..." if len(full_text) > 120 else full_text

        record = {
            "id": transcription_id,
            "user_id": user_id,
            "status": "COMPLETED",
            "language": language,
            "full_text": full_text,
            "summary": summary,
            "action_items": action_items,
            "segments": [s.model_dump() for s in segments],
            "created_at": now
        }
        _transcriptions_db[transcription_id] = record

        return TranscriptionUploadResponse(
            id=transcription_id,
            filename=file.filename or "audio.wav",
            language=language,
            status="COMPLETED",
            transcribed_text=full_text,
            summary=summary
        )

    @classmethod
    async def list_transcriptions(cls, user_id: UUID) -> List[TranscriptionResultResponse]:
        user_items = [
            TranscriptionResultResponse(**t)
            for t in _transcriptions_db.values()
            if t["user_id"] == user_id
        ]
        return sorted(user_items, key=lambda x: x.created_at or datetime.min, reverse=True)

    @classmethod
    async def get_transcription(cls, user_id: UUID, transcription_id: UUID) -> Optional[TranscriptionResultResponse]:
        record = _transcriptions_db.get(transcription_id)
        if record and record["user_id"] == user_id:
            return TranscriptionResultResponse(**record)
        return None

    @classmethod
    async def delete_transcription(cls, user_id: UUID, transcription_id: UUID) -> bool:
        record = _transcriptions_db.get(transcription_id)
        if not record or record["user_id"] != user_id:
            return False
        del _transcriptions_db[transcription_id]
        return True
