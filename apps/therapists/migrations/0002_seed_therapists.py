"""
Data migration — seeds the Therapist table with the 12 therapists
that match the frontend doctors array in Therapist.jsx.
"""
from django.db import migrations

THERAPISTS = [
    {
        "name": "Dr. Ali Samir",
        "title": "Psychotherapist (Anxiety & Depression)",
        "specialty": "Anxiety, Depression, Stress Management",
        "experience": 10,
        "languages": "English, Arabic",
        "rating": "4.9",
        "review_count": 128,
        "price": 75,
        "img": "https://xsgames.co/randomusers/assets/avatars/male/74.jpg",
        "bio": (
            "Dr. Ali Samir specializes in cognitive-behavioral therapy for anxiety and "
            "depression. With 10 years of experience, he helps patients regain emotional "
            "balance through evidence-based techniques."
        ),
    },
    {
        "name": "Dr. Sara Hany",
        "title": "Clinical Counselor (Child Behavior)",
        "specialty": "Child Behavior, Parenting, ADHD",
        "experience": 8,
        "languages": "English, Arabic",
        "rating": "4.8",
        "review_count": 95,
        "price": 70,
        "img": "https://xsgames.co/randomusers/assets/avatars/female/24.jpg",
        "bio": (
            "Dr. Sara Hany works closely with children and families to address behavioral "
            "challenges. She uses play-based therapy and parent coaching to create lasting "
            "positive change."
        ),
    },
    {
        "name": "Dr. Mariah Holland",
        "title": "Couple & Family Therapist",
        "specialty": "Couples Therapy, Family Conflict, Communication",
        "experience": 12,
        "languages": "English, French",
        "rating": "4.7",
        "review_count": 112,
        "price": 90,
        "img": "https://xsgames.co/randomusers/assets/avatars/female/32.jpg",
        "bio": (
            "Dr. Mariah Holland is a certified couple and family therapist. She guides "
            "families through conflict resolution, communication improvement, and rebuilding trust."
        ),
    },
    {
        "name": "Dr. Xavier Roberto",
        "title": "Psychotherapist (Anxiety & Emotional)",
        "specialty": "Emotional Regulation, Anxiety, Phobias",
        "experience": 9,
        "languages": "English, Spanish",
        "rating": "4.8",
        "review_count": 87,
        "price": 80,
        "img": "https://xsgames.co/randomusers/assets/avatars/male/40.jpg",
        "bio": (
            "Dr. Xavier Roberto focuses on emotional regulation and anxiety disorders. "
            "He blends psychodynamic and cognitive approaches to help clients navigate "
            "complex emotional experiences."
        ),
    },
    {
        "name": "Dr. Kareem El-Hadidy",
        "title": "Trauma & Recovery Specialist",
        "specialty": "PTSD, Trauma, Grief, Recovery",
        "experience": 14,
        "languages": "English, Arabic",
        "rating": "4.9",
        "review_count": 201,
        "price": 95,
        "img": "https://xsgames.co/randomusers/assets/avatars/male/52.jpg",
        "bio": (
            "Dr. Kareem El-Hadidy is a trauma specialist with 14 years of experience in "
            "PTSD treatment and grief recovery. He uses EMDR and somatic therapy for deep healing."
        ),
    },
    {
        "name": "Dr. Monica Hernandez",
        "title": "Adolescent & Young Adult Psychologist",
        "specialty": "Teen Mental Health, Identity, Peer Pressure",
        "experience": 7,
        "languages": "English, Spanish",
        "rating": "4.7",
        "review_count": 74,
        "price": 70,
        "img": "https://xsgames.co/randomusers/assets/avatars/female/45.jpg",
        "bio": (
            "Dr. Monica Hernandez specializes in adolescent psychology, helping teens and "
            "young adults navigate identity challenges, peer pressure, and academic stress."
        ),
    },
    {
        "name": "Dr. Hagar Osama",
        "title": "Emotional Health Counselor",
        "specialty": "Emotional Health, Self-Esteem, Life Transitions",
        "experience": 6,
        "languages": "English, Arabic",
        "rating": "4.6",
        "review_count": 63,
        "price": 65,
        "img": "https://xsgames.co/randomusers/assets/avatars/female/18.jpg",
        "bio": (
            "Dr. Hagar Osama supports clients through life transitions, low self-esteem, "
            "and emotional struggles. Her warm, client-centered approach creates a safe space "
            "for healing."
        ),
    },
    {
        "name": "Dr. George Matt",
        "title": "Mindfulness Coach & Psychotherapist",
        "specialty": "Mindfulness, Burnout, Stress, Meditation",
        "experience": 11,
        "languages": "English",
        "rating": "4.8",
        "review_count": 143,
        "price": 85,
        "img": "https://xsgames.co/randomusers/assets/avatars/male/65.jpg",
        "bio": (
            "Dr. George Matt integrates mindfulness-based cognitive therapy with traditional "
            "psychotherapy. He has helped hundreds of clients overcome burnout and chronic stress."
        ),
    },
    {
        "name": "Dr. Ethan Brooks",
        "title": "Behavioral Therapist (Addiction & Adult)",
        "specialty": "Addiction, Behavioral Therapy, Adult Mental Health",
        "experience": 13,
        "languages": "English",
        "rating": "4.9",
        "review_count": 176,
        "price": 90,
        "img": "https://xsgames.co/randomusers/assets/avatars/male/22.jpg",
        "bio": (
            "Dr. Ethan Brooks is a leading behavioral therapist specializing in addiction "
            "recovery and adult mental health. He uses motivational interviewing and DBT."
        ),
    },
    {
        "name": "Dr. Emily Carter",
        "title": "Psychiatrist (Mood & Sleep Disorders)",
        "specialty": "Bipolar Disorder, Insomnia, Mood Disorders",
        "experience": 15,
        "languages": "English",
        "rating": "4.9",
        "review_count": 218,
        "price": 110,
        "img": "https://xsgames.co/randomusers/assets/avatars/female/35.jpg",
        "bio": (
            "Dr. Emily Carter is a board-certified psychiatrist with 15 years of expertise "
            "in mood and sleep disorders. She provides comprehensive psychiatric evaluations "
            "and medication management."
        ),
    },
    {
        "name": "Dr. Oliver Chen",
        "title": "Clinical Psychologist (CBT Therapy)",
        "specialty": "CBT, OCD, Panic Disorder, Social Anxiety",
        "experience": 10,
        "languages": "English, Mandarin",
        "rating": "4.8",
        "review_count": 134,
        "price": 80,
        "img": "https://xsgames.co/randomusers/assets/avatars/male/12.jpg",
        "bio": (
            "Dr. Oliver Chen is a clinical psychologist specializing in CBT for OCD, panic "
            "disorder, and social anxiety. He draws on both Western and Eastern therapeutic traditions."
        ),
    },
    {
        "name": "Dr. Jacob Miller",
        "title": "Clinical Counselor (Stress & Burnout)",
        "specialty": "Work Stress, Burnout, Anxiety, Career Transitions",
        "experience": 8,
        "languages": "English",
        "rating": "4.7",
        "review_count": 91,
        "price": 75,
        "img": "https://xsgames.co/randomusers/assets/avatars/male/15.jpg",
        "bio": (
            "Dr. Jacob Miller helps professionals manage work-related stress and burnout. "
            "His solution-focused counseling approach delivers practical tools for immediate relief."
        ),
    },
]


def seed_therapists(apps, schema_editor):
    Therapist = apps.get_model("therapists", "Therapist")
    for data in THERAPISTS:
        Therapist.objects.get_or_create(name=data["name"], defaults=data)


def unseed_therapists(apps, schema_editor):
    Therapist = apps.get_model("therapists", "Therapist")
    names = [t["name"] for t in THERAPISTS]
    Therapist.objects.filter(name__in=names).delete()


class Migration(migrations.Migration):

    dependencies = [
        ("therapists", "0001_initial"),
    ]

    operations = [
        migrations.RunPython(seed_therapists, reverse_code=unseed_therapists),
    ]
