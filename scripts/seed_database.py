#!/usr/bin/env python3
"""
scripts/seed_database.py
-------------------------
Database seeding script for the Sahaayi Elder Care & Accessibility Assistant.

Seeds:
  1. Default Administrator account.
  2. Test Elder Citizen account (Madhavan Nair).
  3. User Profile and Accessibility Preferences.
  4. Verified Personal Memory Bank (Profile Fields for Autofill).
  5. Sample Medication & Appointment Reminders.
  6. Designated Emergency Contact.

Usage:
  python scripts/seed_database.py
"""

import asyncio
import os
import sys
import uuid
from datetime import datetime, date, timedelta, timezone

# Add backend directory to sys.path
backend_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "backend")
sys.path.insert(0, backend_dir)

from sqlalchemy import select
from app.config.database import AsyncSessionFactory, engine, Base
from app.core.config import settings
from app.core.security import hash_password
from app.models import (
    User,
    UserProfile,
    ProfileField,
    Reminder,
    ReminderLog,
    EmergencyContact,
    AuditLog,
)


async def seed() -> None:
    print("=" * 60)
    print("🌱 SAHAAYI: Database Seeding Initializing")
    print(f"Target DB URL: {settings.DATABASE_URL}")
    print("=" * 60)

    # In dev mode, ensure tables exist
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    print("✓ Schema tables verified.")

    async with AsyncSessionFactory() as session:
        # 1. Admin Account
        admin_email = "admin@sahaayi.app"
        res = await session.execute(select(User).where(User.email == admin_email))
        admin_user = res.scalar_one_or_none()
        if not admin_user:
            admin_user = User(
                id=uuid.uuid4(),
                email=admin_email,
                hashed_password=hash_password("AdminSecurePassword123!"),
                full_name="Sahaayi System Administrator",
                phone="+919000000001",
                language_preference="en",
                is_active=True,
                is_verified=True,
            )
            session.add(admin_user)
            print(f"✓ Created Administrator: {admin_email}")
        else:
            print(f"• Administrator already exists: {admin_email}")

        # 2. Test Elder User: Madhavan Nair
        elder_email = "madhavan@sahaayi.app"
        res = await session.execute(select(User).where(User.email == elder_email))
        elder_user = res.scalar_one_or_none()
        if not elder_user:
            elder_id = uuid.uuid4()
            elder_user = User(
                id=elder_id,
                email=elder_email,
                hashed_password=hash_password("ElderSecure123!"),
                full_name="Madhavan Nair",
                phone="+919847012345",
                language_preference="ml",
                is_active=True,
                is_verified=True,
            )
            session.add(elder_user)
            await session.flush()

            # 3. Extended Profile
            profile = UserProfile(
                id=uuid.uuid4(),
                user_id=elder_user.id,
                date_of_birth=date(1952, 4, 12),
                blood_group="B+",
                residential_address="Thiruvonam House, Medical College Road, Thiruvananthapuram, Kerala 695011",
                emergency_notes="Type 2 Diabetes, Mild Hypertension. Carries inhaler in pocket.",
            )
            session.add(profile)

            # 4. Verified Personal Memory Fields (Available for Smart Autofill)
            verified_fields = [
                ("full_name", "Madhavan Nair", "TEXT", 1.0),
                ("date_of_birth", "1952-04-12", "DATE", 0.99),
                ("residential_address", "Thiruvonam House, Medical College Road, Thiruvananthapuram, Kerala 695011", "TEXT", 0.98),
                ("phone_number", "+919847012345", "PHONE", 1.0),
                ("email_address", "madhavan@sahaayi.app", "EMAIL", 1.0),
                ("blood_group", "B+", "TEXT", 1.0),
                ("guardian_name", "Ramesh Nair", "TEXT", 0.95),
            ]
            for field_name, field_val, f_type, conf in verified_fields:
                session.add(
                    ProfileField(
                        id=uuid.uuid4(),
                        user_id=elder_user.id,
                        field_name=field_name,
                        field_value=field_val,
                        field_type=f_type,
                        is_verified=True,
                        confidence_score=conf,
                    )
                )

            # 5. Medication Reminders
            now = datetime.now(tz=timezone.utc)
            reminders = [
                (
                    "Metformin 500mg (Morning Dose)",
                    "Take 1 tablet immediately after morning breakfast with a full glass of water.",
                    "MEDICINE",
                    now + timedelta(hours=2),
                    "FREQ=DAILY;BYHOUR=8;BYMINUTE=30",
                ),
                (
                    "Amlodipine 5mg (Evening Dose)",
                    "Blood pressure medicine after evening tea.",
                    "MEDICINE",
                    now + timedelta(hours=8),
                    "FREQ=DAILY;BYHOUR=18;BYMINUTE=0",
                ),
                (
                    "Cardiology Review Appointment",
                    "Dr. K. S. Ramanathan at Thiruvananthapuram Medical College, OP Room 14.",
                    "APPOINTMENT",
                    now + timedelta(days=3, hours=10),
                    None,
                ),
            ]
            for title, desc, r_type, s_time, rrule in reminders:
                session.add(
                    Reminder(
                        id=uuid.uuid4(),
                        user_id=elder_user.id,
                        title=title,
                        description=desc,
                        reminder_type=r_type,
                        scheduled_time=s_time,
                        recurrence_rule=rrule,
                        is_active=True,
                    )
                )

            # 6. Emergency Contacts
            session.add(
                EmergencyContact(
                    id=uuid.uuid4(),
                    user_id=elder_user.id,
                    name="Ramesh Nair (Son)",
                    phone="+919847054321",
                    relationship="Son",
                    is_primary=True,
                    consent_given=True,
                )
            )

            # 7. Initial Compliance Audit Log
            session.add(
                AuditLog(
                    id=uuid.uuid4(),
                    user_id=elder_user.id,
                    action="SEED_DATA_INITIALIZED",
                    resource_type="USER_ACCOUNT",
                    resource_id=str(elder_user.id),
                    ip_address="127.0.0.1",
                    details={"seeded_by": "scripts/seed_database.py", "locale": "ml"},
                )
            )

            print(f"✓ Created Test Elder User: {elder_email} with verified memory, reminders & contacts.")
        else:
            print(f"• Test Elder User already exists: {elder_email}")

        await session.commit()

    print("=" * 60)
    print("✨ Database seeding complete successfully!")
    print("=" * 60)


if __name__ == "__main__":
    asyncio.run(seed())
