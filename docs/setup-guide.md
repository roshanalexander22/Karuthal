# Developer Environment Setup Guide

## 1. Prerequisites
- **Operating System**: Linux (Ubuntu 22.04+), macOS (13+), or Windows 11 with WSL2.
- **Python**: 3.11.x
- **Flutter SDK**: 3.22.x (Channel: Stable)
- **Android Studio**: Iguana or newer with Android SDK Platform 34
- **Docker & Docker Compose**: v2.20+
- **PostgreSQL Client / psql** (Optional for local query debugging)

---

## 2. Quickstart with Docker Compose
```bash
# Clone the repository
git clone https://github.com/organization/sahaayi.git
cd sahaayi

# Copy environment template
cp .env.example .env

# Spin up PostgreSQL, Redis, Backend, and AI Engine
docker compose up -d

# Verify services
curl http://localhost:8000/api/v1/health
```

---

## 3. Local Native Development

### Backend (FastAPI)
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt

# Run migrations
alembic upgrade head

# Start development server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### AI Engine
```bash
cd ai-engine
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```

### Flutter Mobile App
```bash
cd frontend/mobile
flutter pub get
flutter run
```
