"""
app/main.py
-----------
FastAPI application entry point for the Sahaayi Elder-Care AI backend.

Responsibilities:
- Create and configure the FastAPI application instance.
- Register CORS middleware.
- Manage database / cache lifecycle via the lifespan context manager.
- Mount all versioned API routers.
- Register global exception handlers.
- Expose health-check and root discovery endpoints.
"""

from __future__ import annotations

import logging
import time
import uuid
from contextlib import asynccontextmanager
from typing import AsyncGenerator

from fastapi import FastAPI, HTTPException, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import ValidationError

from app.api.v1.router import api_router
from app.config.database import engine
from app.core.config import settings
from app.core.exceptions import SahaayiException
from app.core.logging import configure_logging

# ---------------------------------------------------------------------------
# Module-level logger
# ---------------------------------------------------------------------------
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Lifespan — startup / shutdown logic
# ---------------------------------------------------------------------------
@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:  # noqa: ARG001
    """
    Manage application lifecycle events.

    On startup:
      - Configure structured logging.
      - Verify database connectivity.

    On shutdown:
      - Dispose the database engine connection pool.
    """
    # ---- Startup ----
    configure_logging()
    logger.info("Sahaayi API starting up …")
    logger.info("Environment: %s", settings.APP_ENV)

    # Verify DB connectivity, auto-fallback to SQLite if Postgres unreachable, and seed dev data
    from app.config.database import ensure_database_connected
    await ensure_database_connected()

    logger.info("Sahaayi API is ready.")

    yield  # Application runs here

    # ---- Shutdown ----
    logger.info("Sahaayi API shutting down …")
    from app.config.database import engine
    await engine.dispose()
    logger.info("Database engine disposed. Goodbye.")


# ---------------------------------------------------------------------------
# Application factory
# ---------------------------------------------------------------------------
def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    application = FastAPI(
        title="Sahaayi API",
        version="1.0.0",
        description=(
            "Sahaayi is an AI-powered elder-care companion. "
            "This API provides document intelligence, personal memory management, "
            "smart autofill, medication reminders, fall detection, medical "
            "transcription, and emergency response services."
        ),
        contact={
            "name": "Sahaayi Team",
            "email": "support@sahaayi.app",
        },
        license_info={
            "name": "Private",
        },
        docs_url="/docs",
        redoc_url="/redoc",
        openapi_url="/openapi.json",
        lifespan=lifespan,
    )

    # ----------------------------------------------------------------
    # Middleware
    # ----------------------------------------------------------------
    application.add_middleware(
        CORSMiddleware,
        allow_origins=settings.ALLOWED_ORIGINS,
        allow_origin_regex=r"^https?://(localhost|127\.0\.0\.1)(:[0-9]+)?$",
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # ----------------------------------------------------------------
    # Request-ID middleware (injects X-Request-ID into every response)
    # ----------------------------------------------------------------
    @application.middleware("http")
    async def add_request_id(request: Request, call_next):  # type: ignore[no-untyped-def]
        request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
        request.state.request_id = request_id
        start = time.perf_counter()
        response = await call_next(request)
        duration = time.perf_counter() - start
        response.headers["X-Request-ID"] = request_id
        response.headers["X-Process-Time"] = f"{duration:.4f}s"
        return response

    # ----------------------------------------------------------------
    # Routers
    # ----------------------------------------------------------------
    application.include_router(api_router, prefix="/api/v1")

    # ----------------------------------------------------------------
    # Exception handlers
    # ----------------------------------------------------------------
    @application.exception_handler(SahaayiException)
    async def sahaayi_exception_handler(
        request: Request, exc: SahaayiException
    ) -> JSONResponse:
        """Handle domain-specific Sahaayi exceptions."""
        logger.warning(
            "SahaayiException [%s]: %s",
            exc.__class__.__name__,
            exc.detail,
            extra={"request_id": getattr(request.state, "request_id", None)},
        )
        return JSONResponse(
            status_code=exc.status_code,
            content={"detail": exc.detail, "error_code": exc.error_code},
        )

    @application.exception_handler(HTTPException)
    async def http_exception_handler(
        request: Request, exc: HTTPException
    ) -> JSONResponse:
        """Handle FastAPI / Starlette HTTP exceptions."""
        return JSONResponse(
            status_code=exc.status_code,
            content={"detail": exc.detail},
        )

    @application.exception_handler(ValidationError)
    async def validation_exception_handler(
        request: Request, exc: ValidationError
    ) -> JSONResponse:
        """Handle Pydantic v2 validation errors raised outside of FastAPI request parsing."""
        return JSONResponse(
            status_code=getattr(status, "HTTP_422_UNPROCESSABLE_ENTITY", 422),
            content={"detail": exc.errors()},
        )

    @application.exception_handler(Exception)
    async def generic_exception_handler(
        request: Request, exc: Exception
    ) -> JSONResponse:
        """Catch-all handler; masks internal details in production."""
        logger.exception(
            "Unhandled exception on %s %s",
            request.method,
            request.url.path,
            extra={"request_id": getattr(request.state, "request_id", None)},
        )
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"detail": "An internal server error occurred."},
        )

    # ----------------------------------------------------------------
    # Utility endpoints
    # ----------------------------------------------------------------
    @application.get(
        "/health",
        tags=["System"],
        summary="Health check",
        response_description="Returns 200 when the service is healthy.",
    )
    async def health_check() -> dict:
        """
        Liveness / readiness probe.

        Returns a JSON object with:
        - `status`: always "ok" if the service is running.
        - `version`: the current API version.
        - `environment`: the deployment environment.
        """
        return {
            "status": "ok",
            "app": "Sahaayi API",
            "version": "1.0.0",
            "environment": settings.APP_ENV,
        }

    @application.get(
        "/",
        tags=["System"],
        summary="API root",
    )
    async def root() -> dict:
        """
        Returns basic API discovery information.
        """
        return {
            "name": "Sahaayi API",
            "version": "1.0.0",
            "description": "AI-powered elder-care companion backend",
            "docs": "/docs",
            "health": "/health",
            "api_prefix": "/api/v1",
        }

    return application


# ---------------------------------------------------------------------------
# ASGI entry point
# ---------------------------------------------------------------------------
app: FastAPI = create_app()
