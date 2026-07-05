"""
Serializers for chat sessions, messages, and inline diagnosis reports.
"""
from rest_framework import serializers

from .models import ChatMessage, ChatSession, DiagnosisReport


class ChatMessageSerializer(serializers.ModelSerializer):
    """
    Serializes a single ChatMessage.
    The parent session is injected by the view — callers never send it.
    """

    class Meta:
        model = ChatMessage
        fields = ("id", "role", "content", "token_count", "created_at")
        read_only_fields = ("id", "token_count", "created_at")

    def validate_role(self, value):
        valid = {ChatMessage.RoleChoices.USER, ChatMessage.RoleChoices.ASSISTANT}
        if value not in valid:
            raise serializers.ValidationError(
                f"role must be one of: {sorted(valid)}"
            )
        return value


class DiagnosisReportSerializer(serializers.ModelSerializer):
    """Read-only representation of an inline DiagnosisReport."""

    class Meta:
        model = DiagnosisReport
        fields = (
            "sentiment_score",
            "sentiment_label",
            "disorder_tags",
            "severity",
            "summary",
            "recommendations",
            "is_mock",
            "created_at",
            "updated_at",
        )
        read_only_fields = fields


class ChatSessionSerializer(serializers.ModelSerializer):
    """
    Full session representation — includes all messages and the diagnosis
    report if one exists.  Used for retrieve and list endpoints.
    """

    chat_messages = ChatMessageSerializer(many=True, read_only=True)
    diagnosis_report = DiagnosisReportSerializer(read_only=True)
    message_count = serializers.ReadOnlyField()
    user_email = serializers.EmailField(source="user.email", read_only=True)

    class Meta:
        model = ChatSession
        fields = (
            "id",
            "user_email",
            "title",
            "status",
            "message_count",
            "chat_messages",
            "diagnosis_report",
            "started_at",
            "ended_at",
            "updated_at",
        )
        read_only_fields = (
            "id", "user_email", "message_count",
            "started_at", "updated_at",
        )


class ChatSessionCreateSerializer(serializers.ModelSerializer):
    """Lightweight serializer — only the fields needed to open a session."""

    class Meta:
        model = ChatSession
        fields = ("id", "title", "status", "started_at")
        read_only_fields = ("id", "status", "started_at")


class ChatSessionCompleteSerializer(serializers.ModelSerializer):
    """Validates and applies the status transition to COMPLETED."""

    class Meta:
        model = ChatSession
        fields = ("id", "status", "ended_at")
        read_only_fields = ("id",)

    def validate_status(self, value):
        if value != ChatSession.StatusChoices.COMPLETED:
            raise serializers.ValidationError(
                "Only 'completed' is a valid target status for this action."
            )
        return value
