# Welcome Member 2: Feature Development Lead Onboarding Guide

Welcome to **Sahaayi (സഹായി)**!

As **Member 2**, you are the **Feature Development Lead**. You own the high-impact intelligent capabilities that senior citizens in Kerala interact with daily:
- Regional Malayalam Speech Recognition (ASR) & Text-to-Speech (TTS)
- Document OCR & Personal Information Extraction
- Verified Memory Bank & Profile Management
- Medicine Reminders & Exact Alarm Scheduling
- Audio Transcription & Fall Detection Algorithms

This guide provides everything you need to start implementing features smoothly alongside **Member 1 (System Architect & Integration Lead)**.

---

## 1. Quick Local Environment Setup

### Prerequisites
- **Python 3.11+**
- **Flutter 3.22+** (with Android SDK 33+)
- **Git**

### Clone & Branch Setup
```bash
# Clone the repository
git clone https://github.com/roshanalexander22/Karuthal.git
cd Karuthal

# Ensure you have the latest develop branch
git checkout develop
git pull origin develop
```

### Starting the Local Backend & AI Engine
You do NOT need Docker to develop features locally. Member 1 has provided SQLite development fallbacks and pre-configured servers:

```bash
# Terminal 1: Start FastAPI Backend (:8000)
cd backend
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload

# Terminal 2: Start AI Engine (:8001)
cd ai-engine
python -m uvicorn main:app --host 127.0.0.1 --port 8001 --reload

# Terminal 3: Seed Sample Data
python scripts/seed_database.py
```

Verify in your browser:
- Backend Health: `http://127.0.0.1:8000/health`
- Backend Swagger: `http://127.0.0.1:8000/docs`
- AI Engine Health: `http://127.0.0.1:8001/health`

---

## 2. Your Feature Branches

All your work must originate from `develop` on dedicated feature branches:

| Feature | Your Dedicated Branch |
|---|---|
| Malayalam TTS & Voice | `feature/m2-malayalam-voice` |
| Document OCR Extraction | `feature/m2-document-ocr` |
| Verified Memory Bank | `feature/m2-personal-memory` |
| Medication Reminders | `feature/m2-reminders` |
| Audio Transcription | `feature/m2-transcription` |
| Fall Detection Logic | `feature/m2-fall-detection` |
| Smart Autofill (Joint) | `feature/joint-smart-autofill` |

---

## 3. Strict Boundary Matrix: What to Touch vs. What NEVER to Touch

### ✅ Files & Folders You Own (Modify Freely):
- `ai-engine/` (All model inference code, TTS, ASR, OCR, TFLite models)
- `backend/app/modules/documents/` (OCR upload & structuring logic)
- `backend/app/modules/personal_memory/` (Memory bank CRUD & verification)
- `backend/app/modules/reminders/` (Medication scheduling logic)
- `backend/app/modules/transcription/` (Speech-to-text endpoints)
- `backend/app/modules/fall_detection/` (Sensor telemetry logic)
- `frontend/mobile/lib/features/` (Voice assistant, OCR vault, reminders, transcription screens)
- `frontend/mobile/lib/l10n/` (Adding Malayalam/English translation strings)

### ❌ Files You Must NEVER Modify Directly (Owned by Member 1):
- `backend/app/core/` (`config.py`, `security.py`, `dependencies.py`, `exceptions.py`)
- `backend/app/config/` (`database.py`)
- `backend/app/database/migrations/` (Alembic environment & migrations)
- `backend/app/models/` (SQLAlchemy 2.0 ORM models)
- `shared/api-contracts/` & `shared/schemas/` (Submit PR if contracts need changes)
- `frontend/mobile/lib/core/` (Network interceptors, theme system, core constants)
- `frontend/mobile/lib/navigation/` (`app_router.dart`)
- `.github/workflows/` (CI/CD pipelines)
- `docker-compose.yml` & `Dockerfile`

*Note: If you need a new database column or shared API endpoint, notify Member 1. Member 1 will generate the Alembic migration and update the shared contract for you!*

---

## 4. Step-by-Step Guide for Your First Feature: Malayalam Text-to-Speech

1. **Checkout your feature branch**:
   ```bash
   git checkout feature/m2-malayalam-voice
   ```
2. **Review Member 1's shared UI widgets**:
   - `frontend/mobile/lib/shared/widgets/audio_control_widget.dart` (Play/Pause/Speed)
   - `frontend/mobile/lib/shared/widgets/accessible_button.dart`
3. **Implement Malayalam synthesis in `ai-engine/text_to_speech/`**:
   - Add your acoustic model or AI4Bharat Indic-TTS wrapper.
4. **Wire Flutter TTS Service**:
   - Call the local endpoint from `frontend/mobile/lib/features/text_to_speech/services/tts_service.dart`.
5. **Run tests & verification**:
   ```bash
   cd ai-engine && pytest
   cd ../frontend/mobile && flutter test && flutter analyze
   ```
6. **Open a Pull Request into `develop`**:
   - Use `.github/PULL_REQUEST_TEMPLATE.md` to document your changes.
   - Member 1 will review and merge into `develop`!
