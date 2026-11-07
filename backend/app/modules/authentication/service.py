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

    Methods are intentionally stateless; a database session is passed
    into each call rather than stored on the instance.
    """

    # ------------------------------------------------------------------
    async def register_user(
        self,
        payload: UserRegisterRequest,
        db: AsyncSession,
    ) -> RegisterResponse:
        """
        Register a new user account.

        Steps:
          1. Check the email is not already taken.
          2. Hash the password.
          3. Persist the new User record.
          4. Issue JWT token pair.

        Args:
            payload: Validated registration form data.
            db:      Async database session (injected by FastAPI).

        Returns:
            :class:`~app.modules.authentication.schemas.RegisterResponse`
            containing the new user and JWT tokens.

        Raises:
            :class:`~app.core.exceptions.AuthenticationError`: If the email
                is already registered.
        """
        # 1. Duplicate-email check
        result = await db.execute(select(User).where(User.email == payload.email))
        existing: Optional[User] = result.scalar_one_or_none()
        if existing is not None:
            raise AuthenticationError("An account with this email already exists.")

        # 2. Create user record
        new_user = User(
            id=str(uuid.uuid4()),
            email=payload.email,
            hashed_password=hash_password(payload.password),
            full_name=payload.full_name,
            phone=payload.phone,
            language_preference=payload.language_preference,
            is_active=True,
            is_verified=False,
        )
        db.add(new_user)
        await db.flush()  # Obtain the generated ID without committing yet

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

    # ------------------------------------------------------------------
    async def authenticate_user(
        self,
        email: str,
        password: str,
        db: AsyncSession,
    ) -> TokenResponse:
        """
        Verify credentials and return a JWT token pair.

        Args:
            email:    The user-supplied email address.
            password: The raw password to verify.
            db:       Async database session.

        Returns:
            :class:`~app.modules.authentication.schemas.TokenResponse`.

        Raises:
            :class:`~app.core.exceptions.AuthenticationError`: On invalid
                credentials or inactive account.
        """
        # Load user
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

    # ------------------------------------------------------------------
    async def refresh_token(
        self,
        refresh_token_str: str,
        db: AsyncSession,
    ) -> TokenResponse:
        """
        Issue a new access + refresh token pair from a valid refresh token.

        Args:
            refresh_token_str: The refresh JWT supplied by the client.
            db:                Async database session.

        Returns:
            New :class:`~app.modules.authentication.schemas.TokenResponse`.

        Raises:
            :class:`~app.core.exceptions.AuthenticationError`: If the
                refresh token is invalid or the user no longer exists.
        """
        token_data = verify_token(refresh_token_str, expected_type="refresh")

        result = await db.execute(select(User).where(User.id == token_data.sub))
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

    # ------------------------------------------------------------------
    async def logout_user(
        self,
        user_id: str,
    ) -> None:
        """
        Invalidate the user's current session.

        In a stateless JWT setup, true token revocation requires storing
        a denylist in Redis.

        TODO: Implement Redis-based token denylist.
              1. Add the ``jti`` claim to tokens.
              2. On logout, store the ``jti`` in Redis with TTL equal to
                 the token's remaining lifetime.
              3. In ``verify_token``, check the denylist before accepting
                 a token as valid.

        Args:
            user_id: The UUID of the user logging out.
        """
        logger.info("User logged out: %s (token denylist TODO)", user_id)
        # TODO: Push JTI to Redis denylist
