## Pull Request: Sahaayi (സഹായി) Integration

### 1. Ownership & Module Affected
- [ ] **Member 1 (Lead/Core)**: Architecture / Auth / Database / Platform Channels / CI-CD / Docker
- [ ] **Member 2 (Features)**: Malayalam Voice / OCR / Memory Bank / Reminders / Fall Detection / AI Engine
- [ ] **Joint Responsibility**: Smart Autofill Platform

**Subsystems Impacted:**
- [ ] Backend API (`backend/`)
- [ ] Flutter Mobile App (`frontend/mobile/`)
- [ ] Native Android Services (`android-native/` or `frontend/mobile/android/`)
- [ ] AI Microservice (`ai-engine/`)
- [ ] Shared Contracts / Schemas (`shared/`)
- [ ] Database Schema / Migrations (`database/` or `backend/app/database/migrations/`)

---

### 2. Description of Changes
<!-- Provide a concise summary of the rationale and implementation details. -->

---

### 3. API Contract & Schema Modifications
- [ ] **No changes** to shared API contracts.
- [ ] **Modifications made**: Updated `shared/api-contracts/openapi.yaml` and schemas in `shared/schemas/`.
- [ ] Backward compatibility verified.

---

### 4. Database Schema Impact
- [ ] **No database modifications**.
- [ ] **Schema modified**: Alembic migration script included under `backend/app/database/migrations/versions/`.
- [ ] Tested against both PostgreSQL 15 and SQLite development fallback.

---

### 5. Accessibility Impact Assessment (Elderly & Assistive Users)
- [ ] Adheres to WCAG 2.1 AA/AAA standards.
- [ ] Minimum touch target >= 56dp x 56dp verified.
- [ ] Minimum font size >= 18sp verified.
- [ ] High-contrast color compliance checked.
- [ ] Bilingual text (Malayalam + English) provided.
- [ ] Screen reader (`Semantics`) attributes verified.

---

### 6. Security & Privacy Non-Negotiable Boundaries
- [ ] **No password/OTP inspection**: Accessibility/Autofill never touches sensitive credentials.
- [ ] **No automatic form submission**: User must review and submit forms manually.
- [ ] **No hardcoded secrets**: All API keys/secrets use environment variables.
- [ ] **Unverified OCR protected**: Unverified OCR is never stored as authoritative personal data without user consent.

---

### 7. Verification & Test Coverage
- [ ] Backend tests passing (`cd backend && pytest`)
- [ ] AI Engine tests passing (`cd ai-engine && pytest`)
- [ ] Flutter analyze clean (`cd frontend/mobile && flutter analyze`)
- [ ] Flutter tests passing (`cd frontend/mobile && flutter test`)

---

### 8. Two-Developer Review Signoff
- **Reviewer Required**: @roshanalexander22 (Member 1) or Member 2.
- [ ] Code reviewed and approved for merge into `develop`.
