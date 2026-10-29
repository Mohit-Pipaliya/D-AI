"""User token budget enforcement and usage tracking."""

from __future__ import annotations

import time
from dataclasses import dataclass, field

from app.core.exceptions import AppException
from app.core.logging import get_logger

logger = get_logger(__name__)

DEFAULT_DAILY_TOKEN_BUDGET = 50_000


class TokenBudgetExceededError(AppException):
    """Raised when a user has exceeded their allocated token budget."""

    def __init__(self, detail: str = "Daily token budget exceeded.") -> None:
        super().__init__(
            status_code=429,
            detail=detail,
            error_code="TOKEN_BUDGET_EXCEEDED",
        )


@dataclass
class UserBudgetRecord:
    total_tokens_used: int = 0
    window_start: float = field(default_factory=time.time)


class TokenService:
    """Tracks and enforces per-user token consumption budgets."""

    def __init__(self, daily_budget: int = DEFAULT_DAILY_TOKEN_BUDGET) -> None:
        self.daily_budget = daily_budget
        self._user_usage: dict[str, UserBudgetRecord] = {}

    def _get_or_reset_record(self, user_id: str) -> UserBudgetRecord:
        now = time.time()
        record = self._user_usage.get(user_id)
        # Reset budget after 24 hours (86400 seconds)
        if not record or (now - record.window_start) > 86400:
            record = UserBudgetRecord(total_tokens_used=0, window_start=now)
            self._user_usage[user_id] = record
        return record

    def check_budget(self, user_id: str, estimated_tokens: int = 250) -> None:
        """Verifies that the user has sufficient remaining token budget."""
        record = self._get_or_reset_record(user_id)
        if record.total_tokens_used + estimated_tokens > self.daily_budget:
            logger.warning(
                "token_budget_exhausted",
                user_id=user_id,
                used=record.total_tokens_used,
                budget=self.daily_budget,
            )
            raise TokenBudgetExceededError(
                f"Daily token budget of {self.daily_budget} exceeded. "
                f"Used: {record.total_tokens_used}. Please try again tomorrow."
            )

    def record_usage(self, user_id: str, tokens: int) -> int:
        """Records consumed tokens and returns cumulative daily usage."""
        record = self._get_or_reset_record(user_id)
        record.total_tokens_used += tokens
        logger.info(
            "tokens_consumed",
            user_id=user_id,
            tokens=tokens,
            total_used=record.total_tokens_used,
            budget=self.daily_budget,
        )
        return record.total_tokens_used

    def get_remaining_budget(self, user_id: str) -> int:
        """Returns the number of tokens remaining for the user today."""
        record = self._get_or_reset_record(user_id)
        return max(0, self.daily_budget - record.total_tokens_used)


token_service = TokenService()

