"""Tests for the chat streaming endpoint and context management."""

from __future__ import annotations

from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from httpx import AsyncClient

from app.schemas.chat import ChatMessage
from app.services.context_service import context_manager
from app.services.openai_service import openai_service
from app.services.token_service import TokenBudgetExceededError, TokenService


@pytest.mark.asyncio
async def test_chat_stream_simulated_when_no_api_key(client: AsyncClient) -> None:
    """Verify that /api/v1/chat/stream streams SSE chunks cleanly when no key is set."""
    payload = {
        "conversation_id": "test_conv_1",
        "prompt": "Hello D, how are you?",
        "history": [],
    }

    response = await client.post("/api/v1/chat/stream", json=payload)
    assert response.status_code == 200
    assert "text/event-stream" in response.headers["content-type"]

    body = response.text
    assert "event: token" in body
    assert "event: done" in body
    assert "[DONE]" in body


@pytest.mark.asyncio
async def test_chat_stream_with_mocked_openai(client: AsyncClient) -> None:
    """Verify chat stream yields tokens produced by OpenAI AsyncClient."""
    mock_choice1 = MagicMock()
    mock_choice1.delta.content = "Namaste! "
    mock_choice1.finish_reason = None

    mock_choice2 = MagicMock()
    mock_choice2.delta.content = "I am ready."
    mock_choice2.finish_reason = "stop"

    mock_chunk1 = MagicMock(choices=[mock_choice1])
    mock_chunk2 = MagicMock(choices=[mock_choice2])

    async def fake_stream():
        yield mock_chunk1
        yield mock_chunk2

    mock_openai_client = MagicMock()
    mock_openai_client.chat.completions.create = AsyncMock(return_value=fake_stream())

    with (
        patch.object(openai_service, "_get_client", return_value=mock_openai_client),
        patch("app.core.config.settings.OPENAI_API_KEY", "sk-valid-test-key-12345678"),
    ):
        payload = {
            "conversation_id": "test_conv_2",
            "prompt": "Namaste",
            "language": "hi",
        }
        response = await client.post("/api/v1/chat/stream", json=payload)
        assert response.status_code == 200
        assert "text/event-stream" in response.headers["content-type"]

        body = response.text
        assert "Namaste!" in body
        assert "I am ready." in body
        assert "[DONE]" in body


def test_context_manager_summarizes_long_history() -> None:
    """Verify that history exceeding recent turn limit is summarized."""
    history = [
        ChatMessage(role="user", content=f"User turn number {i}")
        if i % 2 == 0
        else ChatMessage(role="assistant", content=f"Assistant turn number {i}")
        for i in range(12)
    ]

    prepared = context_manager.prepare_messages(
        prompt="Latest prompt",
        history=history,
    )

    # First turn is system prompt
    assert prepared[0]["role"] == "system"
    # Second turn should be summarized context
    assert "Previous conversation context" in prepared[1]["content"]
    # Last turn is the user prompt
    assert prepared[-1]["role"] == "user"
    assert prepared[-1]["content"] == "Latest prompt"


def test_token_service_budget_enforcement() -> None:
    """Verify token budget triggers exception when exhausted."""
    service = TokenService(daily_budget=100)
    user_id = "test_user_budget"

    # Should succeed within budget
    service.check_budget(user_id=user_id, estimated_tokens=50)
    service.record_usage(user_id=user_id, tokens=80)

    assert service.get_remaining_budget(user_id) == 20

    # Exceeding budget should raise
    with pytest.raises(TokenBudgetExceededError):
        service.check_budget(user_id=user_id, estimated_tokens=30)
