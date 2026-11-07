"""
app/modules/authentication/service.py
--------------------------------------
Business logic for user authentication and token management.
"""

from __future__ import annotations

import logging
import uuid
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import AuthenticationError
from app.core.security import (
    create_token_pair,
    hash_password,
    verify_password,
    verify_token,
)
from app.models.user import User
from app.modules.authentication.schemas import (
    RegisterResponse,
    TokenResponse,
    UserRegisterRequest,
    UserResponse,
)

logger = logging.getLogger(__name__)


class AuthService:
    """
    Handles all authentication-related business operations.
    Methods are stateless and can be called on an instance or as classmethods.
    """

    @classmethod
    async def register_user(
        cls,
        payload: UserRegisterRequest,
        db: AsyncSession,
    ) -> RegisterResponse:
        """
        Register a new user account.
        """
        # 1. Duplicate-email check
        result = await db.execute(select(User).where(User.email == payload.email))
        existing: Optional[User] = result.scalar_one_or_none()
        if existing is not None:
            raise AuthenticationError("An account with this email already exists.")

        # 2. Create user record
        new_user = User(
            id=uuid.uuid4(),
            email=payload.email,
            hashed_password=hash_password(payload.password),
            full_name=payload.full_name,
            phone=payload.phone,
            language_preference=payload.language_preference,
            is_active=True,
            is_verified=False,
        )
        db.add(new_user)
        await db.flush()

        logger.info("New user registered: %s (id=%s)", new_user.email, new_user.id)

        # 3. Issue tokens
        tokens = create_token_pair(str(new_user.id), new_user.email)

        return RegisterResponse(
            user=UserResponse.model_validate(new_user),
            tokens=TokenResponse(
                access_token=tokens.access_token,
                refresh_token=tokens.refresh_token,
                expires_in=tokens.expires_in,
            ),
        )

    @classmethod
    async def authenticate_user(
        cls,
        email: str,
        password: str,
        db: AsyncSession,
    ) -> TokenResponse:
        """
        Verify credentials and return a JWT token pair.
        """
        result = await db.execute(select(User).where(User.email == email))
        user: Optional[User] = result.scalar_one_or_none()

        if user is None or not verify_password(password, user.hashed_password):
            raise AuthenticationError("Invalid email or password.")

        if not user.is_active:
            raise AuthenticationError("Your account has been deactivated.")

        logger.info("User authenticated: %s", email)
        tokens = create_token_pair(str(user.id), user.email)

        return TokenResponse(
            access_token=tokens.access_token,
            refresh_token=tokens.refresh_token,
            expires_in=tokens.expires_in,
        )

    @classmethod
    async def refresh_token(
        cls,
        refresh_token_str: str,
        db: AsyncSession,
    ) -> TokenResponse:
        """
        Issue a new access + refresh token pair from a valid refresh token.
        """
        token_data = verify_token(refresh_token_str, expected_type="refresh")

        # Query user using uuid or str
        user_uuid = uuid.UUID(token_data.sub) if isinstance(token_data.sub, str) else token_data.sub
        result = await db.execute(select(User).where(User.id == user_uuid))
        user: Optional[User] = result.scalar_one_or_none()

        if user is None or not user.is_active:
            raise AuthenticationError("User account not found or inactive.")

        logger.info("Token refreshed for user: %s", user.email)
        tokens = create_token_pair(str(user.id), user.email)

        return TokenResponse(
            access_token=tokens.access_token,
            refresh_token=tokens.refresh_token,
            expires_in=tokens.expires_in,
        )

    @classmethod
    async def logout_user(
        cls,
        user_id: str,
    ) -> None:
        """
        Invalidate user's current session.
        """
        logger.info("User logged out: %s", user_id)


auth_service = AuthService()
