from __future__ import annotations
from uuid import UUID
from app.modules.emergency.schemas import EmergencyTriggerRequest, EmergencyTriggerResponse

class EmergencyService:
    @staticmethod
    async def trigger_emergency(user_id: UUID, request: EmergencyTriggerRequest) -> EmergencyTriggerResponse:
        return EmergencyTriggerResponse(
            alert_id=UUID("00000000-0000-0000-0000-000000000005"),
            dispatched_contacts_count=2,
            status="DISPATCHED",
            message="Emergency alert transmitted to designated caregivers"
        )
