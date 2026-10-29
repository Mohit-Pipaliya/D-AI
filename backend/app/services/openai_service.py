"""OpenAI streaming completions proxy with backoff retry and token tracking."""

from __future__ import annotations

import asyncio
import json
from collections.abc import AsyncIterator

from openai import APIConnectionError, AsyncOpenAI, RateLimitError

from app.core.config import settings
from app.core.logging import get_logger
from app.services.context_service import context_manager
from app.services.token_service import token_service

logger = get_logger(__name__)

MAX_RETRIES = 3
INITIAL_BACKOFF = 0.5
REQUEST_TIMEOUT_SECONDS = 30.0


class OpenAIService:
    """Async client wrapper for OpenAI streaming chat completions."""

    def __init__(self) -> None:
        self._client: AsyncOpenAI | None = None

    def _get_client(self) -> AsyncOpenAI | None:
        if not settings.OPENAI_API_KEY:
            return None
        if self._client is None:
            self._client = AsyncOpenAI(
                api_key=settings.OPENAI_API_KEY,
                timeout=REQUEST_TIMEOUT_SECONDS,
            )
        return self._client

    async def stream_chat(
        self,
        messages: list[dict[str, str]],
        user_id: str = "default_user",
        max_tokens: int = 512,
        temperature: float = 0.7,
    ) -> AsyncIterator[str]:
        """Streams completion tokens formatted as Server-Sent Events (SSE).

        Yields SSE lines:
            event: token\\ndata: {"token": "..."}\\n\\n
            event: done\\ndata: [DONE]\\n\\n
        """
        # Pre-check token budget
        token_service.check_budget(user_id=user_id, estimated_tokens=max_tokens)

        client = self._get_client()

        # Graceful fallback if no OpenAI key is configured yet
        if not client or settings.OPENAI_API_KEY.startswith("sk-CHANGE-ME"):
            logger.warning("openai_key_not_configured_simulating_response")
            simulated_response = (
                f"Hello! I am {settings.APP_NAME}. "
                "OpenAI API key is not configured in backend/.env yet. "
                "Please set OPENAI_API_KEY to start live conversational reasoning."
            )
            for word in simulated_response.split(" "):
                chunk_data = json.dumps({"token": word + " ", "finish_reason": None})
                yield f"event: token\ndata: {chunk_data}\n\n"
                await asyncio.sleep(0.04)
            yield "event: done\ndata: [DONE]\n\n"
            return

        # Attempt stream with exponential backoff
        backoff = INITIAL_BACKOFF
        last_error: Exception | None = None

        for attempt in range(1, MAX_RETRIES + 1):
            try:
                logger.info(
                    "openai_stream_attempt",
                    attempt=attempt,
                    model=settings.OPENAI_MODEL,
                    user_id=user_id,
                )

                response_stream = await client.chat.completions.create(
                    model=settings.OPENAI_MODEL,
                    messages=messages,  # type: ignore[arg-type]
                    max_tokens=max_tokens,
                    temperature=temperature,
                    stream=True,
                )

                accumulated_tokens = ""
                async for chunk in response_stream:
                    delta = chunk.choices[0].delta if chunk.choices else None
                    finish_reason = chunk.choices[0].finish_reason if chunk.choices else None

                    if delta and delta.content:
                        token = delta.content
                        accumulated_tokens += token
                        chunk_payload = json.dumps({"token": token, "finish_reason": finish_reason})
                        yield f"event: token\ndata: {chunk_payload}\n\n"

                    if finish_reason:
                        break

                # Record actual tokens used
                total_tokens = context_manager.count_tokens(accumulated_tokens)
                token_service.record_usage(user_id, total_tokens)

                yield "event: done\ndata: [DONE]\n\n"
                return

            except (RateLimitError, APIConnectionError) as e:
                last_error = e
                logger.warning(
                    "openai_transient_error",
                    attempt=attempt,
                    error=str(e),
                    backoff=backoff,
                )
                if attempt < MAX_RETRIES:
                    await asyncio.sleep(backoff)
                    backoff *= 2.0
                else:
                    break
            except Exception as e:
                logger.error("openai_fatal_error", error=str(e), exc_info=True)
                error_payload = json.dumps({"error": f"OpenAI error: {e!s}"})
                yield f"event: error\ndata: {error_payload}\n\n"
                return

        # If retries exhausted
        error_msg = f"OpenAI request failed after {MAX_RETRIES} attempts: {last_error}"
        logger.error("openai_retries_exhausted", error=error_msg)
        error_payload = json.dumps({"error": error_msg})
        yield f"event: error\ndata: {error_payload}\n\n"


openai_service = OpenAIService()
