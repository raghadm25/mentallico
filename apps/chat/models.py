"""
Chat session, message, and inline diagnosis models.
"""
import uuid

from django.conf import settings
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class ChatSession(models.Model):
    """
    Groups all messages belonging to a single diagnostic conversation.

    State machine
    -------------
    ACTIVE  → user is chatting
    COMPLETED → session closed, ready for analysis
    ANALYZED  → DiagnosisReport has been generated
    """

    class StatusChoices(models.TextChoices):
        ACTIVE = "active", "Active"
        COMPLETED = "completed", "Completed"
        ANALYZED = "analyzed", "Analyzed"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="chat_sessions",
    )
    title = models.CharField(
        max_length=255,
        blank=True,
        help_text="Auto-generated or user-defined label for this session.",
    )
    status = models.CharField(
        max_length=20,
        choices=StatusChoices.choices,
        default=StatusChoices.ACTIVE,
        db_index=True,
    )
    started_at = models.DateTimeField(auto_now_add=True)
    ended_at = models.DateTimeField(null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "chat session"
        verbose_name_plural = "chat sessions"
        ordering = ["-started_at"]

    def __str__(self):
        return f"Session {self.id} — {self.user.email} [{self.status}]"

    # ------------------------------------------------------------------
    # Convenience helpers used by the NLP service and serializers
    # ------------------------------------------------------------------

    @property
    def message_count(self):
        return self.chat_messages.count()

    @property
    def full_transcript(self):
        """
        Returns an ordered list of (role, content) tuples.
        Passed directly into services.run_analysis().
        """
        return list(
            self.chat_messages.order_by("created_at").values_list("role", "content")
        )

    @property
    def user_text(self):
        """
        Concatenated text of all user-authored messages.
        Convenient shorthand for the mock / real NLP service.
        """
        parts = (
            self.chat_messages
            .filter(role=ChatMessage.RoleChoices.USER)
            .order_by("created_at")
            .values_list("content", flat=True)
        )
        return " ".join(parts)


class ChatMessage(models.Model):
    """
    A single turn inside a ChatSession.

    role='user'      — patient's message
    role='assistant' — AI / bot response
    """

    class RoleChoices(models.TextChoices):
        USER = "user", "User"
        ASSISTANT = "assistant", "Assistant"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    session = models.ForeignKey(
        ChatSession,
        on_delete=models.CASCADE,
        related_name="chat_messages",
    )
    role = models.CharField(
        max_length=10,
        choices=RoleChoices.choices,
        db_index=True,
    )
    content = models.TextField()
    token_count = models.PositiveIntegerField(
        default=0,
        help_text="Approximate token count for cost / rate-limit accounting.",
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "chat message"
        verbose_name_plural = "chat messages"
        ordering = ["created_at"]

    def __str__(self):
        preview = self.content[:60] + "..." if len(self.content) > 60 else self.content
        return f"[{self.role}] {preview}"


class DiagnosisReport(models.Model):
    """
    Inline analysis result attached to a completed ChatSession.

    Stores the output of services.run_analysis() — either the live NLP
    pipeline or the mock implementation used during development.

    Fields
    ------
    sentiment_score  — polarity in [-1.0, +1.0]
    disorder_tags    — list of detected pattern labels, e.g.
                       ["anxiety_indicators", "sleep_issues"]
    summary          — human-readable narrative generated from the analysis
    is_mock          — True when produced by the placeholder service;
                       False once a real NLP model is wired in
    """

    class SeverityChoices(models.TextChoices):
        NONE = "none", "None / Minimal"
        MILD = "mild", "Mild"
        MODERATE = "moderate", "Moderate"
        SEVERE = "severe", "Severe"

    session = models.OneToOneField(
        ChatSession,
        on_delete=models.CASCADE,
        related_name="diagnosis_report",
    )
    sentiment_score = models.FloatField(
        null=True,
        blank=True,
        validators=[MinValueValidator(-1.0), MaxValueValidator(1.0)],
        help_text="Overall polarity of the patient's messages in [-1.0, +1.0].",
    )
    sentiment_label = models.CharField(
        max_length=20,
        blank=True,
        help_text="Derived label: 'positive', 'neutral', or 'negative'.",
    )
    disorder_tags = models.JSONField(
        default=list,
        blank=True,
        help_text="List of detected pattern/category labels.",
    )
    severity = models.CharField(
        max_length=20,
        choices=SeverityChoices.choices,
        default=SeverityChoices.NONE,
    )
    summary = models.TextField(
        blank=True,
        help_text="Narrative generated from the NLP results.",
    )
    recommendations = models.JSONField(
        default=list,
        blank=True,
        help_text="Suggested resource tags or actions for the patient.",
    )
    is_mock = models.BooleanField(
        default=True,
        help_text="Set to False once a production NLP model is integrated.",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "diagnosis report"
        verbose_name_plural = "diagnosis reports"
        ordering = ["-created_at"]

    def __str__(self):
        mock_tag = " [MOCK]" if self.is_mock else ""
        return f"Report for {self.session_id}{mock_tag} — {self.severity}"
