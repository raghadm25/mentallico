"""
URL routes for the users app.
"""
from django.urls import include, path
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView, TokenBlacklistView

from .views import (
    ChangePasswordView,
    CustomTokenObtainPairView,
    EmergencyContactViewSet,
    RegisterView,
    UserProfileView,
)

router = DefaultRouter()
router.register(r"emergency-contacts", EmergencyContactViewSet, basename="emergency-contact")

urlpatterns = [
    path("register/", RegisterView.as_view(), name="auth-register"),
    path("login/", CustomTokenObtainPairView.as_view(), name="auth-login"),
    path("token/refresh/", TokenRefreshView.as_view(), name="auth-token-refresh"),
    path("logout/", TokenBlacklistView.as_view(), name="auth-logout"),
    path("profile/", UserProfileView.as_view(), name="auth-profile"),
    path("change-password/", ChangePasswordView.as_view(), name="auth-change-password"),
    path("", include(router.urls)),
]
