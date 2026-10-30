"""Shared FastAPI dependencies — DB session, authenticated user, etc."""

from __future__ import annotations

from collections.abc import AsyncGenerator
from typing import Annotated

from fastapi import Depends, Header
from jose import JWTError
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.core.config import settings
from app.core.exceptions import AuthenticationError
from app.core.security import decode_token

# ---------------------------------------------------------------------------
# Database engine & session factory
# ---------------------------------------------------------------------------
_is_sqlite = "sqlite" in settings.DATABASE_URL.lower()
_engine_kwargs: dict = {
    "echo": settings.APP_DEBUG,
    "pool_pre_ping": True,
}
if not _is_sqlite:
    _engine_kwargs["pool_size"] = 10
    _engine_kwargs["max_overflow"] = 20

engine = create_async_engine(
    settings.DATABASE_URL,
    **_engine_kwargs,
)

async_session_factory = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """Yield an async database session, rolling back on error."""
    async with async_session_factory() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise


# ---------------------------------------------------------------------------
# Current user dependency
# ---------------------------------------------------------------------------
async def get_current_user(
    authorization: Annotated[str | None, Header(alias="Authorization")] = None,
) -> dict:
    """Extract and validate the current user from the Authorization header.

    Returns the decoded JWT payload as a dict. Raises AuthenticationError on
    any failure.
    """
    if not authorization or not authorization.startswith("Bearer "):
        raise AuthenticationError(detail="Missing or malformed Authorization header.")

    token = authorization.removeprefix("Bearer ").strip()
    try:
        payload = decode_token(token)
    except JWTError:
        raise AuthenticationError(detail="Invalid or expired token.")

    sub = payload.get("sub")
    if not sub:
        raise AuthenticationError(detail="Token payload missing subject.")

    token_type = payload.get("type")
    if token_type != "access":
        raise AuthenticationError(detail="Invalid token type. Access token required.")

    return payload


# Type alias for convenience
DBSession = Annotated[AsyncSession, Depends(get_db)]
CurrentUser = Annotated[dict, Depends(get_current_user)]
