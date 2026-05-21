from django.contrib import admin

from .models import ChatMessage, ChatSession, DiagnosisReport


class ChatMessageInline(admin.TabularInline):
    model = ChatMessage
    extra = 0
    fields = ("role", "content", "token_count", "created_at")
    readonly_fields = ("created_at",)
    ordering = ("created_at",)


class DiagnosisReportInline(admin.StackedInline):
    model = DiagnosisReport
    extra = 0
    readonly_fields = (
        "sentiment_score", "sentiment_label", "disorder_tags",
        "severity", "summary", "recommendations", "is_mock",
        "created_at", "updated_at",
    )
    can_delete = False

    def has_add_permission(self, request, obj=None):
        return False


@admin.register(ChatSession)
class ChatSessionAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "status", "message_count", "started_at", "ended_at")
    list_filter = ("status",)
    search_fields = ("user__email",)
    readonly_fields = ("id", "started_at", "updated_at")
    inlines = [ChatMessageInline, DiagnosisReportInline]

    def message_count(self, obj):
        return obj.message_count
    message_count.short_description = "Messages"


@admin.register(ChatMessage)
class ChatMessageAdmin(admin.ModelAdmin):
    list_display = ("id", "session", "role", "created_at")
    list_filter = ("role",)
    search_fields = ("content", "session__user__email")
    readonly_fields = ("id", "created_at")


@admin.register(DiagnosisReport)
class DiagnosisReportAdmin(admin.ModelAdmin):
    list_display = (
        "session", "sentiment_label", "severity", "is_mock", "created_at"
    )
    list_filter = ("severity", "sentiment_label", "is_mock")
    search_fields = ("session__user__email",)
    readonly_fields = (
        "session", "sentiment_score", "sentiment_label", "disorder_tags",
        "severity", "summary", "recommendations", "is_mock",
        "created_at", "updated_at",
    )

    def has_add_permission(self, request):
        return False
