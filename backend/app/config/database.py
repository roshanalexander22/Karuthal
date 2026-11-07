"""
app/config/database.py
----------------------
Async SQLAlchemy engine, session-factory setup, and self-healing connection
manager for the Sahaayi backend.

Exports:
  - ``engine``                   — the shared :class:`AsyncEngine` instance.
  - ``AsyncSessionFactory``      — a session factory bound to the active engine.
  - ``Base``                     — the declarative base class for all ORM models.
  - ``get_db``                   — FastAPI dependency yielding a session per request.
  - ``ensure_database_connected``— Startup self-healing connection and schema initializer.
  - ``get_canonical_sqlite_url`` — Canonical path to local SQLite database.
"""

from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import AsyncGenerator

from sqlalchemy import select
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.orm import DeclarativeBase

from app.core.config import settings
from app.core.security import hash_password

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Declarative Base
# ---------------------------------------------------------------------------
class Base(DeclarativeBase):
    """
    Base class for all SQLAlchemy ORM models.
    All models in ``app.models`` must inherit from this class.
    """
    pass


# ---------------------------------------------------------------------------
# Engine Construction Helpers
# ---------------------------------------------------------------------------
def get_canonical_sqlite_url() -> str:
    """
    Returns an absolute, canonical file URI to backend/sahaayi_dev.db.
    This guarantees that all processes (uvicorn, pytest, scripts, CLI) resolve
    the exact same database file regardless of current working directory.
    """
    backend_dir = Path(__file__).resolve().parent.parent.parent
    db_path = (backend_dir / "sahaayi_dev.db").resolve()
    return f"sqlite+aiosqlite:///{db_path.as_posix()}"


def create_app_engine(url: str) -> AsyncEngine:
    """Creates a configured AsyncEngine for SQLite or PostgreSQL."""
    if url.startswith("sqlite"):
        return create_async_engine(
            url,
            echo=settings.DEBUG,
            connect_args={"check_same_thread": False},
        )
    return create_async_engine(
        url,
        echo=settings.DEBUG,
        pool_size=10,
        max_overflow=20,
        pool_pre_ping=True,
        pool_recycle=3600,
    )


# ---------------------------------------------------------------------------
# Global Engine and Session Factory
# ---------------------------------------------------------------------------
_initial_url = settings.DATABASE_URL
engine: AsyncEngine = create_app_engine(_initial_url)

AsyncSessionFactory: async_sessionmaker[AsyncSession] = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False,
    autocommit=False,
)


# ---------------------------------------------------------------------------
# Self-Healing Connection & Migration / Seed Harness
# ---------------------------------------------------------------------------
async def ensure_database_connected() -> None:
    """
    Verifies database connectivity during application startup.

    If the primary database (e.g. PostgreSQL) is unreachable in development mode,
    it automatically and seamlessly switches to the local SQLite database,
    verifies/creates all schema tables, and seeds initial development records.
    """
    global engine, AsyncSessionFactory

    # Import models so all tables are registered with Base.metadata
    import app.models  # noqa: F401

    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        logger.info("Database connection and schema verified on %s", engine.url)
    except Exception as exc:
        if settings.APP_ENV in ("development", "test"):
            fallback_url = get_canonical_sqlite_url()
            logger.warning(
                "Primary database connection failed (%s). "
                "Switching automatically to local SQLite dev database: %s",
                exc,
                fallback_url,
            )
            try:
                await engine.dispose()
            except Exception:
                pass

            engine = create_app_engine(fallback_url)
            AsyncSessionFactory.configure(bind=engine)

            async with engine.begin() as conn:
                await conn.run_sync(Base.metadata.create_all)
            logger.info("Local SQLite database schema verified on %s", fallback_url)
        else:
            logger.critical("Database connection failed in production: %s", exc)
            raise

    # Ensure baseline development seeds exist
    await _seed_dev_data_if_empty()


