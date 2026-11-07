from __future__ import annotations
from typing import List, Optional
from uuid import UUID
from fastapi import UploadFile
from app.modules.documents.schemas import DocumentResponse, DocumentExtractionStatusResponse

class DocumentService:
    @staticmethod
    async def upload_document(user_id: UUID, file: UploadFile, category: str) -> DocumentResponse:
        # Placeholder integration with file storage & database
        return DocumentResponse(
            id=UUID("00000000-0000-0000-0000-000000000001"),
            user_id=user_id,
            filename=f"doc_{file.filename}",
            original_filename=file.filename or "unknown",
            file_type=file.content_type or "application/octet-stream",
            document_category=category,
            ocr_status="PENDING",
            created_at="2026-11-07T00:00:00Z"
        )

    @staticmethod
    async def list_documents(user_id: UUID) -> List[DocumentResponse]:
        return []

    @staticmethod
    async def get_document(user_id: UUID, document_id: UUID) -> Optional[DocumentResponse]:
        return None

    @staticmethod
    async def delete_document(user_id: UUID, document_id: UUID) -> bool:
        return True

    @staticmethod
    async def trigger_extraction(user_id: UUID, document_id: UUID) -> DocumentExtractionStatusResponse:
        return DocumentExtractionStatusResponse(
            document_id=document_id,
            status="PROCESSING",
            message="OCR extraction pipeline queued"
        )

    @staticmethod
    async def get_extraction_status(user_id: UUID, document_id: UUID) -> DocumentExtractionStatusResponse:
        return DocumentExtractionStatusResponse(
            document_id=document_id,
            status="COMPLETED",
            message="Extraction completed"
        )
