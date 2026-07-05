"""
Views for user registration, profile management, and emergency contacts.
"""
import logging

import requests
from django.conf import settings
from django.contrib.auth import get_user_model
from rest_framework import generics, permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from .models import EmergencyContact
from .serializers import (
    ChangePasswordSerializer,
    CustomTokenObtainPairSerializer,
    EmergencyContactSerializer,
    RegisterSerializer,
    UserProfileSerializer,
)

User = get_user_model()
logger = logging.getLogger(__name__)

GOOGLE_TOKENINFO_URL = "https://oauth2.googleapis.com/tokeninfo"
GOOGLE_USERINFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo"

FACEBOOK_DEBUG_TOKEN_URL = "https://graph.facebook.com/debug_token"
FACEBOOK_ME_URL = "https://graph.facebook.com/me"


def _get_or_create_social_user(email, first_name, last_name, provider, logger_):
    """Shared by GoogleAuthView/FacebookAuthView: get-or-create by email and
    issue the same JWT pair shape the normal login/register endpoints use."""
    user, created = User.objects.get_or_create(
        email=email,
        defaults={"first_name": first_name, "last_name": last_name},
    )
    if created:
        user.set_unusable_password()  # this account only ever signs in via that provider
        user.save(update_fields=["password"])
        logger_.info("Created new user via %s sign-in: %s", provider, email)

    token = CustomTokenObtainPairSerializer.get_token(user)
    return Response(
        {
            "access": str(token.access_token),
            "refresh": str(token),
            "created": created,
        },
        status=status.HTTP_200_OK,
    )


class RegisterView(generics.CreateAPIView):
    """
    POST /api/v1/auth/register/
    Create a new patient account. No authentication required.
    """

    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]


class CustomTokenObtainPairView(TokenObtainPairView):
    """
    POST /api/v1/auth/login/
    Returns access and refresh JWT tokens with enriched payload.
    """

    serializer_class = CustomTokenObtainPairSerializer


class UserProfileView(generics.RetrieveUpdateAPIView):
    """
    GET  /api/v1/auth/profile/   — retrieve own profile
    PATCH /api/v1/auth/profile/  — partial update
    """

    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user


class ChangePasswordView(generics.UpdateAPIView):
    """
    PUT /api/v1/auth/change-password/
    Changes the password for the authenticated user.
    """

    serializer_class = ChangePasswordSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user

    def update(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(
            {"detail": "Password updated successfully."},
            status=status.HTTP_200_OK,
        )


class EmergencyContactViewSet(viewsets.ModelViewSet):
    """
    CRUD endpoints for a user's emergency contacts.

    GET    /api/v1/auth/emergency-contacts/
    POST   /api/v1/auth/emergency-contacts/
    GET    /api/v1/auth/emergency-contacts/{id}/
    PUT    /api/v1/auth/emergency-contacts/{id}/
    PATCH  /api/v1/auth/emergency-contacts/{id}/
    DELETE /api/v1/auth/emergency-contacts/{id}/
    POST   /api/v1/auth/emergency-contacts/{id}/set_primary/
    """

    serializer_class = EmergencyContactSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return EmergencyContact.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=True, methods=["post"], url_path="set-primary")
    def set_primary(self, request, pk=None):
        """Promote a contact to primary, demoting any existing primary."""
        contact = self.get_object()
        EmergencyContact.objects.filter(user=request.user, is_primary=True).update(
            is_primary=False
        )
        contact.is_primary = True
        contact.save(update_fields=["is_primary"])
        serializer = self.get_serializer(contact)
        return Response(serializer.data, status=status.HTTP_200_OK)