async def _seed_dev_data_if_empty() -> None:
    """
    Seeds standard development users and memory records if the users table is empty.
    """
    from app.models.user import User, UserProfile
    from app.models.profile import PersonalProfileField
    from app.models.reminder import Reminder
    from app.models.emergency_contact import EmergencyContact

    async with AsyncSessionFactory() as session:
        try:
            res = await session.execute(select(User).limit(1))
            if res.scalar_one_or_none() is not None:
                return  # Database already seeded

            logger.info("Seeding initial development elder accounts and profile...")

            # 1. Primary Elder User
            elder_id = uuid.uuid4()
            elder_user = User(
                id=elder_id,
                email="elder_care@sahaayi.in",
                hashed_password=hash_password("SecurePassword123!"),
                full_name="മാധവൻ നായർ",
                phone="+91 98470 12345",
                language_preference="ml",
                is_active=True,
                is_verified=True,
                created_at=datetime.now(timezone.utc),
                updated_at=datetime.now(timezone.utc),
            )
            session.add(elder_user)

            # 2. English / Dev Alias Account
            dev_user = User(
                id=uuid.uuid4(),
                email="dev.elder@sahaayi.in",
                hashed_password=hash_password("Password123!"),
                full_name="Madhavan Nair",
                phone="+91 98765 43210",
                language_preference="en",
                is_active=True,
                is_verified=True,
                created_at=datetime.now(timezone.utc),
                updated_at=datetime.now(timezone.utc),
            )
            session.add(dev_user)

            # 3. User Profile
            elder_profile = UserProfile(
                id=uuid.uuid4(),
                user_id=elder_id,
                blood_group="O+ve",
                residential_address="ശാന്തിനിലയം, കോട്ടയം, കേരളം 686001",
                emergency_notes="ഹൈപ്പർടെൻഷൻ, മൈൽഡ് ഡയബറ്റിസ്",
                created_at=datetime.now(timezone.utc),
                updated_at=datetime.now(timezone.utc),
            )
            session.add(elder_profile)

            # 4. Verified Personal Memory Bank Fields
            memory_fields = [
                ("മുഴുവൻ പേര് (Full Name)", "മാധവൻ നായർ", "TEXT"),
                ("ജനനതീയതി (Date of Birth)", "12-04-1952", "DATE"),
                ("രക്തഗ്രൂപ്പ് (Blood Group)", "O+ve", "TEXT"),
                ("മേൽവിലാസം (Address)", "ശാന്തിനിലയം, കോട്ടയം, കേരളം 686001", "TEXT"),
                ("പെൻഷൻ നമ്പർ (Pension PPO)", "KTR/PEN/2012/8841", "TEXT"),
            ]
            for name, val, ftype in memory_fields:
                field = PersonalProfileField(
                    id=uuid.uuid4(),
                    user_id=elder_id,
                    field_name=name,
                    field_value=val,
                    field_type=ftype,
                    is_verified=True,
                    confidence_score=1.0,
                    created_at=datetime.now(timezone.utc),
                    updated_at=datetime.now(timezone.utc),
                )
                session.add(field)

            # 5. Baseline Reminders
            now = datetime.now(timezone.utc)
            r1 = Reminder(
                id=uuid.uuid4(),
                user_id=elder_id,
                title="പ്രഷർ മരുന്ന് (Telmisartan 40mg)",
                description="ഭക്ഷണത്തിന് ശേഷം 1 ഗുളിക",
                reminder_type="MEDICINE",
                scheduled_time=now.replace(hour=8, minute=0, second=0),
                recurrence_rule="DAILY",
                is_active=True,
                created_at=now,
            )
            r2 = Reminder(
                id=uuid.uuid4(),
                user_id=elder_id,
                title="ഷുഗർ മരുന്ന് (Metformin 500mg)",
                description="ഭക്ഷണത്തിന് മുൻപ് 1 ഗുളിക",
                reminder_type="MEDICINE",
                scheduled_time=now.replace(hour=13, minute=30, second=0),
                recurrence_rule="DAILY",
                is_active=True,
                created_at=now,
            )
            session.add_all([r1, r2])

            # 6. Baseline Emergency Contacts
            c1 = EmergencyContact(
                id=uuid.uuid4(),
                user_id=elder_id,
                name="അരുൺ മാധവൻ (Son)",
                phone="+91 98470 12345",
                relationship="മകൻ (Son)",
                is_primary=True,
                consent_given=True,
                created_at=now,
            )
            c2 = EmergencyContact(
                id=uuid.uuid4(),
                user_id=elder_id,
                name="ഡോ. സുരേഷ് മേനോൻ",
                phone="+91 94471 56789",
                relationship="കുടുംബ ഡോക്ടർ",
                is_primary=False,
                consent_given=True,
                created_at=now,
            )
            session.add_all([c1, c2])

            await session.commit()
            logger.info("Successfully seeded development accounts and memory bank.")
        except Exception as seed_err:
            await session.rollback()
            logger.warning("Auto-seed skipped or encountered error: %s", seed_err)


# ---------------------------------------------------------------------------
# FastAPI Dependency
# ---------------------------------------------------------------------------
async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    FastAPI dependency that yields an async database session.
    Commits on success, rolls back on exception, and closes on exit.
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
