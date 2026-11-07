"""
app/core/dependencies.py
------------------------
Reusable FastAPI dependency-injection functions used across all routers.

Provides:
  - ``get_db``              — async SQLAlchemy session per request
  - ``get_current_user``    — authenticated user extracted from Bearer JWT
  - ``get_current_active_user`` — user that is not disabled
  - ``get_redis``           — async Redis client
"""

from __future__ import annotations

import logging
from typing import AsyncGenerator, Optional

import redis.asyncio as aioredis
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.config.database import AsyncSessionFactory
from app.core.config import settings
from app.core.exceptions import AuthenticationError, AuthorizationError
from app.core.security import verify_token
from app.models.user import User

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# OAuth2 / Bearer scheme
# ---------------------------------------------------------------------------
_bearer_scheme = HTTPBearer(auto_error=False)

# ---------------------------------------------------------------------------
# Redis connection pool (module-level singleton)
# ---------------------------------------------------------------------------
_redis_pool: Optional[aioredis.Redis] = None  # type: ignore[type-arg]


def _get_redis_pool() -> aioredis.Redis:  # type: ignore[type-arg]
    """Lazy-initialise a module-level async Redis pool."""
    global _redis_pool
    if _redis_pool is None:
        _redis_pool = aioredis.from_url(
            settings.REDIS_URL,
            encoding="utf-8",
            decode_responses=True,
        )
    return _redis_pool


# ---------------------------------------------------------------------------
# Database session dependency
# ---------------------------------------------------------------------------
async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    Yield an async SQLAlchemy database session for the duration of a request.

    The session is automatically committed on success or rolled back on
    exception, and always closed when the request is done.

    Usage::

        @router.get("/items")
        async def list_items(db: AsyncSession = Depends(get_db)):
            ...
    """
    async with AsyncSessionFactory() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


# ---------------------------------------------------------------------------
# Redis dependency
# ---------------------------------------------------------------------------
async def get_redis() -> aioredis.Redis:  # type: ignore[type-arg]
    """
    Return the shared async Redis client.

    Usage::

        @router.get("/cached")
        async def cached(redis: aioredis.Redis = Depends(get_redis)):
            value = await redis.get("some_key")
    """
    return _get_redis_pool()


# ---------------------------------------------------------------------------
# Authentication dependencies
# ---------------------------------------------------------------------------
async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(_bearer_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    """
    Extract and validate the Bearer JWT from the ``Authorization`` header,
    then load the corresponding :class:`~app.models.user.User` from the DB.

    Args:
        credentials: Injected by FastAPI from the ``Authorization`` header.
        db:          Async database session.

    Returns:
        The authenticated :class:`~app.models.user.User` instance.

    Raises:
        :class:`fastapi.HTTPException` (401): If the token is missing,
            invalid, or expired.
        :class:`fastapi.HTTPException` (404): If the user no longer exists.
    """
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication credentials were not provided.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        token_data = verify_token(credentials.credentials, expected_type="access")
    except AuthenticationError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(exc.detail),
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc

    # Load user from database
    from sqlalchemy import select  # local import to avoid circular deps at module level

    result = await db.execute(select(User).where(User.id == token_data.sub))
    user: Optional[User] = result.scalar_one_or_none()

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User account not found.",
        )

    return user


async def get_current_active_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """
    Extends :func:`get_current_user` by additionally requiring the user
    account to be active (not disabled / banned).

    Args:
        current_user: Injected by :func:`get_current_user`.

    Returns:
        The active :class:`~app.models.user.User` instance.

    Raises:
        :class:`fastapi.HTTPException` (403): If the account is inactive.
    """
    if not current_user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Your account has been deactivated. Please contact support.",
        )
    return current_user
