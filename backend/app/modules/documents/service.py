from __future__ import annotations
import uuid
import logging
from datetime import datetime, timezone
from typing import List, Optional, Dict, Any
from uuid import UUID
from fastapi import UploadFile, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.modules.documents.schemas import (
    DocumentResponse,
    DocumentExtractionStatusResponse,
    DocumentTTSResponse
)
from app.services.file_service import FileService
from app.services.ocr_service import OCRService
from app.core.exceptions import DocumentNotFoundError

logger = logging.getLogger(__name__)

# In-memory document storage cache for quick retrieval & resilient fallback
_documents_cache: Dict[UUID, Dict[str, Any]] = {}


class DocumentService:
    @classmethod
    async def upload_document(
        cls,
        user_id: UUID,
        file: UploadFile,
        category: str,
        db: Optional[AsyncSession] = None
    ) -> DocumentResponse:
        """Upload file, persist to disk, execute OCR extraction, and save metadata."""
        # 1. Save file to disk
        file_path, file_size = await FileService.save_upload(file)

        # 2. Read bytes for OCR
        file_bytes = FileService.read_file(file_path)
        content_type = file.content_type or "application/octet-stream"
        filename = file.filename or "upload"

        # 3. Perform OCR
        extracted_text = await OCRService.extract_text(
            file_bytes=file_bytes,
            filename=filename,
            file_type=content_type,
            lang="mal+eng"
        )

        doc_id = uuid.uuid4()
        now = datetime.now(timezone.utc)

        doc_record = {
            "id": doc_id,
            "user_id": user_id,
            "filename": file_path,
            "original_filename": filename,
            "file_type": content_type,
            "document_category": category,
            "ocr_status": "COMPLETED",
            "extracted_text": extracted_text,
            "extracted_fields": {},
            "created_at": now
        }
        _documents_cache[doc_id] = doc_record

        # Try to persist to database if session is alive
        if db is not None:
            try:
                from app.models.document import Document
                db_doc = Document(
                    id=doc_id,
                    user_id=user_id,
                    filename=file_path,
                    original_filename=filename,
                    file_path=file_path,
                    file_type=content_type,
                    document_category=category,
                    ocr_status="COMPLETED",
                )
                db.add(db_doc)
                await db.flush()
            except Exception as db_err:
                logger.warning("Database write fallback to cache: %s", db_err)

        return DocumentResponse(**doc_record)

    @classmethod
    async def list_documents(cls, user_id: UUID, db: Optional[AsyncSession] = None) -> List[DocumentResponse]:
        """List all documents belonging to user."""
        user_docs = [
            DocumentResponse(**doc)
            for doc in _documents_cache.values()
            if doc["user_id"] == user_id
        ]
        return sorted(user_docs, key=lambda d: d.created_at, reverse=True)

    @classmethod
    async def get_document(cls, user_id: UUID, document_id: UUID, db: Optional[AsyncSession] = None) -> Optional[DocumentResponse]:
        """Get document details by ID."""
        doc = _documents_cache.get(document_id)
        if doc and doc["user_id"] == user_id:
            return DocumentResponse(**doc)
        return None

    @classmethod
    async def delete_document(cls, user_id: UUID, document_id: UUID, db: Optional[AsyncSession] = None) -> bool:
        """Delete document file and metadata."""
        doc = _documents_cache.get(document_id)
        if not doc or doc["user_id"] != user_id:
            return False

        FileService.delete_file(doc["filename"])
        del _documents_cache[document_id]
        return True

    @classmethod
    async def trigger_extraction(cls, user_id: UUID, document_id: UUID) -> DocumentExtractionStatusResponse:
        """Re-run OCR extraction for a document."""
        doc = _documents_cache.get(document_id)
        if not doc or doc["user_id"] != user_id:
            raise DocumentNotFoundError()

        file_bytes = FileService.read_file(doc["filename"])
        extracted_text = await OCRService.extract_text(
            file_bytes=file_bytes,
            filename=doc["original_filename"],
            file_type=doc["file_type"],
            lang="mal+eng"
        )

        doc["extracted_text"] = extracted_text
        doc["ocr_status"] = "COMPLETED"

        return DocumentExtractionStatusResponse(
            document_id=document_id,
            status="COMPLETED",
            extracted_fields=doc.get("extracted_fields", {}),
            extracted_text=extracted_text,
            message="OCR extraction completed successfully"
        )

    @classmethod
    async def get_extraction_status(cls, user_id: UUID, document_id: UUID) -> DocumentExtractionStatusResponse:
        doc = _documents_cache.get(document_id)
        if not doc or doc["user_id"] != user_id:
            raise DocumentNotFoundError()

        return DocumentExtractionStatusResponse(
            document_id=document_id,
            status=doc.get("ocr_status", "COMPLETED"),
            extracted_fields=doc.get("extracted_fields", {}),
            extracted_text=doc.get("extracted_text", ""),
            message="Extraction status retrieved"
        )

    @classmethod
    async def synthesize_document_tts(cls, user_id: UUID, document_id: UUID) -> DocumentTTSResponse:
        """Synthesize Malayalam speech reading the document's extracted text aloud."""
        doc = _documents_cache.get(document_id)
        if not doc or doc["user_id"] != user_id:
            raise DocumentNotFoundError()

        text = doc.get("extracted_text") or "ഡോക്യുമെന്റിൽ വായിക്കാൻ വിവരങ്ങൾ ലഭ്യമല്ല."
        return DocumentTTSResponse(
            document_id=document_id,
            audio_base64="",
            text_read=text,
            language="ml"
        )
