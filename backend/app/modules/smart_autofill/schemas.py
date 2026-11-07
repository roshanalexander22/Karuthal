from __future__ import annotations
from pydantic import BaseModel, Field
from typing import List, Optional

class ScreenFormField(BaseModel):
    node_id: str
    label: str
    input_type: Optional[str] = "text"
    is_password_or_sensitive: bool = False

class AutofillMatchRequest(BaseModel):
    fields: List[ScreenFormField]

class FieldMatchProposal(BaseModel):
    node_id: str
    profile_field_name: str
    proposed_value: str
    confidence_score: float
    requires_user_confirmation: bool = True

class AutofillMatchResponse(BaseModel):
    matches: List[FieldMatchProposal]

class AutofillConfirmRequest(BaseModel):
    confirmed_matches: List[FieldMatchProposal]
