"""Pytest configuration and shared fixtures for backend tests."""

from __future__ import annotations

from collections.abc import AsyncGenerator

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app


@pytest.fixture(scope="session")
def anyio_backend() -> str:
    return "asyncio"


@pytest.fixture
async def client() -> AsyncGenerator[AsyncClient, None]:
    """Async test client bound to the FastAPI application."""
    transport = ASGITransport(app=app)
    async with AsyncClient(
        transport=transport,
        base_url="http://testserver",
        headers={"Accept": "application/json"},
    ) as ac:
        yield ac


@pytest.fixture
def auth_headers() -> dict[str, str]:
    """Generates valid JWT Authorization headers for test requests."""
    from app.core.security import create_access_token

    token = create_access_token(
        subject="test-user-id",
        claims={"email": "test@example.com", "role": "user"},
    )
    return {"Authorization": f"Bearer {token}"}
