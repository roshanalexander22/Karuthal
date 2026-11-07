from __future__ import annotations
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID, uuid4


class ProfileFieldItem(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    field_name: str
    field_value: str
    field_type: str = "TEXT"
    is_verified: bool = False
    confidence_score: float = 1.0
    source_document_id: Optional[UUID] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    model_config = {"from_attributes": True}


class UserProfileResponse(BaseModel):
    user_id: UUID
    fields: List[ProfileFieldItem]
    total: int = 0


class ProfileUpdatePayload(BaseModel):
    field_name: str
    field_value: str
    is_verified: bool = True
    field_type: str = "TEXT"
