import os
import uuid
from pathlib import Path
from fastapi import UploadFile

class FileService:
    UPLOAD_DIR = Path("./uploads")

    @classmethod
    def save_upload(cls, file: UploadFile) -> str:
        cls.UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
        filename = f"{uuid.uuid4()}_{file.filename}"
        dest = cls.UPLOAD_DIR / filename
        return str(dest)

    @classmethod
    def delete_file(cls, file_path: str) -> bool:
        p = Path(file_path)
        if p.exists():
            p.unlink()
            return True
        return False
