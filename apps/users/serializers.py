"""
Serializers for user registration, authentication, and profile management.
"""
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from .models import EmergencyContact

User = get_user_model()


class RegisterSerializer(serializers.ModelSerializer):
    """Handles new user registration with password confirmation."""

    password = serializers.CharField(
        write_only=True, required=True, validators=[validate_password]
    )
    password_confirm = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = (
            "id",
            "email",
            "first_name",
            "last_name",
            "password",
            "password_confirm",
            "date_of_birth",
            "gender",
            "phone_number",
        )
        extra_kwargs = {
            "first_name": {"required": True},
            "last_name": {"required": True},
        }

    def validate(self, attrs):
        if attrs["password"] != attrs.pop("password_confirm"):
            raise serializers.ValidationError(
                {"password_confirm": "Passwords do not match."}
            )
        return attrs

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """Extends the default JWT payload with user identity fields."""

    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token["email"] = user.email
        token["full_name"] = user.full_name
        return token


class UserProfileSerializer(serializers.ModelSerializer):
    """Read/update the authenticated user's own profile."""

    full_name = serializers.ReadOnlyField()

    class Meta:
        model = User
        fields = (
            "id",
            "email",
            "first_name",
            "last_name",
            "full_name",
            "date_of_birth",
            "gender",
            "phone_number",
            "profile_picture",
            "bio",
            "date_joined",
        )
        read_only_fields = ("id", "email", "date_joined")


class ChangePasswordSerializer(serializers.Serializer):
    """Validates and applies a password change for the current user."""

    old_password = serializers.CharField(write_only=True, required=True)
    new_password = serializers.CharField(
        write_only=True, required=True, validators=[validate_password]
    )
    new_password_confirm = serializers.CharField(write_only=True, required=True)

    def validate_old_password(self, value):
        user = self.context["request"].user
        if not user.check_password(value):
            raise serializers.ValidationError("Current password is incorrect.")
        return value

    def validate(self, attrs):
        if attrs["new_password"] != attrs["new_password_confirm"]:
            raise serializers.ValidationError(
                {"new_password_confirm": "New passwords do not match."}
            )
        return attrs

    def save(self):
        user = self.context["request"].user
        user.set_password(self.validated_data["new_password"])
        user.save(update_fields=["password"])
        return user


class EmergencyContactSerializer(serializers.ModelSerializer):
    """CRUD serializer for emergency contacts."""

    class Meta:
        model = EmergencyContact
        fields = (
            "id",
            "name",
            "relationship",
            "phone_number",
            "email",
            "is_primary",
            "notes",
            "created_at",
        )
        read_only_fields = ("id", "created_at")

    def validate(self, attrs):
        """
        Prevent a user from manually assigning a second primary contact.
        The view layer may also enforce this; this is a belt-and-suspenders check.
        """
        request = self.context.get("request")
        if attrs.get("is_primary") and request:
            existing_primary = EmergencyContact.objects.filter(
                user=request.user, is_primary=True
            )
            if self.instance:
                existing_primary = existing_primary.exclude(pk=self.instance.pk)
            if existing_primary.exists():
                raise serializers.ValidationError(
                    {"is_primary": "A primary contact already exists. Update it instead."}
                )
        return attrs
