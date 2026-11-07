from __future__ import annotations
from fastapi import APIRouter, Depends, UploadFile, File, Form, status, HTTPException
from typing import List, Optional
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_active_user, get_db
from app.modules.documents.schemas import (
    DocumentResponse,
    DocumentListResponse,
    DocumentExtractionStatusResponse,
    DocumentTTSResponse
)
from app.modules.documents.service import DocumentService
from app.core.exceptions import DocumentNotFoundError

router = APIRouter()


def _extract_user_id(user) -> UUID:
    if hasattr(user, "id"):
        return user.id if isinstance(user.id, UUID) else UUID(str(user.id))
    if isinstance(user, dict):
        val = user.get("sub") or user.get("id")
        return UUID(str(val))
    return UUID(str(user))


@router.post("/upload", response_model=DocumentResponse, status_code=status.HTTP_201_CREATED)
async def upload_document(
    file: UploadFile = File(...),
    category: str = Form("OTHER"),
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Upload a document (Image or PDF) for OCR processing and indexing."""
    user_id = _extract_user_id(current_user)
    return await DocumentService.upload_document(user_id, file, category, db=db)


@router.get("", response_model=DocumentListResponse)
async def list_documents(
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """List all documents belonging to the authenticated user."""
    user_id = _extract_user_id(current_user)
    docs = await DocumentService.list_documents(user_id, db=db)
    return DocumentListResponse(documents=docs, total=len(docs))


@router.get("/{document_id}", response_model=DocumentResponse)
async def get_document(
    document_id: UUID,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get single document metadata and extracted text."""
    user_id = _extract_user_id(current_user)
    doc = await DocumentService.get_document(user_id, document_id, db=db)
    if not doc:
        raise DocumentNotFoundError()
    return doc


@router.delete("/{document_id}", status_code=status.HTTP_200_OK)
async def delete_document(
    document_id: UUID,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Delete a document and its stored file."""
    user_id = _extract_user_id(current_user)
    success = await DocumentService.delete_document(user_id, document_id, db=db)
    if not success:
        raise DocumentNotFoundError()
    return {"message": "Document deleted successfully"}


@router.post("/{document_id}/extract", response_model=DocumentExtractionStatusResponse, status_code=status.HTTP_202_ACCEPTED)
async def trigger_extraction(
    document_id: UUID,
    current_user = Depends(get_current_active_user)
):
    """Trigger or re-run OCR extraction pipeline."""
    user_id = _extract_user_id(current_user)
    return await DocumentService.trigger_extraction(user_id, document_id)


@router.get("/{document_id}/status", response_model=DocumentExtractionStatusResponse)
async def get_extraction_status(
    document_id: UUID,
    current_user = Depends(get_current_active_user)
):
    """Check status of document OCR extraction."""
    user_id = _extract_user_id(current_user)
    return await DocumentService.get_extraction_status(user_id, document_id)


@router.post("/{document_id}/tts", response_model=DocumentTTSResponse)
@router.get("/{document_id}/tts", response_model=DocumentTTSResponse)
@router.post("/tts/{document_id}", response_model=DocumentTTSResponse)
async def read_document_aloud(
    document_id: UUID,
    current_user = Depends(get_current_active_user)
):
    """Read document's extracted OCR text aloud via Malayalam TTS."""
    user_id = _extract_user_id(current_user)
    return await DocumentService.synthesize_document_tts(user_id, document_id)
