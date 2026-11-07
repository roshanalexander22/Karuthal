# Sahaayi System Architecture

## 1. High-Level Architectural Diagram

```
       +-----------------------------------------------------------+
       |                      ANDROID CLIENT                       |
       |                                                           |
       |   +---------------------------------------------------+   |
       |   |             Flutter UI & Business Logic           |   |
       |   |  - Voice Assistant Screen     - Document Vault    |   |
       |   |  - Smart Autofill Prompt      - Medicine Alarms   |   |
       |   |  - SOS / Distress Hub         - Caregiver Portal  |   |
       |   +---------------------------------------------------+   |
       |                             |                             |
       |                 MethodChannel / EventChannel              |
       |                             |                             |
       |   +-------------------------+-------------------------+   |
       |   |                Android Native Layer               |   |
       |   |  - SahaayiAccessibilityService (Screen Reading)   |   |
       |   |  - SahaayiAutofillService (Secure Input Filling)  |   |
       |   |  - SensorMonitoringService (Accelerometer / Gyro) |   |
       |   |  - ReminderNotificationService (Exact Alarms)     |   |
       |   +---------------------------------------------------+   |
       +-----------------------------+-----------------------------+
                                     |
                          HTTPS / WSS (REST & Audio Streams)
                                     |
       +-----------------------------v-----------------------------+
       |                   FASTAPI BACKEND (Port 8000)             |
       |                                                           |
       |  +-----------------------------------------------------+  |
       |  | Core & Middleware: JWT Auth, CORS, Audit Logger     |  |
       |  +-----------------------------------------------------+  |
       |  | Feature Modules:                                    |  |
       |  |  - Auth         - Documents        - Personal Memory|  |
       |  |  - Autofill     - Reminders        - Transcription  |  |
       |  |  - Fall Alert   - Emergency Notify - Caregiver Sync |  |
       |  +-----------------------------------------------------+  |
       +--------------+-----------------------------+--------------+
                      |                             |
        SQLAlchemy Async (pg)            Internal HTTP / gRPC
                      |                             |
       +--------------v-----------+   +-------------v--------------+
       |  PostgreSQL 15 Database  |   |   AI ENGINE (Port 8001)    |
       |  - Users & Profiles      |   |  - IndicConformer / Whisper|
       |  - Document Metadata     |   |  - Indic-TTS / DhVaani     |
       |  - Encrypted Memory Bank |   |  - Tesseract / PaddleOCR   |
       |  - Reminders & Logs      |   |  - Gemini Intent & Matcher |
       |  - Audit Trail           |   |  - TFLite Fall Classifier  |
       +--------------------------+   +----------------------------+
```

---

## 2. Subsystem Descriptions

### A. Flutter Mobile Frontend
Built using **Flutter 3.22+** with **Riverpod 2.5** for deterministic unidirectional data flow and state management. Adheres strictly to WCAG 2.1 AA/AAA accessibility guidelines, with high-contrast themes, dynamic font scaling, and semantic labels.

### B. Android Native Integration
Native Kotlin services interact with low-level Android frameworks:
- `SahaayiAccessibilityService`: Interrogates accessible window hierarchies (`AccessibilityNodeInfo`) upon user request. Never inspects password fields or silent background apps.
- `SahaayiAutofillService`: Integrates with the official Android Autofill Framework to populate form fields securely.
- `SensorMonitoringService`: Foreground service monitoring tri-axial acceleration and rotational velocity.

### C. FastAPI Backend
Asynchronous Python 3.11 backend organized into self-contained domain modules. Utilizes Pydantic v2 schemas for rigorous request/response contracts and SQLAlchemy 2.0 with `asyncpg` for PostgreSQL transactions.

### D. AI Engine Microservice
Dedicated compute service housing heavy AI pipelines:
- **Speech Recognition**: Malayalam acoustic models (AI4Bharat IndicConformer, OpenAI Whisper).
- **TTS Synthesis**: AI4Bharat Indic-TTS and IISc DhVaani.
- **OCR Engine**: Tesseract OCR Malayalam (`mal.traineddata`) and English (`eng.traineddata`).
- **Semantic Structuring**: Google Gemini models for entity extraction, semantic field alignment, and natural language summarization.

---

## 3. Communication Protocols
- **Client to Backend**: RESTful JSON over TLS 1.3. Real-time audio streaming uses WebSockets (`/api/v1/transcription/stream`).
- **Flutter to Native Kotlin**: Standard Flutter `MethodChannel` (`sahaayi/accessibility`, `sahaayi/autofill`, `sahaayi/sensors`) and `EventChannel` for continuous sensor telemetry.
- **Backend to AI Engine**: Private Docker network HTTP POST with payload caching in Redis.
