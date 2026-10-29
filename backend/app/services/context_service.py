"""Context window management and conversation summarization."""

from __future__ import annotations

from typing import TYPE_CHECKING

from app.core.config import settings
from app.core.logging import get_logger
from app.schemas.chat import ChatMessage

if TYPE_CHECKING:
    import tiktoken

logger = get_logger(__name__)

SYSTEM_PROMPT_TEMPLATE = (
    "You are {app_name} (pronounced 'Dee'), a privacy-first, voice-first AI assistant.\n"
    "Persona: friendly, caring, funny, helpful, and smart (Siri + Google Assistant + Jarvis).\n"
    "CRITICAL CONSTRAINTS:\n"
    "1. Voice replies MUST be concise: maximum 2 lines for spoken output.\n"
    "2. If longer answer required, provide 1-2 line summary, then clear bullet points.\n"
    "3. Match user language naturally: Hindi, English, Hinglish, or Gujarati.\n"
    "4. Never output passwords, financial credentials, or private internal secrets."
)

MAX_CONTEXT_TOKENS = 3000
KEEP_RECENT_TURNS = 6


class ContextManager:
    """Manages LLM context budget, token counting, and historical turn pruning."""

    def __init__(self) -> None:
        self._tokenizer = self._init_tokenizer()

    def _init_tokenizer(self) -> tiktoken.Encoding | None:
        try:
            import tiktoken

            return tiktoken.get_encoding("cl100k_base")
        except Exception as e:
            logger.warning("tiktoken_init_failed", error=str(e))
            return None

    def count_tokens(self, text: str) -> int:
        """Count tokens accurately with tiktoken or fallback to 4 chars per token."""
        if not text:
            return 0
        if self._tokenizer:
            try:
                return len(self._tokenizer.encode(text))
            except Exception as e:
                logger.debug("token_encode_fallback", error=str(e))
        return max(1, len(text) // 4)

    def count_messages_tokens(self, messages: list[dict[str, str]]) -> int:
        """Count total tokens across a list of message dicts."""
        total = 0
        for msg in messages:
            total += 4  # message overhead
            total += self.count_tokens(msg.get("content", ""))
        return total

    def prepare_messages(
        self,
        prompt: str,
        history: list[ChatMessage],
        language: str | None = None,
    ) -> list[dict[str, str]]:
        """Prepares a bounded context message payload for OpenAI completions.

        Summarizes older turns if the historical context exceeds `MAX_CONTEXT_TOKENS`.
        """
        system_content = SYSTEM_PROMPT_TEMPLATE.format(app_name=settings.APP_NAME)
        if language and language != "en":
            system_content += f"\nActive User Language Preference: {language}."

        prepared: list[dict[str, str]] = [{"role": "system", "content": system_content}]

        # If history is long, prune or summarize older turns
        if len(history) > KEEP_RECENT_TURNS:
            older_turns = history[:-KEEP_RECENT_TURNS]
            recent_turns = history[-KEEP_RECENT_TURNS:]

            summary_bullet_points = []
            for m in older_turns:
                snippet = m.content[:120] + ("..." if len(m.content) > 120 else "")
                summary_bullet_points.append(f"- {m.role}: {snippet}")

            summary_text = "Previous conversation context:\n" + "\n".join(summary_bullet_points)
            prepared.append({"role": "system", "content": summary_text})

            for m in recent_turns:
                prepared.append({"role": m.role, "content": m.content})
        else:
            for m in history:
                prepared.append({"role": m.role, "content": m.content})

        # Append current user prompt
        prepared.append({"role": "user", "content": prompt})

        # Check total token count; if still exceeding budget, drop oldest user/assistant turns
        while len(prepared) > 2 and self.count_messages_tokens(prepared) > MAX_CONTEXT_TOKENS:
            # Drop the earliest non-system turn
            dropped = False
            for i, msg in enumerate(prepared):
                if msg["role"] != "system":
                    prepared.pop(i)
                    dropped = True
                    break
            if not dropped:
                break

        return prepared


context_manager = ContextManager()
