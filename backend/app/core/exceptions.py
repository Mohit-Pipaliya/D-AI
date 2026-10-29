"""Custom application exceptions with structured HTTP error responses."""

from __future__ import annotations

from fastapi import Request
from fastapi.responses import ORJSONResponse
from starlette import status


class AppException(Exception):
    """Base application exception that maps to an HTTP error response."""

    def __init__(
        self,
        status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail: str = "An unexpected error occurred.",
        error_code: str = "INTERNAL_ERROR",
        headers: dict[str, str] | None = None,
    ) -> None:
        self.status_code = status_code
        self.detail = detail
        self.error_code = error_code
        self.headers = headers
        super().__init__(detail)


class AuthenticationError(AppException):
    """Raised when authentication fails."""

    def __init__(self, detail: str = "Could not validate credentials.") -> None:
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=detail,
            error_code="AUTHENTICATION_ERROR",
            headers={"WWW-Authenticate": "Bearer"},
        )


class AuthorizationError(AppException):
    """Raised when the user lacks permissions."""

    def __init__(self, detail: str = "Not enough permissions.") -> None:
        super().__init__(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=detail,
            error_code="AUTHORIZATION_ERROR",
        )


class NotFoundError(AppException):
    """Raised when a requested resource is not found."""

    def __init__(self, detail: str = "Resource not found.") -> None:
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=detail,
            error_code="NOT_FOUND",
        )


class ConflictError(AppException):
    """Raised when a resource already exists."""

    def __init__(self, detail: str = "Resource already exists.") -> None:
        super().__init__(
            status_code=status.HTTP_409_CONFLICT,
            detail=detail,
            error_code="CONFLICT",
        )


class ValidationError(AppException):
    """Raised for business-logic validation failures."""

    def __init__(self, detail: str = "Validation error.") -> None:
        super().__init__(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=detail,
            error_code="VALIDATION_ERROR",
        )


async def app_exception_handler(request: Request, exc: AppException) -> ORJSONResponse:
    """Global handler that converts AppException into a JSON response."""
    return ORJSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": exc.error_code,
                "message": exc.detail,
            }
        },
        headers=exc.headers,
    )
