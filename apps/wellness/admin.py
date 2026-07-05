from django.contrib import admin

from .models import Habit, HabitCompletion, JournalEntry, MoodEntry


@admin.register(MoodEntry)
class MoodEntryAdmin(admin.ModelAdmin):
    list_display = ("user", "date", "mood")
    list_filter = ("mood",)
    search_fields = ("user__email",)


@admin.register(JournalEntry)
class JournalEntryAdmin(admin.ModelAdmin):
    list_display = ("user", "date", "created_at")
    search_fields = ("user__email", "content")


@admin.register(Habit)
class HabitAdmin(admin.ModelAdmin):
    list_display = ("user", "name", "icon_key", "is_active")
    list_filter = ("is_active",)
    search_fields = ("user__email", "name")


@admin.register(HabitCompletion)
class HabitCompletionAdmin(admin.ModelAdmin):
    list_display = ("habit", "date")
    search_fields = ("habit__user__email", "habit__name")
