# Sahaayi Development Roadmap (Phases 0 - 9)

## Phase 0: Architecture & Foundation (Current)
- Complete directory structure and scaffolding.
- Establish shared API schemas, OpenAPI contracts, and database DDL.
- Configure CI/CD pipelines, Docker networks, and environment variables.

## Phase 1: Authentication & Client Foundation
- JWT registration, login, and secure local token vault.
- Flutter base application with accessible high-contrast theme and navigation router.
- PostgreSQL schema deployment and Alembic migration verification.

## Phase 2: Document Processing & Verified Memory Bank
- Document upload pipeline (PDF/Image) with Tesseract OCR.
- LLM entity structuring into verified profile fields.
- User review and verification UI in Flutter.

## Phase 3: Malayalam Voice Assistant & TTS
- Local and cloud TTS integration for Malayalam and English.
- Screen reading via Android AccessibilityService platform bridge.
- Push-to-talk voice command processing.

## Phase 4: Medicine & Appointment Reminders
- Reminder creation via voice and accessible UI.
- Android AlarmManager integration for reliable alarms.
- Missed dose tracking and optional caregiver alerts.

## Phase 5: Smart Autofill Platform
- Joint implementation: Accessibility tree parsing + autofill matching.
- User confirmation workflow before field population.
- Graceful fallback for non-standard form layouts.

## Phase 6: Audio & Conversation Transcription
- Streaming speech-to-text with bilingual code-mixing support.
- Transcript summarization and key action item extraction.

## Phase 7: Sensor-Based Fall Detection (Experimental)
- Accelerometer/gyroscope foreground telemetry monitoring.
- Impact and inactivity detection algorithms.
- 30-second cancellation countdown before emergency dispatch.

## Phase 8: Emergency & Caregiver Coordination
- One-tap SOS broadcasting location to designated contacts.
- Consent-based caregiver dashboard with read-only visibility.

## Phase 9: Real-World Testing & Accessibility Hardening
- Field testing with senior citizens in Kerala.
- Latency and battery consumption profiling.
- Formal security and privacy audit.
