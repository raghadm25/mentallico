"""
User and patient profile models.
"""
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django.db import models
from django.utils import timezone

from .managers import UserManager


class User(AbstractBaseUser, PermissionsMixin):
    """
    Custom user model that uses email as the unique identifier.

    Extends the default auth model with patient-specific fields
    and an emergency contact relationship.
    """

    class GenderChoices(models.TextChoices):
        MALE = "male", "Male"
        FEMALE = "female", "Female"
        NON_BINARY = "non_binary", "Non-Binary"
        PREFER_NOT_TO_SAY = "prefer_not_to_say", "Prefer not to say"

    # Core auth fields
    email = models.EmailField(unique=True, db_index=True)
    first_name = models.CharField(max_length=150, blank=True)
    last_name = models.CharField(max_length=150, blank=True)

    # Patient profile fields
    date_of_birth = models.DateField(null=True, blank=True)
    gender = models.CharField(
        max_length=20,
        choices=GenderChoices.choices,
        blank=True,
    )
    phone_number = models.CharField(max_length=20, blank=True)
    profile_picture = models.ImageField(
        upload_to="profile_pictures/", null=True, blank=True
    )
    bio = models.TextField(blank=True)

    # Account state
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    objects = UserManager()

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["first_name", "last_name"]

    class Meta:
        verbose_name = "user"
        verbose_name_plural = "users"
        ordering = ["-date_joined"]

    def __str__(self):
        return self.email

    @property
    def full_name(self):
        return f"{self.first_name} {self.last_name}".strip()


class EmergencyContact(models.Model):
    """
    A trusted contact that can be notified in a crisis situation.

    Each user may have multiple emergency contacts with priority ordering.
    """

    class RelationshipChoices(models.TextChoices):
        PARENT = "parent", "Parent"
        SIBLING = "sibling", "Sibling"
        SPOUSE = "spouse", "Spouse / Partner"
        FRIEND = "friend", "Friend"
        THERAPIST = "therapist", "Therapist"
        OTHER = "other", "Other"

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="emergency_contacts",
    )
    name = models.CharField(max_length=200)
    relationship = models.CharField(
        max_length=20,
        choices=RelationshipChoices.choices,
        default=RelationshipChoices.OTHER,
    )
    phone_number = models.CharField(max_length=20)
    email = models.EmailField(blank=True)
    is_primary = models.BooleanField(
        default=False,
        help_text="Marks the first contact to notify in an emergency.",
    )
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "emergency contact"
        verbose_name_plural = "emergency contacts"
        ordering = ["-is_primary", "name"]
        constraints = [
            models.UniqueConstraint(
                fields=["user"],
                condition=models.Q(is_primary=True),
                name="unique_primary_emergency_contact_per_user",
            )
        ]

    def __str__(self):
        return f"{self.name} ({self.get_relationship_display()}) — {self.user.email}"
