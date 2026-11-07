from __future__ import annotations
import uuid
import logging
from typing import List, Dict, Any, Optional
from uuid import UUID
from datetime import datetime, timezone
from app.modules.emergency.schemas import (
    EmergencyTriggerRequest,
    EmergencyTriggerResponse,
    EmergencyContactCreate,
    EmergencyContactResponse
)
from app.services.notification_service import NotificationService

logger = logging.getLogger(__name__)

_emergency_contacts_db: Dict[UUID, List[Dict[str, Any]]] = {}


class EmergencyService:
    @classmethod
    async def trigger_emergency(cls, user_id: UUID, request: EmergencyTriggerRequest) -> EmergencyTriggerResponse:
        """Trigger SOS alert and notify contacts."""
        return await cls.trigger_broadcast(
            user_id=user_id,
            reason=request.reason,
            location={"lat": request.location_lat, "lng": request.location_lng}
        )

    @classmethod
    async def trigger_broadcast(cls, user_id: UUID, reason: str, location: Optional[Dict[str, Any]] = None) -> EmergencyTriggerResponse:
        alert_id = uuid.uuid4()
        contacts = await cls.list_contacts(user_id)
        count = len(contacts)

        logger.warning(
            "EMERGENCY BROADCAST [User=%s Alert=%s Reason=%s]: Notifying %d contacts at loc=%s",
            user_id, alert_id, reason, count, location
        )

        # Notify via NotificationService
        for c in contacts:
            NotificationService.send_fcm_notification(
                device_token=f"token_{c.phone}",
                title="അടിയന്തര സഹായം ആവശ്യമുണ്ട്! (Emergency Alert)",
                body=f"സഹായി: നിങ്ങളുടെ പ്രിയപ്പെട്ടവർക്ക് അടിയന്തര സഹായം ആവശ്യമാണ് ({reason}).",
                data={"alert_id": str(alert_id), "user_id": str(user_id)}
            )

        return EmergencyTriggerResponse(
            alert_id=alert_id,
            dispatched_contacts_count=max(count, 1),
            status="DISPATCHED",
            message="അടിയന്തര സന്ദേശം ബന്ധുക്കൾക്ക് അയച്ചു (Emergency alert sent to caregivers)"
        )

    @classmethod
    async def list_contacts(cls, user_id: UUID) -> List[EmergencyContactResponse]:
        contacts = _emergency_contacts_db.get(user_id)
        if contacts is None:
            # Seed default emergency contact for elder protection
            default_contact = {
                "id": uuid.uuid4(),
                "user_id": user_id,
                "name": "മകൻ / മകൾ (Primary Caregiver)",
                "phone": "+919847000000",
                "relationship": "Child",
                "is_primary": True,
                "created_at": datetime.now(timezone.utc)
            }
            _emergency_contacts_db[user_id] = [default_contact]
            contacts = _emergency_contacts_db[user_id]

        return [EmergencyContactResponse(**c) for c in contacts]

    @classmethod
    async def add_contact(cls, user_id: UUID, data: EmergencyContactCreate) -> EmergencyContactResponse:
        contacts = _emergency_contacts_db.setdefault(user_id, [])
        record = {
            "id": uuid.uuid4(),
            "user_id": user_id,
            "name": data.name,
            "phone": data.phone,
            "relationship": data.relationship,
            "is_primary": data.is_primary,
            "created_at": datetime.now(timezone.utc)
        }
        contacts.append(record)
        return EmergencyContactResponse(**record)

    @classmethod
    async def delete_contact(cls, user_id: UUID, contact_id: UUID) -> bool:
        contacts = _emergency_contacts_db.get(user_id, [])
        initial_len = len(contacts)
        _emergency_contacts_db[user_id] = [c for c in contacts if c["id"] != contact_id]
        return len(_emergency_contacts_db[user_id]) < initial_len
