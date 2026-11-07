# ============================================================
# Sahaayi Backend — Multi-stage Production Dockerfile
# ============================================================

# ------------------------------------------------------------------
# Stage 1: Builder — install Python dependencies
# ------------------------------------------------------------------
FROM python:3.11-slim AS builder

WORKDIR /build

# Install build tools needed for some packages (e.g. cryptography)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first to leverage Docker layer caching
COPY requirements.txt .

RUN pip install --upgrade pip \
    && pip install --no-cache-dir --prefix=/install -r requirements.txt


# ------------------------------------------------------------------
# Stage 2: Runtime — lean production image
# ------------------------------------------------------------------
FROM python:3.11-slim AS runtime

# Metadata labels
LABEL maintainer="Sahaayi Team"
LABEL description="Sahaayi Elder-Care AI — FastAPI backend"
LABEL version="1.0.0"

# ---- System dependencies ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    # OCR engine
    tesseract-ocr \
    tesseract-ocr-eng \
    tesseract-ocr-mal \
    # PDF rasterisation (used by PyMuPDF / poppler tools)
    poppler-utils \
    # libmagic for python-magic file type detection
    libmagic1 \
    # Healthcheck helper
    curl \
    && rm -rf /var/lib/apt/lists/*

# ---- Copy installed Python packages from builder ----
COPY --from=builder /install /usr/local

# ---- Create non-root user ----
RUN groupadd --gid 1001 sahaayi \
    && useradd --uid 1001 --gid sahaayi --shell /bin/bash --create-home sahaayi

# ---- App directory ----
WORKDIR /app

# Copy application source
COPY --chown=sahaayi:sahaayi . /app

# Create directories the app needs at runtime
RUN mkdir -p /app/uploads /app/logs \
    && chown -R sahaayi:sahaayi /app/uploads /app/logs

# Switch to non-root user
USER sahaayi

# Expose application port
EXPOSE 8000

# ---- Health check ----
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# ---- Entrypoint ----
# Use exec form to receive OS signals properly
CMD ["uvicorn", "app.main:app", \
     "--host", "0.0.0.0", \
     "--port", "8000", \
     "--workers", "2", \
     "--log-level", "info", \
     "--no-access-log"]
