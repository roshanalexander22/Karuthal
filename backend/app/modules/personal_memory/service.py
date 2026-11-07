from __future__ import annotations
import uuid
from typing import List, Optional, Dict, Any
from uuid import UUID
from datetime import datetime, timezone
from app.modules.personal_memory.schemas import (
    UserProfileResponse,
    ProfileFieldItem,
    ProfileUpdatePayload
)

# User-isolated personal memory bank: {user_id: {field_name: ProfileFieldItem}}
_memory_store: Dict[UUID, Dict[str, ProfileFieldItem]] = {}


class PersonalMemoryService:
    @classmethod
    def _ensure_user_store(cls, user_id: UUID) -> Dict[str, ProfileFieldItem]:
        if user_id not in _memory_store:
            _memory_store[user_id] = {}
        return _memory_store[user_id]

    @classmethod
    def register_draft_field(
        cls,
        user_id: UUID,
        field_name: str,
        field_value: str,
        source_doc_id: Optional[UUID] = None,
        confidence: float = 0.9
    ) -> ProfileFieldItem:
        """Register unverified draft field from OCR extraction. Does not overwrite verified fields."""
        store = cls._ensure_user_store(user_id)
        now = datetime.now(timezone.utc)

        existing = store.get(field_name)
        if existing and existing.is_verified:
            # Preserve existing user-verified data
            return existing

        item = ProfileFieldItem(
            id=existing.id if existing else uuid.uuid4(),
            field_name=field_name,
            field_value=field_value,
            field_type="TEXT",
            is_verified=False,  # Unverified draft
            confidence_score=confidence,
            source_document_id=source_doc_id,
            created_at=existing.created_at if existing else now,
            updated_at=now
        )
        store[field_name] = item
        return item

    @classmethod
    async def get_profile(cls, user_id: UUID, only_verified: bool = False) -> UserProfileResponse:
        """Retrieve user's personal memory fields."""
        store = cls._ensure_user_store(user_id)
        fields = list(store.values())
        if only_verified:
            fields = [f for f in fields if f.is_verified]
        return UserProfileResponse(
            user_id=user_id,
            fields=sorted(fields, key=lambda f: f.field_name),
            total=len(fields)
        )

    @classmethod
    async def get_verified_memory(cls, user_id: UUID) -> List[ProfileFieldItem]:
        """Retrieve only user-verified fields eligible for autofill."""
        resp = await cls.get_profile(user_id, only_verified=True)
        return resp.fields

    @classmethod
    async def get_verified_dict(cls, user_id: UUID) -> Dict[str, Any]:
        """Return dict of verified field_name -> field_value for autofill engine."""
        verified = await cls.get_verified_memory(user_id)
        return {item.field_name: item.field_value for item in verified}

    @classmethod
    async def update_field(cls, user_id: UUID, payload: ProfileUpdatePayload) -> ProfileFieldItem:
        """Create or update a field in personal memory (typically marked as verified)."""
        store = cls._ensure_user_store(user_id)
        now = datetime.now(timezone.utc)
        existing = store.get(payload.field_name)

        item = ProfileFieldItem(
            id=existing.id if existing else uuid.uuid4(),
            field_name=payload.field_name,
            field_value=payload.field_value,
            field_type=payload.field_type,
            is_verified=payload.is_verified,
            confidence_score=1.0,
            source_document_id=existing.source_document_id if existing else None,
            created_at=existing.created_at if existing else now,
            updated_at=now
        )
        store[payload.field_name] = item
        return item

    @classmethod
    async def delete_field(cls, user_id: UUID, identifier: str) -> bool:
        """Remove a field by field_name or field_id."""
        store = cls._ensure_user_store(user_id)
        # Try direct name
        if identifier in store:
            del store[identifier]
            return True
        # Try ID match
        for name, item in list(store.items()):
            if str(item.id) == identifier:
                del store[name]
                return True
        return False
