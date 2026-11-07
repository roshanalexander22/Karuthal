"""
app/core/security.py
--------------------
Security utilities for the Sahaayi backend:
  - Password hashing / verification (bcrypt via passlib)
  - JWT access & refresh token creation and verification (python-jose)
  - Pydantic models for token payloads
"""

from __future__ import annotations

import logging
from datetime import datetime, timedelta, timezone
from typing import Optional

from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic import BaseModel

from app.core.config import settings
from app.core.exceptions import AuthenticationError

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Password hashing
# ---------------------------------------------------------------------------
_pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(plain_password: str) -> str:
    """
    Hash *plain_password* with bcrypt.

    Args:
        plain_password: The raw password string supplied by the user.

    Returns:
        A bcrypt-hashed string safe to store in the database.
    """
    return _pwd_context.hash(plain_password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify *plain_password* against *hashed_password*.

    Args:
        plain_password:  The raw password supplied during login.
        hashed_password: The stored bcrypt hash retrieved from the database.

    Returns:
        ``True`` if the password matches; ``False`` otherwise.
    """
    return _pwd_context.verify(plain_password, hashed_password)


# ---------------------------------------------------------------------------
# Token payload models
# ---------------------------------------------------------------------------
class TokenData(BaseModel):
    """Data encoded inside a JWT access token."""

    sub: str                        # Subject — the user's UUID as a string
    email: str
    token_type: str = "access"      # "access" or "refresh"
    exp: Optional[datetime] = None


class TokenPair(BaseModel):
    """Access + refresh token pair returned on login / refresh."""

    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int                 # Access token TTL in seconds


# ---------------------------------------------------------------------------
# JWT helpers
# ---------------------------------------------------------------------------
def _create_token(
    subject: str,
    email: str,
    token_type: str,
    expires_delta: timedelta,
) -> str:
    """
    Internal helper that encodes a JWT.

    Args:
        subject:       The user UUID string used as the JWT `sub` claim.
        email:         The user's email address embedded in the token.
        token_type:    ``"access"`` or ``"refresh"``.
        expires_delta: How long until the token expires.

    Returns:
        A signed JWT string.
    """
    now = datetime.now(tz=timezone.utc)
    expire = now + expires_delta
    payload: dict = {
        "sub": subject,
        "email": email,
        "token_type": token_type,
        "iat": now,
        "exp": expire,
    }
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def create_access_token(user_id: str, email: str) -> str:
    """
    Create a short-lived JWT access token.

    Args:
        user_id: The user's UUID (string form).
        email:   The user's email address.

    Returns:
        A signed JWT string valid for ``ACCESS_TOKEN_EXPIRE_MINUTES`` minutes.
    """
    return _create_token(
        subject=user_id,
        email=email,
        token_type="access",
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES),
    )


def create_refresh_token(user_id: str, email: str) -> str:
    """
    Create a long-lived JWT refresh token.

    Args:
        user_id: The user's UUID (string form).
        email:   The user's email address.

    Returns:
        A signed JWT string valid for ``REFRESH_TOKEN_EXPIRE_DAYS`` days.
    """
    return _create_token(
        subject=user_id,
        email=email,
        token_type="refresh",
        expires_delta=timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
    )


def verify_token(token: str, expected_type: str = "access") -> TokenData:
    """
    Decode and validate a JWT token.

    Args:
        token:         The raw JWT string to verify.
        expected_type: ``"access"`` or ``"refresh"`` — the ``token_type``
                       claim must match this value.

    Returns:
        A :class:`TokenData` instance with the decoded claims.

    Raises:
        :class:`~app.core.exceptions.AuthenticationError`: If the token is
            invalid, expired, or has a mismatched type.
    """
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM],
        )
    except JWTError as exc:
        logger.warning("JWT decode failure: %s", exc)
        raise AuthenticationError("Invalid or expired token.") from exc

    token_type: str = payload.get("token_type", "")
    if token_type != expected_type:
        raise AuthenticationError(
            f"Expected '{expected_type}' token but received '{token_type}' token."
        )

    sub: Optional[str] = payload.get("sub")
    email: Optional[str] = payload.get("email")

    if sub is None or email is None:
        raise AuthenticationError("Token is missing required claims.")

    return TokenData(
        sub=sub,
        email=email,
        token_type=token_type,
    )


def create_token_pair(user_id: str, email: str) -> TokenPair:
    """
    Convenience function that creates both access and refresh tokens.

    Args:
        user_id: The user's UUID (string form).
        email:   The user's email address.

    Returns:
        A :class:`TokenPair` containing both tokens.
    """
    access = create_access_token(user_id, email)
    refresh = create_refresh_token(user_id, email)
    return TokenPair(
        access_token=access,
        refresh_token=refresh,
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    )
