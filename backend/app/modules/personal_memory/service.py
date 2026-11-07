from __future__ import annotations
import logging
import httpx
from datetime import datetime, timezone
from typing import Optional, List, Dict, Any
from uuid import UUID, uuid4
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete

from app.models.profile import ProfileField
from app.modules.personal_memory.schemas import (
    UserProfileResponse,
    ProfileFieldItem,
    ProfileUpdatePayload,
    FieldVerificationPayload,
    ProfileDraftImportPayload
)
from app.core.config import settings

logger = logging.getLogger(__name__)

# Fallback in-memory store per user (used when DB is unavailable or during tests)
_in_memory_profile_fields: Dict[UUID, Dict[str, ProfileFieldItem]] = {}


class PersonalMemoryService:
    """Manages 3-state personal profile memory: RAW -> DRAFT -> USER-VERIFIED."""

    @classmethod
    async def get_profile(
        cls,
        user_id: UUID,
        db: Optional[AsyncSession] = None,
        verified_only: bool = False
    ) -> UserProfileResponse:
        fields: List[ProfileFieldItem] = []

        if db is not None:
            try:
                stmt = select(ProfileField).where(ProfileField.user_id == user_id)
                if verified_only:
                    stmt = stmt.where(ProfileField.is_verified == True)
                result = await db.execute(stmt)
                db_fields = result.scalars().all()
                for f in db_fields:
                    fields.append(ProfileFieldItem(
                        field_name=f.field_name,
                        field_value=f.field_value,
                        field_type=f.field_type or "TEXT",
                        is_verified=f.is_verified,
                        confidence_score=f.confidence_score,
                        source_document_id=f.source_document_id,
                        created_at=f.created_at,
                        updated_at=f.updated_at
                    ))
            except Exception as exc:
                logger.debug("Database profile fetch fallback: %s", exc)

        # Merge with in-memory fallback if empty or offline
        if not fields and user_id in _in_memory_profile_fields:
            for item in _in_memory_profile_fields[user_id].values():
                if verified_only and not item.is_verified:
                    continue
                fields.append(item)

        verified_cnt = sum(1 for f in fields if f.is_verified)
        draft_cnt = sum(1 for f in fields if not f.is_verified)

        return UserProfileResponse(
            user_id=user_id,
            fields=fields,
            verified_count=verified_cnt,
            draft_count=draft_cnt
        )

    @classmethod
    async def get_verified_dict(
        cls,
        user_id: UUID,
        db: Optional[AsyncSession] = None
    ) -> Dict[str, str]:
        """Return a clean dictionary of key -> value strictly for USER-VERIFIED fields."""
        profile = await cls.get_profile(user_id=user_id, db=db, verified_only=True)
        return {f.field_name: f.field_value for f in profile.fields if f.is_verified}

    @classmethod
    async def update_field(
        cls,
        user_id: UUID,
        payload: ProfileUpdatePayload,
        db: Optional[AsyncSession] = None
    ) -> ProfileFieldItem:
        """Add or update a personal profile field."""
        now = datetime.now(timezone.utc)
        field_item = ProfileFieldItem(
            field_name=payload.field_name,
            field_value=payload.field_value,
            field_type=payload.field_type,
            is_verified=payload.is_verified,
            confidence_score=payload.confidence_score,
            source_document_id=payload.source_document_id,
            created_at=now,
            updated_at=now
        )

        # 1. Update in-memory fallback
        if user_id not in _in_memory_profile_fields:
            _in_memory_profile_fields[user_id] = {}
        _in_memory_profile_fields[user_id][payload.field_name] = field_item

        # 2. Persist to DB if session available
        if db is not None:
            try:
                stmt = select(ProfileField).where(
                    ProfileField.user_id == user_id,
                    ProfileField.field_name == payload.field_name
                )
                result = await db.execute(stmt)
                db_field = result.scalars().first()

                if db_field:
                    db_field.field_value = payload.field_value
                    db_field.is_verified = payload.is_verified
                    db_field.field_type = payload.field_type or db_field.field_type
                    db_field.confidence_score = payload.confidence_score
                    db_field.source_document_id = payload.source_document_id
                else:
                    db_field = ProfileField(
                        id=uuid4(),
                        user_id=user_id,
                        field_name=payload.field_name,
                        field_value=payload.field_value,
                        field_type=payload.field_type or "TEXT",
                        is_verified=payload.is_verified,
                        confidence_score=payload.confidence_score,
                        source_document_id=payload.source_document_id
                    )
                    db.add(db_field)

                await db.commit()
                await db.refresh(db_field)

                return ProfileFieldItem(
                    field_name=db_field.field_name,
                    field_value=db_field.field_value,
                    field_type=db_field.field_type,
                    is_verified=db_field.is_verified,
                    confidence_score=db_field.confidence_score,
                    source_document_id=db_field.source_document_id,
                    created_at=db_field.created_at,
                    updated_at=db_field.updated_at
                )
            except Exception as exc:
                logger.debug("Database profile update fallback: %s", exc)

        return field_item

    @classmethod
    async def verify_field(
        cls,
        user_id: UUID,
        payload: FieldVerificationPayload,
        db: Optional[AsyncSession] = None
    ) -> Optional[ProfileFieldItem]:
        """Promote a draft entity to USER-VERIFIED status."""
        target_name = payload.field_name
        now = datetime.now(timezone.utc)

        # 1. Update in memory
        if user_id in _in_memory_profile_fields and target_name in _in_memory_profile_fields[user_id]:
            existing = _in_memory_profile_fields[user_id][target_name]
            updated_val = payload.updated_value if payload.updated_value is not None else existing.field_value
            updated = ProfileFieldItem(
                field_name=target_name,
                field_value=updated_val,
                field_type=existing.field_type,
                is_verified=payload.is_verified,
                confidence_score=1.0,  # 100% confidence once verified by user
                source_document_id=existing.source_document_id,
                created_at=existing.created_at,
                updated_at=now
            )
            _in_memory_profile_fields[user_id][target_name] = updated
            return updated

        # 2. Update in DB if session
        if db is not None:
            try:
                stmt = select(ProfileField).where(
                    ProfileField.user_id == user_id,
                    ProfileField.field_name == target_name
                )
                result = await db.execute(stmt)
                db_field = result.scalars().first()
                if db_field:
                    if payload.updated_value is not None:
                        db_field.field_value = payload.updated_value
                    db_field.is_verified = payload.is_verified
                    db_field.confidence_score = 1.0
                    await db.commit()
                    await db.refresh(db_field)
                    return ProfileFieldItem(
                        field_name=db_field.field_name,
                        field_value=db_field.field_value,
                        field_type=db_field.field_type,
                        is_verified=db_field.is_verified,
                        confidence_score=db_field.confidence_score,
                        source_document_id=db_field.source_document_id,
                        created_at=db_field.created_at,
                        updated_at=db_field.updated_at
                    )
            except Exception as exc:
                logger.debug("Database profile verify fallback: %s", exc)

        return None

    @classmethod
    async def delete_field(
        cls,
        user_id: UUID,
        field_name: str,
        db: Optional[AsyncSession] = None
    ) -> bool:
        """Remove a field from the personal memory bank."""
        deleted = False

        if user_id in _in_memory_profile_fields:
            if field_name in _in_memory_profile_fields[user_id]:
                del _in_memory_profile_fields[user_id][field_name]
                deleted = True

        if db is not None:
            try:
                stmt = delete(ProfileField).where(
                    ProfileField.user_id == user_id,
                    ProfileField.field_name == field_name
                )
                await db.execute(stmt)
                await db.commit()
                deleted = True
            except Exception as exc:
                logger.debug("Database delete fallback: %s", exc)

        return deleted

    @classmethod
    async def import_draft_from_document(
        cls,
        user_id: UUID,
        payload: ProfileDraftImportPayload,
        db: Optional[AsyncSession] = None
    ) -> List[ProfileFieldItem]:
        """Extract entities from raw OCR text and import as unverified draft fields."""
        extracted_entities: Dict[str, Any] = {}
        confidence_scores: Dict[str, float] = {}

        # 1. Try calling AI Engine microservice
        ai_url = getattr(settings, "AI_ENGINE_URL", "http://localhost:8001")
        try:
            async with httpx.AsyncClient(timeout=8.0) as client:
                res = await client.post(
                    f"{ai_url}/extraction/extract",
                    json={"raw_ocr_text": payload.raw_ocr_text, "document_type": payload.document_type}
                )
                if res.status_code == 200:
                    data = res.json()
                    extracted_entities = data.get("entities", {})
                    confidence_scores = data.get("confidence_scores", {})
        except Exception as exc:
            logger.debug("AI Engine extraction call failed: %s; using local regex", exc)

        # 2. Fallback heuristic extraction if remote was empty
        if not extracted_entities:
            import re
            text = payload.raw_ocr_text
            aadhaar_m = re.search(r"\b([2-9]\d{3}\s?\d{4}\s?\d{4})\b", text)
            if aadhaar_m:
                extracted_entities["Aadhaar Number"] = aadhaar_m.group(1)
                confidence_scores["Aadhaar Number"] = 0.95
            pan_m = re.search(r"\b([A-Z]{5}[0-9]{4}[A-Z]{1})\b", text.upper())
            if pan_m:
                extracted_entities["PAN Number"] = pan_m.group(1)
                confidence_scores["PAN Number"] = 0.98
            phone_m = re.search(r"\b(?:\+91[-\s]?)?([6-9]\d{9})\b", text)
            if phone_m:
                extracted_entities["Phone Number"] = phone_m.group(1)
                confidence_scores["Phone Number"] = 0.90

        # 3. Create Draft fields (is_verified = False)
        created_items: List[ProfileFieldItem] = []
        for name, val in extracted_entities.items():
            if val:
                item = await cls.update_field(
                    user_id=user_id,
                    payload=ProfileUpdatePayload(
                        field_name=name,
                        field_value=str(val),
                        field_type="TEXT",
                        is_verified=False,  # STRICT PRIVACY: Draft until user verifies
                        confidence_score=confidence_scores.get(name, 0.85),
                        source_document_id=payload.document_id
                    ),
                    db=db
                )
                created_items.append(item)

        return created_items
