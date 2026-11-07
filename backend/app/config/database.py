"""
app/config/database.py
----------------------
Async SQLAlchemy engine and session-factory setup for the Sahaayi backend.

Exports:
  - ``engine``              — the shared :class:`AsyncEngine` instance.
  - ``AsyncSessionFactory`` — a session factory bound to the engine.
  - ``Base``                — the declarative base class for all ORM models.
  - ``get_db``              — FastAPI dependency yielding a session per request.
"""

from __future__ import annotations

from typing import AsyncGenerator

from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.orm import DeclarativeBase

from app.core.config import settings

# ---------------------------------------------------------------------------
# Engine
# ---------------------------------------------------------------------------
_db_url = settings.DATABASE_URL
if _db_url.startswith("sqlite"):
    engine: AsyncEngine = create_async_engine(
        _db_url,
        echo=settings.DEBUG,
        connect_args={"check_same_thread": False},
    )
else:
    engine: AsyncEngine = create_async_engine(
        _db_url,
        echo=settings.DEBUG,          # Log SQL statements in debug mode
        pool_size=10,
        max_overflow=20,
        pool_pre_ping=True,           # Reconnect on stale connections
        pool_recycle=3600,            # Recycle connections every hour
    )

# ---------------------------------------------------------------------------
# Session factory
# ---------------------------------------------------------------------------
AsyncSessionFactory: async_sessionmaker[AsyncSession] = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,       # Keep objects accessible after commit
    autoflush=False,
    autocommit=False,
)

# ---------------------------------------------------------------------------
# Declarative base
# ---------------------------------------------------------------------------
class Base(DeclarativeBase):
    """
    Base class for all SQLAlchemy ORM models.

    All models in ``app.models`` must inherit from this class so that
    Alembic can discover them for auto-generated migrations.
    """
    pass  # noqa: unnecessary-pass


# ---------------------------------------------------------------------------
# FastAPI dependency
# ---------------------------------------------------------------------------
async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    FastAPI dependency that yields an async database session.

    The session is committed on success, rolled back on any exception,
    and closed unconditionally at the end of the request lifecycle.

    Usage::

        @router.get("/items")
        async def list_items(db: AsyncSession = Depends(get_db)):
            result = await db.execute(select(Item))
            return result.scalars().all()
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
