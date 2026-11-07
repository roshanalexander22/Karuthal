from __future__ import annotations
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, List, Dict, Any
from datetime import datetime
from uuid import UUID

class ProfileFieldItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    field_name: str
    field_value: str
    field_type: str = "TEXT"
    is_verified: bool = False
    confidence_score: float = 1.0
    source_document_id: Optional[UUID] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class UserProfileResponse(BaseModel):
    user_id: UUID
    fields: List[ProfileFieldItem]
    verified_count: int = 0
    draft_count: int = 0

class ProfileUpdatePayload(BaseModel):
    field_name: str
    field_value: str
    field_type: str = "TEXT"
    is_verified: bool = True
    confidence_score: float = 1.0
    source_document_id: Optional[UUID] = None

class FieldVerificationPayload(BaseModel):
    field_name: str
    is_verified: bool = True
    edited_value: Optional[str] = None

class ProfileDraftImportPayload(BaseModel):
    document_id: Optional[UUID] = None
    raw_ocr_text: str
    document_type: Optional[str] = "AUTO"
