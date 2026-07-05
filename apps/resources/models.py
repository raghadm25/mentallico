"""
Mental health resource library models.
"""
from django.conf import settings
from django.db import models
from django.utils.text import slugify


class Category(models.Model):
    """Top-level category for grouping articles (e.g. 'Anxiety', 'Sleep')."""

    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=120, unique=True, blank=True)
    description = models.TextField(blank=True)
    icon = models.CharField(
        max_length=50,
        blank=True,
        help_text="Icon identifier for front-end rendering (e.g. 'brain').",
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "category"
        verbose_name_plural = "categories"
        ordering = ["name"]

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name


class Article(models.Model):
    """
    A curated mental-health article or educational resource.

    Articles are tagged with categories so that the diagnostic recommendations
    engine can surface relevant content based on detected patterns.
    """

    class ContentTypeChoices(models.TextChoices):
        ARTICLE = "article", "Article"
        VIDEO = "video", "Video"
        EXERCISE = "exercise", "Exercise / Activity"
        HOTLINE = "hotline", "Crisis Hotline"
        TOOL = "tool", "Interactive Tool"

    class DifficultyChoices(models.TextChoices):
        BEGINNER = "beginner", "Beginner"
        INTERMEDIATE = "intermediate", "Intermediate"
        ADVANCED = "advanced", "Advanced"

    title = models.CharField(max_length=255)
    slug = models.SlugField(max_length=280, unique=True, blank=True)
    category = models.ForeignKey(
        Category,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="articles",
    )
    content_type = models.CharField(
        max_length=20,
        choices=ContentTypeChoices.choices,
        default=ContentTypeChoices.ARTICLE,
    )
    difficulty = models.CharField(
        max_length=20,
        choices=DifficultyChoices.choices,
        default=DifficultyChoices.BEGINNER,
    )
    summary = models.TextField(
        help_text="A short paragraph summarising the resource."
    )
    body = models.TextField(
        blank=True,
        help_text="Full article body (may be empty for external links).",
    )
    external_url = models.URLField(
        blank=True,
        help_text="External link if the resource is hosted elsewhere.",
    )
    thumbnail = models.ImageField(
        upload_to="resource_thumbnails/", null=True, blank=True
    )
    tags = models.JSONField(
        default=list,
        blank=True,
        help_text="Free-form tags used by the recommendation engine "
                  "(e.g. ['sleep_issues', 'anxiety_indicators']).",
    )
    is_published = models.BooleanField(default=False, db_index=True)
    is_crisis_resource = models.BooleanField(
        default=False,
        db_index=True,
        help_text="Flag resources that should surface during a crisis (severity=severe).",
    )
    reading_time_minutes = models.PositiveSmallIntegerField(default=5)
    author = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "article"
        verbose_name_plural = "articles"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["is_published", "is_crisis_resource"]),
        ]

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.title)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.title


class SavedResource(models.Model):
    """Tracks which articles a user has bookmarked."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="saved_resources",
    )
    article = models.ForeignKey(
        Article,
        on_delete=models.CASCADE,
        related_name="saved_by",
    )
    saved_at = models.DateTimeField(auto_now_add=True)
    notes = models.TextField(blank=True)

    class Meta:
        verbose_name = "saved resource"
        verbose_name_plural = "saved resources"
        unique_together = ("user", "article")
        ordering = ["-saved_at"]

    def __str__(self):
        return f"{self.user.email} → {self.article.title}"
