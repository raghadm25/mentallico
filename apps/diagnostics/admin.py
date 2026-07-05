from django.contrib import admin

from .models import DiagnosticReport


@admin.register(DiagnosticReport)
class DiagnosticReportAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "session", "status", "severity_level", "created_at")
    list_filter = ("status", "severity_level", "sentiment_label")
    search_fields = ("user__email",)
    readonly_fields = (
        "id", "session", "user",
        "overall_sentiment_score", "sentiment_label", "subjectivity_score",
        "top_keywords", "bigrams", "trigrams", "identified_patterns",
        "severity_level", "summary", "recommendations",
        "error_message", "created_at", "updated_at",
    )

    def has_add_permission(self, request):
        return False
