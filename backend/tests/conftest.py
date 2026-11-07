import os
import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport

from app.config.database import engine, Base
import app.models  # noqa: F401
from app.main import app as fastapi_app

@pytest_asyncio.fixture(scope="session", autouse=True)
async def setup_test_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield

@pytest_asyncio.fixture
async def async_client():
    async with AsyncClient(transport=ASGITransport(app=fastapi_app), base_url="http://test") as client:
        yield client
