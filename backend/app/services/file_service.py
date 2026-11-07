from __future__ import annotations
import os
import uuid
from pathlib import Path
from typing import Tuple
from fastapi import UploadFile, HTTPException, status
from app.core.config import settings
from app.core.exceptions import InvalidFileTypeError, FileTooLargeError

class FileService:
    UPLOAD_DIR = Path(settings.UPLOAD_DIR)

    @classmethod
    async def save_upload(cls, file: UploadFile) -> Tuple[str, int]:
        """Validate and write binary upload to disk, returning (file_path, file_size)."""
        cls.UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

        content_type = file.content_type or "application/octet-stream"
        filename = file.filename or "uploaded_file"
        
        # Check allowed MIME types or extension
        allowed_extensions = ('.jpg', '.jpeg', '.png', '.webp', '.pdf')
        if content_type not in settings.ALLOWED_MIME_TYPES and not filename.lower().endswith(allowed_extensions):
            raise InvalidFileTypeError(
                detail=f"Unsupported file type: {content_type}. Allowed: {settings.ALLOWED_MIME_TYPES}"
            )

        # Sanitize destination path using UUID
        safe_name = f"{uuid.uuid4()}_{Path(filename).name}"
        dest_path = cls.UPLOAD_DIR / safe_name

        total_bytes = 0
        chunk_size = 1024 * 64  # 64 KB chunks

        with open(dest_path, "wb") as f:
            while chunk := await file.read(chunk_size):
                total_bytes += len(chunk)
                if total_bytes > settings.MAX_UPLOAD_SIZE_BYTES:
                    f.close()
                    dest_path.unlink(missing_ok=True)
                    raise FileTooLargeError(
                        detail=f"File exceeds maximum size limit of {settings.MAX_UPLOAD_SIZE_MB} MB."
                    )
                f.write(chunk)

        return str(dest_path), total_bytes

    @classmethod
    def read_file(cls, file_path: str) -> bytes:
        p = Path(file_path)
        if not p.exists():
            raise FileNotFoundError(f"File not found: {file_path}")
        return p.read_bytes()

    @classmethod
    def delete_file(cls, file_path: str) -> bool:
        p = Path(file_path)
        if p.exists():
            p.unlink(missing_ok=True)
            return True
        return False
