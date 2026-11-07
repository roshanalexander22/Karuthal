from __future__ import annotations
from uuid import UUID
from fastapi import UploadFile
from app.modules.transcription.schemas import (
    TranscriptionSessionResponse,
    TranscriptionUploadResponse,
    TranscriptionResultResponse
)

class TranscriptionService:
    @staticmethod
    async def start_session(user_id: UUID) -> TranscriptionSessionResponse:
        return TranscriptionSessionResponse(
            session_id=UUID("00000000-0000-0000-0000-000000000003"),
            stream_url="/api/v1/transcription/ws/00000000-0000-0000-0000-000000000003",
            status="INITIALIZED"
        )

    @staticmethod
    async def upload_audio(user_id: UUID, file: UploadFile) -> TranscriptionUploadResponse:
        return TranscriptionUploadResponse(
            id=UUID("00000000-0000-0000-0000-000000000003"),
            filename=file.filename or "audio.wav",
            language="ml",
            status="PROCESSING"
        )

    @staticmethod
    async def get_transcription(user_id: UUID, transcription_id: UUID) -> TranscriptionResultResponse:
        return TranscriptionResultResponse(
            id=transcription_id,
            status="COMPLETED",
            language="ml",
            full_text="ശരി, ഇത് ഒരു പരീക്ഷണ ട്രാൻസ്ക്രിപ്ഷൻ ആണ്.",
            summary="പരീക്ഷണ സംഗ്രഹം",
            segments=[]
        )
