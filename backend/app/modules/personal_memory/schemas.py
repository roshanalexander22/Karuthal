from __future__ import annotations
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID

class ProfileFieldItem(BaseModel):
    field_name: str
    field_value: str
    field_type: str = "TEXT"
    is_verified: bool = False
    confidence_score: float = 1.0
    source_document_id: Optional[UUID] = None

class UserProfileResponse(BaseModel):
    user_id: UUID
    fields: List[ProfileFieldItem]

class ProfileUpdatePayload(BaseModel):
    field_name: str
    field_value: str
    is_verified: bool = True
