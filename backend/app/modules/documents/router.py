from __future__ import annotations
from fastapi import APIRouter, Depends, UploadFile, File, Form, status, HTTPException
from typing import List
from uuid import UUID
from app.core.dependencies import get_current_user
from app.modules.documents.schemas import (
    DocumentResponse,
    DocumentListResponse,
    DocumentExtractionStatusResponse,
    DocumentTTSResponse
)
from app.modules.documents.service import DocumentService

router = APIRouter()


def _extract_user_id(user) -> UUID:
    if hasattr(user, "id"):
        return user.id if isinstance(user.id, UUID) else UUID(str(user.id))
    sub = user.get("sub") if isinstance(user, dict) else str(user)
    return UUID(str(sub))


@router.post("/upload", response_model=DocumentResponse, status_code=status.HTTP_201_CREATED)
async def upload_document(
    file: UploadFile = File(...),
    category: str = Form("OTHER"),
    current_user: dict = Depends(get_current_user)
):
    """Upload a document (Image or PDF) for personal memory indexing and OCR."""
    user_id = _extract_user_id(current_user)
    return await DocumentService.upload_document(user_id, file, category)


@router.get("", response_model=DocumentListResponse)
async def list_documents(current_user: dict = Depends(get_current_user)):
    """List all documents belonging to the authenticated user."""
    user_id = _extract_user_id(current_user)
    docs = await DocumentService.list_documents(user_id)
    return DocumentListResponse(documents=docs, total=len(docs))


@router.get("/{document_id}", response_model=DocumentResponse)
async def get_document(document_id: UUID, current_user: dict = Depends(get_current_user)):
    """Get single document metadata and extracted text."""
    user_id = _extract_user_id(current_user)
    doc = await DocumentService.get_document(user_id, document_id)
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")
    return doc


@router.delete("/{document_id}", status_code=status.HTTP_200_OK)
async def delete_document(document_id: UUID, current_user: dict = Depends(get_current_user)):
    """Delete a document and its stored file."""
    user_id = _extract_user_id(current_user)
    success = await DocumentService.delete_document(user_id, document_id)
    if not success:
        raise HTTPException(status_code=404, detail="Document not found")
    return {"message": "Document deleted successfully"}


@router.post("/{document_id}/extract", response_model=DocumentExtractionStatusResponse, status_code=status.HTTP_202_ACCEPTED)
async def trigger_extraction(document_id: UUID, current_user: dict = Depends(get_current_user)):
    """Trigger or re-run OCR extraction pipeline."""
    user_id = _extract_user_id(current_user)
    return await DocumentService.trigger_extraction(user_id, document_id)


@router.get("/{document_id}/status", response_model=DocumentExtractionStatusResponse)
async def get_extraction_status(document_id: UUID, current_user: dict = Depends(get_current_user)):
    """Check status of document OCR extraction."""
    user_id = _extract_user_id(current_user)
    return await DocumentService.get_extraction_status(user_id, document_id)


@router.post("/{document_id}/tts", response_model=DocumentTTSResponse)
@router.post("/tts/{document_id}", response_model=DocumentTTSResponse)
async def read_document_aloud(document_id: UUID, current_user: dict = Depends(get_current_user)):
    """Read document's extracted OCR text aloud via Malayalam TTS."""
    user_id = _extract_user_id(current_user)
    return await DocumentService.synthesize_document_tts(user_id, document_id)
