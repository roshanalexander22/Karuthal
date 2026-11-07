"""
app/core/logging.py
-------------------
Structured logging configuration for the Sahaayi backend using structlog.

Features:
  - JSON output in production, colourised console output in development.
  - Request-ID is automatically injected into every log record when
    available on the request context.
  - Standard library ``logging`` is bridged to structlog so that
    third-party libraries (SQLAlchemy, uvicorn, etc.) also emit
    structured records.
"""

from __future__ import annotations

import logging
import logging.config
import sys
from typing import Any, MutableMapping

import structlog
from structlog.types import EventDict, WrappedLogger

from app.core.config import settings


# ---------------------------------------------------------------------------
# Custom structlog processors
# ---------------------------------------------------------------------------
def _add_log_level(
    logger: WrappedLogger,  # noqa: ARG001
    method_name: str,
    event_dict: EventDict,
) -> EventDict:
    """Ensure the ``level`` key is always present in the event dict."""
    if "level" not in event_dict:
        event_dict["level"] = method_name.upper()
    return event_dict


def _drop_color_message_key(
    logger: WrappedLogger,  # noqa: ARG001
    method_name: str,  # noqa: ARG001
    event_dict: EventDict,
) -> EventDict:
    """Remove the internal ``color_message`` key added by uvicorn."""
    event_dict.pop("color_message", None)
    return event_dict


# ---------------------------------------------------------------------------
# Standard-library logging → structlog bridge configuration
# ---------------------------------------------------------------------------
_STDLIB_LOGGING_CONFIG: dict[str, Any] = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "plain": {
            "()": structlog.stdlib.ProcessorFormatter,
            "processors": [
                structlog.stdlib.ProcessorFormatter.remove_processors_meta,
                structlog.dev.ConsoleRenderer(colors=False),
            ],
        },
        "colored": {
            "()": structlog.stdlib.ProcessorFormatter,
            "processors": [
                structlog.stdlib.ProcessorFormatter.remove_processors_meta,
                structlog.dev.ConsoleRenderer(colors=True),
            ],
        },
        "json": {
            "()": structlog.stdlib.ProcessorFormatter,
            "processors": [
                structlog.stdlib.ProcessorFormatter.remove_processors_meta,
                structlog.processors.JSONRenderer(),
            ],
        },
    },
    "handlers": {
        "default": {
            "level": "DEBUG",
            "class": "logging.StreamHandler",
            "stream": "ext://sys.stdout",
        },
    },
    "root": {
        "handlers": ["default"],
        "level": "DEBUG",
    },
    "loggers": {
        "uvicorn": {"propagate": True},
        "uvicorn.error": {"propagate": True},
        "uvicorn.access": {"propagate": True},
        "sqlalchemy.engine": {"level": "WARNING", "propagate": True},
        "alembic": {"level": "INFO", "propagate": True},
    },
}


def configure_logging() -> None:
    """
    Initialise structlog and the standard-library logging bridge.

    Call this once at application startup (inside the lifespan handler).
    """
    is_production = settings.APP_ENV == "production"
    log_level_str = settings.LOG_LEVEL.upper()
    log_level = getattr(logging, log_level_str, logging.INFO)

    # Choose the stdlib formatter based on environment
    formatter_name = "json" if is_production else "colored"
    _STDLIB_LOGGING_CONFIG["handlers"]["default"]["formatter"] = formatter_name  # type: ignore[index]
    _STDLIB_LOGGING_CONFIG["root"]["level"] = log_level_str  # type: ignore[index]

    logging.config.dictConfig(_STDLIB_LOGGING_CONFIG)

    # Shared processors for all log records
    shared_processors: list[structlog.types.Processor] = [
        structlog.contextvars.merge_contextvars,
        structlog.stdlib.add_logger_name,
        _add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso", utc=True),
        structlog.processors.StackInfoRenderer(),
        _drop_color_message_key,
    ]

    structlog.configure(
        processors=shared_processors
        + [
            structlog.stdlib.ProcessorFormatter.wrap_for_formatter,
        ],
        logger_factory=structlog.stdlib.LoggerFactory(),
        wrapper_class=structlog.make_filtering_bound_logger(log_level),
        cache_logger_on_first_use=True,
    )


def bind_request_context(request_id: str, path: str, method: str) -> None:
    """
    Bind per-request context variables so they appear in all log records
    emitted during the current async task / coroutine.

    Call this at the start of each request (e.g., in middleware).

    Args:
        request_id: A unique identifier for the request (UUID).
        path:       The request URL path.
        method:     The HTTP method (GET, POST, …).
    """
    structlog.contextvars.clear_contextvars()
    structlog.contextvars.bind_contextvars(
        request_id=request_id,
        http_method=method,
        http_path=path,
    )


def clear_request_context() -> None:
    """Clear per-request context variables at the end of a request."""
    structlog.contextvars.clear_contextvars()
