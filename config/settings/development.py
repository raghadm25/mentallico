"""
Development-specific settings.
"""
from .base import *  # noqa: F401, F403

DEBUG = True

ALLOWED_HOSTS = ["*"]

# django-extensions provides shell_plus, graph_models, etc.
# Only activated when the package is actually installed so the server
# doesn't crash with ModuleNotFoundError out of the box.
try:
    import django_extensions  # noqa: F401
    INSTALLED_APPS += ["django_extensions"]  # noqa: F405
except ImportError:
    pass

# ---------------------------------------------------------------------------
# DRF — enable the HTML browsable interface in development only
# ---------------------------------------------------------------------------
REST_FRAMEWORK["DEFAULT_RENDERER_CLASSES"] = (  # noqa: F405
    "rest_framework.renderers.JSONRenderer",
    "rest_framework.renderers.BrowsableAPIRenderer",
)

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "verbose": {
            "format": "{levelname} {asctime} {module} {message}",
            "style": "{",
        },
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "verbose",
        },
    },
    "root": {
        "handlers": ["console"],
        "level": "DEBUG",
    },
    "loggers": {
        "django.db.backends": {
            "handlers": ["console"],
            # Change to DEBUG to print every SQL query
            "level": "INFO",
            "propagate": False,
        },
    },
}

# DATABASE_URL falls back to sqlite:///db.sqlite3 via base.py — no override needed.

EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"
