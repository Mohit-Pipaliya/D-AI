"""Common / shared Pydantic v2 response schemas."""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    """Health check response."""

    status: str = Field(..., examples=["healthy"])
    app_name: str
    version: str
    environment: str
    timestamp: datetime


class ErrorDetail(BaseModel):
    """Structured error detail payload."""

    code: str
    message: str


class ErrorResponse(BaseModel):
    """Standard error envelope."""

    error: ErrorDetail


class MessageResponse(BaseModel):
    """Simple success / info message."""

    message: str
