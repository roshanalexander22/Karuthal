# Security Policy

## Overview

The Sahaayi project takes security seriously. Because our application handles sensitive personal data belonging to elderly users — including health information, identity documents, location data, and biometric recordings — we hold ourselves to a high standard of security practice.

This document describes our supported versions, vulnerability disclosure process, and core security principles.

---

## Supported Versions

| Version | Support Status |
|---|---|
| `main` branch (development) | ✅ Security fixes applied immediately |
| Latest tagged release | ✅ Security patches backported |
| Older releases (> 1 minor behind) | ❌ Not supported — please upgrade |

We follow [Semantic Versioning](https://semver.org/). Security patches increment the **patch** version and are released as soon as a fix is verified.

---

## Reporting a Vulnerability

**Do not** report security vulnerabilities through public GitHub issues. Public disclosure before a fix is available could put users at risk.

### Private Disclosure Process

1. **Email the security team** at: `security@sahaayi.example.com`
   *(Replace with actual contact once project is public)*

   Alternatively, use GitHub's [Private Security Advisories](https://docs.github.com/en/code-security/security-advisories/working-with-repository-security-advisories/creating-a-repository-security-advisory) feature:
   - Navigate to the **Security** tab of the repository
   - Click **Advisories → New draft security advisory**

2. **Include in your report:**
   - Type of vulnerability (e.g., authentication bypass, injection, data exposure)
   - Affected component(s) and version(s)
   - Step-by-step reproduction instructions
   - Proof-of-concept code or screenshots (if applicable)
   - Potential impact assessment
   - Your suggested fix (optional but appreciated)

3. **Encrypt sensitive reports** using our PGP key (to be published in the repository once available).

### What Happens Next

| Milestone | Target Timeline |
|---|---|
| Acknowledgement of receipt | Within **48 hours** |
| Initial severity assessment | Within **5 business days** |
| Fix development | Within **14 days** for critical issues; **30 days** for high severity |
| Coordinated public disclosure | After fix is released and deployed |
| Credit to reporter (if desired) | In the release notes and Security Advisory |

We follow a **90-day coordinated disclosure policy**. If a fix cannot be delivered within 90 days, we will notify the reporter and work together to determine an appropriate disclosure timeline.

---

## Severity Classification

We use the [CVSS v3.1](https://www.first.org/cvss/) scoring system to classify severity:

| Severity | CVSS Score | Response SLA |
|---|---|---|
| **Critical** | 9.0–10.0 | Immediate — patch within 7 days |
| **High** | 7.0–8.9 | Patch within 14 days |
| **Medium** | 4.0–6.9 | Patch within 30 days |
| **Low** | 0.1–3.9 | Addressed in next scheduled release |
| **Informational** | 0.0 | Acknowledged; addressed if feasible |

---

## Security Principles

### 1. Encryption

**In Transit:**
- All client-server communication uses **TLS 1.2+** (TLS 1.3 preferred).
- Certificate pinning is implemented in the Flutter app for the primary API endpoints.
- WebSocket connections for audio streaming use `wss://` exclusively.

**At Rest:**
- Personal profile fields are encrypted at the database level using AES-256 before storage.
- Uploaded documents are stored with server-side encryption (SSE).
- Local on-device data (cached profiles, reminders) uses Android's `EncryptedSharedPreferences` and `EncryptedFile` APIs.
- TensorFlow Lite model files are stored in internal app storage and are not world-readable.

### 2. No Credentials in Git

**Never commit to the repository:**
- API keys or tokens (Gemini, Firebase, OpenAI, etc.)
- Database passwords or connection strings
- Private keys, certificates, or `.p12`/`.jks` files
- Firebase `google-services.json` with sensitive project credentials
- Any file matching patterns in `.gitignore`

All credentials must be stored in `.env` (locally) or via CI/CD secrets (in GitHub Actions). `.env.example` must contain only placeholder values.

**If credentials are accidentally committed:**
1. Immediately revoke and rotate the leaked credential.
2. Remove from git history using `git filter-repo` (do **not** use `git filter-branch`).
3. Force-push to the remote repository.
4. Notify the security team.

### 3. Permission-Based Access

**Android Permissions:**
- Request only permissions that are strictly necessary for the feature in use.
- Use `requestPermissions()` at runtime immediately before the feature is needed, not at app launch.
- Explain the reason for each permission request in plain Malayalam and English before triggering the system dialog.
- Gracefully degrade functionality if a permission is denied; never refuse to run the app.
- Dangerous permissions required: `RECORD_AUDIO`, `CAMERA`, `READ_CONTACTS`, `BODY_SENSORS`, `ACCESS_FINE_LOCATION` (fall detection alert only).

**API Access Control:**
- All backend API endpoints (except `/health` and `/auth/register`) require a valid JWT token.
- JWT tokens have short expiry (30 minutes) with refresh token rotation.
- Caregiver access to user data requires explicit, revocable consent from the primary user.
- All access control decisions are enforced server-side; never rely on client-side checks alone.

### 4. Data Minimisation

- Collect only the personal data strictly necessary for each feature.
- Do not log personal data (names, Aadhaar numbers, health information) in application logs.
- Document storage is ephemeral by default — uploaded documents are deleted after processing unless the user explicitly chooses to retain them.
- Audio recordings for transcription are deleted from the server after the transcription is complete (within 24 hours) unless the user opts to retain them.

---

## Sensitive Data Handling Rules

### Category: Identity Documents (Aadhaar, Passports, etc.)

- Never log document content or extracted fields in plaintext server logs.
- OCR results are stored in encrypted columns in the database.
- Documents are assigned a unique UUID on upload; the original filename is not stored.
- Document files are stored in an isolated storage bucket/directory, not publicly accessible.
- Deletion requests (from user or via TTL) must result in immediate, irreversible deletion of both the file and all extracted data.

### Category: Health Data (Prescriptions, Medical Records)

- Treated as the most sensitive data category.
- Never shared with third parties without explicit informed consent.
- Reminder data includes medicine names which are considered health data.
- Access restricted to the user and explicitly approved caregivers.

### Category: Audio Recordings

- All audio captures must be clearly indicated to the user (visual recording indicator).
- Audio is transmitted over TLS and immediately discarded from device storage after upload.
- Not used for model training without explicit opt-in consent.

### Category: Sensor Data (Accelerometer, Gyroscope)

- Fall detection processing happens **on-device** using TFLite — raw sensor streams are never uploaded.
- Only fall events (timestamp, confidence score, location if permitted) are sent to the server.

### Category: Location Data

- Location is collected only at the moment of a detected fall event.
- Location is not tracked continuously or stored historically.
- Requires explicit `ACCESS_FINE_LOCATION` permission granted by the user.

---

## Audit Logging

The backend maintains an audit log of all sensitive operations:
- Login and logout events (success and failure)
- Document upload, access, and deletion
- Profile field creation and modification
- Caregiver access grants and revocations
- Emergency alert triggers

Audit logs are:
- Append-only (no updates or deletes)
- Retained for a minimum of 90 days
- Not accessible to end users directly (available to admins and during security investigations)

---

## Security Checklist for Developers

Before merging any code that touches sensitive features, verify:

- [ ] No secrets or credentials added to source code or configuration files
- [ ] New API endpoints are protected by JWT authentication middleware
- [ ] User input is validated with Pydantic schemas before processing
- [ ] SQL queries use parameterised statements (never string interpolation)
- [ ] File uploads validate MIME type and file size server-side
- [ ] New permissions requested on Android are justified in a code comment
- [ ] Personal data is not written to logs (check `logging.*` calls)
- [ ] New data storage respects the data minimisation and deletion policies
- [ ] Dependency versions are pinned and checked against known CVEs (`pip-audit`, `flutter pub outdated`)
- [ ] New encryption usage uses approved algorithms (AES-256-GCM, RSA-OAEP, bcrypt/argon2 for passwords)

---

## Acknowledgements

We thank all security researchers who responsibly disclose vulnerabilities to us. With your permission, we will credit you in our security advisories.
