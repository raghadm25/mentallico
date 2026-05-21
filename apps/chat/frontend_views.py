"""
Frontend-contract views for the Vite/React chat interface.

These views return JSON shaped to match the React component state exactly:

  Message object  →  { id, text, sender: "user"|"bot", type: "text" }

Three endpoints
---------------
POST /api/v1/chat/start/
    Opens a new ChatSession. No auth required.
    Response: { session_id }

POST /api/v1/chat/send/
    Saves the user message, returns a hardcoded bot reply.
    Body:     { session_id, message }
    Response: { user_message, bot_message }   (both shaped as message objects)

GET  /api/v1/chat/history/<session_id>/
    Returns all messages for a session, oldest first.
    Response: { session_id, messages: [...] }

Authentication
--------------
All three endpoints are open (AllowAny) so the frontend team can test
immediately without an auth flow. Sessions are tracked by session_id which
the client stores in localStorage.

Unregistered users are linked to a shared guest account so the ChatSession
FK constraint is satisfied. Once the frontend wires up login, pass the JWT
and the real authenticated user will be used automatically.
"""
import logging

from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import ChatMessage, ChatSession

logger = logging.getLogger(__name__)

User = get_user_model()

# ---------------------------------------------------------------------------
# Hardcoded bot responses (replace with real AI later)
# ---------------------------------------------------------------------------
_RESPONSES = [
    "Hello! I am your mental health assistant. How are you feeling today?",
    "Thank you for sharing that with me. Could you tell me more about what you are experiencing?",
    "I hear you. It takes courage to open up. How long have you been feeling this way?",
    "That sounds really difficult. You are not alone in this. What would help you most right now?",
    "I appreciate your honesty. On a scale of 1 to 10, how would you rate your mood today?",
    "Let us take this one step at a time. What is the main thing on your mind right now?",
    "I am processing everything you have shared. Remember, seeking support is a sign of strength.",
    "It is okay to feel this way. Would you like to explore some coping strategies together?",
]


def _pick_response(session: ChatSession) -> str:
    """Cycle through responses based on how many user turns exist."""
    user_count = session.chat_messages.filter(
        role=ChatMessage.RoleChoices.USER
    ).count()
    index = min(user_count - 1, len(_RESPONSES) - 1)
    return _RESPONSES[index % len(_RESPONSES)]


# ---------------------------------------------------------------------------
# Guest user helper
# ---------------------------------------------------------------------------
def _resolve_user(request):
    """
    Return the authenticated user if a valid JWT is present,
    otherwise return (or create) a shared guest account.
    """
    if request.user and request.user.is_authenticated:
        return request.user

    guest, created = User.objects.get_or_create(
        email="guest@mentallico.local",
        defaults={"first_name": "Guest", "last_name": "User"},
    )
    if created:
        guest.set_unusable_password()
        guest.save(update_fields=["password"])
    return guest


# ---------------------------------------------------------------------------
# Serialization helper
# ---------------------------------------------------------------------------
def _serialize_message(msg: ChatMessage) -> dict:
    """
    Convert a ChatMessage to the shape React expects:
      { id, text, sender: "user"|"bot", type: "text" }
    """
    return {
        "id": str(msg.id),
        "text": msg.content,
        "sender": "bot" if msg.role == ChatMessage.RoleChoices.ASSISTANT else "user",
        "type": "text",
    }


# ---------------------------------------------------------------------------
# Views
# ---------------------------------------------------------------------------

class ChatStartView(APIView):
    """
    POST /api/v1/chat/start/

    Opens a new active ChatSession.

    Request body (optional)
    -----------------------
    { "title": "optional session name" }

    Response 201
    ------------
    { "session_id": "<uuid>" }
    """

    permission_classes = [permissions.AllowAny]

    def post(self, request):
        user = _resolve_user(request)
        title = (request.data.get("title") or "").strip()

        session = ChatSession.objects.create(
            user=user,
            title=title or "New conversation",
        )
        logger.info("ChatSession %s started (user=%s)", session.id, user.email)

        return Response(
            {"session_id": str(session.id)},
            status=status.HTTP_201_CREATED,
        )


class ChatSendView(APIView):
    """
    POST /api/v1/chat/send/

    Accepts a user message, saves it, and returns a hardcoded bot reply.

    Request body
    ------------
    {
        "session_id": "<uuid>",
        "message":    "I have been feeling anxious lately."
    }

    Response 200
    ------------
    {
        "user_message": { "id": "...", "text": "...", "sender": "user", "type": "text" },
        "bot_message":  { "id": "...", "text": "...", "sender": "bot",  "type": "text" }
    }

    Errors
    ------
    400 — session_id or message missing / session not active
    404 — session not found
    """

    permission_classes = [permissions.AllowAny]

    def post(self, request):
        session_id = request.data.get("session_id", "").strip()
        message_text = request.data.get("message", "").strip()

        if not session_id:
            return Response(
                {"detail": "session_id is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if not message_text:
            return Response(
                {"detail": "message must not be empty."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        session = get_object_or_404(ChatSession, pk=session_id)

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

        user_msg = ChatMessage.objects.create(
            session=session,
            role=ChatMessage.RoleChoices.USER,
            content=message_text,
        )
        bot_reply = _pick_response(session)
        bot_msg = ChatMessage.objects.create(
            session=session,
            role=ChatMessage.RoleChoices.ASSISTANT,
            content=bot_reply,
        )

        return Response(
            {
                "user_message": _serialize_message(user_msg),
                "bot_message": _serialize_message(bot_msg),
            },
            status=status.HTTP_200_OK,
        )


class ChatHistoryView(APIView):
    """
    GET /api/v1/chat/history/<session_id>/

    Returns all messages in a session, oldest first.

    Response 200
    ------------
    {
        "session_id": "...",
        "title":      "...",
        "status":     "active",
        "messages": [
            { "id": "...", "text": "...", "sender": "user", "type": "text" },
            { "id": "...", "text": "...", "sender": "bot",  "type": "text" }
        ]
    }
    """

    permission_classes = [permissions.AllowAny]

    def get(self, request, session_id):
        session = get_object_or_404(ChatSession, pk=session_id)
        messages = session.chat_messages.order_by("created_at")

        return Response(
            {
                "session_id": str(session.id),
                "title": session.title,
                "status": session.status,
                "messages": [_serialize_message(m) for m in messages],
            },
            status=status.HTTP_200_OK,
        )
