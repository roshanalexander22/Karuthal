from __future__ import annotations
import logging
from typing import List, Optional
from uuid import UUID

from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.profile import ProfileField
from app.modules.personal_memory.schemas import (
    UserProfileResponse,
    ProfileFieldItem,
    ProfileUpdatePayload,
)

logger = logging.getLogger(__name__)


class PersonalMemoryService:
    @staticmethod
    async def get_profile(user_id: UUID, db: AsyncSession) -> UserProfileResponse:
        """Retrieve all personal profile fields for the given user."""
        stmt = select(ProfileField).where(ProfileField.user_id == user_id).order_by(ProfileField.field_name)
        result = await db.execute(stmt)
        fields = result.scalars().all()

        items = [
            ProfileFieldItem(
                field_name=f.field_name,
                field_value=f.field_value,
                field_type=f.field_type,
                is_verified=f.is_verified,
                confidence_score=f.confidence_score,
                source_document_id=f.source_document_id,
            )
            for f in fields
        ]
        return UserProfileResponse(user_id=user_id, fields=items)

    @staticmethod
    async def update_field(
        user_id: UUID, payload: ProfileUpdatePayload, db: AsyncSession
    ) -> ProfileFieldItem:
        """Add or update a verified personal memory field."""
        stmt = select(ProfileField).where(
            ProfileField.user_id == user_id,
            ProfileField.field_name == payload.field_name,
        )
        result = await db.execute(stmt)
        field = result.scalars().first()

        if field:
            field.field_value = payload.field_value
            field.is_verified = payload.is_verified
        else:
            field = ProfileField(
                user_id=user_id,
                field_name=payload.field_name,
                field_value=payload.field_value,
                field_type="TEXT",
                is_verified=payload.is_verified,
                confidence_score=1.0,
            )
            db.add(field)

        await db.commit()
        await db.refresh(field)

        return ProfileFieldItem(
            field_name=field.field_name,
            field_value=field.field_value,
            field_type=field.field_type,
            is_verified=field.is_verified,
            confidence_score=field.confidence_score,
            source_document_id=field.source_document_id,
        )

    @staticmethod
    async def delete_field(user_id: UUID, field_name: str, db: AsyncSession) -> bool:
        """Remove a field from the personal memory bank."""
        stmt = delete(ProfileField).where(
            ProfileField.user_id == user_id,
            ProfileField.field_name == field_name,
        )
        await db.execute(stmt)
        await db.commit()
        return True
