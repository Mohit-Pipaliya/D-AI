"""Application configuration via pydantic-settings."""

from __future__ import annotations

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Central configuration loaded from environment / .env file."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )

    # --- Application ---
    APP_NAME: str = "D"
    APP_ENV: str = "development"
    APP_DEBUG: bool = True
    APP_VERSION: str = "0.1.0"

    # --- Server ---
    APP_HOST: str = "0.0.0.0"
    APP_PORT: int = 8000

    # --- Database ---
    DATABASE_URL: str = "postgresql+asyncpg://d_user:d_password@localhost:5432/d_db"

    # --- JWT ---
    JWT_SECRET_KEY: str = "CHANGE-ME-to-a-random-64-char-hex-string"
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # --- CORS ---
    CORS_ORIGINS: list[str] = ["http://localhost:3000", "http://localhost:8080"]

    # --- Rate Limiting ---
    RATE_LIMIT_PER_MINUTE: int = 60

    # --- Logging ---
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "json"  # json | console

    # --- OpenAI ---
    OPENAI_API_KEY: str = ""
    OPENAI_MODEL: str = "gpt-4o"

    @field_validator("APP_ENV")
    @classmethod
    def validate_app_env(cls, v: str) -> str:
        allowed = {"development", "staging", "production"}
        if v not in allowed:
            msg = f"APP_ENV must be one of {allowed}"
            raise ValueError(msg)
        return v

    @property
    def is_production(self) -> bool:
        return self.APP_ENV == "production"


settings = Settings()
