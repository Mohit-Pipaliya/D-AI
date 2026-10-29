"""Health check endpoint."""

from __future__ import annotations

from datetime import datetime, timezone

from fastapi import APIRouter, Request

from app.core.config import settings
from app.schemas.common import HealthResponse

router = APIRouter()


@router.get(
    "/health",
    response_model=HealthResponse,
    summary="Health check",
    description="Returns basic application health status.",
)
async def health_check(request: Request) -> HealthResponse:
    """Lightweight health probe for load balancers and monitoring."""
    return HealthResponse(
        status="healthy",
        app_name=settings.APP_NAME,
        version=settings.APP_VERSION,
        environment=settings.APP_ENV,
        timestamp=datetime.now(timezone.utc),
    )
