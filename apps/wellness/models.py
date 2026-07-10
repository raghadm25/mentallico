"""
Personal self-tracking models for the User Profile page:
daily mood log, freeform journal entries, and habit completion tracking.
"""
from django.conf import settings
from django.core.validators import MaxValueValidator
from django.db import models


class MoodEntry(models.Model):
    """One logged mood per user per calendar day."""

    class MoodChoices(models.TextChoices):
        HAPPY = "happy", "Happy"
        CALM = "calm", "Calm"
        MOTIVATED = "motivated", "Motivated"
        HOPEFUL = "hopeful", "Hopeful"
        TIRED = "tired", "Tired"
        STRESSED = "stressed", "Stressed"
        ANXIOUS = "anxious", "Anxious"
        NUMB = "numb", "Numb"
        LONELY = "lonely", "Lonely"
        SAD = "sad", "Sad"

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="mood_entries"
    )
    date = models.DateField()
    mood = models.CharField(max_length=20, choices=MoodChoices.choices)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "mood entry"
        verbose_name_plural = "mood entries"
        unique_together = ("user", "date")
        ordering = ["-date"]

    def __str__(self):
        return f"{self.user.email} — {self.date} — {self.mood}"


class JournalEntry(models.Model):
    """A short freeform note the user wrote for a given day."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="journal_entries"
    )
    date = models.DateField()
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "journal entry"
        verbose_name_plural = "journal entries"
        unique_together = ("user", "date")
        ordering = ["-date"]

    def __str__(self):
        preview = self.content[:40] + "..." if len(self.content) > 40 else self.content
        return f"{self.user.email} — {self.date}: {preview}"


class Habit(models.Model):
    """A habit the user is tracking (e.g. 'Daily Gratitude')."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="habits"
    )
    name = models.CharField(max_length=100)
    icon_key = models.CharField(
        max_length=50,
        blank=True,
        help_text="Frontend icon/theme identifier, e.g. 'gratitude', 'reading', 'breathing'.",
    )
    progress = models.PositiveSmallIntegerField(
        default=0,
        validators=[MaxValueValidator(100)],
        help_text="User-controlled progress (0-100), adjusted directly via +/- in the UI "
        "rather than derived from daily completions.",
    )
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "habit"
        verbose_name_plural = "habits"
        ordering = ["created_at"]

    def __str__(self):
        return f"{self.user.email} — {self.name}"


class HabitCompletion(models.Model):
    """One completed day for a habit."""

    habit = models.ForeignKey(Habit, on_delete=models.CASCADE, related_name="completions")
    date = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "habit completion"
        verbose_name_plural = "habit completions"
        unique_together = ("habit", "date")
        ordering = ["-date"]

    def __str__(self):
        return f"{self.habit.name} — {self.date}"