class GoogleAuthView(APIView):
    """
    POST /api/v1/auth/google/
    Body: { "access_token": "<Google OAuth2 access token>" }

    Verifies the token directly with Google (tokeninfo + userinfo), then
    gets-or-creates the matching account and returns the same
    {access, refresh} JWT pair shape as the normal login/register endpoints,
    so the frontend can store it identically either way.
    """

    permission_classes = [permissions.AllowAny]

    def post(self, request):
        if not settings.GOOGLE_OAUTH_CLIENT_ID:
            return Response(
                {"detail": "Google sign-in isn't configured on this server yet."},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        access_token = request.data.get("access_token")
        if not access_token:
            return Response(
                {"detail": "access_token is required."}, status=status.HTTP_400_BAD_REQUEST
            )

        try:
            tokeninfo_resp = requests.get(
                GOOGLE_TOKENINFO_URL, params={"access_token": access_token}, timeout=10
            )
        except requests.RequestException:
            logger.exception("Could not reach Google's tokeninfo endpoint.")
            return Response(
                {"detail": "Could not verify Google token right now. Try again."},
                status=status.HTTP_502_BAD_GATEWAY,
            )

        if tokeninfo_resp.status_code != 200:
            return Response(
                {"detail": "Google rejected this token — please sign in again."},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        tokeninfo = tokeninfo_resp.json()

        # Reject a token that's valid but was issued for a DIFFERENT app —
        # otherwise any Google access token from any site could authenticate here.
        if tokeninfo.get("aud") != settings.GOOGLE_OAUTH_CLIENT_ID:
            return Response(
                {"detail": "This Google token was not issued for this application."},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        try:
            userinfo_resp = requests.get(
                GOOGLE_USERINFO_URL,
                headers={"Authorization": f"Bearer {access_token}"},
                timeout=10,
            )
        except requests.RequestException:
            logger.exception("Could not reach Google's userinfo endpoint.")
            return Response(
                {"detail": "Could not fetch your Google profile right now. Try again."},
                status=status.HTTP_502_BAD_GATEWAY,
            )

        if userinfo_resp.status_code != 200:
            return Response(
                {"detail": "Could not fetch your Google profile."},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        userinfo = userinfo_resp.json()
        email = userinfo.get("email")
        if not email or not userinfo.get("email_verified"):
            return Response(
                {"detail": "Your Google account must have a verified email."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        return _get_or_create_social_user(
            email=email,
            first_name=userinfo.get("given_name", ""),
            last_name=userinfo.get("family_name", ""),
            provider="Google",
            logger_=logger,
        )


class FacebookAuthView(APIView):
    """
    POST /api/v1/auth/facebook/
    Body: { "access_token": "<Facebook OAuth2 user access token>" }

    Verifies the token directly with Facebook's Graph API (debug_token, to
    confirm it was actually issued for THIS app, then /me for the profile),
    gets-or-creates the matching account, and returns the same
    {access, refresh} JWT pair shape as every other auth endpoint.
    """

    permission_classes = [permissions.AllowAny]

    def post(self, request):
        if not settings.FACEBOOK_APP_ID or not settings.FACEBOOK_APP_SECRET:
            return Response(
                {"detail": "Facebook sign-in isn't configured on this server yet."},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        access_token = request.data.get("access_token")
        if not access_token:
            return Response(
                {"detail": "access_token is required."}, status=status.HTTP_400_BAD_REQUEST
            )

        app_access_token = f"{settings.FACEBOOK_APP_ID}|{settings.FACEBOOK_APP_SECRET}"
        try:
            debug_resp = requests.get(
                FACEBOOK_DEBUG_TOKEN_URL,
                params={"input_token": access_token, "access_token": app_access_token},
                timeout=10,
            )
        except requests.RequestException:
            logger.exception("Could not reach Facebook's debug_token endpoint.")
            return Response(
                {"detail": "Could not verify Facebook token right now. Try again."},
                status=status.HTTP_502_BAD_GATEWAY,
            )

        if debug_resp.status_code != 200:
            return Response(
                {"detail": "Facebook rejected this token — please sign in again."},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        debug_data = debug_resp.json().get("data", {})

        # Reject a token that's invalid, expired, or was issued for a
        # DIFFERENT Facebook app — otherwise any Facebook access token from
        # any site could authenticate here.
        if not debug_data.get("is_valid") or str(debug_data.get("app_id")) != str(
            settings.FACEBOOK_APP_ID
        ):
            return Response(
                {"detail": "This Facebook token is invalid or was not issued for this application."},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        try:
            me_resp = requests.get(
                FACEBOOK_ME_URL,
                params={"fields": "id,email,first_name,last_name", "access_token": access_token},
                timeout=10,
            )
        except requests.RequestException:
            logger.exception("Could not reach Facebook's /me endpoint.")
            return Response(
                {"detail": "Could not fetch your Facebook profile right now. Try again."},
                status=status.HTTP_502_BAD_GATEWAY,
            )

        if me_resp.status_code != 200:
            return Response(
                {"detail": "Could not fetch your Facebook profile."},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        me_data = me_resp.json()
        email = me_data.get("email")
        if not email:
            # Facebook accounts can lack a verified/associated email, or the
            # user may have declined the email permission at the consent
            # screen — we have no way to identify/link an account without it.
            return Response(
                {
                    "detail": (
                        "Your Facebook account has no email address available. "
                        "Please allow email access, or sign up with email/password instead."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        return _get_or_create_social_user(
            email=email,
            first_name=me_data.get("first_name", ""),
            last_name=me_data.get("last_name", ""),
            provider="Facebook",
            logger_=logger,
        )
