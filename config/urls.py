"""
Root URL configuration.

All application routes are namespaced under /api/v1/ to allow versioning.
The DRF browsable API session-auth endpoint is added in DEBUG mode only so
the interactive HTML UI works during local development without affecting
the production JWT-only authentication contract.
"""
from django.contrib import admin
from django.http import JsonResponse
from django.urls import include, path
from django.conf import settings
from django.conf.urls.static import static

API_V1 = "api/v1/"


def health_check(request):
    """
    GET /health/
    Lightweight liveness probe — returns 200 with no database queries.
    Used by container orchestrators (Docker, Kubernetes) and uptime monitors.
    """
    return JsonResponse({"status": "ok"})


urlpatterns = [
    # ------------------------------------------------------------------ #
    # Health / liveness                                                    #
    # ------------------------------------------------------------------ #
    path("health/", health_check, name="health-check"),

    # ------------------------------------------------------------------ #
    # Django admin                                                         #
    # ------------------------------------------------------------------ #
    path("admin/", admin.site.urls),

    # ------------------------------------------------------------------ #
    # API v1                                                               #
    # ------------------------------------------------------------------ #

    # Authentication & user management (register, login, profile, emergency contacts)
    path(API_V1 + "auth/", include("apps.users.urls")),

    # Chat sessions and messages
    path(API_V1 + "chat/", include("apps.chat.urls")),

    # NLP diagnostic analysis and reports
    path(API_V1 + "diagnostics/", include("apps.diagnostics.urls")),

    # Mental health resource library
    path(API_V1 + "resources/", include("apps.resources.urls")),
]

# ------------------------------------------------------------------ #
# Development-only additions                                           #
# ------------------------------------------------------------------ #
if settings.DEBUG:
    # DRF browsable API uses session login — safe to expose locally only.
    urlpatterns += [
        path("api-auth/", include("rest_framework.urls", namespace="rest_framework")),
    ]
    # Serve user-uploaded media files through Django's dev server.
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
