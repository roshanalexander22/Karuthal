from __future__ import annotations
from fastapi import APIRouter, Depends, UploadFile, File, Form, status, HTTPException
from typing import List
from uuid import UUID

from app.core.dependencies import get_current_active_user
from app.models.user import User
from app.modules.documents.schemas import (
    DocumentResponse,
    DocumentListResponse,
    DocumentExtractionStatusResponse,
)
from app.modules.documents.service import DocumentService

router = APIRouter()


@router.post("/upload", response_model=DocumentResponse, status_code=status.HTTP_201_CREATED)
async def upload_document(
    file: UploadFile = File(...),
    category: str = Form("OTHER"),
    current_user: User = Depends(get_current_active_user),
):
    """Upload a document (Image or PDF) for personal memory indexing."""
    return await DocumentService.upload_document(current_user.id, file, category)


@router.get("", response_model=DocumentListResponse)
async def list_documents(current_user: User = Depends(get_current_active_user)):
    """List all documents belonging to the authenticated user."""
    docs = await DocumentService.list_documents(current_user.id)
    return DocumentListResponse(documents=docs, total=len(docs))


@router.get("/{document_id}", response_model=DocumentResponse)
async def get_document(
    document_id: UUID, current_user: User = Depends(get_current_active_user)
):
    doc = await DocumentService.get_document(current_user.id, document_id)
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")
    return doc


@router.delete("/{document_id}", status_code=status.HTTP_200_OK)
async def delete_document(
    document_id: UUID, current_user: User = Depends(get_current_active_user)
):
    success = await DocumentService.delete_document(current_user.id, document_id)
    if not success:
        raise HTTPException(status_code=404, detail="Document not found")
    return {"message": "Document deleted successfully"}


@router.post("/{document_id}/extract", response_model=DocumentExtractionStatusResponse, status_code=status.HTTP_202_ACCEPTED)
async def trigger_extraction(
    document_id: UUID, current_user: User = Depends(get_current_active_user)
):
    return await DocumentService.trigger_extraction(current_user.id, document_id)


@router.get("/{document_id}/status", response_model=DocumentExtractionStatusResponse)
async def get_extraction_status(
    document_id: UUID, current_user: User = Depends(get_current_active_user)
):
    return await DocumentService.get_extraction_status(current_user.id, document_id)
