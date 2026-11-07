from __future__ import annotations
from uuid import UUID
from app.modules.caregiver.schemas import CaregiverInvite, CaregiverResponse

class CaregiverService:
    @staticmethod
    async def list_caregivers(user_id: UUID):
        return []

    @staticmethod
    async def invite_caregiver(user_id: UUID, payload: CaregiverInvite):
        return {"status": "INVITED", "message": f"Invitation dispatched to {payload.caregiver_email}"}
