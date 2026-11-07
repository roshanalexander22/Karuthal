"""
shared package for Sahaayi.
Shared across FastAPI backend, AI microservice, and offline utilities.
"""

from __future__ import annotations
import json
import os
from pathlib import Path

_BASE_DIR = Path(__file__).resolve().parent

def get_constants(filename: str):
    path = _BASE_DIR / "constants" / filename
    if path.exists():
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    return None

LANGUAGES = get_constants("languages.json")
DOCUMENT_CATEGORIES = get_constants("document_categories.json")
REMINDER_TYPES = get_constants("reminder_types.json")
ERROR_CODES = get_constants("error_codes.json")
