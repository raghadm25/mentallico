from django.db import migrations, models
import django.core.validators


class Migration(migrations.Migration):

    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name="Therapist",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("name", models.CharField(max_length=150)),
                ("title", models.CharField(help_text="Professional title shown under the name", max_length=200)),
                ("specialty", models.CharField(help_text="Comma-separated list of specialties", max_length=300)),
                ("experience", models.PositiveSmallIntegerField(help_text="Years of experience")),
                ("languages", models.CharField(help_text="Comma-separated list of languages", max_length=200)),
                ("rating", models.DecimalField(
                    decimal_places=1,
                    max_digits=3,
                    validators=[
                        django.core.validators.MinValueValidator(0),
                        django.core.validators.MaxValueValidator(5),
                    ],
                )),
                ("review_count", models.PositiveIntegerField(default=0)),
                ("price", models.PositiveIntegerField(help_text="Session price in USD")),
                ("img", models.URLField(blank=True, help_text="Avatar / profile photo URL", max_length=500)),
                ("bio", models.TextField(blank=True)),
                ("is_active", models.BooleanField(default=True, help_text="Uncheck to hide from the public listing")),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
            ],
            options={
                "verbose_name": "Therapist",
                "verbose_name_plural": "Therapists",
                "ordering": ["-rating", "name"],
            },
        ),
    ]
