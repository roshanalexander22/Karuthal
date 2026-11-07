"""001_initial_schema

Revision ID: 001_initial_schema
Revises: 
Create Date: 2026-11-07 12:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '001_initial_schema'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. users
    op.create_table(
        'users',
        sa.Column('id', sa.Uuid(), primary_key=True),
        sa.Column('email', sa.String(255), unique=True, nullable=False, index=True),
        sa.Column('hashed_password', sa.String(255), nullable=False),
        sa.Column('full_name', sa.String(255), nullable=False),
        sa.Column('phone', sa.String(32), nullable=True),
        sa.Column('language_preference', sa.String(8), default='ml'),
        sa.Column('is_active', sa.Boolean(), default=True),
        sa.Column('is_verified', sa.Boolean(), default=False),
        sa.Column('created_at', sa.DateTime(timezone=True), default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(timezone=True), default=sa.func.now()),
    )

    # 2. user_profiles
    op.create_table(
        'user_profiles',
        sa.Column('id', sa.Uuid(), primary_key=True),
        sa.Column('user_id', sa.Uuid(), sa.ForeignKey('users.id', ondelete='CASCADE'), unique=True, nullable=False),
        sa.Column('date_of_birth', sa.Date(), nullable=True),
        sa.Column('blood_group', sa.String(8), nullable=True),
        sa.Column('residential_address', sa.Text(), nullable=True),
        sa.Column('emergency_notes', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(timezone=True), default=sa.func.now()),
    )

    # 3. documents
    op.create_table(
        'documents',
        sa.Column('id', sa.Uuid(), primary_key=True),
        sa.Column('user_id', sa.Uuid(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True),
        sa.Column('filename', sa.String(255), nullable=False),
        sa.Column('original_filename', sa.String(255), nullable=False),
        sa.Column('file_path', sa.String(512), nullable=False),
        sa.Column('file_type', sa.String(64), nullable=False),
        sa.Column('document_category', sa.String(64), nullable=False),
        sa.Column('ocr_status', sa.String(32), default='PENDING'),
        sa.Column('created_at', sa.DateTime(timezone=True), default=sa.func.now()),
    )

    # 4. document_fields
    op.create_table(
        'document_fields',
        sa.Column('id', sa.Uuid(), primary_key=True),
        sa.Column('document_id', sa.Uuid(), sa.ForeignKey('documents.id', ondelete='CASCADE'), nullable=False, index=True),
        sa.Column('field_name', sa.String(128), nullable=False),
        sa.Column('field_value', sa.Text(), nullable=False),
        sa.Column('confidence', sa.Float(), default=0.0),
        sa.Column('is_verified', sa.Boolean(), default=False),
        sa.Column('created_at', sa.DateTime(timezone=True), default=sa.func.now()),
    )

    # 5. personal_profile_fields
    op.create_table(
        'personal_profile_fields',
        sa.Column('id', sa.Uuid(), primary_key=True),
        sa.Column('user_id', sa.Uuid(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True),
        sa.Column('field_name', sa.String(128), nullable=False),
        sa.Column('field_value', sa.Text(), nullable=False),
        sa.Column('field_type', sa.String(32), default='TEXT'),
        sa.Column('source_document_id', sa.Uuid(), sa.ForeignKey('documents.id', ondelete='SET NULL'), nullable=True),
        sa.Column('is_verified', sa.Boolean(), default=False),
        sa.Column('confidence_score', sa.Float(), default=1.0),
        sa.Column('created_at', sa.DateTime(timezone=True), default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(timezone=True), default=sa.func.now()),
        sa.UniqueConstraint('user_id', 'field_name', name='uq_user_profile_field'),
    )

    # 6. reminders
    op.create_table(
        'reminders',
        sa.Column('id', sa.Uuid(), primary_key=True),
        sa.Column('user_id', sa.Uuid(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True),
        sa.Column('title', sa.String(255), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('reminder_type', sa.String(64), default='MEDICINE'),
        sa.Column('scheduled_time', sa.DateTime(timezone=True), nullable=False),
        sa.Column('recurrence_rule', sa.String(128), nullable=True),
        sa.Column('is_active', sa.Boolean(), default=True),
        sa.Column('created_at', sa.DateTime(timezone=True), default=sa.func.now()),
    )

    # 7. reminder_logs
    op.create_table(
        'reminder_logs',
        sa.Column('id', sa.Uuid(), primary_key=True),
        sa.Column('reminder_id', sa.Uuid(), sa.ForeignKey('reminders.id', ondelete='CASCADE'), nullable=False, index=True),
        sa.Column('triggered_at', sa.DateTime(timezone=True), default=sa.func.now()),
        sa.Column('acknowledged_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('was_missed', sa.Boolean(), default=False),
    )

    # 8. transcriptions
    op.create_table(
        'transcriptions',
        sa.Column('id', sa.Uuid(), primary_key=True),
        sa.Column('user_id', sa.Uuid(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True),
        sa.Column('source_type', sa.String(64), default='MICROPHONE'),
        sa.Column('language', sa.String(8), default='ml'),
        sa.Column('raw_text', sa.Text(), nullable=False),
        sa.Column('summary', sa.Text(), nullable=True),
        sa.Column('duration_seconds', sa.Float(), default=0.0),
        sa.Column('created_at', sa.DateTime(timezone=True), default=sa.func.now()),
    )

    # 9. emergency_contacts
    op.create_table(
        'emergency_contacts',
        sa.Column('id', sa.Uuid(), primary_key=True),
        sa.Column('user_id', sa.Uuid(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True),
        sa.Column('name', sa.String(255), nullable=False),
        sa.Column('phone', sa.String(32), nullable=False),
        sa.Column('relationship', sa.String(64), nullable=True),
        sa.Column('is_primary', sa.Boolean(), default=False),
        sa.Column('consent_given', sa.Boolean(), default=True),
        sa.Column('created_at', sa.DateTime(timezone=True), default=sa.func.now()),
    )

    # 10. fall_events
    op.create_table(
        'fall_events',
        sa.Column('id', sa.Uuid(), primary_key=True),
        sa.Column('user_id', sa.Uuid(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True),
        sa.Column('detected_at', sa.DateTime(timezone=True), default=sa.func.now()),
        sa.Column('confidence_score', sa.Float(), nullable=False),
        sa.Column('sensor_data', sa.JSON(), nullable=True),
        sa.Column('confirmed', sa.Boolean(), default=False),
        sa.Column('false_alarm', sa.Boolean(), default=False),
        sa.Column('location_lat', sa.Float(), nullable=True),
        sa.Column('location_lng', sa.Float(), nullable=True),
    )

    # 11. caregiver_relationships
    op.create_table(
        'caregiver_relationships',
        sa.Column('id', sa.Uuid(), primary_key=True),
        sa.Column('user_id', sa.Uuid(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True),
        sa.Column('caregiver_user_id', sa.Uuid(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=True),
        sa.Column('caregiver_email', sa.String(255), nullable=False),
        sa.Column('relationship', sa.String(64), nullable=True),
        sa.Column('consent_given', sa.Boolean(), default=False),
        sa.Column('consent_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('can_view_reminders', sa.Boolean(), default=True),
        sa.Column('can_view_location', sa.Boolean(), default=False),
        sa.Column('created_at', sa.DateTime(timezone=True), default=sa.func.now()),
    )

    # 12. audit_logs
    op.create_table(
        'audit_logs',
        sa.Column('id', sa.Uuid(), primary_key=True),
        sa.Column('user_id', sa.Uuid(), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True, index=True),
        sa.Column('action', sa.String(128), nullable=False),
        sa.Column('resource_type', sa.String(64), nullable=False),
        sa.Column('resource_id', sa.String(128), nullable=True),
        sa.Column('ip_address', sa.String(45), nullable=True),
        sa.Column('details', sa.JSON(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), default=sa.func.now()),
    )


def downgrade() -> None:
    op.drop_table('audit_logs')
    op.drop_table('caregiver_relationships')
    op.drop_table('fall_events')
    op.drop_table('emergency_contacts')
    op.drop_table('transcriptions')
    op.drop_table('reminder_logs')
    op.drop_table('reminders')
    op.drop_table('personal_profile_fields')
    op.drop_table('document_fields')
    op.drop_table('documents')
    op.drop_table('user_profiles')
    op.drop_table('users')
