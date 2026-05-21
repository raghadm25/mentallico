from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class Therapist(models.Model):
    name = models.CharField(max_length=150)
    title = models.CharField(max_length=200, help_text="Professional title shown under the name")
    specialty = models.CharField(max_length=300, help_text="Comma-separated list of specialties")
    experience = models.PositiveSmallIntegerField(help_text="Years of experience")
    languages = models.CharField(max_length=200, help_text="Comma-separated list of languages")
    rating = models.DecimalField(
        max_digits=3, decimal_places=1,
        validators=[MinValueValidator(0), MaxValueValidator(5)],
    )
    review_count = models.PositiveIntegerField(default=0)
    price = models.PositiveIntegerField(help_text="Session price in USD")
    img = models.URLField(max_length=500, blank=True, help_text="Avatar / profile photo URL")
    bio = models.TextField(blank=True)
    is_active = models.BooleanField(default=True, help_text="Uncheck to hide from the public listing")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-rating", "name"]
        verbose_name = "Therapist"
        verbose_name_plural = "Therapists"

    def __str__(self):
        return f"{self.name} — {self.title}"
