"""Tests for security, password hashing, and JWT token operations."""

from __future__ import annotations

import pytest
from httpx import AsyncClient

from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)


def test_password_hashing_and_verification() -> None:
    """Verify passwords hash cleanly and match upon verification."""
    password = "SuperSecretPassword123!"
    hashed = hash_password(password)

    assert hashed != password
    assert verify_password(password, hashed) is True
    assert verify_password("WrongPassword!", hashed) is False


def test_jwt_token_lifecycle() -> None:
    """Verify access and refresh token encoding and decoding."""
    subject = "user-12345"
    access_token = create_access_token(subject=subject, claims={"tier": "pro"})
    refresh_token = create_refresh_token(subject=subject)

    # Decode access token
    access_payload = decode_token(access_token)
    assert access_payload["sub"] == subject
    assert access_payload["type"] == "access"
    assert access_payload["tier"] == "pro"

    # Decode refresh token
    refresh_payload = decode_token(refresh_token)
    assert refresh_payload["sub"] == subject
    assert refresh_payload["type"] == "refresh"


@pytest.mark.asyncio
async def test_refresh_endpoint_rejects_invalid_token(client: AsyncClient) -> None:
    """Verify that POST /api/v1/auth/refresh rejects fake tokens."""
    response = await client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": "totally-invalid-garbage-token"},
    )
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_refresh_endpoint_with_valid_refresh_token(client: AsyncClient) -> None:
    """Verify that POST /api/v1/auth/refresh returns new token pair for valid refresh token."""
    valid_refresh = create_refresh_token(subject="user-test-789")
    response = await client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": valid_refresh},
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["token_type"] == "bearer"
