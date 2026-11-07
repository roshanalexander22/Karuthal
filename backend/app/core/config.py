"""
app/core/config.py
------------------
Application configuration loaded from environment variables / .env file
using Pydantic Settings v2.

All settings are grouped logically:
  - App metadata
  - Database
  - JWT authentication
  - File uploads
  - CORS
  - AI / LLM engine
  - Redis / cache
  - Firebase Cloud Messaging
"""

from __future__ import annotations

from functools import lru_cache
from typing import List, Optional

from pydantic import AnyHttpUrl, EmailStr, computed_field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Master settings class.  Values are read (in priority order) from:
      1. Environment variables
      2. .env file at the project root
      3. Default values defined here
    """

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )

    # ------------------------------------------------------------------
    # Application metadata
    # ------------------------------------------------------------------
    APP_NAME: str = "Sahaayi API"
    APP_ENV: str = "development"          # development | staging | production
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    LOG_LEVEL: str = "INFO"

    # ------------------------------------------------------------------
    # Database (PostgreSQL / SQLite dev fallback)
    # ------------------------------------------------------------------
    DB_HOST: str = "localhost"
    DB_PORT: int = 5432
    DB_NAME: str = "sahaayi"
    DB_USER: str = "sahaayi_user"
    DB_PASSWORD: str = "changeme"
    DATABASE_URL_OVERRIDE: Optional[str] = None
    DATABASE_URL_CONFIG: Optional[str] = None

    @computed_field  # type: ignore[misc]
    @property
    def DATABASE_URL(self) -> str:
        """Async database URL for SQLAlchemy."""
        if self.DATABASE_URL_OVERRIDE:
            return self.DATABASE_URL_OVERRIDE
        if self.DATABASE_URL_CONFIG:
            return self.DATABASE_URL_CONFIG
        return (
            f"postgresql+asyncpg://{self.DB_USER}:{self.DB_PASSWORD}"
            f"@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
        )

    @computed_field  # type: ignore[misc]
    @property
    def DATABASE_URL_SYNC(self) -> str:
        """Synchronous database URL for Alembic migrations."""
        if self.DATABASE_URL_OVERRIDE:
            return self.DATABASE_URL_OVERRIDE.replace("+asyncpg", "+psycopg2").replace("+aiosqlite", "")
        return (
            f"postgresql+psycopg2://{self.DB_USER}:{self.DB_PASSWORD}"
            f"@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
        )

    # ------------------------------------------------------------------
    # JWT Authentication
    # ------------------------------------------------------------------
    SECRET_KEY: str = "CHANGE_THIS_TO_A_LONG_RANDOM_SECRET_KEY"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # ------------------------------------------------------------------
    # File upload
    # ------------------------------------------------------------------
    UPLOAD_DIR: str = "uploads"
    MAX_UPLOAD_SIZE_MB: int = 20
    ALLOWED_MIME_TYPES: List[str] = [
        "image/jpeg",
        "image/png",
        "image/webp",
        "application/pdf",
    ]

    @computed_field  # type: ignore[misc]
    @property
    def MAX_UPLOAD_SIZE_BYTES(self) -> int:
        return self.MAX_UPLOAD_SIZE_MB * 1024 * 1024

    # ------------------------------------------------------------------
    # CORS
    # ------------------------------------------------------------------
    ALLOWED_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "http://localhost:8000",
        "http://127.0.0.1:8000",
        "http://localhost:8080",
        "http://127.0.0.1:8080",
    ]

    # ------------------------------------------------------------------
    # AI / LLM (Google Gemini & AI Engine)
    # ------------------------------------------------------------------
    AI_ENGINE_URL: str = "http://localhost:8001"
    GEMINI_API_KEY: str = ""
    GEMINI_MODEL: str = "gemini-1.5-flash"
    AI_MAX_TOKENS: int = 4096
    AI_TEMPERATURE: float = 0.2

    # ------------------------------------------------------------------
    # Redis / Cache
    # ------------------------------------------------------------------
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_DB: int = 0
    REDIS_PASSWORD: str = ""

    @computed_field  # type: ignore[misc]
    @property
    def REDIS_URL(self) -> str:
        if self.REDIS_PASSWORD:
            return (
                f"redis://:{self.REDIS_PASSWORD}@{self.REDIS_HOST}:{self.REDIS_PORT}/{self.REDIS_DB}"
            )
        return f"redis://{self.REDIS_HOST}:{self.REDIS_PORT}/{self.REDIS_DB}"

    # ------------------------------------------------------------------
    # Firebase Cloud Messaging (push notifications)
    # ------------------------------------------------------------------
    FCM_SERVER_KEY: str = ""
    FCM_API_URL: str = "https://fcm.googleapis.com/fcm/send"

    # ------------------------------------------------------------------
    # Admin / superuser (seed on first run)
    # ------------------------------------------------------------------
    FIRST_SUPERUSER_EMAIL: EmailStr = "admin@sahaayi.app"  # type: ignore[assignment]
    FIRST_SUPERUSER_PASSWORD: str = "changeme"

    # ------------------------------------------------------------------
    # Tesseract OCR
    # ------------------------------------------------------------------
    TESSERACT_CMD: str = "tesseract"       # path to binary if not on PATH
    OCR_LANGUAGES: str = "eng+mal"        # Tesseract language codes

    # ------------------------------------------------------------------
    # Celery (task queue)
    # ------------------------------------------------------------------
    CELERY_BROKER_URL: str = "redis://localhost:6379/1"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/2"

    # ------------------------------------------------------------------
    # Validators
    # ------------------------------------------------------------------
    @field_validator("ALLOWED_ORIGINS", mode="before")
    @classmethod
    def parse_origins(cls, v: object) -> List[str]:
        """Accept a comma-separated string OR a Python list."""
        if isinstance(v, str):
            return [origin.strip() for origin in v.split(",") if origin.strip()]
        return list(v)  # type: ignore[arg-type]

    @field_validator("ALLOWED_MIME_TYPES", mode="before")
    @classmethod
    def parse_mime_types(cls, v: object) -> List[str]:
        if isinstance(v, str):
            return [m.strip() for m in v.split(",") if m.strip()]
        return list(v)  # type: ignore[arg-type]


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return a cached Settings instance (singleton)."""
    return Settings()


# Module-level singleton for convenient import
settings: Settings = get_settings()
