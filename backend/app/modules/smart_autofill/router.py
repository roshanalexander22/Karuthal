from __future__ import annotations
from fastapi import APIRouter, Depends, status
from uuid import UUID
from app.core.dependencies import get_current_user
from app.modules.smart_autofill.schemas import AutofillMatchRequest, AutofillMatchResponse, AutofillConfirmRequest
from app.modules.smart_autofill.service import AutofillService

router = APIRouter()


def _extract_user_id(user) -> UUID:
    if hasattr(user, "id"):
        return user.id if isinstance(user.id, UUID) else UUID(str(user.id))
    sub = user.get("sub") if isinstance(user, dict) else str(user)
    return UUID(str(sub))


@router.post("/match", response_model=AutofillMatchResponse)
async def match_form_fields(request: AutofillMatchRequest, current_user: dict = Depends(get_current_user)):
    """Semantic matching of on-screen labels to verified profile data."""
    user_id = _extract_user_id(current_user)
    return await AutofillService.match_fields(user_id, request)


@router.post("/confirm", status_code=status.HTTP_200_OK)
async def confirm_autofill(request: AutofillConfirmRequest, current_user: dict = Depends(get_current_user)):
    """Audit and record user confirmation before injection."""
    user_id = _extract_user_id(current_user)
    return await AutofillService.confirm_autofill(user_id, request)
