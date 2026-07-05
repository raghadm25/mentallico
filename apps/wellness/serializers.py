"""
Serializers for mood entries, journal entries, and habit tracking.
"""
from django.utils import timezone
from rest_framework import serializers

from .models import Habit, HabitCompletion, JournalEntry, MoodEntry


class MoodEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = MoodEntry
        fields = ("id", "date", "mood", "created_at", "updated_at")
        read_only_fields = ("id", "created_at", "updated_at")


class JournalEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = JournalEntry
        fields = ("id", "date", "content", "created_at", "updated_at")
        read_only_fields = ("id", "created_at", "updated_at")


class HabitSerializer(serializers.ModelSerializer):
    is_completed_today = serializers.SerializerMethodField()
    completion_rate = serializers.SerializerMethodField()

    class Meta:
        model = Habit
        fields = ("id", "name", "icon_key", "is_completed_today", "completion_rate", "created_at")
        read_only_fields = fields

    def get_is_completed_today(self, obj):
        today = timezone.localdate()
        return obj.completions.filter(date=today).exists()

    def get_completion_rate(self, obj):
        """Percentage of the last 7 days (including today) this habit was completed."""
        today = timezone.localdate()
        window_start = today - timezone.timedelta(days=6)
        completed = obj.completions.filter(date__gte=window_start, date__lte=today).count()
        return round((completed / 7) * 100)
