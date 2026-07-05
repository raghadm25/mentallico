"""
Client for the Mentallico AI Hugging Face Space (stateful chat API).

Space:  https://huggingface.co/spaces/Ziad9022/Mentallico-API-v2
API:    https://ziad9022-mentallico-api-v2.hf.space/docs

Each Django ChatSession is linked to a remote HF session (ChatSession.hf_session_id)
so the model keeps multi-turn conversational context across /chat/send/ calls.
"""
import logging

import requests
from django.conf import settings

logger = logging.getLogger(__name__)


class AIServiceError(Exception):
    """Raised when the Hugging Face Space is unreachable or returns an error."""


def _headers() -> dict:
    headers = {"Content-Type": "application/json"}
    if settings.HF_API_TOKEN:
        headers["Authorization"] = f"Bearer {settings.HF_API_TOKEN}"
    return headers


def _create_remote_session() -> str:
    url = f"{settings.HF_SPACE_BASE_URL}/api/v2/session/create"
    try:
        resp = requests.post(url, headers=_headers(), timeout=settings.HF_API_TIMEOUT_SECONDS)
        resp.raise_for_status()
    except requests.RequestException as exc:
        logger.error("Failed to create Hugging Face session: %s", exc)
        raise AIServiceError("Could not reach the AI service. Please try again shortly.") from exc
    return resp.json()["session_id"]


def _send_remote_message(hf_session_id: str, text: str) -> dict:
    url = f"{settings.HF_SPACE_BASE_URL}/api/v2/session/{hf_session_id}/message"
    try:
        resp = requests.post(
            url, headers=_headers(), json={"text": text}, timeout=settings.HF_API_TIMEOUT_SECONDS
        )
        resp.raise_for_status()
    except requests.RequestException as exc:
        logger.error("Hugging Face message call failed: %s", exc)
        raise AIServiceError("The AI service is currently unavailable. Please try again.") from exc
    return resp.json()


def get_ai_reply(session, text: str) -> str:
    """
    Forward `text` to the AI Space on behalf of `session` (an apps.chat.models.ChatSession)
    and return the assistant's reply text.

    Lazily creates a remote HF session on first use and persists it on `session` so later
    turns stay in the same conversation. Free-tier Spaces can restart and drop sessions, so
    a single retry with a fresh remote session is attempted before giving up.
    """
    if not session.hf_session_id:
        session.hf_session_id = _create_remote_session()
        session.save(update_fields=["hf_session_id"])

    try:
        data = _send_remote_message(session.hf_session_id, text)
    except AIServiceError:
        session.hf_session_id = _create_remote_session()
        session.save(update_fields=["hf_session_id"])
        data = _send_remote_message(session.hf_session_id, text)

    return data.get("response", "").strip() or (
        "I'm here, but I didn't quite catch that — could you rephrase?"
    )
