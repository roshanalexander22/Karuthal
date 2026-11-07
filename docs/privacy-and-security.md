# Privacy, Consent, and Security Policy

## 1. Core Principles
1. **Explicit User Consent**: Sensitive operations (document reading, microphone listening, contact alerts) require explicit user opt-in.
2. **Never Store Unverified OCR Data**: Extracted document data remains in a *Draft/Unverified* state until the user or their authorized caregiver reviews and confirms accuracy.
3. **No Automatic Form Submission**: Sahaayi assists in populating fields; the user must personally tap the final "Submit" button on external websites/apps.
4. **Absolute Exclusion of Credentials**: Sahaayi services programmatically ignore and discard passwords, PINs, OTPs, CVVs, and banking login tokens.

---

## 2. Android Permission Safeguards
- **AccessibilityService**: Restricted strictly to active form screens when explicitly summoned by the user. Must never collect background telemetry from unrelated applications.
- **Microphone**: Operates strictly upon push-to-talk activation or explicit transcription sessions. No continuous clandestine ambient listening.
- **Location**: Ingested only when an emergency fall event or SOS trigger is activated, and shared only with pre-enrolled emergency contacts.

---

## 3. Data Protection Architecture
- **In Transit**: All client-server traffic is encrypted using TLS 1.3.
- **At Rest**: AES-256 encryption for stored document binaries; database fields containing sensitive personal identity numbers (Aadhaar, PAN, Bank Account) are encrypted at the application tier before database persistence.
- **Audit Trails**: Every profile read, export, or deletion event generates an unalterable row in `audit_logs`.
