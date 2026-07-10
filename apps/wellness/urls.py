"""
URL routes for the wellness app (mood calendar, journal, habits).
"""
from django.urls import path

from .views import (
    HabitDetailView,
    HabitListView,
    HabitToggleView,
    JournalEntryDetailView,
    JournalWeekView,
    MoodCalendarView,
    MoodEntryDetailView,
)

urlpatterns = [
    path("moods/", MoodCalendarView.as_view(), name="wellness-moods"),
    path("moods/<str:date>/", MoodEntryDetailView.as_view(), name="wellness-mood-detail"),
    path("journal/", JournalWeekView.as_view(), name="wellness-journal-week"),
    path("journal/<str:date>/", JournalEntryDetailView.as_view(), name="wellness-journal-entry"),
    path("habits/", HabitListView.as_view(), name="wellness-habits"),
    path("habits/<int:habit_id>/", HabitDetailView.as_view(), name="wellness-habit-detail"),
    path("habits/<int:habit_id>/toggle/", HabitToggleView.as_view(), name="wellness-habit-toggle"),
]
