"""
app/modules/authentication/schemas.py
--------------------------------------
Pydantic v2 request / response schemas for the authentication module.
"""

from __future__ import annotations

import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr, Field, field_validator


# ---------------------------------------------------------------------------
# Request schemas
# ---------------------------------------------------------------------------
class UserRegisterRequest(BaseModel):
    """Payload for the POST /auth/register endpoint."""

    full_name: str = Field(..., min_length=2, max_length=120, examples=["Meera Nair"])
    email: EmailStr = Field(..., examples=["meera@example.com"])
    password: str = Field(
        ...,
        min_length=8,
        max_length=128,
        description="Must be at least 8 characters.",
        examples=["Str0ng!Pass"],
    )
    phone: Optional[str] = Field(
        default=None,
        pattern=r"^\+?[0-9\s\-()]{7,20}$",
        examples=["+91 9876543210"],
    )
    language_preference: str = Field(
        default="en",
        max_length=10,
        description="BCP-47 language code (e.g. 'en', 'ml', 'hi').",
        examples=["ml"],
    )

    @field_validator("password")
    @classmethod
    def password_complexity(cls, v: str) -> str:
        """Reject passwords that are entirely lowercase or have no digit."""
        if v.isalpha():
            raise ValueError("Password must contain at least one non-alphabetic character.")
        return v


class UserLoginRequest(BaseModel):
    """Payload for the POST /auth/login endpoint."""

    email: EmailStr = Field(..., examples=["meera@example.com"])
    password: str = Field(..., min_length=1, examples=["Str0ng!Pass"])


class RefreshTokenRequest(BaseModel):
    """Payload for the POST /auth/refresh endpoint."""

    refresh_token: str = Field(..., description="A valid refresh JWT obtained at login.")


# ---------------------------------------------------------------------------
# Response schemas
# ---------------------------------------------------------------------------
class TokenResponse(BaseModel):
    """JWT token pair returned on successful login or refresh."""

    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = Field(description="Access token TTL in seconds.")


class UserResponse(BaseModel):
    """Public user representation returned after registration or login."""

    id: uuid.UUID
    email: EmailStr
    full_name: str
    phone: Optional[str] = None
    language_preference: str
    is_active: bool
    is_verified: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class RegisterResponse(BaseModel):
    """Response envelope for successful user registration."""

    user: UserResponse
    tokens: TokenResponse


class MessageResponse(BaseModel):
    """Generic single-message response (e.g., logout confirmation)."""

    message: str
