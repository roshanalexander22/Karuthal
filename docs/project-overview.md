# Sahaayi (സഹായി) — Project Overview

## 1. Executive Summary
**Sahaayi** (Malayalam for *Helper/Companion*) is an intelligent, voice-first AI assistance and accessibility platform designed specifically for the elderly and individuals with accessibility challenges.

By bridging modern mobile accessibility frameworks, regional language voice models (primarily Malayalam, alongside English), and secure document extraction, Sahaayi restores digital independence to senior citizens navigating bureaucratic paperwork, medical routines, daily communications, and emergency situations.

---

## 2. Target Audience & Problem Statement
### The Challenge
- **Digital Literacy & Cognitive Load**: Complex mobile interfaces, nested menus, tiny touch targets, and English-dominated terminology alienate senior citizens.
- **Form Filling Anxiety**: Government pension applications, welfare programs, insurance reimbursements, and banking forms are demanding and error-prone.
- **Medication Adherence**: Seniors managing multiple chronic prescriptions struggle with timing, missed dosages, and reading prescription labels.
- **Physical Vulnerability**: Accidental falls and sudden distress often occur when individuals are alone at home.

### The Sahaayi Solution
- **Voice-First Interaction**: Natural speech comprehension and speech synthesis in Malayalam and English.
- **Verified Personal Memory**: Personal documents (Aadhaar, Election ID, Ration Card, Prescriptions, Bank Passbooks) are read via OCR, structured via LLM, and verified by the user once—then securely reused.
- **Intelligent Screen Autofill**: Assistance in filling digital forms across third-party applications without ever capturing passwords or auto-submitting.
- **Safety Net**: Fall & distress detection fusing device accelerometer, gyroscope, and acoustic distress signals with immediate caregiver alerting.

---

## 3. Core Architectural Pillars
1. **Accessibility by Default**: Minimal cognitive load, high contrast, large typography, and zero hidden gestures.
2. **Privacy & Consent First**: Zero cloud upload of unverified sensitive OCR data without explicit user confirmation. No covert background monitoring.
3. **Regional Language Prioritization**: Deep native support for Malayalam linguistic nuance, colloquial phrasing, and code-mixed (Manglish) inputs.
4. **Resilient Offline Fallbacks**: Local on-device TTS, cached personal profile fields, and rule-based emergency triggers when disconnected.
5. **Team Modular Separation**: Independent contracts enabling a 2-developer team to progress simultaneously without merge conflicts.

---

## 4. Technology Stack Summary
| Layer | Technologies |
|---|---|
| **Mobile Client** | Flutter 3.22+ (Dart), Android SDK 34+ (Kotlin Services) |
| **Backend API** | Python 3.11, FastAPI, Pydantic v2, SQLAlchemy 2.0 (Async) |
| **Database & Cache** | PostgreSQL 15, Redis 7 (Tokens & Job State) |
| **AI Microservices** | IndicConformer / Whisper (ASR), Indic-TTS / DhVaani (TTS), Tesseract 5 / PaddleOCR, Google Gemini Flash / Pro (Structuring & Intent) |
| **DevOps & CI** | Docker, Docker Compose, GitHub Actions, Alembic |
