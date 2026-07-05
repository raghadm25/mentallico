"""
Seed Article rows for the books shown in ResourcesCenter.jsx so the
existing "Save to collection" heart button has real Article ids to
attach SavedResource bookmarks to. Frontend book art still comes from
locally bundled images — these rows only carry title/summary/link.
"""
from django.db import migrations

SEED_BOOKS = [
    {
        "title": "Where To Start",
        "slug": "where-to-start",
        "summary": "A gentle starting point for anyone new to processing their mental health.",
        "external_url": "https://www.goodreads.com/book/show/61612877-where-to-start",
        "author": "MHA",
    },
    {
        "title": "The Body Keeps the Score",
        "slug": "the-body-keeps-the-score",
        "summary": "How trauma reshapes the body and mind, and paths toward healing.",
        "external_url": "https://www.goodreads.com/book/show/18693771-the-body-keeps-the-score",
        "author": "Bessel van der Kolk",
    },
    {
        "title": "Maybe You Should Talk to Someone",
        "slug": "maybe-you-should-talk",
        "summary": "A therapist, her therapist, and our lives revealed.",
        "external_url": "https://www.goodreads.com/book/show/37570546-maybe-you-should-talk-to-someone",
        "author": "Lori Gottlieb",
    },
]


def seed_books(apps, schema_editor):
    Article = apps.get_model("resources", "Article")
    for entry in SEED_BOOKS:
        Article.objects.get_or_create(
            slug=entry["slug"],
            defaults={
                "title": entry["title"],
                "summary": entry["summary"],
                "external_url": entry["external_url"],
                "author": entry["author"],
                "content_type": "article",
                "is_published": True,
                "tags": ["community_picks"],
            },
        )


def remove_seeded_books(apps, schema_editor):
    Article = apps.get_model("resources", "Article")
    slugs = [entry["slug"] for entry in SEED_BOOKS]
    Article.objects.filter(slug__in=slugs).delete()


class Migration(migrations.Migration):

    dependencies = [
        ("resources", "0001_initial"),
    ]

    operations = [
        migrations.RunPython(seed_books, remove_seeded_books),
    ]
