from __future__ import annotations
from fastapi import APIRouter, Depends, Request, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_active_user, get_db
from app.models.user import User
from app.modules.smart_autofill.schemas import (
    AutofillMatchRequest,
    AutofillMatchResponse,
    AutofillConfirmRequest,
)
from app.modules.smart_autofill.service import autofill_service

router = APIRouter()

@router.post("/match", response_model=AutofillMatchResponse)
async def match_form_fields(
    payload: AutofillMatchRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Semantic matching of on-screen labels to user's verified memory bank.
    Never returns matches for password, PIN, or OTP fields.
    """
    return await autofill_service.match_fields(current_user.id, payload, db)

@router.post("/confirm", status_code=status.HTTP_200_OK)
async def confirm_autofill(
    payload: AutofillConfirmRequest,
    request: Request,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Record user confirmation and audit log before platform fills screen form fields.
    """
    client_ip = request.client.host if request.client else "127.0.0.1"
    return await autofill_service.confirm_autofill(
        current_user.id,
        payload,
        db,
        ip_address=client_ip,
    )
