"""D AI Assistant — FastAPI application factory."""

from __future__ import annotations

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import ORJSONResponse
from starlette.middleware.base import BaseHTTPMiddleware

from app.api.v1.api import api_router
from app.core.config import settings
from app.core.exceptions import AppException, app_exception_handler
from app.core.logging import get_logger, setup_logging
from app.core.middleware import LoggingMiddleware, RequestIDMiddleware

logger = get_logger(__name__)


@asynccontextmanager
async def lifespan(application: FastAPI) -> AsyncIterator[None]:
    """Application startup / shutdown lifecycle."""
    setup_logging()
    logger.info(
        "application_startup",
        app_name=settings.APP_NAME,
        app_env=settings.APP_ENV,
        app_version=settings.APP_VERSION,
    )
    yield
    logger.info("application_shutdown")


def create_app() -> FastAPI:
    """Build and configure the FastAPI application."""
    application = FastAPI(
        title=f"{settings.APP_NAME} AI Assistant API",
        version=settings.APP_VERSION,
        description="Privacy-first, voice-first AI assistant backend.",
        docs_url="/docs" if settings.APP_DEBUG else None,
        redoc_url="/redoc" if settings.APP_DEBUG else None,
        openapi_url="/openapi.json" if settings.APP_DEBUG else None,
        default_response_class=ORJSONResponse,
        lifespan=lifespan,
    )

    # --- Exception Handlers ---
    application.add_exception_handler(AppException, app_exception_handler)  # type: ignore[arg-type]

    # --- Middleware (order matters: last added = first executed) ---
    application.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    application.add_middleware(BaseHTTPMiddleware, dispatch=LoggingMiddleware())
    application.add_middleware(RequestIDMiddleware)

    # --- Routers ---
    application.include_router(api_router, prefix="/api/v1")

    return application


app = create_app()
