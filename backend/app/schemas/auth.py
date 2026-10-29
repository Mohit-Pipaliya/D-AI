"""Pydantic v2 schemas for authentication endpoints."""

from __future__ import annotations

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class RegisterRequest(BaseModel):
    """Request body for user registration."""

    model_config = ConfigDict(str_strip_whitespace=True)

    email: EmailStr = Field(..., description="User email address.")
    password: str = Field(
        ...,
        min_length=8,
        max_length=128,
        description="Plaintext password (min 8 chars).",
    )
    display_name: str | None = Field(
        None,
        max_length=255,
        description="Optional display name.",
    )


class LoginRequest(BaseModel):
    """Request body for user login."""

    email: EmailStr = Field(..., description="User email address.")
    password: str = Field(..., description="Plaintext password.")


class RefreshRequest(BaseModel):
    """Request body for token refresh."""

    refresh_token: str = Field(..., description="A valid refresh JWT.")


class TokenResponse(BaseModel):
    """Response containing access and refresh tokens."""

    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class UserResponse(BaseModel):
    """Public-facing user representation (no secrets)."""

    id: str
    email: str
    display_name: str | None = None
