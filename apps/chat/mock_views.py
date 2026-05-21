"""
Simplified chat endpoints for frontend integration and early testing.

These three views provide a thin, React/Vite-friendly API that your
frontend can call immediately while the real AI chatbot is being built.

Endpoints
---------
POST /api/v1/chat/start/
    Opens a new ChatSession for the authenticated user.
    Returns: { session_id, title, status, started_at }

POST /api/v1/chat/send/
    Saves the user's message, appends a hardcoded bot reply, and
    returns both messages.
    Body:    { "session_id": "<uuid>", "content": "<text>" }
    Returns: { user_message: {...}, bot_message: {...} }

GET  /api/v1/chat/history/<session_id>/
    Returns all messages in the session in chronological order.
    Returns: { session_id, status, messages: [...] }

Authentication
--------------
All three endpoints require a valid JWT Bearer token in the
Authorization header — the same token issued by POST /api/v1/auth/login/.

CORS
----
Requests from http://localhost:5173 (Vite) and http://localhost:3000 are
allowed by default via CORS_ALLOWED_ORIGINS in settings.
"""
import logging

from django.shortcuts import get_object_or_404
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import ChatMessage, ChatSession
from .serializers import ChatMessageSerializer

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Hardcoded bot responses — replace with real AI calls when ready
# ---------------------------------------------------------------------------
_INITIAL_GREETING = (
    "Hello! I am your mental health assistant. "
    "How are you feeling today?"
)

_FOLLOW_UP_RESPONSES = [
    "Thank you for sharing that with me. Could you tell me more?",
    "I hear you. It takes courage to open up. How long have you been feeling this way?",
    "That sounds really difficult. You are not alone in this. What would help you most right now?",
    "I appreciate your honesty. On a scale of 1 to 10, how would you rate your mood today?",
    "Let us take this one step at a time. What is the main thing on your mind right now?",
]


def _pick_bot_reply(session: ChatSession) -> str:
    """
    Return the greeting for the very first user message,
    then cycle through follow-up responses.
    """
    user_message_count = session.chat_messages.filter(
        role=ChatMessage.RoleChoices.USER
    ).count()

    if user_message_count <= 1:
        return _INITIAL_GREETING

    # Cycle deterministically so repeated calls are predictable in tests
    index = (user_message_count - 2) % len(_FOLLOW_UP_RESPONSES)
    return _FOLLOW_UP_RESPONSES[index]


# ---------------------------------------------------------------------------
# Views
# ---------------------------------------------------------------------------

class ChatStartView(APIView):
    """
    POST /api/v1/chat/start/

    Creates a new ChatSession owned by the requesting user.

    Request body (optional)
    -----------------------
    { "title": "My first session" }

    Response 201
    ------------
    {
        "session_id": "3fa85f64-...",
        "title": "My first session",
        "status": "active",
        "started_at": "2025-01-01T00:00:00Z"
    }
    """

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        title = request.data.get("title", "").strip()
        session = ChatSession.objects.create(
            user=request.user,
            title=title or f"Session — {request.user.first_name or request.user.email}",
        )
        logger.info("ChatSession %s opened for user %s", session.id, request.user.email)
        return Response(
            {
                "session_id": str(session.id),
                "title": session.title,
                "status": session.status,
                "started_at": session.started_at,
            },
            status=status.HTTP_201_CREATED,
        )


class ChatSendView(APIView):
    """
    POST /api/v1/chat/send/

    Saves the user's message, generates a mock bot reply, and returns both.

    Request body
    ------------
    {
        "session_id": "<uuid>",
        "content": "I have been feeling anxious lately."
    }

    Response 200
    ------------
    {
        "user_message": {
            "id": "...", "role": "user", "content": "...", "created_at": "..."
        },
        "bot_message": {
            "id": "...", "role": "assistant", "content": "...", "created_at": "..."
        }
    }

    Errors
    ------
    400 — missing session_id or content
    400 — session is not ACTIVE
    404 — session not found or not owned by this user
    """

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        session_id = request.data.get("session_id")
        content = request.data.get("content", "").strip()

        if not session_id:
            return Response(
                {"detail": "session_id is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if not content:
            return Response(
                {"detail": "content must not be empty."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        session = get_object_or_404(
            ChatSession, pk=session_id, user=request.user
        )

        if session.status != ChatSession.StatusChoices.ACTIVE:
            return Response(
                {
                    "detail": (
                        f"This session is '{session.status}' and no longer accepts messages. "
                        "Start a new session to continue."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Persist the user's message
        user_message = ChatMessage.objects.create(
            session=session,
            role=ChatMessage.RoleChoices.USER,
            content=content,
        )

        # Generate and persist the bot reply
        bot_reply_text = _pick_bot_reply(session)
        bot_message = ChatMessage.objects.create(
            session=session,
            role=ChatMessage.RoleChoices.ASSISTANT,
            content=bot_reply_text,
        )

        return Response(
            {
                "user_message": ChatMessageSerializer(user_message).data,
                "bot_message": ChatMessageSerializer(bot_message).data,
            },
            status=status.HTTP_200_OK,
        )


class ChatHistoryView(APIView):
    """
    GET /api/v1/chat/history/<session_id>/

    Retrieves all messages in a session, ordered chronologically.
    Only the session owner can access this endpoint.

    Response 200
    ------------
    {
        "session_id": "...",
        "title": "...",
        "status": "active",
        "messages": [
            { "id": "...", "role": "user",      "content": "...", "created_at": "..." },
            { "id": "...", "role": "assistant",  "content": "...", "created_at": "..." },
            ...
        ]
    }
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, session_id):
        session = get_object_or_404(
            ChatSession, pk=session_id, user=request.user
        )
        messages = session.chat_messages.order_by("created_at")
        return Response(
            {
                "session_id": str(session.id),
                "title": session.title,
                "status": session.status,
                "messages": ChatMessageSerializer(messages, many=True).data,
            },
            status=status.HTTP_200_OK,
        )
