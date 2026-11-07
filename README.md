# Sahaayi (സഹായി) — AI-Powered Elderly Assistance & Accessibility Platform

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Platform: Android" />
  <img src="https://img.shields.io/badge/Flutter-3.22+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter 3.22+" />
  <img src="https://img.shields.io/badge/FastAPI-0.111+-009688?style=for-the-badge&logo=fastapi&logoColor=white" alt="FastAPI" />
  <img src="https://img.shields.io/badge/Python-3.11+-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python 3.11+" />
  <img src="https://img.shields.io/badge/PostgreSQL-15-336791?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL 15" />
  <img src="https://img.shields.io/badge/License-Apache%202.0-blue?style=for-the-badge" alt="Apache 2.0 License" />
</p>

---

## 📖 Table of Contents
1. [Overview](#-overview)
2. [Feature Implementation Status](#-feature-implementation-status)
3. [Target Audience & Problem Statement](#-target-audience--problem-statement)
4. [Full System Architecture](#-full-system-architecture)
   - [Architectural Topology](#architectural-topology)
   - [Subsystem Breakdown](#subsystem-breakdown)
   - [Component Communication Protocols](#component-communication-protocols)
5. [Accessible UI/UX Design System & Hackathon Deliverables](#-accessible-uiux-design-system--hackathon-deliverables)
   - [Color Palette Specification](#color-palette-specification)
   - [Elderly Accessibility Standards](#elderly-accessibility-standards)
   - [Screen-by-Screen Implementation](#screen-by-screen-implementation)
6. [Core Features & Technical Workflows](#-core-features--technical-workflows)
   - [Feature 1: Malayalam TTS & Screen Reading](#feature-1-malayalam-tts--screen-reading)
   - [Feature 2: OCR Document Reader & Verified Personal Memory](#feature-2-ocr-document-reader--verified-personal-memory)
   - [Feature 3: Medicine & Appointment Management](#feature-3-medicine--appointment-management)
   - [Feature 4: Intelligent Screen Understanding & Smart Autofill](#feature-4-intelligent-screen-understanding--smart-autofill)
   - [Feature 5: Low-Latency Audio Transcription & Summarization](#feature-5-low-latency-audio-transcription--summarization)
   - [Feature 6: Proactive Fall & Distress Monitoring](#feature-6-proactive-fall--distress-monitoring)
6. [Privacy, Security & Non-Negotiable Boundaries](#-privacy-security--non-negotiable-boundaries)
7. [Repository Structure](#-repository-structure)
8. [API Contract Matrix](#-api-contract-matrix)
9. [Two-Developer Team Organization & Git Workflow](#-two-developer-team-organization--git-workflow)
10. [Setup & Installation](#-setup--installation)
    - [Environment Configuration](#environment-configuration)
    - [Database Setup & Migrations](#database-setup--migrations)
    - [Backend Setup](#backend-setup)
    - [AI Engine Setup](#ai-engine-setup)
    - [Flutter & Android Client Setup](#flutter--android-client-setup)
11. [Testing & CI/CD Pipelines](#-testing--cicd-pipelines)
12. [Dependencies & Licenses](#-dependencies--licenses)
13. [Known Limitations](#-known-limitations)
14. [Roadmap](#-roadmap)

---

## 🌟 Overview

**Sahaayi** (Malayalam: **സഹായി**, meaning *"Helper"* or *"Companion"*) is an intelligent, voice-first AI assistance and accessibility platform designed for senior citizens and individuals with accessibility challenges.

By bridging modern mobile accessibility frameworks, regional Indian language speech models (primarily **Malayalam**, alongside **English**), optical document intelligence, and privacy-preserving automation, Sahaayi restores digital independence to senior citizens navigating bureaucratic paperwork, healthcare routines, daily communications, and emergency situations.

---

## 📊 Feature Implementation Status

> **Last Updated**: November 7, 2026  
> **Repository Baseline**: Commit `8ccd2a0` (Merged into `develop` & `main`)  
> **System Verification**: 14 / 14 Automated Checks Passing (`scripts/verify_all.py`)

| Feature / Subsystem | Status | Owner | Verification Evidence |
|---|---|---|---|
| **Repository Architecture & Git Governance** | **COMPLETED & VERIFIED** | Member 1 | 14 feature branches, clean trees, branch rules enforced. |
| **Backend Core Framework (FastAPI)** | **COMPLETED & VERIFIED** | Member 1 | Lifespan, CORS, logging, `/health` and `/api/v1/health` 200 OK. |
| **JWT Authentication & Password Hashing** | **COMPLETED & VERIFIED** | Member 1 | Live registration, login, refresh, `/auth/me`, native bcrypt (12 rounds). |
| **Relational Database (SQLAlchemy 2.0)** | **COMPLETED & VERIFIED** | Member 1 | 12 tables, UUID PKs, SQLite dev + PostgreSQL 15 async engines. |
| **Alembic Database Migrations** | **COMPLETED & VERIFIED** | Member 1 | Migration `001_initial_schema.py` executed cleanly, seed script verified. |
| **Shared API Contracts & Schemas** | **COMPLETED & VERIFIED** | Member 1 | OpenAPI 3.1 YAML (25 endpoints), 31 JSON schemas, shared constants. |
| **Flutter Mobile Core Infrastructure** | **COMPLETED & VERIFIED** | Member 1 | Dio `ApiClient`, JWT interceptor, `FlutterSecureStorage`, GoRouter. |
| **Flutter Accessible UI Components** | **COMPLETED & VERIFIED** | Member 1 | `AccessibleButton` (56dp min), `AccessibleTextField`, `AccessibleCard`, haptics. |
| **Flutter Static Analysis & Tests** | **COMPLETED & VERIFIED** | Member 1 | `flutter analyze` (0 issues), widget test suite passing. |
| **Android Platform Channel Bridge** | **COMPLETED & VERIFIED** | Member 1 | `FlutterChannelBridge.kt`, 5 MethodChannels, 2 EventChannels. |
| **Android Accessibility Service Foundation**| **COMPLETED & VERIFIED** | Member 1 | UI node traversal, sensitive field filter, `injectFieldValue` bridge. |
| **Android Autofill Framework Service** | **COMPLETED & VERIFIED** | Member 1 | `SahaayiAutofillService.kt` for Android 8.0+ autofill framework. |
| **Android Exact Alarm Reminders Bridge** | **COMPLETED & VERIFIED** | Member 1 | `ReminderNotificationService.kt` (AlarmManager) & `ReminderReceiver`. |
| **Smart Autofill Integration** | **COMPLETED & VERIFIED** | Joint | Semantic matcher (Malayalam/English), security filter, Flutter provider & UI. |
| **Personal Memory Bank (API & DB Engine)** | **COMPLETED & VERIFIED** | Member 1 / Member 2 | Database CRUD, verification flags, and endpoints tested; OCR sync in progress. |
| **AI Engine Microservice Foundation** | **COMPLETED & VERIFIED** | Member 1 / Member 2 | FastAPI (:8001) live healthcheck 200 OK, pytest suite passes. |
| **Automated Verification Harness** | **COMPLETED & VERIFIED** | Member 1 | `scripts/verify_all.py` (14 automated checks covering all tiers). |
| **CI/CD Pipelines (GitHub Actions)** | **COMPLETED & VERIFIED** | Member 1 | `backend-ci.yml`, `frontend-ci.yml`, `ai-engine-ci.yml` targeting `main`/`develop`. |
| **Member 2 Integration & Onboarding** | **COMPLETED & VERIFIED** | Member 1 | `docs/MEMBER_2_ONBOARDING.md` & `docs/member-2-onboarding.md`. |
| **Hackathon Accessible UI/UX Suite** | **COMPLETED & VERIFIED** | Member 1 | 10 accessible screens, light theme `#F8FAFC`/`#4EAD91`, 56dp touch targets, Malayalam typography. |
| **Malayalam Text-to-Speech (Indic-TTS)** | **IN PROGRESS / SCAFFOLDED** | Member 2 | Scaffolding in `ai-engine/text_to_speech/`, awaiting model loading. |
| **Malayalam Speech Recognition (ASR)** | **IN PROGRESS / SCAFFOLDED** | Member 2 | Scaffolding in `ai-engine/speech_recognition/`, awaiting model loading. |
| **OCR Document Reader (Tesseract 5)** | **IN PROGRESS / SCAFFOLDED** | Member 2 | Upload & status API ready; Malayalam OCR pipeline in progress. |
| **Medicine Reminders Feature Logic** | **IN PROGRESS / SCAFFOLDED** | Member 2 | Native AlarmManager ready; recurrence rule scheduler in progress. |
| **Low-Latency Audio Transcription** | **IN PROGRESS / SCAFFOLDED** | Member 2 | API routers in place; streaming STT pipeline in progress. |
| **Fall Detection Sensor Telemetry** | **IN PROGRESS / SCAFFOLDED** | Member 2 | Sensor listeners & algorithm math ready; calibration in progress. |
| **Emergency SOS & Caregiver Coordination** | **IN PROGRESS / SCAFFOLDED** | Member 2 | Schemas & router ready; SMS/Push notification dispatch in progress. |

---

## 🎯 Target Audience & Problem Statement

### The Challenge
- **Digital Divide & Cognitive Load**: Modern mobile interfaces are nested, rapidly changing, and dominated by complex English terminology, alienating older adults.
- **Form-Filling Anxiety**: Welfare schemes, pension certificates, banking applications, and insurance portals create steep barriers to entry.
- **Medication Non-Adherence**: Managing multiple daily prescriptions with complex timings leads to dangerous missed doses.
- **Physical Vulnerability & Isolation**: Accidental falls and sudden physical distress often occur when seniors are alone, with delayed emergency dispatch.

### The Sahaayi Solution
- **Voice-First Dignity**: Natural speech comprehension and speech synthesis in Malayalam and English.
- **Verified Personal Memory Bank**: Critical identity and medical documents are extracted once, user-verified, and securely stored for instant reuse.
- **Assisted Screen Understanding**: Inspects permitted on-screen forms and offers confirmed autofill suggestions—**never** auto-submitting and **never** capturing secrets.
- **Proactive Safety Net**: Tri-axial sensor monitoring detecting abrupt impacts and inactivity with an audio-visual confirmation countdown before caregiver alerting.

---

## 🏗️ Full System Architecture

Sahaayi utilizes a decoupled, microservices-oriented architecture across three distinct compute boundaries: the **Android Client Device**, the **FastAPI Cloud/Edge Backend**, and a dedicated **AI Engine Compute Microservice**.

### Architectural Topology

```
+-------------------------------------------------------------------------------+
|                              ANDROID MOBILE CLIENT                            |
|                                                                               |
|   +-----------------------------------------------------------------------+   |
|   |                         FLUTTER UI LAYER                              |   |
|   |  - Accessible Typography (18sp body floor, >= 56dp touch targets)     |   |
|   |  - Riverpod State Controllers (Unidirectional Data Flow)              |   |
|   |  - GoRouter Declarative Navigation (16 accessible routes)             |   |
|   |  - Bilingual ARB Localization (Malayalam default + English fallback)   |   |
|   +-----------------------------------+-----------------------------------+   |
|                                       |                                       |
|                            MethodChannels / EventChannels                     |
|                                       |                                       |
|   +-----------------------------------v-----------------------------------+   |
|   |                       NATIVE ANDROID KOTLIN LAYER                     |   |
|   |  - SahaayiAccessibilityService : Permitted screen node tree parsing   |   |
|   |  - SahaayiAutofillService       : Android Autofill framework integration|  |
|   |  - SensorMonitoringService      : Foreground accelerometer telemetry  |   |
|   |  - ReminderNotificationService  : Exact alarm dispatch (AlarmManager)  |   |
|   |  - FlutterChannelBridge         : Centralized platform communication  |   |
|   +-----------------------------------+-----------------------------------+   |
+---------------------------------------+---------------------------------------+
                                        |
                          HTTPS / WSS (REST & Audio Streams)
                                        |
+---------------------------------------v---------------------------------------+
|                         FASTAPI BACKEND SERVICE (:8000)                       |
|                                                                               |
|   +-----------------------------------------------------------------------+   |
|   | Core Infrastructure: Pydantic v2 Config, JWT Auth, StructLog, CORS   |   |
|   +-----------------------------------------------------------------------+   |
|   | Domain Feature Modules:                                               |   |
|   |  ├── /auth          : Registration, login, token refresh, sessions     |   |
|   |  ├── /documents     : Secure upload, metadata, OCR queue dispatch     |   |
|   |  ├── /profile       : Verified memory bank CRUD & consent management  |   |
|   |  ├── /autofill      : Form label alignment & confirmation audit       |   |
|   |  ├── /reminders     : Medication schedules & recurrence logging       |   |
|   |  ├── /transcription : Audio ingestion & transcript retrieval          |   |
|   |  ├── /fall-detection: Telemetry ingestion & false-alarm filtering    |   |
|   |  ├── /emergency     : SOS trigger & multi-channel contact broadcast   |   |
|   |  └── /caregiver     : Caregiver relationship management & consent     |   |
|   +-------------------+-------------------------------+-------------------+   |
+-----------------------+-------------------------------+-----------------------+
                        |                               |
           SQLAlchemy 2.0 (asyncpg)           Internal HTTP REST (Docker Net)
                        |                               |
+-----------------------v-------+       +---------------v-----------------------+
|    POSTGRESQL 15 DATABASE     |       |          AI ENGINE MICROSERVICE       |
|                               |       |                 (:8001)               |
|  - users & user_profiles      |       |  - ASR: IndicConformer / Whisper      |
|  - documents & document_fields|       |  - TTS: AI4Bharat Indic-TTS / DhVaani |
|  - personal_profile_fields    |       |  - OCR: Tesseract 5 (mal+eng)         |
|  - reminders & reminder_logs  |       |  - LLM: Google Gemini API (1.5 Flash) |
|  - transcriptions             |       |  - Matcher: Semantic Field Align      |
|  - fall_events & contacts     |       |  - Classifier: TFLite Fall Detector   |
|  - audit_logs compliance trail|       +---------------------------------------+
+-------------------------------+
```

---

### Subsystem Breakdown

#### 1. Mobile Client (`frontend/mobile/` & `android-native/`)
- **Flutter UI (`frontend/mobile/lib/`)**: Implements strict accessibility standards (WCAG 2.1 AA/AAA) designed for elderly users: high-contrast themes, large typography, simple single-tap interactions, and bilingual ARB string localization.
- **Android Native Services (`android-native/`)**:
  - `SahaayiAccessibilityService`: Uses Android's `AccessibilityService` API to parse visible screen hierarchies (`AccessibilityNodeInfo`) upon user request. Never inspects background apps silently and ignores password/OTP fields.
  - `SahaayiAutofillService`: Integrates with Android's Autofill Framework to populate third-party forms using user-verified profile data.
  - `SensorMonitoringService`: A foreground service with persistent notification that collects accelerometer and gyroscope data at controlled intervals.
  - `ReminderNotificationService`: Uses Android's `AlarmManager.setExactAndAllowWhileIdle()` to guarantee timely alarms even during device Doze mode.

#### 2. Backend API Service (`backend/`)
- Built with **FastAPI** (Python 3.11+) and structured into independent, domain-driven modules.
- Employs **SQLAlchemy 2.0** with `asyncpg` for non-blocking database transactions.
- Enforces strict contract boundaries using **Pydantic v2** schemas.
- Implements comprehensive security: bcrypt password hashing, JWT authentication (access + refresh tokens), role-based authorization, and an unalterable compliance audit log (`audit_logs`).

#### 3. AI Engine Microservice (`ai-engine/`)
- Decoupled from the API backend to ensure heavy machine learning computation does not degrade REST API responsiveness.
- Runs on port `8001` and encapsulates speech recognition, voice synthesis, optical character recognition, and large language model inference.

#### 4. Relational Persistence (`database/`)
- **PostgreSQL 15**: All primary keys are UUIDv4 to eliminate ID enumeration vulnerabilities.
- Stores user accounts, uploaded document metadata, raw extracted fields, verified profile memory, reminder schedules, compliance audit logs, and emergency contact relationships.
- Schema versioning is managed via **Alembic** migrations.

---

### Component Communication Protocols

| Source | Destination | Protocol | Purpose |
|---|---|---|---|
| Flutter Mobile | Android Native | Flutter `MethodChannel` | Bridge accessibility node inspection, sensor controls, and local alarms |
| Android Native | Flutter Mobile | Flutter `EventChannel` | Continuous streaming of sensor telemetry and speech recognition events |
| Flutter Mobile | Backend API | HTTPS (REST JSON) | CRUD operations, authentication, profile sync, reminder management |
| Flutter Mobile | Backend API | WSS (WebSocket) | Real-time audio streaming for low-latency transcription |
| Backend API | AI Engine | HTTP REST (Internal) | Dispatching OCR jobs, LLM extraction queries, and semantic matching |
| Backend API | PostgreSQL | PostgreSQL Wire (`asyncpg`)| Asynchronous persistence with connection pooling |
| Backend API | Redis | Redis Protocol (RESP) | Token revocation lists, session state, and job queues |

---

## 🎨 Accessible UI/UX Design System & Hackathon Deliverables

Sahaayi's mobile client features a ground-up, elderly-accessible design system crafted specifically for senior citizens and individuals with low vision, motor tremors, or digital anxiety.

### Color Palette Specification

A light, calming, high-contrast palette is enforced (`ThemeMode.light` only) to eliminate visual ambiguity and eye fatigue:

| Color Token | Hex Code | Visual Swatch | Semantic Purpose |
|---|---|---|---|
| **Background** | `#F8FAFC` | ⬜ Soft Off-White | Clean, non-glare canvas across all screens |
| **Primary** | `#4EAD91` | 🟩 Mint Green | Main actions, positive affirmations, key status pills |
| **Secondary** | `#DFF3EC` | 🟩 Pastel Mint Tint | Selected states, badge backgrounds, icon containers |
| **Accent** | `#DCEBFA` | 🟦 Soft Pastel Sky Blue | Information banners, active sensor/GPS badges |
| **Card Surface**| `#FFFFFF` | ⬜ Crisp White | Isolated, elevation-shadowed content cards (20dp radius) |
| **Main Text** | `#263238` | ⬛ Dark Charcoal | High-contrast readability for all Malayalam & English typography |
| **Secondary** | `#718096` | 🔘 Cool Slate Gray | Informative subheadings and secondary metadata |
| **Danger / SOS**| `#DC2626` | 🟥 Deep Coral Red | Emergency triggers, distress cancellations, secure logout |

### Elderly Accessibility Standards

1. **Touch Target Dimensions**: All primary buttons (`SahaayiButton`, `AccessibleButton`) strictly enforce a minimum height of **56dp** (surpassing the WCAG 48dp guideline) with generous hitboxes for users with motor tremors.
2. **Typography Floor**: Body typography begins at **18sp**, subheadings at **20sp**, and primary titles at **24sp**, using clear Malayalam rendering that eliminates script truncation and diacritic clipping.
3. **No Dark Mode Ambiguity**: Senior users frequently struggle with low-contrast dark themes; Sahaayi locks to a clean, bright, legible light theme.
4. **Card-Based Visual Hierarchy**: Screens are segmented into distinct rounded cards (`AccessibleCard`, 20dp border radius, 1.2px subtle borders) to reduce cognitive load and isolate actionable items.
5. **Multi-Modal Feedback**: Haptic pulses, voice confirmations, and high-visibility status chips accompany all interactive gestures.

### Screen-by-Screen Implementation & Complete Button Interactivity

| Screen | Route | Capabilities & Finished Interactive Actions |
|---|---|---|
| **Welcome & Login** | `/auth/login` | Sahaayi branding, large input fields, eye password toggle, instant feedback banner, wired to real JWT API. |
| **Registration** | `/auth/register` | Full name, email, phone, and password with real-time validation, error recovery, and automatic session setup. |
| **Home Dashboard** | `/` | Warm Malayalam greeting banner (*"നമസ്കാരം! ഇന്ന് സഹായി എന്തു ചെയ്യണം?"*), upcoming medicine alert card, emergency SOS quick trigger, 5 primary service cards, 4-tab bottom navigation with live routing. |
| **OCR Document Vault** | `/documents` | Categorized cards (Identity, Medical, Banking), status badges (*"ഉറപ്പിച്ചു"* / *"പരിശോധനയിൽ"*), interactive detail modal with **"വായിക്കുക (Read Aloud)"** and **"കോപ്പി ചെയ്യുക (Copy Text)"** actions. |
| **Document Upload** | `/documents/upload`| Interactive dropzone with tap-to-upload, camera photo capture, file picker, document category choice chips, and high-visibility preview. |
| **Medicine Reminders** | `/reminders` | Schedule summary card, whole-card and checkmark dose toggles marking doses taken with visual distinction and feedback, and new schedule creator. |
| **New Reminder Form** | `/reminders/new` | Medicine name, dosage, native `TimePicker` integration, meal timing chips (Before food, After food, Bedtime), form validation and immediate save. |
| **Malayalam Voice Assistant**| `/voice` | Multi-turn conversational view (user & assistant chat bubbles), interactive question chips (tapping automatically executes query), text input bar for web/typing, re-listen audio button, and 96dp animated mic toggle. |
| **Smart Autofill Assistant** | `/autofill` | Accessibility service status card, privacy guarantee note (zero passwords/OTPs), screen inspection trigger with demo simulation mode, proposed fields checklist, and confirmed form injection. |
| **Verified Memory Profile** | `/profile` | Verified identity card (*മാധവൻ നായർ, 74 yrs, Kottayam*), tap-to-edit memory dialog, **"പുതിയ വിവരം ചേർക്കുക (Add Information)"** modal sheet, clipboard copy buttons, and caregiver sync link. |
| **Emergency SOS Hub** | `/emergency` | High-visibility 190dp SOS trigger, one-tap calling buttons (Caregiver, Family Doctor, 108 Ambulance), GPS status badge, and *"ഞാൻ സുരക്ഷിതനാണ് (I am Safe)"* cancellation. |
| **Settings & Accessibility**| `/settings` | Malayalam/English language toggle, font size selector (Normal/Large/Extra Large), speech rate slider (0.85x recommended), high-contrast mode, and confirmed logout dialog. |
| **Caregiver Coordination** | `/caregiver` | Connected caregiver relationship cards, direct call simulation, permission scopes, and an interactive **"പുതിയ പരിചാരകനെ ചേർക്കുക"** bottom sheet with validation. |
| **Fall Detection Alert** | `/fall-detection`| Medical disclaimer notice, live sensor accelerometer telemetry toggle (1.02g baseline), sensitivity selector (Low/Medium/High), **"വീഴ്ച കണ്ടെത്തൽ പരീക്ഷിക്കുക (Test Fall Alert)"** simulation with 30s emergency countdown banner and cancel controls. |
| **Screen Reading (TTS)** | `/tts` | Malayalam speech synthesis playground, large text editor, read aloud and stop controls. |
| **Audio Transcription** | `/transcription` | Voice note recorder, real-time audio waveform simulation, and Malayalam AI transcript display with clipboard copy. |

---

## ⚡ Core Features & Technical Workflows

### Feature 1: Malayalam TTS & Screen Reading
- **Objective**: Voice-first screen reading with natural Malayalam and English speech synthesis.
- **Workflow**:
  1. User triggers screen reading via voice command or persistent accessibility floating pill.
  2. `SahaayiAccessibilityService` scans the active window's `AccessibilityNodeInfo` tree.
  3. Accessible labels, buttons, and text blocks are extracted (ignoring sensitive/password inputs).
  4. Text is synthesized into audio using **AI4Bharat Indic-TTS** (or on-device TTS fallback).
  5. Audio is played at an elderly-friendly cadence (0.85x speed) with pause, resume, and stop controls.

### Feature 2: OCR Document Reader & Verified Personal Memory
- **Objective**: Digitize personal identity cards, medical prescriptions, and certificates into a secure memory bank.
- **Workflow**:
  1. User photographs or uploads a document (PDF, PNG, JPEG).
  2. Backend stores the file securely with a unique UUID filename and logs an audit entry.
  3. AI Engine runs **Tesseract 5** (`mal+eng`) or **PaddleOCR** to extract raw text.
  4. Google Gemini LLM processes raw OCR text and structures it into standardized entities (Name, DOB, ID Number, Address, Dosage).
  5. **Verification Gate**: The extracted data is presented to the user in the Flutter UI as *Draft*. The user confirms or corrects each field.
  6. Only user-verified fields are saved to `personal_profile_fields` in the database.

### Feature 3: Medicine & Appointment Management
- **Objective**: Eliminate missed medications through reliable, high-priority reminders.
- **Workflow**:
  1. User creates a reminder via natural voice command (*"വൈകിട്ട് 7 മണിക്ക് പ്രഷറിന്റെ മരുന്ന് കഴിക്കാൻ ഓർമ്മിപ്പിക്കുക"*) or accessible UI.
  2. Backend parses the schedule and stores it with recurrence rules.
  3. Mobile client registers exact wakeup alarms with Android's `AlarmManager`.
  4. At trigger time, full-screen audio and vibration alerts activate.
  5. User acknowledges the dose. If unacknowledged after a configurable interval, an alert can be dispatched to registered caregivers.

### Feature 4: Intelligent Screen Understanding & Smart Autofill
- **Objective**: Assist seniors in filling digital forms across third-party apps using their verified memory bank.
- **Workflow**:
  ```
  [User opens government / banking form]
                   │
  [User explicitly taps Sahaayi Autofill Pill]
                   │
  [SahaayiAccessibilityService reads form labels] ──> (Filters out passwords/OTPs)
                   │
  [AI Engine matches labels to Verified Profile]
                   │
  [Flutter Dialog displays Proposed Field Values]
                   │
  [User Reviews & Taps "Confirm & Fill"]
                   │
  [SahaayiAutofillService populates supported fields]
                   │
  [User reviews filled form and clicks "Submit" themselves]
  ```
- **Strict Guardrails**:
  - **Never** automatically submits external forms.
  - **Never** captures, reads, stores, or fills passwords, OTPs, or CVVs.
  - **Never** invents missing values (asks the user if confidence < 0.85).

### Feature 5: Low-Latency Audio Transcription & Summarization
- **Objective**: Record doctor visits, phone conversations, or personal notes with Malayalam/English transcription.
- **Workflow**:
  1. Audio is captured via the microphone in 2-second streaming chunks.
  2. Streamed via WebSocket to the AI Engine's **IndicConformer** or **Whisper** pipeline.
  3. Transcribed text is displayed with timestamps.
  4. Upon session completion, Gemini generates a concise summary and action items in Malayalam.
  5. **Legal Notice**: Sahaayi discloses recording to all parties and does not claim to intercept cellular phone calls at the system level.

### Feature 6: Proactive Fall & Distress Monitoring
- **Objective**: Detect potential physical falls using device motion sensors and trigger safety protocols.
- **Workflow**:
  1. `SensorMonitoringService` monitors tri-axial acceleration and rotational velocity.
  2. `FallDetectionAlgorithm` calculates Signal Magnitude Area (SMA) and detects impact spikes followed by prolonged inactivity.
  3. When an event exceeds the calibrated threshold, a **30-second cancellation countdown** initiates with loud audio and haptic alarms.
  4. If the user cancels, the event is logged as a *false alarm* to refine heuristics.
  5. If uncancelled after 30 seconds, an SOS payload with GPS coordinates is dispatched to enrolled emergency contacts and caregivers.
  6. **Medical Disclaimer**: This is an experimental feature and is explicitly not a replacement for certified medical or emergency dispatch devices.

---

## 🔒 Privacy, Security & Non-Negotiable Boundaries

Sahaayi is built around strict data protection and accessibility ethics:

1. **Explicit User Consent**: Sensitive operations (reading screen content, microphone activation, caregiver access) require explicit user opt-in.
2. **Absolute Exclusion of Credentials**: Passwords, banking PINs, OTP codes, and payment credentials are programmatically ignored by both the Accessibility and Autofill services.
3. **No Automatic Form Submission**: The platform assists in filling values; the user must personally tap the final "Submit" button on third-party forms.
4. **No Silent Ambient Surveillance**: The microphone is active only during explicit user-initiated recording or voice assistant sessions.
5. **No Hallucinated Data**: If a form field cannot be matched with high confidence to verified personal memory, the system prompts the user rather than guessing.
6. **Immutable Audit Trail**: Every access, update, or deletion of personal memory fields is logged in the `audit_logs` table for full transparency.

---

## 📁 Repository Structure

```
sahaayi/
├── README.md                          # Master documentation & architecture guide
├── LICENSE                            # Apache License 2.0
├── CONTRIBUTING.md                    # Contribution workflow & commit standards
├── CODE_OF_CONDUCT.md                 # Contributor Covenant v2.1
├── SECURITY.md                        # Vulnerability disclosure policy
├── .gitignore                         # Comprehensive ignore rules
├── .env.example                       # Complete environment variable template
├── docker-compose.yml                 # Multi-service local stack
├── Makefile                           # Developer automation commands
│
├── docs/                              # Detailed technical documentation
│   ├── project-overview.md            # Vision, users, design principles
│   ├── system-architecture.md         # Architecture diagrams & component flows
│   ├── api-documentation.md           # REST API endpoint reference
│   ├── database-schema.md             # Relational DDL & ER relationships
│   ├── ai-models.md                   # Model evaluation, sources & licenses
│   ├── privacy-and-security.md        # Security principles & compliance
│   ├── accessibility-guidelines.md    # WCAG 2.1 AA/AAA design standards
│   ├── setup-guide.md                 # Step-by-step developer onboarding
│   ├── contribution-guide.md          # Two-developer team rules
│   └── development-roadmap.md         # Phase 0 through Phase 9 milestones
│
├── frontend/mobile/                   # Flutter Android client application
│   ├── pubspec.yaml                   # Dependencies & asset declarations
│   ├── l10n.yaml                      # Flutter localization configuration
│   ├── android/app/src/main/
│   │   ├── AndroidManifest.xml        # Permission declarations & services
│   │   └── kotlin/com/sahaayi/app/
│   │       └── MainActivity.kt        # Flutter MethodChannel bindings
│   ├── test/widget_test.dart          # Smoke widget tests
│   └── lib/
│       ├── main.dart                  # App entry point & Firebase init
│       ├── app/                       # App widget & accessibility theme
│       ├── core/                      # Constants, network client, channels, utils
│       ├── config/app_config.dart     # Environment configuration
│       ├── navigation/app_router.dart # GoRouter routing table
│       ├── shared/widgets/            # Reusable accessible UI components
│       ├── l10n/                      # ARB files (Malayalam & English)
│       └── features/                  # 13 modular presentation features
│
├── backend/                           # FastAPI Python backend service
│   ├── Dockerfile                     # Multi-stage production container
│   ├── requirements.txt               # Pinned Python dependencies
│   ├── app/
│   │   ├── main.py                    # Application bootstrap & CORS
│   │   ├── core/                      # Config, security, dependencies, logging
│   │   ├── config/database.py         # Async SQLAlchemy engine & session factory
│   │   ├── api/v1/router.py           # Unified v1 router aggregation
│   │   ├── models/                    # 8 SQLAlchemy ORM models
│   │   ├── modules/                   # 9 self-contained domain modules
│   │   ├── services/                  # Shared services (OCR, AI, File, Push)
│   │   └── database/                  # Alembic migration configuration
│   └── tests/                         # Pytest test suite with async fixtures
│
├── ai-engine/                         # Standalone AI compute microservice (:8001)
│   ├── Dockerfile                     # GPU/CPU container with Tesseract & FFmpeg
│   ├── requirements.txt               # AI engine dependencies
│   ├── main.py                        # FastAPI microservice entrypoint
│   ├── speech_recognition/            # Malayalam ASR (IndicConformer / Whisper)
│   ├── text_to_speech/                # Malayalam TTS (Indic-TTS / DhVaani)
│   ├── ocr/                           # Tesseract 5 & PaddleOCR wrappers
│   ├── document_extraction/           # LLM entity extraction & structuring
│   ├── llm/gemini_client.py           # Google Gemini API wrapper
│   ├── intent_detection/              # Voice command intent classifier
│   ├── semantic_matching/             # Form field alignment engine
│   ├── transcription/                 # Streaming audio transcription service
│   └── fall_detection/                # TFLite sensor fusion classifier
│
├── android-native/                    # Native Android Kotlin services
│   ├── README.md                      # Native module documentation
│   ├── accessibility_service/         # SahaayiAccessibilityService & XML config
│   ├── autofill_service/              # SahaayiAutofillService implementation
│   ├── sensor_monitoring/             # SensorMonitoringService & FallAlgorithm
│   ├── background_services/           # SahaayiBackgroundService base class
│   ├── notification_service/          # ReminderNotificationService (AlarmManager)
│   └── platform_channels/             # FlutterChannelBridge method dispatcher
│
├── database/                          # Database governance
│   ├── schemas/001_initial_schema.sql # 10 relational tables DDL
│   ├── migrations/README.md           # Migration instructions
│   └── seed/dev_seed.sql              # Sanitized test seed data
│
├── shared/                            # Single source of truth contracts
│   ├── api-contracts/openapi.yaml     # OpenAPI 3.1.0 specification
│   ├── data-models/                   # JSON schemas for data entities
│   └── constants/                     # Document categories & language codes
│
├── scripts/                           # Developer automation scripts
│   ├── setup.sh                       # Environment setup script
│   ├── dev.sh                         # Parallel dev server launcher
│   ├── test.sh                        # Unified test runner
│   └── lint.sh                        # Code quality & formatting checker
│
└── .github/                           # CI/CD and repository health
    ├── PULL_REQUEST_TEMPLATE.md       # Standardized PR checklist
    ├── ISSUE_TEMPLATE/                # Bug report & feature request templates
    └── workflows/                     # GitHub Actions (Backend & Frontend CI)
```

---

## 📋 API Contract Matrix

The backend exposes a standardized RESTful API under `/api/v1`. Private endpoints enforce Bearer JWT authentication.

| Domain | Method | Endpoint | Description |
|---|---|---|---|
| **Auth** | `POST` | `/api/v1/auth/register` | Register a new user account |
| **Auth** | `POST` | `/api/v1/auth/login` | Authenticate and obtain JWT token pair |
| **Auth** | `POST` | `/api/v1/auth/refresh` | Refresh an expired access token |
| **Auth** | `POST` | `/api/v1/auth/logout` | Invalidate the current session |
| **Documents** | `POST` | `/api/v1/documents/upload` | Multipart upload (PDF, PNG, JPEG) |
| **Documents** | `GET` | `/api/v1/documents` | List all user documents |
| **Documents** | `GET` | `/api/v1/documents/{id}` | Get document metadata & OCR status |
| **Documents** | `DELETE`| `/api/v1/documents/{id}` | Securely purge a document |
| **Documents** | `POST` | `/api/v1/documents/{id}/extract`| Trigger asynchronous OCR & LLM extraction |
| **Memory** | `GET` | `/api/v1/profile` | Retrieve verified personal memory bank |
| **Memory** | `PATCH`| `/api/v1/profile` | Add or update a verified profile field |
| **Memory** | `DELETE`| `/api/v1/profile/field/{name}` | Delete a personal profile field |
| **Autofill** | `POST` | `/api/v1/autofill/match` | Match screen form labels to verified memory |
| **Autofill** | `POST` | `/api/v1/autofill/confirm` | Confirm user review before field injection |
| **Reminders** | `POST` | `/api/v1/reminders` | Create medication or appointment schedule |
| **Reminders** | `GET` | `/api/v1/reminders` | List active reminders |
| **Reminders** | `PATCH`| `/api/v1/reminders/{id}` | Update reminder time or acknowledgement |
| **Reminders** | `DELETE`| `/api/v1/reminders/{id}` | Remove a reminder schedule |
| **Transcription**| `POST` | `/api/v1/transcription/start` | Initialize streaming transcription session |
| **Transcription**| `POST` | `/api/v1/transcription/upload`| Upload audio file for batch transcription |
| **Transcription**| `GET` | `/api/v1/transcription/{id}` | Retrieve transcript and AI summary |
| **Fall Detection**| `POST` | `/api/v1/fall-detection/events` | Log sensor event and potential fall |
| **Emergency** | `POST` | `/api/v1/emergency/trigger` | Dispatch emergency SOS alert to contacts |
| **Caregiver** | `GET` | `/api/v1/caregiver` | List authorized caregivers |
| **Health** | `GET` | `/health` | Service healthcheck probe |

Full OpenAPI 3.1.0 specification: [`shared/api-contracts/openapi.yaml`](shared/api-contracts/openapi.yaml)

---

## 👥 Two-Developer Team Organization & Git Workflow

To enable high velocity without merge conflicts, the codebase is partitioned between two developers:

```
+--------------------------------------------------------------------------------+
|                         TWO-DEVELOPER TEAM ALLOCATION                          |
+--------------------------------------------------------------------------------+
|  MEMBER 1 (Project Lead & Core Integration)                                    |
|  ├── Root Architecture, .env.example, Makefile, Docker Compose                 |
|  ├── Core Backend Framework: backend/app/core/ & backend/app/config/           |
|  ├── Database Architecture: Schemas, Alembic Migrations, Seeds                 |
|  ├── Shared Contracts: OpenAPI 3.1 & JSON Schemas in shared/                   |
|  ├── Flutter Core: Networking, GoRouter Navigation, Accessible Theme           |
|  ├── Platform Channel Architecture: android-native/platform_channels/          |
|  └── CI/CD Pipelines & PR Reviews on develop and main                          |
+--------------------------------------------------------------------------------+
|  MEMBER 2 (Feature Development Lead)                                           |
|  ├── AI Engine: Malayalam ASR (IndicConformer) & TTS (Indic-TTS / DhVaani)     |
|  ├── OCR Pipeline: Tesseract Malayalam & Document Extraction                  |
|  ├── Backend Feature Modules: documents, reminders, transcription, fall_alert  |
|  ├── Mobile Feature UI: Document Reader, Personal Memory, Reminders, Voice     |
|  └── Native Sensors: SensorMonitoringService.kt telemetry & fall detection    |
+--------------------------------------------------------------------------------+
|  JOINT CO-DEVELOPMENT                                                          |
|  └── Feature 4: Smart Autofill Platform (Accessibility Node Tree ↔ LLM Matcher)|
+--------------------------------------------------------------------------------+
```

### Git Branching Rules
1. `main` is protected and always holds stable, release-ready code.
2. `develop` is the primary integration branch.
3. Every feature is developed in an isolated branch (`feature/<feature-name>`).
4. Merges into `develop` require a pull request, passing CI, and review.
5. Conventional commit format: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.

```bash
# Workflow example:
git checkout develop
git checkout -b feature/document-ocr
# ... develop feature ...
git commit -m "feat: implement Tesseract OCR pipeline with Malayalam support"
git push -u origin feature/document-ocr
# -> Open Pull Request into develop
```

---

## 🚀 Setup & Installation

### Prerequisites
- **Flutter SDK**: 3.22.x or newer
- **Python**: 3.11.x or newer
- **Android Studio**: Android SDK Platform 34 (Upside Down Cake)
- **Docker & Docker Compose**: v2.20+ (recommended for full stack)

### 1. Clone & Configure Environment
```bash
git clone https://github.com/roshanalexander22/Karuthal.git
cd Karuthal
cp .env.example .env
# Edit .env with your GEMINI_API_KEY and database credentials
```

### 2. Run Entire Stack with Docker
```bash
docker compose up -d
# Backend:    http://localhost:8000
# AI Engine:  http://localhost:8001
# PostgreSQL: localhost:5432
# Redis:      localhost:6379
```

### 3. Native Local Development

#### Backend (FastAPI)
```bash
cd backend
python -m venv venv
# Linux/macOS:
source venv/bin/activate
# Windows:
venv\Scripts\activate
pip install -r requirements.txt
alembic upgrade head
uvicorn app.main:app --port 8000 --reload
```

#### AI Engine Microservice
```bash
cd ai-engine
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
uvicorn main:app --port 8001 --reload
```

#### Flutter Mobile Client
```bash
cd frontend/mobile
flutter pub get
flutter run
```

---

## 🧪 Testing & CI/CD Pipelines

Automated GitHub Actions run on every push and pull request to `main` and `develop`:

- **Backend CI (`.github/workflows/backend-ci.yml`)**:
  - Sets up Python 3.11 with a PostgreSQL 15 service container.
  - Runs code formatting and lint checks using `ruff`.
  - Executes unit and integration tests using `pytest tests/ -v`.
- **Frontend CI (`.github/workflows/frontend-ci.yml`)**:
  - Sets up Java 17 and Flutter stable channel.
  - Runs static analysis with `flutter analyze` (Zero warnings/errors policy).
  - Runs widget and component tests with `flutter test`.
- **AI Engine CI (`.github/workflows/ai-engine-ci.yml`)**:
  - Sets up Python 3.11, installs AI microservice requirements.
  - Runs ruff linting and microservice health & route unit tests.

### System Verification Harness
A comprehensive automated test harness validates the entire multi-subsystem stack:
```bash
python scripts/verify_all.py
```

| Verification Check | Target Component | Status |
|---|---|---|
| **Backend Unit Tests** | `backend/` pytest (auth, profile, autofill, health) | **PASSED ✓** |
| **AI Engine Unit Tests** | `ai-engine/` pytest (health & routes) | **PASSED ✓** |
| **Backend Live Health** | `GET http://127.0.0.1:8000/health` | **PASSED ✓** |
| **Backend v1 Live Health**| `GET http://127.0.0.1:8000/api/v1/health` | **PASSED ✓** |
| **AI Engine Live Health** | `GET http://127.0.0.1:8001/health` | **PASSED ✓** |
| **Live User Registration** | `POST /api/v1/auth/register` | **PASSED ✓** |
| **Live User Authentication** | `POST /api/v1/auth/login` | **PASSED ✓** |
| **Live Protected /me Endpoint** | `GET /api/v1/auth/me` | **PASSED ✓** |
| **Live Memory Bank Upsert** | `PATCH /api/v1/profile` | **PASSED ✓** |
| **Live Memory Bank Retrieval** | `GET /api/v1/profile` | **PASSED ✓** |
| **Smart Autofill Semantic Match** | `POST /api/v1/autofill/match` (Malayalam & English) | **PASSED ✓** |
| **Smart Autofill Audit Log** | `POST /api/v1/autofill/confirm` | **PASSED ✓** |
| **Flutter Static Analysis** | `frontend/mobile` (0 errors, 0 warnings) | **PASSED ✓** |
| **Flutter Widget Tests** | `frontend/mobile` widget test suite | **PASSED ✓** |

```bash
# Run tests locally:
make test-backend    # Runs backend pytest
make test-frontend   # Runs flutter test
make lint-backend    # Runs ruff checks
make lint-frontend   # Runs flutter analyze
```

---

## 📦 Dependencies & Licenses

| Component | Library | License | Notes |
|---|---|---|---|
| **Backend** | FastAPI, Uvicorn, SQLAlchemy | MIT / BSD | Permissive commercial use |
| **Backend** | pytesseract, Pillow, structlog | Apache 2.0 / HPND / MIT | Permissive commercial use |
| **Backend** | **PyMuPDF** | **AGPL-3.0** | ⚠️ If distributed as SaaS, review AGPL copyleft requirements or substitute with `pypdfium2` (Apache 2.0) |
| **Mobile** | Flutter SDK, Dart | BSD | Permissive commercial use |
| **Mobile** | flutter_riverpod, go_router, dio | MIT / BSD | Permissive commercial use |
| **Mobile** | flutter_tts, permission_handler | BSD / MIT | Permissive commercial use |
| **AI Models** | AI4Bharat IndicConformer & Indic-TTS | MIT | Permissive regional speech models |
| **AI Models** | OpenAI Whisper & whisper.cpp | MIT | Permissive speech recognition |
| **AI Models** | Tesseract OCR & Sherpa-ONNX | Apache 2.0 | Permissive OCR & inference engines |
| **AI Models** | Project Vaani (IISc Bangalore) | Custom/Research | Review IISc terms before commercial distribution |
| **AI Models** | Google Gemini API | Commercial API | Terms governed by Google Cloud / AI Studio |
| **Android** | Android Accessibility & Autofill APIs | Apache 2.0 | Android Open Source Project |

---

## ⚠️ Known Limitations

1. **Android Accessibility Permission Gate**: Due to Android platform security policies, the accessibility service cannot be enabled silently or programmatically. The user must manually enable Sahaayi in *Android Settings > Accessibility*.
2. **Strict Security Filtering**: In compliance with privacy regulations, sensitive input types (passwords, PINs, OTPs, CVVs, debit/credit cards) are completely blocked from being read, parsed, or autofilled.
3. **No Automatic Form Submission**: To protect senior citizens from unintended transactions or submissions, Sahaayi only injects verified field values; the user must explicitly review and tap the final submission button themselves.
4. **AI Engine Compute Resource Requirements**: High-fidelity Malayalam speech synthesis and recognition require adequate CPU/GPU capacity on the AI Engine (:8001); on resource-constrained devices, on-device Android TTS acts as a low-latency fallback.
5. **Experimental Sensor Fall Detection**: Acceleration and gyroscope telemetry heuristic thresholds are calibrated for general falls; it is explicitly not a replacement for certified medical-grade alarm hardware.

---

## 🗺️ Roadmap

- [x] **Phase 0: Architecture & Foundation (Completed & Verified)**
  - Full root directory scaffolding, 196 verified files, and modular separation.
  - Shared OpenAPI 3.1 contract and relational PostgreSQL DDL.
  - CI/CD workflows and multi-service Docker configuration.
- [x] **Phase 1: Core Implementation & Mobile Integration Foundation (Completed & Verified)**
  - End-to-end JWT registration, login, token refresh, and user profile (`/auth/me`).
  - All 12 SQLAlchemy 2.0 ORM models and Alembic baseline migration (`001_initial_schema`).
  - Dual-engine compatibility: PostgreSQL 15 + SQLite dev-mode fallback.
  - Complete 25-endpoint OpenAPI 3.1 YAML and 31 Pydantic JSON schemas.
  - Flutter accessible widget suite (`AccessibleButton`, `AccessibleTextField`, `AccessibleCard`, `AudioControlWidget`, `ConfirmationDialog`).
  - Android native Kotlin services wired to `FlutterChannelBridge` with `injectFieldValue` and `EventChannel` streaming.
  - Smart Autofill joint foundation: Malayalam/English semantic matcher, security filtering, compliance audit logging, and Flutter confirmation UI.
  - Member 2 onboarding guide (`docs/MEMBER_2_ONBOARDING.md`) and 14-branch Git architecture.
- [ ] **Phase 2: Document OCR & Verified Memory Bank (Member 2)**
  - Tesseract Malayalam language integration and prescription parsing.
  - Interactive field verification interface in Flutter.
- [ ] **Phase 3: Malayalam Voice Assistant & TTS**
  - Integration of Indic-TTS and streaming voice comprehension.
  - Android AccessibilityService screen reading platform channel bridge.
- [ ] **Phase 4: Medicine Reminders & Caregiver Sync**
  - Exact alarms via Android `AlarmManager` and missed-dose escalation.
- [ ] **Phase 5: Smart Autofill Platform (Joint Co-Development)**
  - Accessible form inspection, semantic label matching, and confirmed injection.
- [ ] **Phase 6: Low-Latency Audio Transcription**
  - Streaming audio WebSocket pipeline with doctor-visit summarization.
- [ ] **Phase 7: Sensor-Based Fall Detection (Experimental)**
  - TFLite accelerometer heuristic refinement and false-positive countdown.
- [ ] **Phase 8: Caregiver & Emergency Portal**
  - One-tap SOS broadcast with location sharing and consent-based dashboard.
- [ ] **Phase 9: Field Testing & Accessibility Hardening**
  - Usability trials with senior citizens in Kerala and performance optimization.

---

<p align="center">
  <b>Sahaayi (സഹായി)</b> — Built with care for the elderly communities of Kerala and beyond.
</p>
