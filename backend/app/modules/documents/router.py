from __future__ import annotations
from fastapi import APIRouter, Depends, UploadFile, File, Form, status, HTTPException
from typing import List
from uuid import UUID
from app.core.dependencies import get_current_user
from app.modules.documents.schemas import DocumentResponse, DocumentListResponse, DocumentExtractionStatusResponse
from app.modules.documents.service import DocumentService

router = APIRouter()

@router.post("/upload", response_model=DocumentResponse, status_code=status.HTTP_201_CREATED)
async def upload_document(
    file: UploadFile = File(...),
    category: str = Form("OTHER"),
    current_user: dict = Depends(get_current_user)
):
    """Upload a document (Image or PDF) for personal memory indexing."""
    user_id = UUID(current_user["sub"])
    return await DocumentService.upload_document(user_id, file, category)

@router.get("", response_model=DocumentListResponse)
async def list_documents(current_user: dict = Depends(get_current_user)):
    """List all documents belonging to the authenticated user."""
    user_id = UUID(current_user["sub"])
    docs = await DocumentService.list_documents(user_id)
    return DocumentListResponse(documents=docs, total=len(docs))

@router.get("/{document_id}", response_model=DocumentResponse)
async def get_document(document_id: UUID, current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    doc = await DocumentService.get_document(user_id, document_id)
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")
    return doc

@router.delete("/{document_id}", status_code=status.HTTP_200_OK)
async def delete_document(document_id: UUID, current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    success = await DocumentService.delete_document(user_id, document_id)
    if not success:
        raise HTTPException(status_code=404, detail="Document not found")
    return {"message": "Document deleted successfully"}

@router.post("/{document_id}/extract", response_model=DocumentExtractionStatusResponse, status_code=status.HTTP_202_ACCEPTED)
async def trigger_extraction(document_id: UUID, current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    return await DocumentService.trigger_extraction(user_id, document_id)

@router.get("/{document_id}/status", response_model=DocumentExtractionStatusResponse)
async def get_extraction_status(document_id: UUID, current_user: dict = Depends(get_current_user)):
    user_id = UUID(current_user["sub"])
    return await DocumentService.get_extraction_status(user_id, document_id)
