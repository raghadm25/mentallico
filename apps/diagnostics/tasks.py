"""
Celery tasks for asynchronous diagnostic analysis.
"""
import logging

from celery import shared_task

logger = logging.getLogger(__name__)


@shared_task(bind=True, max_retries=3, default_retry_delay=30)
def run_diagnostic_analysis(self, report_id: str) -> dict:
    """
    Asynchronous task that runs the NLP pipeline on a completed chat session
    and persists the results to the DiagnosticReport record.

    Parameters
    ----------
    report_id : str (UUID) of the DiagnosticReport to process.
    """
    from .models import DiagnosticReport
    from .services import run_analysis

    try:
        report = DiagnosticReport.objects.select_related(
            "session"
        ).get(pk=report_id)
    except DiagnosticReport.DoesNotExist:
        logger.error("DiagnosticReport %s not found.", report_id)
        return {"status": "error", "detail": "Report not found."}

    report.status = DiagnosticReport.StatusChoices.PROCESSING
    report.save(update_fields=["status"])

    try:
        transcript = report.session.full_transcript
        results = run_analysis(transcript)

        for field, value in results.items():
            setattr(report, field, value)

        report.status = DiagnosticReport.StatusChoices.COMPLETED
        report.error_message = ""
        report.save()

        # Mark session as analyzed
        session = report.session
        from apps.chat.models import ChatSession
        session.status = ChatSession.StatusChoices.ANALYZED
        session.save(update_fields=["status"])

        logger.info("DiagnosticReport %s completed successfully.", report_id)
        return {"status": "completed", "report_id": str(report_id)}

    except Exception as exc:
        logger.exception("DiagnosticReport %s failed: %s", report_id, exc)
        report.status = DiagnosticReport.StatusChoices.FAILED
        report.error_message = str(exc)
        report.save(update_fields=["status", "error_message"])
        raise self.retry(exc=exc)
