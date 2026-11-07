"""
app/core/exceptions.py
----------------------
Custom exception hierarchy for the Sahaayi backend.

All domain exceptions inherit from :class:`SahaayiException`, which carries:
  - ``status_code`` — the HTTP status code to return to the client.
  - ``detail``      — a human-readable error message.
  - ``error_code``  — a machine-readable snake_case identifier for the client.

These are caught by the global exception handler registered in ``main.py``.
"""

from __future__ import annotations

from fastapi import status


class SahaayiException(Exception):
    """
    Base exception for all Sahaayi domain errors.

    Attributes:
        status_code: HTTP status code sent to the client.
        detail:      Human-readable description of the error.
        error_code:  Machine-readable snake_case code for programmatic handling.
    """

    status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR
    detail: str = "An unexpected error occurred."
    error_code: str = "internal_error"

    def __init__(
        self,
        detail: str | None = None,
        error_code: str | None = None,
    ) -> None:
        self.detail = detail or self.__class__.detail
        self.error_code = error_code or self.__class__.error_code
        super().__init__(self.detail)


# ---------------------------------------------------------------------------
# Authentication & authorisation
# ---------------------------------------------------------------------------
class AuthenticationError(SahaayiException):
    """Raised when a request cannot be authenticated (bad / expired token)."""

    status_code = status.HTTP_401_UNAUTHORIZED
    detail = "Authentication failed."
    error_code = "authentication_error"


class AuthorizationError(SahaayiException):
    """Raised when an authenticated user lacks permission to perform an action."""

    status_code = status.HTTP_403_FORBIDDEN
    detail = "You do not have permission to perform this action."
    error_code = "authorization_error"


# ---------------------------------------------------------------------------
# Documents
# ---------------------------------------------------------------------------
class DocumentNotFoundError(SahaayiException):
    """Raised when a requested document does not exist or belongs to another user."""

    status_code = status.HTTP_404_NOT_FOUND
    detail = "Document not found."
    error_code = "document_not_found"


class DocumentProcessingError(SahaayiException):
    """Raised when document parsing / structuring fails."""

    status_code = status.HTTP_422_UNPROCESSABLE_ENTITY
    detail = "Failed to process the document."
    error_code = "document_processing_error"


class InvalidFileTypeError(SahaayiException):
    """Raised when an uploaded file has an unsupported MIME type."""

    status_code = status.HTTP_415_UNSUPPORTED_MEDIA_TYPE
    detail = "The uploaded file type is not supported."
    error_code = "invalid_file_type"


class FileTooLargeError(SahaayiException):
    """Raised when an uploaded file exceeds the maximum allowed size."""

    status_code = status.HTTP_413_REQUEST_ENTITY_TOO_LARGE
    detail = "The uploaded file is too large."
    error_code = "file_too_large"


# ---------------------------------------------------------------------------
# Personal memory / profile
# ---------------------------------------------------------------------------
class ProfileNotFoundError(SahaayiException):
    """Raised when a user profile is not found."""

    status_code = status.HTTP_404_NOT_FOUND
    detail = "Profile not found."
    error_code = "profile_not_found"


class ProfileFieldNotFoundError(SahaayiException):
    """Raised when a specific profile field does not exist for the user."""

    status_code = status.HTTP_404_NOT_FOUND
    detail = "Profile field not found."
    error_code = "profile_field_not_found"


# ---------------------------------------------------------------------------
# Reminders
# ---------------------------------------------------------------------------
class ReminderNotFoundError(SahaayiException):
    """Raised when a reminder record is not found or belongs to another user."""

    status_code = status.HTTP_404_NOT_FOUND
    detail = "Reminder not found."
    error_code = "reminder_not_found"


# ---------------------------------------------------------------------------
# OCR
# ---------------------------------------------------------------------------
class OCRProcessingError(SahaayiException):
    """Raised when Tesseract / PDF OCR extraction fails."""

    status_code = status.HTTP_422_UNPROCESSABLE_ENTITY
    detail = "OCR processing failed."
    error_code = "ocr_processing_error"


# ---------------------------------------------------------------------------
# Transcription
# ---------------------------------------------------------------------------
class TranscriptionError(SahaayiException):
    """Raised when audio transcription fails."""

    status_code = status.HTTP_422_UNPROCESSABLE_ENTITY
    detail = "Audio transcription failed."
    error_code = "transcription_error"


class TranscriptionNotFoundError(SahaayiException):
    """Raised when a transcription session is not found."""

    status_code = status.HTTP_404_NOT_FOUND
    detail = "Transcription session not found."
    error_code = "transcription_not_found"


# ---------------------------------------------------------------------------
# Fall detection
# ---------------------------------------------------------------------------
class FallDetectionError(SahaayiException):
    """Raised when fall event processing fails."""

    status_code = status.HTTP_422_UNPROCESSABLE_ENTITY
    detail = "Fall detection event processing failed."
    error_code = "fall_detection_error"


class FallEventNotFoundError(SahaayiException):
    """Raised when a fall event record is not found."""

    status_code = status.HTTP_404_NOT_FOUND
    detail = "Fall event not found."
    error_code = "fall_event_not_found"


# ---------------------------------------------------------------------------
# Emergency
# ---------------------------------------------------------------------------
class EmergencyTriggerError(SahaayiException):
    """Raised when an emergency alert cannot be dispatched."""

    status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    detail = "Failed to trigger the emergency alert."
    error_code = "emergency_trigger_error"


# ---------------------------------------------------------------------------
# Caregiver
# ---------------------------------------------------------------------------
class CaregiverNotFoundError(SahaayiException):
    """Raised when a caregiver relationship is not found."""

    status_code = status.HTTP_404_NOT_FOUND
    detail = "Caregiver relationship not found."
    error_code = "caregiver_not_found"


class DuplicateCaregiverError(SahaayiException):
    """Raised when a caregiver link already exists."""

    status_code = status.HTTP_409_CONFLICT
    detail = "This caregiver is already linked to the account."
    error_code = "duplicate_caregiver"
