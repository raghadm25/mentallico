"""
Serializers for diagnostic reports.
"""
from rest_framework import serializers

from .models import DiagnosticReport


class DiagnosticReportSerializer(serializers.ModelSerializer):
    """Full read-only representation of a diagnostic report."""

    session_id = serializers.UUIDField(source="session.id", read_only=True)
    user_email = serializers.EmailField(source="user.email", read_only=True)

    class Meta:
        model = DiagnosticReport
        fields = (
            "id",
            "session_id",
            "user_email",
            "status",
            "overall_sentiment_score",
            "sentiment_label",
            "subjectivity_score",
            "top_keywords",
            "bigrams",
            "trigrams",
            "identified_patterns",
            "severity_level",
            "summary",
            "recommendations",
            "error_message",
            "created_at",
            "updated_at",
        )
        read_only_fields = fields


class TriggerAnalysisSerializer(serializers.Serializer):
    """
    Input serializer for the trigger-analysis endpoint.
    Validates that the referenced session belongs to the requesting user
    and is in a state that allows analysis.
    """

    session_id = serializers.UUIDField()

    def validate_session_id(self, value):
        from apps.chat.models import ChatSession

        request = self.context["request"]
        try:
            session = ChatSession.objects.get(pk=value, user=request.user)
        except ChatSession.DoesNotExist:
            raise serializers.ValidationError(
                "Session not found or you do not have permission to analyze it."
            )

        if session.status != ChatSession.StatusChoices.COMPLETED:
            raise serializers.ValidationError(
                f"Session must be in 'completed' status to trigger analysis. "
                f"Current status: '{session.status}'."
            )

        if hasattr(session, "diagnostic_report"):
            existing = session.diagnostic_report
            if existing.status in (
                DiagnosticReport.StatusChoices.PROCESSING,
                DiagnosticReport.StatusChoices.COMPLETED,
            ):
                raise serializers.ValidationError(
                    f"A diagnostic report already exists for this session "
                    f"(status: {existing.status})."
                )

        return value
