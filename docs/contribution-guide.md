# Two-Developer Team Coordination & Responsibility Matrix

Sahaayi is built by exactly **TWO developers**. To eliminate merge conflicts and maintain strict modularity, module ownership and integration boundaries are strictly demarcated.

---

## 1. Member Ownership Matrix

### Member 1 — Project Lead, System Architect & Core Integration Engineer
**Sole Ownership:**
1. **Root Architecture**: Workspace structure, module conventions, environment configuration (`.env.example`).
2. **Git Workflow**: Branching governance, PR templates, branch protection rules, repository administration.
3. **Environment Configuration**: Multi-service environment variables, Docker Compose configuration, port orchestration.
4. **Backend Core**: FastAPI application lifecycle, security protocols, exception hierarchy, structured logging (`structlog`), CORS middleware.
5. **Authentication & Authorization**: JWT token pairs (access + refresh), session management, password hashing (bcrypt), token rotation.
6. **Database Architecture**: PostgreSQL 15 relational schema design, connection pooling (`asyncpg`), SQLite dev fallback (`aiosqlite`).
7. **Alembic Migrations**: Migration environment configuration, version tracking, automated migration generation, migration rollbacks.
8. **Shared API Contracts**: OpenAPI 3.1 specifications (`shared/api-contracts/openapi.yaml`), request/response JSON schemas, shared constants.
9. **Shared Data Models**: Cross-subsystem data structures, shared DTOs, domain interfaces.
10. **Flutter Core Architecture**: Mobile framework configuration, Riverpod 2.6 state container setup, dependency injection providers.
11. **Flutter Navigation**: GoRouter declarative route hierarchy, sub-route parameter passing, deep linking foundation.
12. **Networking Infrastructure**: Dio HTTP client (`api_client.dart`), token interception, automatic refresh logic, exponential retry policy.
13. **Android Platform-Channel Architecture**: MethodChannel and EventChannel communication contracts between Flutter and native Android.
14. **Accessibility Integration Foundation**: High-contrast theme compliance, WCAG 2.1 AA/AAA typography, native accessibility bridge.
15. **CI/CD Pipelines**: GitHub Actions workflows for backend, frontend, and AI microservice testing and static analysis.
16. **Docker Configuration**: Multi-stage Dockerfiles, Docker Compose networking, persistent volume mounts.
17. **Integration Testing**: End-to-end integration test harnesses, mock databases, cross-service sanity checks.
18. **Pull Request Review**: Code review authority for all changes submitted to `develop` and `main`.
19. **Final System Integration**: Coordinating releases, production staging, and deployment readiness.

### Member 2 — Feature Development Lead
**Feature Ownership:**
1. **Malayalam Speech Recognition**: Acoustic and language models (AI4Bharat IndicConformer / Whisper), voice command processing.
2. **Malayalam Text-to-Speech**: Speech synthesis engines (AI4Bharat Indic-TTS / DhVaani), audio playback, speech rate/pitch tuning.
3. **OCR Document Processing**: Multi-page PDF/image optical text extraction (Tesseract 5 Malayalam + English, PaddleOCR).
4. **Personal Information Extraction**: Gemini LLM structuring prompts, document entity extraction, categorization.
5. **Verified Personal Memory Feature**: Profile field review, user verification workflow, verified memory bank storage/retrieval.
6. **Medicine & Appointment Reminders**: Schedule creation, recurring dosage rules, Android AlarmManager integration, reminder acknowledgement.
7. **Audio Transcription**: Real-time WebSocket audio streaming, bilingual transcription, conversation summarization.
8. **Fall-Detection Algorithms**: Tri-axial sensor signal filtering, impact acceleration thresholds, inactivity detection, emergency countdown.
9. **Associated Flutter Feature Screens**: Presentation layer for voice assistant, document vault, reminders, transcription, and emergency hubs.
10. **Associated Backend Feature Modules**: Domain services and endpoint implementations under `/documents`, `/profile`, `/reminders`, `/transcription`, `/fall-detection`.
11. **AI Engine Implementations**: Model weight loading, GPU/CPU acceleration, inference pipelines under `ai-engine/`.
12. **Native Sensor Monitoring**: Foreground service telemetry data collection and hardware sensor event subscriptions.

### Joint Responsibility: Smart Autofill Platform
- **Member 1**: Android AccessibilityService node-tree inspection, Android AutofillService platform integration, Flutter MethodChannels, and security boundary enforcement.
- **Member 2**: Semantic form-field alignment, LLM field matching against verified personal memory, confidence scoring, and suggestion generation.
- **Joint**: End-to-end form autofill workflow, user confirmation prompt, and non-disclosure guarantees.

---

## 2. Git Branching Governance

```
main (Production / Stable Release)
  |
  └── develop (Integration Branch)
        |
        ├── feature/m1-core-architecture
        ├── feature/m1-authentication
        ├── feature/m1-api-contracts
        ├── feature/m1-database
        ├── feature/m1-flutter-core
        ├── feature/m1-android-integration
        ├── feature/m1-ci-cd
        |
        ├── feature/m2-malayalam-voice
        ├── feature/m2-document-ocr
        ├── feature/m2-personal-memory
        ├── feature/m2-reminders
        ├── feature/m2-transcription
        ├── feature/m2-fall-detection
        |
        └── feature/joint-smart-autofill
```

### Branch Rules:
1. `main` is protected; only merges from `develop` following passing CI and two-member signoff are allowed.
2. `develop` is the primary integration branch.
3. All feature branches MUST originate from `develop`.
4. Feature branches MUST be kept short-lived.
5. Never force-push (`git push --force`) to shared branches (`main`, `develop`).
6. Never delete or overwrite the other member's branches.
7. All Pull Requests must link an issue, pass automated CI checks, and obtain review approval.
