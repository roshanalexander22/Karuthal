from __future__ import annotations
from pydantic import BaseModel, Field
from typing import Optional, List
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

    class Config:
        from_attributes = True

class DocumentListResponse(BaseModel):
    documents: List[DocumentResponse]
    total: int

class DocumentExtractionStatusResponse(BaseModel):
    document_id: UUID
    status: str
    extracted_fields: Optional[dict] = None
    message: Optional[str] = None
