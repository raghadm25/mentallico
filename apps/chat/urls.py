"""
URL routes for the chat app.

Frontend-integration routes (no auth required, exact React JSON contract)
--------------------------------------------------------------------------
  POST  /api/v1/chat/start/                    open a session  → { session_id }
  POST  /api/v1/chat/send/                     send message    → { user_message, bot_message }
  GET   /api/v1/chat/history/<session_id>/     load history    → { session_id, messages }

Full RESTful routes (JWT auth, ViewSet-based)
---------------------------------------------
  /api/v1/chat/sessions/                       session CRUD
  /api/v1/chat/sessions/<id>/message/          append a message
  /api/v1/chat/sessions/<id>/complete/         close a session
  /api/v1/chat/sessions/<id>/analyze/          run NLP → DiagnosisReport
  /api/v1/chat/sessions/<id>/messages/         read-only nested messages
"""
from django.urls import include, path
from rest_framework.routers import DefaultRouter
from rest_framework_nested import routers as nested_routers

from .frontend_views import ChatHistoryView, ChatSendView, ChatStartView
from .views import ChatMessageViewSet, ChatSessionViewSet

# ---------------------------------------------------------------------------
# Full RESTful router
# ---------------------------------------------------------------------------
router = DefaultRouter()
router.register(r"sessions", ChatSessionViewSet, basename="chat-session")

sessions_router = nested_routers.NestedDefaultRouter(
    router, r"sessions", lookup="session"
)
sessions_router.register(r"messages", ChatMessageViewSet, basename="session-messages")

# ---------------------------------------------------------------------------
# URL patterns
# ---------------------------------------------------------------------------
urlpatterns = [
    # --- Frontend-integration (simple, no auth) ---
    path("start/", ChatStartView.as_view(), name="chat-start"),
    path("send/", ChatSendView.as_view(), name="chat-send"),
    path("history/<uuid:session_id>/", ChatHistoryView.as_view(), name="chat-history"),

    # --- Full REST API ---
    path("", include(router.urls)),
    path("", include(sessions_router.urls)),
]
