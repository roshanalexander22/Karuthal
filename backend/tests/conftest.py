import os
import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport

# Ensure SQLite dev database fallback for local pytest if not explicitly overridden by CI
if "DATABASE_URL_OVERRIDE" not in os.environ and "DATABASE_URL" not in os.environ:
    os.environ["DATABASE_URL_OVERRIDE"] = "sqlite+aiosqlite:///sahaayi_dev.db"

import app.models  # noqa: F401
from app.main import app as fastapi_app
from app.config.database import engine, Base

@pytest_asyncio.fixture(scope="session", autouse=True)
async def setup_test_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

@pytest_asyncio.fixture
async def async_client():
    async with AsyncClient(transport=ASGITransport(app=fastapi_app), base_url="http://test") as client:
        yield client
