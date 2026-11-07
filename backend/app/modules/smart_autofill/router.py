from __future__ import annotations
from fastapi import APIRouter, Depends, status
from uuid import UUID
from app.core.dependencies import get_current_user
from app.modules.smart_autofill.schemas import AutofillMatchRequest, AutofillMatchResponse, AutofillConfirmRequest
from app.modules.smart_autofill.service import AutofillService

router = APIRouter()

@router.post("/match", response_model=AutofillMatchResponse)
async def match_form_fields(request: AutofillMatchRequest, current_user: dict = Depends(get_current_user)):
    """Semantic matching of on-screen labels to verified profile data."""
    user_id = UUID(current_user["sub"])
    return await AutofillService.match_fields(user_id, request)

@router.post("/confirm", status_code=status.HTTP_200_OK)
async def confirm_autofill(request: AutofillConfirmRequest, current_user: dict = Depends(get_current_user)):
    """Audit and record user confirmation before injection."""
    user_id = UUID(current_user["sub"])
    return await AutofillService.confirm_autofill(user_id, request)
