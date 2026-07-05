"""
Seeds a handful of realistic, multi-turn demo conversations for a user so
the chat sidebar has real history to click into instead of placeholder text.

Usage:
    python manage.py seed_demo_chats --email hm612215@gmail.com

Idempotent: re-running skips any demo conversation whose title already
exists for that user, so it's safe to run more than once.
"""
from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand, CommandError

from apps.chat.models import ChatMessage, ChatSession

User = get_user_model()

DEMO_CONVERSATIONS = [
    {
        "title": "How To Get Over The Feeling Of Guilt?",
        "turns": [
            ("user", "I've been feeling really guilty about something I said to my friend last week."),
            ("assistant", "I hear you — guilt can be really heavy to carry. Do you want to tell me what happened?"),
            ("user", "I snapped at her when she was just trying to help, and I still feel bad about it."),
            ("assistant", "It sounds like you care about her a lot, which is why this is weighing on you. Have you had a chance to talk to her about how you're feeling?"),
        ],
    },
    {
        "title": "Best Books To Read About Personal Growth",
        "turns": [
            ("user", "Can you recommend some books about personal growth?"),
            ("assistant", "Sure! A few that a lot of people find helpful are 'Atomic Habits' by James Clear, 'The Body Keeps the Score' by Bessel van der Kolk, and 'Maybe You Should Talk to Someone' by Lori Gottlieb."),
            ("user", "I've heard of the first one. What's the second one about?"),
            ("assistant", "It's about how trauma affects the body and mind, and how healing can happen — it's a great read if you're curious about the mind-body connection."),
        ],
    },
    {
        "title": "Daily Fights With Overthinking",
        "turns": [
            ("user", "I overthink everything, every single day. It's exhausting."),
            ("assistant", "That sounds really draining. What does overthinking usually look like for you — is it more about the past, or worrying about what's next?"),
            ("user", "Mostly worrying about what could go wrong before it even happens."),
            ("assistant", "That's really common with anxious thinking. One thing that can help is gently asking yourself: 'Is this thought a fact, or a fear?' Would you like to try a short grounding exercise together?"),
        ],
    },
    {
        "title": "Feeling Misunderstood",
        "turns": [
            ("user", "I feel like no one really gets what I'm going through."),
            ("assistant", "That's such an isolating feeling. I'm here, and I want to understand — can you tell me a bit more about what's been going on?"),
            ("user", "I try to explain it but people just don't get it."),
            ("assistant", "It makes sense that would be frustrating. Sometimes it's not about finding the right words — it's about finding someone who's willing to really listen. I'm listening."),
        ],
    },
    {
        "title": "Overwhelming Day",
        "turns": [
            ("user", "Today has just been so overwhelming, I don't even know where to start."),
            ("assistant", "That sounds like a lot to carry. Do you want to talk through what's making today feel so heavy, or would it help more to just take a moment to breathe first?"),
            ("user", "Maybe breathing first."),
            ("assistant", "Okay, let's do that together. Breathe in slowly for 4 counts... hold for 4... and out for 4. We can repeat that a few times whenever you're ready."),
        ],
    },
]


class Command(BaseCommand):
    help = "Seed realistic demo chat conversations for a user's sidebar history."

    def add_arguments(self, parser):
        parser.add_argument(
            "--email",
            default="hm612215@gmail.com",
            help="Email of the user to seed conversations for.",
        )

    def handle(self, *args, **options):
        email = options["email"]
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            raise CommandError(f"No user found with email '{email}'.")

        created_count = 0
        for convo in DEMO_CONVERSATIONS:
            if ChatSession.objects.filter(user=user, title=convo["title"]).exists():
                self.stdout.write(f"Skipping (already exists): {convo['title']}")
                continue

            session = ChatSession.objects.create(user=user, title=convo["title"])
            for role, content in convo["turns"]:
                ChatMessage.objects.create(
                    session=session,
                    role=ChatMessage.RoleChoices.USER if role == "user" else ChatMessage.RoleChoices.ASSISTANT,
                    content=content,
                )
            created_count += 1
            self.stdout.write(self.style.SUCCESS(f"Created: {convo['title']} ({session.id})"))

        self.stdout.write(self.style.SUCCESS(f"Done — {created_count} conversation(s) created for {email}."))
