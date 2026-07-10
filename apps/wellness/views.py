"""
Views for the User Profile page's self-tracking features:
mood calendar, journal entries, and habit completion toggling.

All endpoints are per-user personal data, so everything here requires login.
"""
import datetime
import logging

from django.utils import timezone
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Habit, HabitCompletion, JournalEntry, MoodEntry
from .serializers import HabitSerializer, JournalEntrySerializer, MoodEntrySerializer

logger = logging.getLogger(__name__)

DEFAULT_HABITS = [
    {"name": "Daily Gratitude", "icon_key": "gratitude"},
    {"name": "1 Hour Of Reading", "icon_key": "reading"},
    {"name": "Breathing Exercises", "icon_key": "breathing"},
]


def _parse_date(value, default=None):
    try:
        return datetime.date.fromisoformat(value)
    except (TypeError, ValueError):
        return default


# ---------------------------------------------------------------------------
# Mood calendar
# ---------------------------------------------------------------------------

class MoodCalendarView(APIView):
    """
    GET /api/v1/wellness/moods/?year=2026&month=1
        Returns every mood the user logged that month.

    POST /api/v1/wellness/moods/
        Body: { "date": "2026-01-15" (optional, defaults to today), "mood": "hopeful" }
        Creates or overwrites that day's mood (one per user per day).
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        today = timezone.localdate()
        year = int(request.query_params.get("year", today.year))
        month = int(request.query_params.get("month", today.month))

        entries = MoodEntry.objects.filter(user=request.user, date__year=year, date__month=month)
        return Response(
            {
                "year": year,
                "month": month,
                "entries": MoodEntrySerializer(entries, many=True).data,
            }
        )

    def post(self, request):
        date = _parse_date(request.data.get("date"), default=timezone.localdate())
        mood = request.data.get("mood")

        valid_moods = {choice for choice, _ in MoodEntry.MoodChoices.choices}
        if mood not in valid_moods:
            return Response(
                {"detail": f"mood must be one of: {sorted(valid_moods)}"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        entry, _ = MoodEntry.objects.update_or_create(
            user=request.user, date=date, defaults={"mood": mood}
        )
        logger.info("Mood logged for %s on %s: %s", request.user.email, date, mood)
        return Response(MoodEntrySerializer(entry).data, status=status.HTTP_200_OK)


class MoodEntryDetailView(APIView):
    """
    DELETE /api/v1/wellness/moods/<date>/
        Removes that day's logged mood entirely.
    """

    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, date):
        parsed = _parse_date(date)
        if not parsed:
            return Response({"detail": "Invalid date."}, status=status.HTTP_400_BAD_REQUEST)

        deleted, _ = MoodEntry.objects.filter(user=request.user, date=parsed).delete()
        if not deleted:
            return Response({"detail": "No mood logged for that date."}, status=status.HTTP_404_NOT_FOUND)
        return Response(status=status.HTTP_204_NO_CONTENT)


# ---------------------------------------------------------------------------
# Journal entries
# ---------------------------------------------------------------------------

class JournalWeekView(APIView):
    """
    GET /api/v1/wellness/journal/?start=2026-01-19&days=7
        Returns every entry the user wrote within that date range
        (missing days simply won't appear — the frontend fills the gaps).
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        today = timezone.localdate()
        start = _parse_date(request.query_params.get("start"), default=today)
        days = int(request.query_params.get("days", 7))
        end = start + datetime.timedelta(days=days - 1)

        entries = JournalEntry.objects.filter(user=request.user, date__gte=start, date__lte=end)
        return Response(
            {
                "start": start.isoformat(),
                "end": end.isoformat(),
                "entries": JournalEntrySerializer(entries, many=True).data,
            }
        )


class JournalEntryDetailView(APIView):
    """
    GET  /api/v1/wellness/journal/<date>/   Returns the entry for that day, or null content.
    POST /api/v1/wellness/journal/<date>/   Body: { "content": "..." } — creates or overwrites it.
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, date):
        parsed = _parse_date(date)
        if not parsed:
            return Response({"detail": "Invalid date."}, status=status.HTTP_400_BAD_REQUEST)

        entry = JournalEntry.objects.filter(user=request.user, date=parsed).first()
        if not entry:
            return Response({"date": parsed.isoformat(), "content": None})
        return Response(JournalEntrySerializer(entry).data)

    def post(self, request, date):
        parsed = _parse_date(date)
        if not parsed:
            return Response({"detail": "Invalid date."}, status=status.HTTP_400_BAD_REQUEST)

        content = (request.data.get("content") or "").strip()
        if not content:
            return Response({"detail": "content must not be empty."}, status=status.HTTP_400_BAD_REQUEST)

        entry, _ = JournalEntry.objects.update_or_create(
            user=request.user, date=parsed, defaults={"content": content}
        )
        return Response(JournalEntrySerializer(entry).data, status=status.HTTP_200_OK)


# ---------------------------------------------------------------------------
# Habits
# ---------------------------------------------------------------------------

def _ensure_default_habits(user):
    if not Habit.objects.filter(user=user).exists():
        Habit.objects.bulk_create([Habit(user=user, **data) for data in DEFAULT_HABITS])


class HabitListView(APIView):
    """
    GET /api/v1/wellness/habits/
        Returns the user's habits (seeding the 3 defaults on first use),
        each with today's completion state and a 7-day completion rate.

    POST /api/v1/wellness/habits/
        Body: { "name": "Workout", "icon_key": "workout" (optional) }
        Gets-or-creates a habit with that name for the current user, so
        other entry points (e.g. the Resources page's habit tiles) can
        start tracking a habit without duplicating it on repeat clicks.
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        _ensure_default_habits(request.user)
        habits = Habit.objects.filter(user=request.user, is_active=True)
        return Response(HabitSerializer(habits, many=True).data)

    def post(self, request):
        name = (request.data.get("name") or "").strip()
        if not name:
            return Response({"detail": "name is required."}, status=status.HTTP_400_BAD_REQUEST)

        icon_key = (request.data.get("icon_key") or "").strip()
        habit, created = Habit.objects.get_or_create(
            user=request.user, name=name, defaults={"icon_key": icon_key}
        )
        if not created and not habit.is_active:
            # Re-adding a habit that was previously removed — reactivate the
            # existing row instead of leaving it invisible to future GETs
            # (which filter on is_active=True).
            habit.is_active = True
            habit.save(update_fields=["is_active"])
        return Response(
            HabitSerializer(habit).data,
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )


class HabitToggleView(APIView):
    """
    POST /api/v1/wellness/habits/<id>/toggle/
        Toggles today's completion for that habit and returns its updated summary.
    """

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, habit_id):
        try:
            habit = Habit.objects.get(id=habit_id, user=request.user)
        except Habit.DoesNotExist:
            return Response({"detail": "Habit not found."}, status=status.HTTP_404_NOT_FOUND)

        today = timezone.localdate()
        completion, created = HabitCompletion.objects.get_or_create(habit=habit, date=today)
        if not created:
            completion.delete()

        return Response(HabitSerializer(habit).data, status=status.HTTP_200_OK)


class HabitDetailView(APIView):
    """
    DELETE /api/v1/wellness/habits/<id>/
        Soft-deletes the habit (is_active=False) so it drops out of the
        user's tracked list while preserving its HabitCompletion history.

    PATCH /api/v1/wellness/habits/<id>/
        Body: { "progress": <int 0-100> }
        Directly sets the habit's user-controlled progress value — a plain
        manual number, not derived from daily completions — clamped to the
        valid 0-100 range regardless of what the client sends.
    """

    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, habit_id):
        try:
            habit = Habit.objects.get(id=habit_id, user=request.user)
        except Habit.DoesNotExist:
            return Response({"detail": "Habit not found."}, status=status.HTTP_404_NOT_FOUND)

        habit.is_active = False
        habit.save(update_fields=["is_active"])
        return Response(status=status.HTTP_204_NO_CONTENT)

    def patch(self, request, habit_id):
        try:
            habit = Habit.objects.get(id=habit_id, user=request.user)
        except Habit.DoesNotExist:
            return Response({"detail": "Habit not found."}, status=status.HTTP_404_NOT_FOUND)

        if "progress" not in request.data:
            return Response({"detail": "progress is required."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            progress = int(request.data.get("progress"))
        except (TypeError, ValueError):
            return Response({"detail": "progress must be an integer."}, status=status.HTTP_400_BAD_REQUEST)

        habit.progress = max(0, min(100, progress))
        habit.save(update_fields=["progress"])
        return Response(HabitSerializer(habit).data, status=status.HTTP_200_OK)
