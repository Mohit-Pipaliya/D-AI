"""Chat streaming endpoint using Server-Sent Events (SSE)."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, Header
from fastapi.responses import StreamingResponse

from app.core.logging import get_logger
from app.core.rate_limit import rate_limit_dependency
from app.core.security import decode_token
from app.schemas.chat import ChatStreamRequest
from app.services.context_service import context_manager
from app.services.openai_service import openai_service

logger = get_logger(__name__)

router = APIRouter()


async def get_optional_user_id(
    authorization: Annotated[str | None, Header(alias="Authorization")] = None,
) -> str:
    """Extracts user ID from Authorization header if present, or defaults to 'anonymous'."""
    if not authorization or not authorization.startswith("Bearer "):
        return "anonymous_user"
    token = authorization.removeprefix("Bearer ").strip()
    try:
        payload = decode_token(token)
        sub = payload.get("sub")
        return str(sub) if sub else "anonymous_user"
    except Exception:
        return "anonymous_user"


@router.post(
    "/stream",
    summary="Stream conversational completions via SSE",
    description="Streams token-by-token response chunks using Server-Sent Events.",
    dependencies=[Depends(rate_limit_dependency())],
)
async def chat_stream(
    request: ChatStreamRequest,
    user_id: Annotated[str, Depends(get_optional_user_id)],
) -> StreamingResponse:
    """Streams LLM completion tokens over an SSE connection."""
    logger.info(
        "chat_stream_requested",
        conversation_id=request.conversation_id,
        user_id=user_id,
        history_len=len(request.history),
    )

    # Prepare bounded context messages
    messages = context_manager.prepare_messages(
        prompt=request.prompt,
        history=request.history,
        language=request.language,
    )

    stream_generator = openai_service.stream_chat(
        messages=messages,
        user_id=user_id,
        max_tokens=request.max_tokens,
        temperature=request.temperature,
    )

    return StreamingResponse(
        stream_generator,
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )
