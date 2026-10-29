"""Request-ID injection and request/response logging middleware."""

from __future__ import annotations

import time
import uuid

import structlog
from fastapi import Request, Response
from starlette.middleware.base import RequestResponseEndpoint
from starlette.types import ASGIApp, Receive, Scope, Send

from app.core.logging import get_logger

logger = get_logger(__name__)

REQUEST_ID_HEADER = "X-Request-ID"


class RequestIDMiddleware:
    """ASGI middleware that injects a unique request ID into every request.

    The ID is set on ``request.state.request_id`` and returned via the
    ``X-Request-ID`` response header.
    """

    def __init__(self, app: ASGIApp) -> None:
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] not in ("http", "websocket"):
            await self.app(scope, receive, send)
            return

        request_id = str(uuid.uuid4())
        scope.setdefault("state", {})
        if isinstance(scope["state"], dict):
            scope["state"]["request_id"] = request_id
        else:
            scope["state"].request_id = request_id

        # Bind to structlog context for the duration of the request
        structlog.contextvars.clear_contextvars()
        structlog.contextvars.bind_contextvars(request_id=request_id)

        async def send_with_request_id(message: dict) -> None:  # type: ignore[type-arg]
            if message["type"] == "http.response.start":
                headers = list(message.get("headers", []))
                headers.append((REQUEST_ID_HEADER.lower().encode(), request_id.encode()))
                message["headers"] = headers
            await send(message)

        await self.app(scope, receive, send_with_request_id)


class LoggingMiddleware:
    """BaseHTTPMiddleware-compatible dispatch that logs request/response info.

    NOTE: PII (cookies, authorization headers, body) is intentionally excluded
    from logs per project privacy rules.
    """

    async def __call__(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        start = time.perf_counter()

        logger.info(
            "request_started",
            method=request.method,
            path=request.url.path,
            query=str(request.url.query) if request.url.query else None,
        )

        response = await call_next(request)

        duration_ms = round((time.perf_counter() - start) * 1000, 2)
        logger.info(
            "request_completed",
            method=request.method,
            path=request.url.path,
            status_code=response.status_code,
            duration_ms=duration_ms,
        )

        return response
