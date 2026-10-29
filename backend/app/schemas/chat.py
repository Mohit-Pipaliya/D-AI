"""Pydantic v2 schemas for chat and streaming endpoints."""

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class ChatMessage(BaseModel):
    """Single chat turn in conversation history."""

    model_config = ConfigDict(str_strip_whitespace=True)

    role: Literal["user", "assistant", "system"] = Field(
        ..., description="Author role of the message."
    )
    content: str = Field(..., description="Text content of the message.")


class ChatStreamRequest(BaseModel):
    """Payload for POST /api/v1/chat/stream."""

    model_config = ConfigDict(str_strip_whitespace=True)

    conversation_id: str = Field(default="default", description="Unique conversation identifier.")
    prompt: str = Field(..., min_length=1, max_length=4096, description="User query / prompt.")
    history: list[ChatMessage] = Field(
        default_factory=list, description="Recent conversation turns."
    )
    language: str | None = Field(default="en", description="Detected or preferred user language.")
    max_tokens: int = Field(default=512, ge=16, le=2048, description="Maximum completion tokens.")
    temperature: float = Field(default=0.7, ge=0.0, le=2.0, description="Sampling temperature.")


class ChatChunk(BaseModel):
    """Single token chunk emitted via SSE."""

    model_config = ConfigDict(str_strip_whitespace=True)

    token: str = Field(..., description="Text delta token.")
    finish_reason: str | None = Field(
        default=None, description="Completion finish reason if stream ends."
    )
