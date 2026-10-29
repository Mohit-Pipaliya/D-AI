"""Central API v1 router — aggregates all v1 endpoint routers."""

from __future__ import annotations

from fastapi import APIRouter

from app.api.v1.endpoints.auth import router as auth_router
from app.api.v1.endpoints.chat import router as chat_router
from app.api.v1.endpoints.health import router as health_router

api_router = APIRouter()

# Health check is mounted at the root level (not under /api/v1)
# but we also include it here for convenience via the v1 prefix.
api_router.include_router(health_router, tags=["health"])
api_router.include_router(auth_router, prefix="/auth", tags=["auth"])
api_router.include_router(chat_router, prefix="/chat", tags=["chat"])
