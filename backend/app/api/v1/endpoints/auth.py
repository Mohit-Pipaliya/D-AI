"""Authentication endpoints — register, login, refresh (stubs)."""

from __future__ import annotations

from fastapi import APIRouter, Depends

from app.api.deps import DBSession
from app.core.exceptions import AuthenticationError
from app.core.logging import get_logger
from app.core.rate_limit import rate_limit_dependency
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
)
from app.schemas.auth import (
    LoginRequest,
    RefreshRequest,
    RegisterRequest,
    TokenResponse,
    UserResponse,
)

logger = get_logger(__name__)

router = APIRouter()


@router.post(
    "/register",
    response_model=UserResponse,
    status_code=201,
    summary="Register a new user",
    dependencies=[Depends(rate_limit_dependency())],
)
async def register(body: RegisterRequest, db: DBSession) -> UserResponse:
    """Create a new user account.

    TODO: Wire up actual database persistence via UserRepository.
    """
    logger.info("user_register_attempt", email=body.email)

    # Stub — will be replaced with real DB lookup
    # raise ConflictError("A user with this email already exists.") if exists

    hashed = hash_password(body.password)
    _ = hashed  # placeholder until we persist

    return UserResponse(
        id="stub-uuid",
        email=body.email,
        display_name=body.display_name,
    )


@router.post(
    "/login",
    response_model=TokenResponse,
    summary="Authenticate and obtain tokens",
    dependencies=[Depends(rate_limit_dependency())],
)
async def login(body: LoginRequest, db: DBSession) -> TokenResponse:
    """Authenticate a user and return access + refresh tokens.

    TODO: Wire up actual database lookup and password verification.
    """
    logger.info("user_login_attempt", email=body.email)

    # Stub — will be replaced with real DB lookup + verify_password()
    # For now, raise to prevent unauthenticated access
    raise AuthenticationError(detail="Login not yet implemented. Stub endpoint.")


@router.post(
    "/refresh",
    response_model=TokenResponse,
    summary="Refresh an access token",
    dependencies=[Depends(rate_limit_dependency())],
)
async def refresh(body: RefreshRequest) -> TokenResponse:
    """Exchange a valid refresh token for a new access + refresh token pair.

    TODO: Implement token rotation and revocation tracking.
    """
    from jose import JWTError

    try:
        payload = decode_token(body.refresh_token)
    except JWTError:
        raise AuthenticationError(detail="Invalid or expired refresh token.")

    if payload.get("type") != "refresh":
        raise AuthenticationError(detail="Token is not a refresh token.")

    subject = payload.get("sub", "")
    access_token = create_access_token(subject=subject)
    new_refresh_token = create_refresh_token(subject=subject)

    return TokenResponse(
        access_token=access_token,
        refresh_token=new_refresh_token,
        token_type="bearer",
    )
