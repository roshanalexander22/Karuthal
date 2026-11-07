from __future__ import annotations
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from uuid import UUID

class DocumentResponse(BaseModel):
    id: UUID
    user_id: UUID
    filename: str
    original_filename: str
    file_type: str
    document_category: str
    ocr_status: str
    created_at: datetime
    extracted_text: Optional[str] = None
    extracted_fields: Optional[Dict[str, Any]] = None

    model_config = {"from_attributes": True}

class DocumentListResponse(BaseModel):
    documents: List[DocumentResponse]
    total: int

class DocumentExtractionStatusResponse(BaseModel):
    document_id: UUID
    status: str
    extracted_fields: Optional[Dict[str, Any]] = None
    extracted_text: Optional[str] = None
    message: Optional[str] = None

class DocumentTTSResponse(BaseModel):
    document_id: UUID
    audio_base64: str
    text_read: str
    language: str = "ml"
