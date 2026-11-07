# Sahaayi REST API Specification (v1)

Base URL: `https://api.sahaayi.internal/api/v1` (Production) or `http://localhost:8000/api/v1` (Local Dev)

All authenticated endpoints require the header:
```http
Authorization: Bearer <jwt_access_token>
```

---

## 1. Authentication Module (`/auth`)

### POST `/auth/register`
Create a new user account.
```json
// Request
{
  "email": "user@sahaayi.in",
  "password": "SecurePassword123!",
  "full_name": "Madhavan Nair",
  "phone": "+919876543210",
  "language_preference": "ml"
}

// Response (201 Created)
{
  "id": "c1f7b6b2-6529-4d8b-944a-d68a30704901",
  "email": "user@sahaayi.in",
  "full_name": "Madhavan Nair",
  "language_preference": "ml",
  "is_active": true
}
```

### POST `/auth/login`
Authenticate user credentials and receive JWT access/refresh token pair.
```json
// Request
{
  "username": "user@sahaayi.in",
  "password": "SecurePassword123!"
}

// Response (200 OK)
{
  "access_token": "eyJhbGciOi...",
  "refresh_token": "eyJhbGciOi...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

---

## 2. Document Processing (`/documents`)

### POST `/documents/upload`
Upload a document image or PDF for parsing (Multipart Form).
- `file`: Binary file (PDF, PNG, JPEG)
- `category`: `IDENTITY` | `MEDICAL` | `PRESCRIPTION` | `BANK` | `ADDRESS` | `CERTIFICATE` | `OTHER`

### POST `/documents/{id}/extract`
Trigger asynchronous OCR and LLM entity extraction.
```json
// Response (202 Accepted)
{
  "document_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "status": "PROCESSING",
  "message": "OCR and structuring job queued"
}
```

---

## 3. Personal Memory Bank (`/profile`)

### GET `/profile`
Retrieve all verified personal profile fields.
```json
// Response (200 OK)
{
  "user_id": "c1f7b6b2-6529-4d8b-944a-d68a30704901",
  "fields": [
    {
      "field_name": "full_name",
      "field_value": "Madhavan Nair",
      "field_type": "TEXT",
      "is_verified": true,
      "confidence_score": 0.98,
      "source_document_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d"
    },
    {
      "field_name": "date_of_birth",
      "field_value": "1952-04-12",
      "field_type": "DATE",
      "is_verified": true,
      "confidence_score": 0.95
    }
  ]
}
```

---

## 4. Smart Autofill (`/autofill`)

### POST `/autofill/match`
Match inspected screen form field labels to verified profile fields.
```json
// Request
{
  "fields": [
    {"node_id": "txt_name", "label": "Full Name / പേര്"},
    {"node_id": "txt_dob", "label": "Date of Birth"},
    {"node_id": "txt_aadhaar", "label": "Aadhaar Number"}
  ]
}

// Response (200 OK)
{
  "matches": [
    {
      "node_id": "txt_name",
      "profile_field_name": "full_name",
      "proposed_value": "Madhavan Nair",
      "confidence_score": 0.96,
      "requires_user_confirmation": false
    },
    {
      "node_id": "txt_aadhaar",
      "profile_field_name": "aadhaar_number",
      "proposed_value": "XXXX-XXXX-1234",
      "confidence_score": 0.92,
      "requires_user_confirmation": true
    }
  ]
}
```

---

## 5. Medicine Reminders (`/reminders`)
- `POST /reminders`: Create reminder with scheduling rules.
- `GET /reminders`: List active reminders.
- `PATCH /reminders/{id}`: Modify schedule or acknowledgement status.
- `DELETE /reminders/{id}`: Soft delete reminder.

---

## 6. Transcription (`/transcription`)
- `POST /transcription/start`: Initialize a transcription session.
- `POST /transcription/upload`: Upload pre-recorded audio file.
- `GET /transcription/{id}`: Fetch generated transcript with timestamps.

---

## 7. Fall & Distress Monitoring (`/fall-detection` & `/emergency`)
- `POST /fall-detection/events`: Ingest sensor alert payload with accelerometer peaks.
- `POST /emergency/trigger`: Dispatch urgent alerts to enrolled caregivers and emergency contacts.
