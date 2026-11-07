from __future__ import annotations
from fastapi import APIRouter, Depends, Request, status
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user, get_db
from app.modules.smart_autofill.schemas import (
    AutofillMatchRequest,
    AutofillMatchResponse,
    AutofillConfirmRequest,
)
from app.modules.smart_autofill.service import autofill_service

router = APIRouter()


def _extract_user_id(user) -> UUID:
    if hasattr(user, "id"):
        return user.id if isinstance(user.id, UUID) else UUID(str(user.id))
    sub = user.get("sub") if isinstance(user, dict) else str(user)
    return UUID(str(sub))


@router.post("/match", response_model=AutofillMatchResponse)
async def match_form_fields(
    payload: AutofillMatchRequest,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Semantic matching of on-screen labels to user's verified memory bank.
    Never returns matches for password, PIN, or OTP fields.
    """
    user_id = _extract_user_id(current_user)
    return await autofill_service.match_fields(user_id, payload, db)


@router.post("/confirm", status_code=status.HTTP_200_OK)
async def confirm_autofill(
    payload: AutofillConfirmRequest,
    request: Request,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Record user confirmation and audit log before platform fills screen form fields.
    """
    user_id = _extract_user_id(current_user)
    client_ip = request.client.host if request.client else "127.0.0.1"
    return await autofill_service.confirm_autofill(
        user_id,
        payload,
        db,
        ip_address=client_ip,
    )
