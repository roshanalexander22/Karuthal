from __future__ import annotations
import logging
from uuid import UUID
from typing import List, Dict, Any
from app.modules.smart_autofill.schemas import (
    AutofillMatchRequest,
    AutofillMatchResponse,
    AutofillConfirmRequest,
    FieldMatchProposal
)
from app.modules.personal_memory.service import PersonalMemoryService
from app.services.ai_service import AIService

logger = logging.getLogger(__name__)

# In-memory audit log for autofill events
_autofill_audit_log: List[Dict[str, Any]] = []


class AutofillService:
    @classmethod
    async def match_fields(cls, user_id: UUID, request: AutofillMatchRequest) -> AutofillMatchResponse:
        """
        Semantically match screen form fields against user's VERIFIED personal memory.
        Excludes sensitive fields like passwords.
        """
        verified_memory = await PersonalMemoryService.get_verified_dict(user_id)
        if not verified_memory:
            return AutofillMatchResponse(matches=[])

        proposals: List[FieldMatchProposal] = []
        screen_labels = []
        field_by_label = {}

        for screen_field in request.fields:
            # Sensitive or password fields are never autofilled
            if screen_field.is_password_or_sensitive or "password" in screen_field.label.lower():
                continue
            screen_labels.append(screen_field.label)
            field_by_label[screen_field.label] = screen_field

        # Run semantic matching via AIService
        matches_dict = await AIService.match_form_fields(screen_labels, verified_memory)

        for label, val in matches_dict.items():
            field_obj = field_by_label.get(label)
            if field_obj:
                proposals.append(
                    FieldMatchProposal(
                        node_id=field_obj.node_id,
                        profile_field_name=label,
                        proposed_value=val,
                        confidence_score=0.95,
                        requires_user_confirmation=True
                    )
                )

        return AutofillMatchResponse(matches=proposals)

    @classmethod
    async def confirm_autofill(cls, user_id: UUID, request: AutofillConfirmRequest) -> dict:
        """Log audit trail when user confirms autofill operation."""
        import datetime
        entry = {
            "user_id": str(user_id),
            "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
            "applied_count": len(request.confirmed_matches),
            "applied_nodes": [m.node_id for m in request.confirmed_matches]
        }
        _autofill_audit_log.append(entry)
        logger.info("Autofill confirmed for user %s: %d fields filled", user_id, len(request.confirmed_matches))
        return {
            "status": "SUCCESS",
            "message": f"Autofill confirmed for {len(request.confirmed_matches)} fields."
        }
