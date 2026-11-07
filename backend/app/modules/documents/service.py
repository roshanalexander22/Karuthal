from __future__ import annotations
import uuid
import logging
from datetime import datetime, timezone
from typing import List, Optional, Dict, Any
from uuid import UUID
from fastapi import UploadFile, HTTPException, status
from app.modules.documents.schemas import (
    DocumentResponse,
    DocumentExtractionStatusResponse,
    DocumentTTSResponse
)
from app.services.file_service import FileService
from app.services.ocr_service import OCRService
from app.services.ai_service import AIService

logger = logging.getLogger(__name__)

# In-memory document repository for fast retrieval & offline fallback
_documents_db: Dict[UUID, Dict[str, Any]] = {}


class DocumentService:
    @classmethod
    async def upload_document(cls, user_id: UUID, file: UploadFile, category: str) -> DocumentResponse:
        """Upload file, persist to storage, run OCR and structured field extraction."""
        # 1. Save file to disk
        file_path, file_size = await FileService.save_upload(file)

        # 2. Read bytes for OCR
        file_bytes = FileService.read_file(file_path)
        content_type = file.content_type or "application/octet-stream"

        # 3. Perform OCR
        extracted_text = OCRService.extract_text(file_bytes, content_type)

        # 4. Extract structured fields via AI service
        structured = await AIService.structure_document_data(extracted_text, category=category)

        doc_id = uuid.uuid4()
        now = datetime.now(timezone.utc)

        doc_record = {
            "id": doc_id,
            "user_id": user_id,
            "filename": file_path,
            "original_filename": file.filename or "uploaded_doc",
            "file_type": content_type,
            "document_category": structured.get("document_type", category),
            "ocr_status": "COMPLETED",
            "extracted_text": extracted_text,
            "extracted_fields": structured.get("fields", {}),
            "created_at": now
        }
        _documents_db[doc_id] = doc_record

        # Also register draft unverified fields into personal memory bank (Phase 4 integration)
        from app.modules.personal_memory.service import PersonalMemoryService
        for k, v in structured.get("fields", {}).items():
            if isinstance(v, (str, int, float)):
                PersonalMemoryService.register_draft_field(
                    user_id=user_id,
                    field_name=k,
                    field_value=str(v),
                    source_doc_id=doc_id,
                    confidence=0.9
                )

        return DocumentResponse(**doc_record)

    @classmethod
    async def list_documents(cls, user_id: UUID) -> List[DocumentResponse]:
        """List all documents belonging to user."""
        user_docs = [
            DocumentResponse(**doc)
            for doc in _documents_db.values()
            if doc["user_id"] == user_id
        ]
        return sorted(user_docs, key=lambda d: d.created_at, reverse=True)

    @classmethod
    async def get_document(cls, user_id: UUID, document_id: UUID) -> Optional[DocumentResponse]:
        """Get document details by ID."""
        doc = _documents_db.get(document_id)
        if doc and doc["user_id"] == user_id:
            return DocumentResponse(**doc)
        return None

    @classmethod
    async def delete_document(cls, user_id: UUID, document_id: UUID) -> bool:
        """Delete document file and metadata."""
        doc = _documents_db.get(document_id)
        if not doc or doc["user_id"] != user_id:
            return False

        # Delete physical file
        FileService.delete_file(doc["filename"])
        del _documents_db[document_id]
        return True

    @classmethod
    async def trigger_extraction(cls, user_id: UUID, document_id: UUID) -> DocumentExtractionStatusResponse:
        """Re-run OCR extraction for a document."""
        doc = _documents_db.get(document_id)
        if not doc or doc["user_id"] != user_id:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Document not found")

        file_bytes = FileService.read_file(doc["filename"])
        extracted_text = OCRService.extract_text(file_bytes, doc["file_type"])
        structured = await AIService.structure_document_data(extracted_text, category=doc["document_category"])

        doc["extracted_text"] = extracted_text
        doc["extracted_fields"] = structured.get("fields", {})
        doc["ocr_status"] = "COMPLETED"

        return DocumentExtractionStatusResponse(
            document_id=document_id,
            status="COMPLETED",
            extracted_fields=doc["extracted_fields"],
            extracted_text=extracted_text,
            message="OCR extraction completed successfully"
        )

    @classmethod
    async def get_extraction_status(cls, user_id: UUID, document_id: UUID) -> DocumentExtractionStatusResponse:
        doc = _documents_db.get(document_id)
        if not doc or doc["user_id"] != user_id:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Document not found")

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
        doc = _documents_db.get(document_id)
        if not doc or doc["user_id"] != user_id:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Document not found")

        text = doc.get("extracted_text") or "ഡോക്യുമെന്റിൽ വായിക്കാൻ വിവരങ്ങൾ ലഭ്യമല്ല."
        tts_res = await AIService.synthesize_speech(text=text, language="ml", speed=0.85)

        return DocumentTTSResponse(
            document_id=document_id,
            audio_base64=tts_res.get("audio_base64", ""),
            text_read=text,
            language="ml"
        )
