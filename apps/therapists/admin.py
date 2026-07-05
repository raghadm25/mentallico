from django.contrib import admin

from .models import Therapist


@admin.register(Therapist)
class TherapistAdmin(admin.ModelAdmin):
    list_display = (
        "name",
        "title",
        "specialty",
        "experience",
        "languages",
        "rating",
        "review_count",
        "price",
        "is_active",
    )
    list_filter = ("is_active", "experience", "rating")
    search_fields = ("name", "title", "specialty", "languages", "bio")
    list_editable = ("is_active", "price", "rating")
    ordering = ("-rating", "name")
    readonly_fields = ("created_at", "updated_at")

    fieldsets = (
        (None, {
            "fields": ("name", "title", "specialty", "is_active"),
        }),
        ("Details", {
            "fields": ("experience", "languages", "rating", "review_count", "price"),
        }),
        ("Profile", {
            "fields": ("img", "bio"),
        }),
        ("Timestamps", {
            "fields": ("created_at", "updated_at"),
            "classes": ("collapse",),
        }),
    )
