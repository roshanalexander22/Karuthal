# Sahaayi: Two-Developer Integration Testing Plan

This document establishes the end-to-end verification and integration protocol between **Member 1 (System Architect & Mobile Lead)** and **Member 2 (Feature Development Lead)**.

---

## 1. Local Cross-Subsystem Execution Matrix

Both developers can run the entire decoupled stack locally using the following coordinated ports:

| Service | Host Port | Protocol | Health Probe | Primary Owner |
|---|---|---|---|---|
| **FastAPI Backend** | `8000` | HTTP / WS | `GET /health` | Member 1 |
| **AI Engine Microservice** | `8001` | HTTP / REST | `GET /health` | Member 2 |
| **PostgreSQL Database** | `5432` | TCP (pg) | `pg_isready` | Member 1 |
| **Redis Cache** | `6379` | TCP | `redis-cli ping` | Member 1 |
| **Flutter Mobile Client** | Android VM / USB | Native / Dart | Smoke Test | Member 1 & 2 |

---

## 2. End-to-End Integration Scenarios

### Scenario 1: Authentication & Token Lifecycle
1. User submits `POST /api/v1/auth/register` with Malayalam preference.
2. Backend returns `RegisterResponse` with JWT access and refresh tokens.
3. Mobile app persists tokens in `FlutterSecureStorage`.
4. User accesses protected route (`/profile` or `/reminders`); token interceptor attaches `Authorization: Bearer <token>`.
5. Access token expires after 30 minutes; queued interceptor automatically calls `/api/v1/auth/refresh` and resumes in-flight requests transparently.

### Scenario 2: Malayalam Text-to-Speech & Screen Reading
1. Elder opens a screen and taps **"വായിക്കുക (Read Screen)"**.
2. Flutter invokes MethodChannel `sahaayi/accessibility` (`requestScreenRead`).
3. Native `SahaayiAccessibilityService` extracts visible screen text nodes (excluding password/OTP fields).
4. Text payload is dispatched to Member 2's TTS engine (`sahaayi/tts` or AI Engine port 8001).
5. Audio stream plays back with pause, resume, and speed controls (`AudioControlWidget`).

### Scenario 3: Document OCR & Verified Memory Bank
1. Elder captures photo of pension or medical prescription.
2. Flutter sends multipart payload to `POST /api/v1/documents/upload`.
3. Backend queues task to Member 2's OCR pipeline (`POST /documents/{id}/extract`).
4. Extracted raw fields are saved in `document_fields`.
5. Flutter displays review dialog (`ConfirmationDialog`). Elder verifies each item.
6. Verified items are promoted to `personal_profile_fields` for Smart Autofill.

### Scenario 4: Smart Autofill Workflow (Joint Feature)
1. Elder opens supported government / banking form on Android.
2. `SahaayiAccessibilityService` detects non-sensitive form input fields.
3. Native bridge sends field metadata to `POST /api/v1/autofill/match`.
4. Backend matches fields against verified memory bank and returns proposed values with confidence scores.
5. Flutter presents bilingual confirmation bottom-sheet.
6. Elder reviews and taps **"ശരി, പൂരിപ്പിക്കുക (Confirm & Fill)"**.
7. Backend logs immutable entry in `audit_logs`.
8. Native Android Autofill populates the fields; elder manually reviews and submits.

### Scenario 5: Proactive Fall Detection & Distress Countdown
1. `SensorMonitoringService` detects high-acceleration impact followed by inactivity.
2. Native bridge triggers Flutter emergency countdown overlay.
3. Audio alarm sounds in Malayalam for 30 seconds: *"വീഴ്ച കണ്ടെത്തി. സഹായം വിളിക്കണോ? (Fall detected. Call for help?)"*.
4. If cancelled by user: false alarm logged.
5. If countdown expires: `POST /api/v1/emergency/trigger` broadcasts SMS / location alert to designated emergency contacts.

---

## 3. Regression & Sanity Verification Commands

```bash
# Backend validation
cd backend
pytest -v

# AI Engine validation
cd ai-engine
pytest -v

# Flutter static analysis & test
cd frontend/mobile
flutter analyze
flutter test
```
