"""
Views for chat sessions, messages, and inline diagnostic analysis.
"""
import logging

from django.utils import timezone
from rest_framework import permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import PermissionDenied, ValidationError
from rest_framework.response import Response

from .models import ChatMessage, ChatSession, DiagnosisReport
from .serializers import (
    ChatMessageSerializer,
    ChatSessionCompleteSerializer,
    ChatSessionCreateSerializer,
    ChatSessionSerializer,
    DiagnosisReportSerializer,
)
from .services import run_analysis

logger = logging.getLogger(__name__)


class ChatSessionViewSet(viewsets.ModelViewSet):
    """
    Full CRUD for the authenticated user's chat sessions, plus custom
    actions for closing a session and triggering inline NLP analysis.

    Endpoints
    ---------
    GET    /api/v1/chat/sessions/                  list all sessions
    POST   /api/v1/chat/sessions/                  open a new session
    GET    /api/v1/chat/sessions/{id}/             session detail + messages + report
    PATCH  /api/v1/chat/sessions/{id}/             update title
    DELETE /api/v1/chat/sessions/{id}/             delete (blocked if ANALYZED)
    POST   /api/v1/chat/sessions/{id}/message/     append a message
    POST   /api/v1/chat/sessions/{id}/complete/    mark session COMPLETED
    POST   /api/v1/chat/sessions/{id}/analyze/     run NLP and store DiagnosisReport
    """

    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return (
            ChatSession.objects
            .filter(user=self.request.user)
            .prefetch_related("chat_messages")
            .select_related("diagnosis_report")
        )

    def get_serializer_class(self):
        if self.action == "create":
            return ChatSessionCreateSerializer
        if self.action == "complete":
            return ChatSessionCompleteSerializer
        return ChatSessionSerializer

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def destroy(self, request, *args, **kwargs):
        session = self.get_object()
        if session.status == ChatSession.StatusChoices.ANALYZED:
            raise ValidationError(
                "Analyzed sessions cannot be deleted because they are "
                "linked to a DiagnosisReport."
            )
        return super().destroy(request, *args, **kwargs)

    # ------------------------------------------------------------------ #
    # Custom actions                                                        #
    # ------------------------------------------------------------------ #

    @action(detail=True, methods=["post"], url_path="message")
    def add_message(self, request, pk=None):
        """
        Append a single message to an ACTIVE session.

        POST /api/v1/chat/sessions/{id}/message/
        Body: { "role": "user" | "assistant", "content": "<text>" }
        """
        session = self.get_object()
        if session.status != ChatSession.StatusChoices.ACTIVE:
            raise ValidationError(
                f"Messages can only be added to active sessions "
                f"(current status: '{session.status}')."
            )
        serializer = ChatMessageSerializer(
            data=request.data, context={"request": request}
        )
        serializer.is_valid(raise_exception=True)
        serializer.save(session=session)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["post"], url_path="complete")
    def complete(self, request, pk=None):
        """
        Transition a session from ACTIVE to COMPLETED.

        POST /api/v1/chat/sessions/{id}/complete/
        Stamps ended_at and returns the updated session object.
        """
        session = self.get_object()
        if session.status != ChatSession.StatusChoices.ACTIVE:
            raise ValidationError(
                f"Cannot complete a session with status '{session.status}'."
            )
        session.status = ChatSession.StatusChoices.COMPLETED
        session.ended_at = timezone.now()
        session.save(update_fields=["status", "ended_at"])
        return Response(
            ChatSessionSerializer(session, context={"request": request}).data,
            status=status.HTTP_200_OK,
        )

    @action(detail=True, methods=["post"], url_path="analyze")
    def analyze(self, request, pk=None):
        """
        Run NLP analysis on a COMPLETED session and persist a DiagnosisReport.

        POST /api/v1/chat/sessions/{id}/analyze/

        - Idempotent: calling it again on a session that already has a report
          will re-run the analysis and overwrite the previous result.
        - After successful analysis the session status is set to ANALYZED.

        Response (200 OK)
        -----------------
        The DiagnosisReport payload.
        """
        session = self.get_object()

        if session.status not in (
            ChatSession.StatusChoices.COMPLETED,
            ChatSession.StatusChoices.ANALYZED,
        ):
            raise ValidationError(
                "Analysis can only be run on COMPLETED or ANALYZED sessions. "
                f"Current status: '{session.status}'."
            )

        transcript = session.full_transcript
        if not transcript:
            raise ValidationError(
                "Cannot analyse an empty session — add messages before analyzing."
            )

        results = run_analysis(transcript)

        report, _ = DiagnosisReport.objects.update_or_create(
            session=session,
            defaults={
                "sentiment_score": results["sentiment_score"],
                "sentiment_label": results["sentiment_label"],
                "disorder_tags": results["disorder_tags"],
                "severity": results["severity"],
                "summary": results["summary"],
                "recommendations": results["recommendations"],
                "is_mock": results["is_mock"],
            },
        )

        # Advance status only if not already ANALYZED
        if session.status != ChatSession.StatusChoices.ANALYZED:
            session.status = ChatSession.StatusChoices.ANALYZED
            session.save(update_fields=["status"])

        logger.info(
            "DiagnosisReport created for session %s — severity=%s is_mock=%s",
            session.id,
            report.severity,
            report.is_mock,
        )
        return Response(
            DiagnosisReportSerializer(report).data,
            status=status.HTTP_200_OK,
        )


class ChatMessageViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Read-only access to messages within a specific session.

    GET /api/v1/chat/sessions/{session_pk}/messages/
    GET /api/v1/chat/sessions/{session_pk}/messages/{id}/
    """

    serializer_class = ChatMessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        session_pk = self.kwargs.get("session_pk")
        try:
            session = ChatSession.objects.get(
                pk=session_pk, user=self.request.user
            )
        except ChatSession.DoesNotExist:
            raise PermissionDenied("Session not found or access denied.")
        return ChatMessage.objects.filter(session=session)
