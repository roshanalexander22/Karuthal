# Sahaayi Backend API

The backend service for **Sahaayi** — an AI-powered elder-care companion. Built with FastAPI, PostgreSQL, and SQLAlchemy, it provides REST APIs for document intelligence, personal memory, smart autofill, reminders, fall detection, transcription, and emergency response.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Web Framework | FastAPI 0.111 |
| ASGI Server | Uvicorn |
| ORM | SQLAlchemy 2.0 (async) |
| Database | PostgreSQL 15+ |
| Migrations | Alembic |
| Auth | python-jose (JWT) + passlib (bcrypt) |
| Caching | Redis |
| OCR | Tesseract via pytesseract + PyMuPDF |
| Task Queue | Celery |
| Validation | Pydantic v2 |
| Logging | structlog |

---

## Project Structure

```
backend/
├── app/
│   ├── main.py                  # FastAPI app entrypoint
│   ├── core/                    # Config, security, dependencies, exceptions
│   ├── config/                  # Database engine setup
│   ├── api/v1/                  # Versioned API router
│   ├── modules/                 # Feature modules (auth, documents, etc.)
│   │   ├── authentication/
│   │   ├── documents/
│   │   ├── personal_memory/
│   │   ├── smart_autofill/
│   │   ├── reminders/
│   │   ├── transcription/
│   │   ├── fall_detection/
│   │   ├── emergency/
│   │   └── caregiver/
│   ├── models/                  # SQLAlchemy ORM models
│   ├── services/                # Shared services (OCR, AI, files, notifications)
│   └── database/                # Alembic config & migrations
├── tests/
├── requirements.txt
└── Dockerfile
```

---

## Prerequisites

- Python 3.11+
- PostgreSQL 15+
- Redis 7+
- Tesseract OCR (`tesseract-ocr`) installed on the system
- `poppler-utils` (for PDF rendering)

---

## Setup

### 1. Clone & create virtual environment

```bash
cd backend
python -m venv .venv
# Windows
.venv\Scripts\activate
# Linux / macOS
source .venv/bin/activate
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure environment

```bash
cp .env.example .env
# Edit .env with your database credentials, JWT secret, etc.
```

### 4. Run database migrations

```bash
alembic -c app/database/alembic.ini upgrade head
```

---

## Running the Development Server

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API is now available at `http://localhost:8000`.

---

## API Documentation

| URL | Description |
|---|---|
| `http://localhost:8000/docs` | Swagger UI (interactive) |
| `http://localhost:8000/redoc` | ReDoc (read-only) |
| `http://localhost:8000/openapi.json` | Raw OpenAPI schema |

---

## Running Tests

```bash
# All tests with coverage report
pytest --cov=app --cov-report=term-missing

# Single module
pytest tests/test_auth.py -v
```

---

## Code Quality

```bash
# Lint
ruff check app/

# Format
black app/

# Type-check
mypy app/
```

---

## Docker

```bash
# Build image
docker build -t sahaayi-backend .

# Run container (requires running PostgreSQL and Redis)
docker run -p 8000:8000 --env-file .env sahaayi-backend
```

---

## Environment Variables

See `.env.example` in the project root for the full list of required variables.

Key variables:

| Variable | Description |
|---|---|
| `DATABASE_URL` | PostgreSQL async connection URL |
| `SECRET_KEY` | JWT signing secret (keep private!) |
| `REDIS_URL` | Redis connection URL |
| `GEMINI_API_KEY` | Google Gemini API key for AI features |
| `FCM_SERVER_KEY` | Firebase Cloud Messaging server key |
| `ALLOWED_ORIGINS` | Comma-separated CORS origins |
