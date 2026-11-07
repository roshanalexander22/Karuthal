"""
app/api/v1/router.py
--------------------
Master API router for version 1 of the Sahaayi REST API.

Each feature module exposes its own ``router`` object which is
mounted here with a URL prefix and a tag for Swagger grouping.
"""

from __future__ import annotations

from fastapi import APIRouter

from app.modules.authentication.router import router as auth_router
from app.modules.caregiver.router import router as caregiver_router
from app.modules.documents.router import router as documents_router
from app.modules.emergency.router import router as emergency_router
from app.modules.fall_detection.router import router as fall_detection_router
from app.modules.personal_memory.router import router as profile_router
from app.modules.reminders.router import router as reminders_router
from app.modules.smart_autofill.router import router as autofill_router
from app.modules.transcription.router import router as transcription_router
from app.modules.voice.router import router as voice_router

# Root router for v1 — all routes here are mounted under /api/v1 by main.py
api_router = APIRouter()

@api_router.get("/health", tags=["System"], summary="API v1 Health check")
async def v1_health_check() -> dict:
    """Returns 200 OK when API v1 router is active."""
    return {
        "status": "ok",
        "api_version": "v1",
        "app": "Sahaayi API",
    }

api_router.include_router(auth_router,          prefix="/auth",           tags=["Authentication"])
api_router.include_router(documents_router,     prefix="/documents",      tags=["Documents"])
api_router.include_router(profile_router,       prefix="/profile",        tags=["Personal Memory"])
api_router.include_router(profile_router,       prefix="/memory",         tags=["Personal Memory"])
api_router.include_router(autofill_router,      prefix="/autofill",       tags=["Smart Autofill"])
api_router.include_router(reminders_router,     prefix="/reminders",      tags=["Reminders"])
api_router.include_router(transcription_router, prefix="/transcription",  tags=["Transcription"])
api_router.include_router(voice_router,          prefix="/voice",          tags=["Voice Assistant"])
api_router.include_router(voice_router,          prefix="/tts",            tags=["Text-to-Speech"])
api_router.include_router(fall_detection_router,prefix="/fall-detection", tags=["Fall Detection"])
api_router.include_router(fall_detection_router,prefix="/fall",           tags=["Fall Detection"])
api_router.include_router(emergency_router,     prefix="/emergency",      tags=["Emergency"])
api_router.include_router(caregiver_router,     prefix="/caregiver",      tags=["Caregiver"])
