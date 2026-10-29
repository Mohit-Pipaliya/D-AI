"""Tests for the /health check endpoint."""

from __future__ import annotations

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_health_check_returns_healthy(client: AsyncClient) -> None:
    """Verify that /api/v1/health returns status 200 and healthy payload."""
    response = await client.get("/api/v1/health")
    assert response.status_code == 200

    data = response.json()
    assert data["status"] == "healthy"
    assert data["app_name"] == "D"
    assert "version" in data
    assert "environment" in data
    assert "timestamp" in data


@pytest.mark.asyncio
async def test_request_id_header_present(client: AsyncClient) -> None:
    """Verify that every response includes an X-Request-ID header."""
    response = await client.get("/api/v1/health")
    assert "x-request-id" in response.headers
    assert len(response.headers["x-request-id"]) > 0
