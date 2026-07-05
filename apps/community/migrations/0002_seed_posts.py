"""
Seed the community feed with the posts that used to be hardcoded in
Community.jsx, so Like/Comment/Save have real rows to attach to.
"""
from django.db import migrations

SEED_POSTS = [
    {
        "display_name": "Anna B.",
        "avatar_url": "https://randomuser.me/api/portraits/women/1.jpg",
        "content": (
            "Proud of Myself \U0001f49b I went for a short walk this morning even "
            "though I didn’t feel motivated. It wasn’t long, but it helped "
            "clear my mind. What are you proud of today?"
        ),
    },
    {
        "display_name": "Anonymous",
        "avatar_url": "https://www.w3schools.com/howto/img_avatar2.png",
        "content": (
            "University has been overwhelming lately. I’m exhausted and scared "
            "I’m falling behind. Any gentle advice from people who’ve been "
            "through this?"
        ),
    },
    {
        "display_name": "Albert G.",
        "avatar_url": "https://randomuser.me/api/portraits/men/1.jpg",
        "content": (
            "I’m trying to build a consistent morning routine. Even simple "
            "things feel hard sometimes. What’s one small habit that made your "
            "mornings better?"
        ),
    },
    {
        "display_name": "Yara S.",
        "avatar_url": "https://randomuser.me/api/portraits/women/2.jpg",
        "content": (
            "Mini Declutter Challenge — Day 3 Pick one tiny thing to tidy "
            "today: your desk, your bag, your photo gallery… anything. Share "
            "your before/after or describe the moment."
        ),
    },
    {
        "display_name": "Anonymous",
        "avatar_url": "https://www.w3schools.com/howto/img_avatar.png",
        "content": (
            "I’ve been feeling disconnected from my friends lately. It’s "
            "like I’m there, but not really there. Does anyone else feel this "
            "sometimes?"
        ),
    },
    {
        "display_name": "Zayn M.",
        "avatar_url": "https://randomuser.me/api/portraits/men/2.jpg",
        "content": (
            "Write one sentence to yourself 6 months from now. Not advice — "
            "but a promise. I’ll start: I promise to rest when I need to, not "
            "only when I break."
        ),
    },
]


def seed_posts(apps, schema_editor):
    Post = apps.get_model("community", "Post")
    for entry in SEED_POSTS:
        Post.objects.get_or_create(
            display_name=entry["display_name"],
            content=entry["content"],
            defaults={"avatar_url": entry["avatar_url"]},
        )


def remove_seeded_posts(apps, schema_editor):
    Post = apps.get_model("community", "Post")
    contents = [entry["content"] for entry in SEED_POSTS]
    Post.objects.filter(content__in=contents).delete()


class Migration(migrations.Migration):

    dependencies = [
        ("community", "0001_initial"),
    ]

    operations = [
        migrations.RunPython(seed_posts, remove_seeded_posts),
    ]
