"""
URL routes for the diagnostics app.
"""
from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import DiagnosticReportViewSet, TriggerAnalysisView

router = DefaultRouter()
router.register(r"reports", DiagnosticReportViewSet, basename="diagnostic-report")

urlpatterns = [
    path("analyze/", TriggerAnalysisView.as_view(), name="diagnostics-analyze"),
    path("", include(router.urls)),
]
