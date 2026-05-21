"""
Views for user registration, profile management, and emergency contacts.
"""
from django.contrib.auth import get_user_model
from rest_framework import generics, permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
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
