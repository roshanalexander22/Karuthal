import os
import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport

# Ensure SQLite dev database fallback for local pytest if not explicitly overridden by CI
if "DATABASE_URL_OVERRIDE" not in os.environ and "DATABASE_URL" not in os.environ:
    os.environ["DATABASE_URL_OVERRIDE"] = "sqlite+aiosqlite:///sahaayi_dev.db"

from app.main import app

@pytest_asyncio.fixture
async def async_client():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        yield client
