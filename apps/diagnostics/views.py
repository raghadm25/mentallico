"""
Views for triggering diagnostic analysis and retrieving reports.
"""
from rest_framework import generics, permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import DiagnosticReport
from .serializers import DiagnosticReportSerializer, TriggerAnalysisSerializer
from .tasks import run_diagnostic_analysis


class TriggerAnalysisView(APIView):
    """
    POST /api/v1/diagnostics/analyze/

    Creates a pending DiagnosticReport for a completed session and
    dispatches an async Celery task to run the NLP pipeline.

    Request body
    ------------
    { "session_id": "<uuid>" }

    Response (202 Accepted)
    -----------------------
    { "report_id": "<uuid>", "status": "pending", "detail": "..." }
    """

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = TriggerAnalysisSerializer(
            data=request.data, context={"request": request}
        )
        serializer.is_valid(raise_exception=True)

        from apps.chat.models import ChatSession

        session = ChatSession.objects.get(
            pk=serializer.validated_data["session_id"], user=request.user
        )

        # Create or re-use a failed report
        report, created = DiagnosticReport.objects.get_or_create(
            session=session,
            defaults={"user": request.user},
        )
        if not created:
            # Reset a previously failed report
            report.status = DiagnosticReport.StatusChoices.PENDING
            report.error_message = ""
            report.save(update_fields=["status", "error_message"])

        run_diagnostic_analysis.delay(str(report.id))

        return Response(
            {
                "report_id": str(report.id),
                "status": report.status,
                "detail": "Analysis queued. Poll the report endpoint for results.",
            },
            status=status.HTTP_202_ACCEPTED,
        )


class DiagnosticReportViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Read-only list and retrieve for the authenticated user's diagnostic reports.

    GET /api/v1/diagnostics/reports/
    GET /api/v1/diagnostics/reports/{id}/
    """

    serializer_class = DiagnosticReportSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return DiagnosticReport.objects.filter(
            user=self.request.user
        ).select_related("session")
