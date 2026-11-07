# Two-Developer Team Coordination & Contribution Guide

We operate as an agile **Two-Developer Team**. To eliminate merge collisions and maximize velocity, module boundaries are strictly demarcated.

---

## 1. Role Allocation Matrix

| Module / Scope | Member 1 (Project Architect & Core) | Member 2 (Feature Specialist) |
|---|---|---|
| **Root & Config** | Owner (Makefile, Docker, CI) | Consumer |
| **API Contracts (`shared/`)** | Owner (OpenAPI, JSON Schema) | Reviewer / Consumer |
| **Core Framework (`app/core`)**| Owner (JWT, DB Engine, Logging) | Consumer |
| **Document OCR Engine** | Integration Reviewer | **Owner** (Tesseract, PaddleOCR) |
| **Personal Memory Module** | Schema & Migration Owner | **Owner** (UI & Services) |
| **Malayalam TTS & ASR** | Platform Channel Lead | **Owner** (AI Models & Audio Flow) |
| **Medicine Reminders** | Architecture Reviewer | **Owner** (Scheduler & Notifications) |
| **Fall & Distress Detection**| Native Service Bridge | **Owner** (Sensor Fusion Logic) |
| **Smart Autofill Service** | **Joint Co-Development** | **Joint Co-Development** |

---

## 2. Git Branch & Commit Policy
- Base branch: `develop`
- Production branch: `main`
- Naming format: `feature/<feature-name>` or `fix/<bug-name>`
- Conventional Commits:
  - `feat: add Malayalam streaming audio buffer`
  - `fix: resolve accessibility node traversal crash`
  - `docs: update database ER diagram`
