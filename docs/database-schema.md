# Sahaayi Database Schema Specification

Relational storage is governed by **PostgreSQL 15+**. All primary keys are `UUIDv4` for collision-free distributed generation.

## Entity Relationship Overview

```
 [users] <---+ [user_profiles]
    |        + [documents] <---+ [document_fields]
    |        + [personal_profile_fields]
    |        + [reminders] <---+ [reminder_logs]
    |        + [transcriptions]
    |        + [fall_events]
    |        + [emergency_contacts]
    |        + [caregiver_relationships]
    +--------+ [audit_logs]
```

---

## Detailed Table Definitions

### 1. `users`
Core identity record.
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(32),
    language_preference VARCHAR(8) DEFAULT 'ml',
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 2. `documents`
Uploaded personal document artifacts.
```sql
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(512) NOT NULL,
    file_type VARCHAR(64) NOT NULL,
    document_category VARCHAR(64) NOT NULL,
    ocr_status VARCHAR(32) DEFAULT 'PENDING',
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 3. `personal_profile_fields`
Verified personal memory elements available for autofill.
```sql
CREATE TABLE personal_profile_fields (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    field_name VARCHAR(128) NOT NULL,
    field_value TEXT NOT NULL,
    field_type VARCHAR(32) DEFAULT 'TEXT',
    source_document_id UUID REFERENCES documents(id) ON DELETE SET NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    confidence_score REAL DEFAULT 1.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, field_name)
);
```

### 4. `reminders` & `reminder_logs`
Schedules for medications, doctor appointments, and recurring tasks.
```sql
CREATE TABLE reminders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    reminder_type VARCHAR(64) DEFAULT 'MEDICINE',
    scheduled_time TIMESTAMPTZ NOT NULL,
    recurrence_rule VARCHAR(128),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE reminder_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reminder_id UUID NOT NULL REFERENCES reminders(id) ON DELETE CASCADE,
    triggered_at TIMESTAMPTZ DEFAULT NOW(),
    acknowledged_at TIMESTAMPTZ,
    was_missed BOOLEAN DEFAULT FALSE
);
```

### 5. `fall_events` & `emergency_contacts`
Safety monitoring records and designated contacts.
```sql
CREATE TABLE emergency_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(32) NOT NULL,
    relationship VARCHAR(64),
    is_primary BOOLEAN DEFAULT FALSE,
    consent_given BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE fall_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    detected_at TIMESTAMPTZ DEFAULT NOW(),
    confidence_score REAL NOT NULL,
    sensor_data JSONB,
    confirmed BOOLEAN DEFAULT FALSE,
    false_alarm BOOLEAN DEFAULT FALSE,
    location_lat DOUBLE PRECISION,
    location_lng DOUBLE PRECISION
);
```

### 6. `audit_logs`
Immutable compliance trail for all sensitive document access and modifications.
```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(128) NOT NULL,
    resource_type VARCHAR(64) NOT NULL,
    resource_id VARCHAR(128),
    ip_address VARCHAR(45),
    details JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```
