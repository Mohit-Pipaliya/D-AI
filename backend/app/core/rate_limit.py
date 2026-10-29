"""Sliding-window rate limiter (in-memory, per-client)."""

from __future__ import annotations

import time
from collections import defaultdict
from collections.abc import Callable

from fastapi import HTTPException, Request, status

from app.core.config import settings


class SlidingWindowRateLimiter:
    """Simple in-memory sliding-window rate limiter.

    Suitable for single-process deployments. For multi-worker / distributed
    setups, swap to Redis-backed ``limits`` library.
    """

    def __init__(self, max_requests: int | None = None, window_seconds: int = 60) -> None:
        self.max_requests = max_requests or settings.RATE_LIMIT_PER_MINUTE
        self.window_seconds = window_seconds
        self._hits: dict[str, list[float]] = defaultdict(list)

    def _client_key(self, request: Request) -> str:
        """Derive a rate-limit key from the request (IP-based)."""
        forwarded = request.headers.get("x-forwarded-for")
        if forwarded:
            return forwarded.split(",")[0].strip()
        client = request.client
        return client.host if client else "unknown"

    def _prune(self, key: str, now: float) -> None:
        cutoff = now - self.window_seconds
        self._hits[key] = [t for t in self._hits[key] if t > cutoff]

    def check(self, request: Request) -> None:
        """Raise 429 if the client has exceeded the rate limit."""
        key = self._client_key(request)
        now = time.monotonic()
        self._prune(key, now)
        if len(self._hits[key]) >= self.max_requests:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Rate limit exceeded. Please try again later.",
            )
        self._hits[key].append(now)


# Module-level singleton
rate_limiter = SlidingWindowRateLimiter()


def rate_limit_dependency() -> Callable:  # type: ignore[type-arg]
    """FastAPI dependency that enforces the global rate limit."""

    async def _check(request: Request) -> None:
        rate_limiter.check(request)

    return _check
