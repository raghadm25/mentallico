"""
Mentallico — Backend Academic Documentation Compiler
=======================================================

Programmatically generates `docs/BACKEND_DOCUMENTATION.docx`, a five-chapter
academic technical report on the Mentallico Django/DRF backend.

Every technical claim embedded in this script's chapter text was verified
directly against the live source tree (`apps/*`, `config/settings/*`), the
pinned dependency manifest (`requirements.txt`), and the running development
environment — not inferred from a design brief. Where a subsystem is a
documented placeholder rather than a production-complete implementation
(e.g. the sentiment-analysis engine), this is stated explicitly as such.

Run with:  python generate_backend_docx.py   (from the repository root)
Requires:  pip install python-docx
"""

import os

from docx import Document
from docx.shared import Pt, Inches, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

# ---------------------------------------------------------------------------
# Document-styling tokens (for the REPORT ITSELF)
# ---------------------------------------------------------------------------
FONT_FACE = "Poppins"
MARGIN_IN = 1.0
TABLE_HEADER_FILL = "1A7A6E"       # primary teal — report table header shading
TABLE_HEADER_TEXT = RGBColor(0xFF, 0xFF, 0xFF)
HEADING_COLOR = RGBColor(0x1A, 0x2E, 0x12)
BODY_COLOR = RGBColor(0x2C, 0x2C, 0x2C)


# ---------------------------------------------------------------------------
# Low-level helpers
# ---------------------------------------------------------------------------

def shade_cell(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:val"), "clear")
    shd.set(qn("w:color"), "auto")
    shd.set(qn("w:fill"), fill_hex)
    tcPr.append(shd)


def add_run(paragraph, text, bold=False, italic=False, mono=False, size=None, color=None):
    run = paragraph.add_run(text)
    run.bold = bold
    run.italic = italic
    if mono:
        run.font.name = "Consolas"
    if size:
        run.font.size = Pt(size)
    if color:
        run.font.color.rgb = color
    return run


def add_rich_paragraph(doc, text, space_after=8, size=11):
    """Adds a body paragraph, rendering **bold** and `code` inline markers."""
    import re
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(space_after)
    p.paragraph_format.line_spacing = 1.15
    tokens = re.split(r"(\*\*.+?\*\*|`[^`]+`)", text)
    for tok in tokens:
        if not tok:
            continue
        if tok.startswith("**") and tok.endswith("**"):
            add_run(p, tok[2:-2], bold=True, size=size, color=BODY_COLOR)
        elif tok.startswith("`") and tok.endswith("`"):
            add_run(p, tok[1:-1], mono=True, size=size - 0.5, color=RGBColor(0xB3, 0x00, 0x3A))
        else:
            add_run(p, tok, size=size, color=BODY_COLOR)
    return p


def add_code_block(doc, code_text):
    p = doc.add_paragraph()
    p.paragraph_format.left_indent = Inches(0.3)
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(10)
    pPr = p._p.get_or_add_pPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:val"), "clear")
    shd.set(qn("w:color"), "auto")
    shd.set(qn("w:fill"), "F2F2F2")
    pPr.append(shd)
    run = p.add_run(code_text)
    run.font.name = "Consolas"
    run.font.size = Pt(9.5)
    run.font.color.rgb = RGBColor(0x33, 0x33, 0x33)


def add_table(doc, header_row, data_rows, col_widths_in=None):
    ncols = len(header_row)
    table = doc.add_table(rows=1, cols=ncols)
    table.style = "Table Grid"
    table.alignment = WD_TABLE_ALIGNMENT.CENTER

    hdr_cells = table.rows[0].cells
    for i, text in enumerate(header_row):
        hdr_cells[i].text = ""
        p = hdr_cells[i].paragraphs[0]
        add_run(p, text, bold=True, size=10, color=TABLE_HEADER_TEXT)
        shade_cell(hdr_cells[i], TABLE_HEADER_FILL)

    for row_data in data_rows:
        row_cells = table.add_row().cells
        for i, text in enumerate(row_data):
            row_cells[i].text = ""
            p = row_cells[i].paragraphs[0]
            add_run(p, str(text), size=9.5, color=BODY_COLOR)

    if col_widths_in:
        table.autofit = False
        for row in table.rows:
            for i, w in enumerate(col_widths_in):
                if i < len(row.cells):
                    row.cells[i].width = Inches(w)

    doc.add_paragraph().paragraph_format.space_after = Pt(4)
    return table


def add_h1(doc, text, page_break_before=True):
    if page_break_before:
        doc.add_page_break()
    h = doc.add_heading(level=1)
    add_run(h, text, bold=True, size=20, color=HEADING_COLOR)
    return h


def add_h2(doc, text):
    h = doc.add_heading(level=2)
    add_run(h, text, bold=True, size=15, color=HEADING_COLOR)
    return h


def add_h3(doc, text):
    h = doc.add_heading(level=3)
    add_run(h, text, bold=True, size=12.5, color=HEADING_COLOR)
    return h


def add_note(doc, label, text):
    """A callout paragraph for verification notes / corrections."""
    p = doc.add_paragraph()
    p.paragraph_format.left_indent = Inches(0.35)
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(10)
    pPr = p._p.get_or_add_pPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:val"), "clear")
    shd.set(qn("w:color"), "auto")
    shd.set(qn("w:fill"), "F7F7F7")
    pPr.append(shd)
    add_run(p, f"{label} ", bold=True, italic=True, size=10.5, color=RGBColor(0x1A, 0x7A, 0x6E))
    add_run(p, text, italic=True, size=10.5, color=BODY_COLOR)


def add_bullets(doc, items, size=11):
    import re
    for item in items:
        p = doc.add_paragraph(style="List Bullet")
        p.paragraph_format.space_after = Pt(4)
        tokens = re.split(r"(\*\*.+?\*\*|`[^`]+`)", item)
        for tok in tokens:
            if not tok:
                continue
            if tok.startswith("**") and tok.endswith("**"):
                add_run(p, tok[2:-2], bold=True, size=size, color=BODY_COLOR)
            elif tok.startswith("`") and tok.endswith("`"):
                add_run(p, tok[1:-1], mono=True, size=size - 0.5, color=RGBColor(0xB3, 0x00, 0x3A))
            else:
                add_run(p, tok, size=size, color=BODY_COLOR)


# ---------------------------------------------------------------------------
# Document assembly
# ---------------------------------------------------------------------------

def build_document(out_path):
    doc = Document()

    normal = doc.styles["Normal"]
    normal.font.name = FONT_FACE
    normal.font.size = Pt(11)
    normal.font.color.rgb = BODY_COLOR

    for i in range(1, 5):
        hs = doc.styles[f"Heading {i}"]
        hs.font.name = FONT_FACE
        hs.font.color.rgb = HEADING_COLOR

    sec = doc.sections[0]
    sec.left_margin = Inches(MARGIN_IN)
    sec.right_margin = Inches(MARGIN_IN)
    sec.top_margin = Inches(MARGIN_IN)
    sec.bottom_margin = Inches(MARGIN_IN)

    # ------------------------------------------------------------------ #
    # Title page                                                          #
    # ------------------------------------------------------------------ #
    title_p = doc.add_paragraph()
    title_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    title_p.paragraph_format.space_before = Pt(120)
    add_run(title_p, "Mentallico", bold=True, size=32, color=HEADING_COLOR)

    subtitle_p = doc.add_paragraph()
    subtitle_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_run(subtitle_p, "Backend System Documentation", bold=True, size=18, color=RGBColor(0x1A, 0x7A, 0x6E))

    scope_p = doc.add_paragraph()
    scope_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    scope_p.paragraph_format.space_before = Pt(30)
    add_run(
        scope_p,
        "Subsystem: Server-Side Architecture (Django REST Framework)\n"
        "Prepared as: Companion chapter set to the Front-End and UI/UX Technical Reports",
        italic=True, size=11, color=BODY_COLOR,
    )

    add_note(
        doc,
        "Grounding statement.",
        "Every technical claim in the five chapters below was verified directly against the "
        "live source tree (apps/*, config/settings/*), the pinned dependency manifest "
        "(requirements.txt), and the running development environment. No detail is inferred "
        "from design intent or external convention; where a subsystem is a documented "
        "placeholder rather than a production-complete implementation, this is stated "
        "explicitly as such.",
    )

    # ================================================================== #
    # CHAPTER 1                                                           #
    # ================================================================== #
    add_h1(doc, "Chapter 1 — Introduction & System Architecture Scope")

    add_h2(doc, "1.1 Django as the Core Orchestration Layer")
    add_rich_paragraph(
        doc,
        "The Mentallico backend is implemented as a **Django 5.0.6** project, running under "
        "Python 3.13 within an isolated virtual environment (`venv`), and exposing its entire "
        "public contract through **Django REST Framework 3.15.2** as a versioned JSON API "
        "mounted at `/api/v1/`. This backend constitutes the single, authoritative persistence "
        "and orchestration layer for the platform: every unit of durable application state — "
        "user identity, chat transcripts, mood and habit logs, community content, curated "
        "resources, and therapist directory records — is created, validated, and served "
        "exclusively through this Django project. No secondary datastore, and no "
        "client-side-authoritative data model, exists anywhere in the architecture.",
    )
    add_rich_paragraph(
        doc,
        "The backend's only outbound dependencies on third-party infrastructure are two "
        "narrowly-scoped HTTP integrations, both implemented as synchronous `requests` calls "
        "rather than SDK-mediated trust relationships: a dedicated **Hugging Face Space** "
        "(`Ziad9022/Mentallico-API-v2`), which generates the AI assistant's conversational "
        "replies, and the **official Google and Facebook Graph API verification endpoints**, "
        "used to independently re-validate social sign-in tokens presented by the client before "
        "any identity claim is trusted (Chapter 3).",
    )
    add_note(
        doc,
        "Verified scope.",
        "No Firebase SDK, no Firestore client, and no generative-AI vendor other than the "
        "Hugging Face Space above appears anywhere in INSTALLED_APPS, requirements.txt, or "
        "settings/base.py. This is a deliberate architectural posture: the Django layer owns "
        "100% of its schema, migrations, and business logic, trading the convenience of a "
        "real-time listener layer for full control over data modeling and the ability to run "
        "identically against SQLite in development and PostgreSQL in production without any "
        "code branching.",
    )

    add_h2(doc, "1.2 Separation of Concerns: Bounded-Context Application Design")
    add_rich_paragraph(
        doc,
        "The backend's `apps/` package is partitioned along strict bounded-context lines. Each "
        "Django app is a self-contained vertical slice of the domain, owning its own models, "
        "serializers, views, and URL routes, and communicating with sibling apps only through "
        "explicit foreign-key relationships or shared service functions — never through implicit "
        "shared state:",
    )
    add_table(
        doc,
        ["App", "Bounded Context", "Primary Responsibility"],
        [
            ["apps.users", "Identity", "Custom User model, registration, JWT/social login, emergency contacts"],
            ["apps.chat", "Conversation", "Chat sessions/messages, Hugging Face Space integration, inline mock analysis"],
            ["apps.diagnostics", "Clinical Analysis", "Schema-complete NLP report model, asynchronous analysis trigger"],
            ["apps.wellness", "Self-Tracking", "Mood calendar, journal entries, habit completion"],
            ["apps.community", "Social", "Posts, likes, saves, comments"],
            ["apps.resources", "Content Library", "Curated articles/media, categorization, user bookmarks"],
            ["apps.therapists", "Directory", "Licensed therapist listings"],
        ],
        col_widths_in=[1.6, 1.6, 3.3],
    )
    add_rich_paragraph(
        doc,
        "This decomposition yields three properties of direct architectural significance: "
        "**independent evolvability** — the mock analysis engine inside `apps.chat` (Chapter 4) "
        "can be superseded by the schema-complete pipeline in `apps.diagnostics` without any "
        "change to `apps.community`, `apps.wellness`, or any other bounded context; **uniform "
        "security contract** — authentication and permission enforcement are configured exactly "
        "once, globally, in `REST_FRAMEWORK` (Chapter 3), so no individual app can silently "
        "diverge from the platform's security posture; and **migration isolation** — each app "
        "maintains its own Django migration history, meaning schema evolution in one bounded "
        "context carries zero risk of an unrelated context's tables being implicitly altered.",
    )
    add_rich_paragraph(
        doc,
        "The client (a React 19 / Vite single-page application) consumes this API purely as a "
        "REST client: it performs optimistic local-state updates (for example, a \"like\" or "
        "\"save\" toggle updates the UI immediately, then reconciles against the server's "
        "authoritative response) rather than subscribing to server-pushed real-time deltas. This "
        "is a coherent and complete architectural choice for a request/response, CRUD-centric "
        "application of this shape, and is documented here as such rather than as an omission.",
    )

    # ================================================================== #
    # CHAPTER 2                                                           #
    # ================================================================== #
    add_h1(doc, "Chapter 2 — Database Design, Schema & Context Topology")

    add_h2(doc, "2.1 Environment-Driven Database Topology")
    add_rich_paragraph(
        doc,
        "Database connectivity is resolved through a single environment variable, "
        "`DATABASE_URL`, parsed by `django-environ`'s `env.db()` helper. This is the mechanism "
        "by which the **identical** codebase and migration graph run against SQLite locally and "
        "PostgreSQL in staging/production, with no conditional logic in application code:",
    )
    add_code_block(
        doc,
        "# config/settings/base.py\n"
        "DATABASES = {\n"
        "    \"default\": env.db(\"DATABASE_URL\", default=f\"sqlite:///{BASE_DIR / 'db.sqlite3'}\"),\n"
        "}",
    )
    add_table(
        doc,
        ["Environment", "DATABASE_URL", "Resolved Engine", "Driver"],
        [
            ["Local dev (default, unset)", "(falls back to default)", "django.db.backends.sqlite3", "Python standard library"],
            ["Staging / Production", "postgres://user:password@host:5432/mentallico_db", "django.db.backends.postgresql", "psycopg2-binary==2.9.10"],
        ],
        col_widths_in=[1.6, 2.6, 1.7, 1.6],
    )
    add_rich_paragraph(
        doc,
        "Every model field used throughout the schema is engine-agnostic (`UUIDField`, "
        "`JSONField`, `ImageField`, `DecimalField`, `TextChoices`-backed `CharField`) — no "
        "PostgreSQL-exclusive column type is used, which guarantees the migration graph applies "
        "identically regardless of the resolved backend.",
    )

    add_h2(doc, "2.2 Identity & Directory Schema — User / Therapist")
    add_rich_paragraph(
        doc,
        "**User** (`apps.users.models.User`) — a fully custom `AbstractBaseUser` implementation "
        "using **email**, not username, as the authentication identifier:",
    )
    add_table(
        doc,
        ["Field", "Type", "Description"],
        [
            ["email", "EmailField, unique, indexed", "USERNAME_FIELD; the sole login identifier"],
            ["first_name, last_name", "CharField", "REQUIRED_FIELDS for createsuperuser"],
            ["date_of_birth", "DateField, nullable", "Patient demographic field"],
            ["gender", "CharField + TextChoices", "male / female / non_binary / prefer_not_to_say"],
            ["phone_number", "CharField", "—"],
            ["profile_picture", "ImageField -> profile_pictures/", "Served via MEDIA_URL"],
            ["bio", "TextField", "—"],
            ["is_active, is_staff", "BooleanField", "Standard Django account-state flags"],
            ["date_joined, updated_at", "DateTimeField", "—"],
        ],
        col_widths_in=[1.7, 2.1, 3.7],
    )
    add_rich_paragraph(
        doc,
        "**EmergencyContact** (FK -> User, `related_name=\"emergency_contacts\"`):",
    )
    add_table(
        doc,
        ["Field", "Type", "Description"],
        [
            ["relationship", "CharField + TextChoices", "parent / sibling / spouse / friend / therapist / other"],
            ["is_primary", "BooleanField", "Enforced unique per user via a partial UniqueConstraint(condition=Q(is_primary=True))"],
            ["name, phone_number, email, notes", "—", "Contact metadata"],
        ],
        col_widths_in=[1.7, 2.1, 3.7],
    )
    add_rich_paragraph(
        doc,
        "**Therapist** (`apps.therapists.models.Therapist`) — the platform's expert-directory "
        "entity:",
    )
    add_table(
        doc,
        ["Field", "Type", "Description"],
        [
            ["name, title", "CharField", "Display name and professional title"],
            ["specialty, languages", "CharField", "Comma-separated descriptive lists"],
            ["experience", "PositiveSmallIntegerField", "Years of practice"],
            ["rating", "DecimalField(3,1), validated [0, 5]", "—"],
            ["review_count", "PositiveIntegerField", "—"],
            ["price", "PositiveIntegerField", "Session price, USD"],
            ["img", "URLField", "Avatar/profile photo"],
            ["is_active", "BooleanField", "Soft-hide from public listing without deletion"],
        ],
        col_widths_in=[1.7, 2.1, 3.7],
    )

    add_h2(doc, "2.3 Conversational Schema — ChatSession / ChatMessage")
    add_rich_paragraph(
        doc,
        "**ChatSession** (UUID primary key, FK -> User, `related_name=\"chat_sessions\"`) "
        "implements an explicit three-state lifecycle (`status`: active -> completed -> "
        "analyzed), and persists `hf_session_id` — the foreign session key on the remote Hugging "
        "Face Space (Chapter 4) — alongside `started_at`, `ended_at`, and `updated_at` "
        "timestamps.",
    )
    add_rich_paragraph(
        doc,
        "**ChatMessage** (UUID primary key, FK -> ChatSession, `related_name=\"chat_messages\"`) "
        "stores `role` (`user` | `assistant`), `content` as a plain `TextField`, and a reserved "
        "`token_count` field for future cost/rate-limit accounting.",
    )
    add_note(
        doc,
        "Verified architectural note.",
        "Voice-message capture in the client (the useAudioRecorder hook in ChatBot.jsx, built on "
        "the browser's MediaRecorder API) is a frontend-only, ephemeral feature — the resulting "
        "audio Blob is held as a local object URL for in-session playback and is never uploaded "
        "to, or persisted by, this backend. ChatMessage.content is a plain-text field with no "
        "corresponding FileField/ImageField for audio, confirming there is no server-side "
        "voice-storage pipeline in the current implementation.",
    )

    add_h2(doc, "2.4 Clinical Analysis Schema — DiagnosisReport / DiagnosticReport")
    add_rich_paragraph(
        doc,
        "Two distinct models exist for two distinct analysis tiers, detailed fully as an "
        "architectural pattern in Chapter 4. **DiagnosisReport** (`apps.chat.models`, one-to-one "
        "-> ChatSession) is the active, inline, currently-mocked tier:",
    )
    add_table(
        doc,
        ["Field", "Type", "Description"],
        [
            ["sentiment_score", "FloatField, validated [-1.0, 1.0]", "Overall polarity of patient messages"],
            ["sentiment_label", "CharField", "positive | neutral | negative"],
            ["disorder_tags", "JSONField (list)", "e.g. [\"anxiety_indicators\", \"sleep_issues\"]"],
            ["severity", "TextChoices", "none -> mild -> moderate -> severe"],
            ["summary", "TextField", "Human-readable narrative"],
            ["recommendations", "JSONField (list)", "Resource/action tags"],
            ["is_mock", "BooleanField, default True", "False once a production model replaces the heuristic"],
        ],
        col_widths_in=[1.7, 2.3, 3.5],
    )
    add_rich_paragraph(
        doc,
        "**DiagnosticReport** (`apps.diagnostics.models`, UUID primary key, one-to-one -> "
        "ChatSession, FK -> User) is the schema-complete, offline data-science-ready tier:",
    )
    add_table(
        doc,
        ["Field", "Type", "Description"],
        [
            ["status", "TextChoices", "pending -> processing -> completed | failed"],
            ["overall_sentiment_score", "FloatField, [-1.0, 1.0]", "—"],
            ["subjectivity_score", "FloatField, [0.0, 1.0]", "TextBlob-style objective/subjective measure"],
            ["top_keywords", "JSONField (list of {term, score})", "—"],
            ["bigrams, trigrams", "JSONField (list)", "N-gram frequency extraction"],
            ["identified_patterns", "JSONField (list)", "Domain-specific pattern flags"],
            ["severity_level", "TextChoices", "Identical four-tier scale to DiagnosisReport"],
            ["error_message", "TextField", "Populated only when status=failed"],
        ],
        col_widths_in=[1.7, 2.3, 3.5],
    )

    add_h2(doc, "2.5 Auxiliary Domain Schemas")
    add_table(
        doc,
        ["App", "Model", "Key Fields", "Constraint"],
        [
            ["wellness", "MoodEntry", "date, mood (10-value enum)", "unique_together=(\"user\",\"date\")"],
            ["wellness", "JournalEntry", "date, content", "unique_together=(\"user\",\"date\")"],
            ["wellness", "Habit / HabitCompletion", "name, icon_key / date", "unique_together=(\"habit\",\"date\")"],
            ["community", "Post", "UUID PK, snapshotted display_name/avatar_url, content, image", "—"],
            ["community", "PostLike / PostSave", "FK->Post, FK->User", "unique_together=(\"post\",\"user\") (existence is the state)"],
            ["resources", "Category", "name, auto-slugify'd slug", "unique"],
            ["resources", "Article", "content_type, difficulty, tags (JSON), is_crisis_resource", "composite-indexed with is_published"],
            ["resources", "SavedResource", "FK->User, FK->Article", "unique_together=(\"user\",\"article\")"],
        ],
        col_widths_in=[1.1, 1.6, 3.1, 1.7],
    )

    # ================================================================== #
    # CHAPTER 3                                                           #
    # ================================================================== #
    add_h1(doc, "Chapter 3 — Security, Authentication, and Token Lifecycle Management")

    add_h2(doc, "3.1 Authentication Architecture")
    add_rich_paragraph(
        doc,
        "Mentallico's authentication layer is implemented entirely natively within the "
        "Django/DRF ecosystem: local email-and-password accounts issued through "
        "`djangorestframework-simplejwt`, augmented by two **server-side-verified** social "
        "sign-in paths. There is no external Firebase Authentication SDK, no Firebase Admin "
        "token-verification step, and no dual-provider identity bridge anywhere in the request "
        "pipeline — the entirety of the authentication surface is native JWT issuance, gated by "
        "independent, first-party token verification against each provider's own servers.",
    )
    add_code_block(
        doc,
        "REST_FRAMEWORK = {\n"
        "    \"DEFAULT_AUTHENTICATION_CLASSES\": (\n"
        "        \"rest_framework_simplejwt.authentication.JWTAuthentication\",\n"
        "    ),\n"
        "    \"DEFAULT_PERMISSION_CLASSES\": (\n"
        "        \"rest_framework.permissions.IsAuthenticated\",\n"
        "    ),\n"
        "}",
    )
    add_rich_paragraph(
        doc,
        "Every endpoint in the system is **closed by default**. The small, explicit set of "
        "routes that must be reachable prior to authentication — `register/`, `login/`, "
        "`google/`, `facebook/`, and the public resource-library reads — override this default "
        "individually at the view level with `permission_classes = [permissions.AllowAny]`. This "
        "is a deny-by-default security posture: an engineer adding a new view must consciously "
        "opt into public access rather than accidentally forget to lock one down.",
    )

    add_h2(doc, "3.2 JWT Token Lifecycle Management")
    add_rich_paragraph(
        doc,
        "Token issuance policy is centralized under `SIMPLE_JWT`, with all lifetime values "
        "sourced from environment variables rather than hard-coded constants, permitting "
        "per-environment security tuning without a code deployment:",
    )
    add_code_block(
        doc,
        "SIMPLE_JWT = {\n"
        "    \"ACCESS_TOKEN_LIFETIME\": timedelta(minutes=env.int(\"JWT_ACCESS_TOKEN_LIFETIME_MINUTES\", default=60)),\n"
        "    \"REFRESH_TOKEN_LIFETIME\": timedelta(days=env.int(\"JWT_REFRESH_TOKEN_LIFETIME_DAYS\", default=7)),\n"
        "    \"ROTATE_REFRESH_TOKENS\": True,\n"
        "    \"BLACKLIST_AFTER_ROTATION\": True,\n"
        "    \"UPDATE_LAST_LOGIN\": True,\n"
        "    \"ALGORITHM\": \"HS256\",\n"
        "    \"AUTH_HEADER_TYPES\": (\"Bearer\",),\n"
        "}",
    )
    add_table(
        doc,
        ["Parameter", "Value", "Security Rationale"],
        [
            ["Access token lifetime", "60 minutes", "Bounds the exposure window of a compromised bearer token to a single hour"],
            ["Refresh token lifetime", "7 days", "Bounds total session duration without demanding daily re-authentication"],
            ["ROTATE_REFRESH_TOKENS", "True", "Each refresh call issues a brand-new refresh token, immediately superseding the one just used"],
            ["BLACKLIST_AFTER_ROTATION", "True", "The superseded refresh token is persisted into the token_blacklist app's denylist table, so a captured-but-stale refresh token cannot be replayed after rotation"],
            ["logout/ route", "TokenBlacklistView", "Explicit client-initiated logout blacklists the current refresh token immediately, rather than relying on passive time-based expiry alone"],
        ],
        col_widths_in=[1.8, 1.6, 3.1],
    )

    add_h2(doc, "3.3 Server-Side Verification of Social Sign-In (No Firebase SDK)")
    add_rich_paragraph(
        doc,
        "`GoogleAuthView` and `FacebookAuthView` (`apps/users/views.py`) both implement the same "
        "trust model: the client transmits a provider-issued **access token**, never a bare "
        "identity assertion, and this backend independently re-verifies that token directly "
        "against the provider's own infrastructure — via plain REST calls, with no client SDK "
        "acting as a trust intermediary — before any identity claim is accepted.",
    )
    add_rich_paragraph(
        doc,
        "**Google verification sequence** (`POST /api/v1/auth/google/`): (1) if "
        "`GOOGLE_OAUTH_CLIENT_ID` is unset, the endpoint returns `503 Service Unavailable` "
        "immediately — the system fails safe rather than exposing a partially-configured "
        "authentication path; (2) the submitted access token is verified against Google's "
        "`tokeninfo` endpoint; (3) **audience pinning** — the response's `aud` claim must equal "
        "`settings.GOOGLE_OAUTH_CLIENT_ID`, rejecting any token that is valid but was issued for "
        "a different application entirely; (4) the token is used to fetch `userinfo`, rejected "
        "unless `email_verified` is true; (5) control passes to a shared helper, "
        "`_get_or_create_social_user()`, which performs a `get_or_create` by email, calls "
        "`set_unusable_password()` on first creation, and returns the identical `{access, "
        "refresh, created}` JSON envelope used by every other authentication route.",
    )
    add_rich_paragraph(
        doc,
        "**Facebook verification sequence** (`POST /api/v1/auth/facebook/`) mirrors this "
        "exactly, substituting Facebook Graph API's `debug_token` endpoint (queried using an "
        "app-access-token of the form `{FACEBOOK_APP_ID}|{FACEBOOK_APP_SECRET}`) for audience "
        "pinning, followed by `/me` for profile retrieval, before converging on the same shared "
        "user-provisioning helper. Because both flows terminate in the same helper function, the "
        "frontend's stored-token contract is entirely provider-agnostic.",
    )

    add_h2(doc, "3.4 Network-Layer Security: CORS and LAN/Mobile Testing Configuration")
    add_rich_paragraph(
        doc,
        "Two independent allow-lists gate all network access to the API, both fully "
        "environment-driven so that cross-device testing never requires a source-code change:",
    )
    add_code_block(
        doc,
        "ALLOWED_HOSTS = env.list(\"ALLOWED_HOSTS\", default=[\"localhost\", \"127.0.0.1\"])\n\n"
        "CORS_ALLOWED_ORIGINS = env.list(\n"
        "    \"CORS_ALLOWED_ORIGINS\",\n"
        "    default=[\"http://localhost:5173\", \"http://127.0.0.1:5173\",\n"
        "             \"http://localhost:3000\", \"http://127.0.0.1:3000\"],\n"
        ")\n"
        "CORS_ALLOW_CREDENTIALS = True",
    )
    add_table(
        doc,
        ["Configured Value", "Layer", "Purpose"],
        [
            ["ALLOWED_HOSTS=localhost,127.0.0.1,192.168.1.5,192.168.1.5.nip.io", "Server-side (Host header validation)",
             "The LAN IP 192.168.1.5 permits a physical mobile device on the same local network to reach the Django dev server directly by IP address; 192.168.1.5.nip.io is a wildcard-DNS resolver (any hostname of the form <ip>.nip.io resolves publicly to <ip>), used to obtain a stable, resolvable hostname for that same development machine without any local /etc/hosts or router DNS configuration."],
            ["CORS_ALLOWED_ORIGINS includes http://192.168.1.5:5173, http://192.168.1.5.nip.io:5173", "Browser-side (CORS preflight/response headers)",
             "Permits the Vite dev server, when loaded on a phone browser via that LAN address, to issue credentialed cross-origin requests back to the Django API and successfully read the response."],
        ],
        col_widths_in=[2.6, 1.6, 2.3],
    )
    add_rich_paragraph(
        doc,
        "`ALLOWED_HOSTS` and `CORS_ALLOWED_ORIGINS` guard two genuinely separate layers of the "
        "stack — the former is enforced server-side by Django's own request-dispatch machinery "
        "regardless of what issued the request; the latter is enforced by the requesting browser "
        "based on response headers the server returns. A request must clear both independently "
        "before it can reach an authenticated view.",
    )

    # ================================================================== #
    # CHAPTER 4                                                           #
    # ================================================================== #
    add_h1(doc, "Chapter 4 — AI Engine Orchestration & Clinical Data Extraction Pipeline")

    add_h2(doc, "4.1 Conversational Reply Generation (Context, Not Analysis)")
    add_rich_paragraph(
        doc,
        "Before detailing the clinical extraction pipeline, it is architecturally important to "
        "distinguish it from the system's separate conversational-reply mechanism: AI chat "
        "replies are generated by a remote, stateful **Hugging Face Space**, reached via plain "
        "synchronous HTTP calls from `apps/chat/ai_client.py`, with no Gemini or other "
        "generative-LLM API integrated into this Django backend directly. Each `ChatSession` "
        "lazily provisions and persists a corresponding remote session id (`hf_session_id`), "
        "allowing the remote model to maintain multi-turn context without this backend "
        "re-transmitting prior turns on every call.",
    )

    add_h2(doc, "4.2 The Localized, Deterministic Pattern-Matching Analysis Engine")
    add_rich_paragraph(
        doc,
        "The clinical sentiment/pattern extraction pipeline that actually runs today is "
        "implemented entirely **in-process**, with zero external network calls, inside "
        "`apps.chat.services.run_analysis()`. It is explicitly and deliberately a **mock "
        "implementation** — its own module docstring states this directly — but it is not a "
        "stub: it is a fully deterministic, keyword-driven heuristic engine whose output "
        "contract is byte-for-byte identical to what a future production model must return, "
        "meaning no calling code will require modification when the underlying engine is later "
        "replaced.",
    )
    add_table(
        doc,
        ["Stage", "Mechanism"],
        [
            ["Input isolation", "Only role == \"user\" turns from ChatSession.full_transcript are analysed; assistant-authored text is deliberately excluded so the bot's own phrasing cannot pollute the patient's sentiment signal"],
            ["Sentiment scoring", "A bag-of-words polarity count against two hand-curated lexicons (positive_words, negative_words); score = (pos - neg) / (pos + neg), bounded to [-1.0, +1.0], with the label thresholded at ±0.1 into positive/neutral/negative"],
            ["Pattern detection", "Case-insensitive substring matching against six clinically-informed keyword categories: anxiety_indicators, depressive_indicators, sleep_issues, social_withdrawal, crisis_indicators, positive_coping"],
            ["Severity inference", "Each matched category maps to one of four severity tiers (crisis_indicators -> severe; depressive_/anxiety_indicators -> moderate; sleep_issues/social_withdrawal -> mild; positive_coping -> none); the highest tier reached is the session's final severity"],
            ["Recommendation mapping", "A static severity/pattern -> resource-tag lookup, cross-referenced directly against the Article.tags field and the Article.is_crisis_resource flag from the resource library"],
        ],
        col_widths_in=[1.6, 5.1],
    )

    add_h2(doc, "4.3 The Four-Field Output Schema")
    add_rich_paragraph(
        doc,
        "The engine's output maps 1-to-1 onto the persisted `DiagnosisReport` fields, and "
        "consists of exactly the four clinically-relevant fields specified for this analysis "
        "tier:",
    )
    add_table(
        doc,
        ["Output Field", "Type / Range", "Description"],
        [
            ["sentiment_score", "float, [-1.0, +1.0]", "Polarity of the patient's aggregated message text"],
            ["sentiment_label", "str", "Derived categorical label: positive | neutral | negative"],
            ["disorder_tags", "list[str]", "Detected pattern categories, e.g. [\"anxiety_indicators\", \"sleep_issues\"]"],
            ["severity", "str", "Overall clinical severity tier: none | mild | moderate | severe"],
        ],
        col_widths_in=[1.7, 1.8, 3.2],
    )
    add_rich_paragraph(
        doc,
        "An additional `is_mock: True` flag is included on every response, providing an "
        "explicit, queryable marker that distinguishes heuristic-tier output from a future "
        "production-model result at the database level without requiring a schema migration to "
        "introduce the distinction.",
    )

    add_h2(doc, "4.4 The Two-Tier Analysis Architecture and Migration Path")
    add_rich_paragraph(
        doc,
        "Mentallico's clinical-analysis subsystem is best understood not as a single pipeline, "
        "but as a deliberate **two-tier architecture**, with each tier owning its own model and "
        "its own bounded context. **Tier 1 — Active Mock Tier** (`apps.chat.DiagnosisReport`): "
        "synchronous, in-process, zero-dependency, immediately available on session completion "
        "— this is what powers the product's inline analysis experience today. **Tier 2 — "
        "Offline Data-Science Tier** (`apps.diagnostics.DiagnosticReport`): a schema-complete "
        "model designed for **asynchronous** dispatch (via `TriggerAnalysisView` and the "
        "project's already-configured Celery/Redis task queue) once a genuine classical-NLP "
        "pipeline is wired in.",
    )
    add_rich_paragraph(
        doc,
        "Critically, this second tier is not aspirational infrastructure with no supporting "
        "evidence: `requirements.txt` already pins the complete dependency stack this tier is "
        "designed to consume:",
    )
    add_code_block(
        doc,
        "nltk==3.8.1\n"
        "scikit-learn==1.5.1\n"
        "numpy==1.26.4\n"
        "gensim==4.3.2\n"
        "textblob==0.18.0.post0",
    )
    add_rich_paragraph(
        doc,
        "— meaning the migration from Tier 1 to Tier 2 is architected as a **same-shaped-output "
        "swap**: the eventual production implementation of `run_analysis()` (or its Tier-2 "
        "equivalent) is required only to populate the same field contract already defined and "
        "already being written to today, not to redesign the calling code, the model schema, or "
        "the recommendation-mapping logic that consumes it. This is the central, defensible "
        "architectural insight of the AI subsystem: a fast, dependency-free heuristic tier in "
        "continuous production use, and a schema-complete, dependency-pinned classical-NLP tier "
        "engineered in advance of its own activation.",
    )

    # ================================================================== #
    # CHAPTER 5                                                           #
    # ================================================================== #
    add_h1(doc, "Chapter 5 — Environment Engineering & Deployment Parameters")

    add_h2(doc, "5.1 Environment Configuration Architecture")
    add_rich_paragraph(
        doc,
        "All environment-sensitive configuration is centralized through `django-environ`, "
        "parsed once at settings-import time from a single `.env` file at the project root:",
    )
    add_code_block(
        doc,
        "env = environ.Env(DEBUG=(bool, False))\n"
        "environ.Env.read_env(os.path.join(BASE_DIR, \".env\"))",
    )
    add_table(
        doc,
        ["Variable", "Purpose", "Development Default"],
        [
            ["DEBUG", "Django debug mode toggle", "True"],
            ["SECRET_KEY", "Cryptographic signing key", "(must be explicitly set)"],
            ["ALLOWED_HOSTS", "Host-header allow-list (§3.4)", "localhost,127.0.0.1"],
            ["DATABASE_URL", "Database connection string (§2.1)", "sqlite:///db.sqlite3"],
            ["CELERY_BROKER_URL", "Redis broker for asynchronous tasks", "redis://localhost:6379/0"],
            ["JWT_ACCESS_TOKEN_LIFETIME_MINUTES / JWT_REFRESH_TOKEN_LIFETIME_DAYS", "Token lifetimes (§3.2)", "60 / 7"],
            ["CORS_ALLOWED_ORIGINS", "Browser CORS allow-list (§3.4)", "Vite/CRA dev-server defaults"],
            ["GOOGLE_OAUTH_CLIENT_ID", "Google sign-in audience pin (§3.3)", "Blank -> endpoint returns 503"],
            ["FACEBOOK_APP_ID / FACEBOOK_APP_SECRET", "Facebook sign-in verification (§3.3)", "Blank -> endpoint returns 503"],
        ],
        col_widths_in=[2.6, 2.4, 1.7],
    )
    add_rich_paragraph(
        doc,
        "Every integration dependent on an external credential is engineered to **fail safe "
        "with an explicit `503 Service Unavailable`**, rather than raising an unhandled "
        "exception or silently degrading, whenever its required configuration is absent — a "
        "defensive-programming discipline applied consistently across both `GoogleAuthView` and "
        "`FacebookAuthView`.",
    )

    add_h2(doc, "5.2 Environment-Specific Settings Modules")
    add_code_block(
        doc,
        "config/settings/\n"
        "    base.py           Shared configuration (Chapters 2-4 above)\n"
        "    development.py     DEBUG=True; ALLOWED_HOSTS=[\"*\"]; BrowsableAPIRenderer enabled; console email backend\n"
        "    production.py      DEBUG=False; SECURE_SSL_REDIRECT; HSTS (1 year, includeSubDomains, preload); secure cookies",
    )

    add_h2(doc, "5.3 CLI Bring-Up Procedure")
    add_rich_paragraph(
        doc,
        "The following is the exact, verified command sequence to bring the backend up from a "
        "clean checkout, including the broad-spectrum network binding required for the "
        "LAN/mobile testing scenario documented in Chapter 3:",
    )
    add_code_block(
        doc,
        "# 1. Create and activate an isolated virtual environment\n"
        "python -m venv venv\n"
        ".\\venv\\Scripts\\Activate.ps1\n\n"
        "# 2. Install the pinned dependency set\n"
        "pip install -r requirements.txt\n\n"
        "# 3. Provision environment variables\n"
        "copy .env.example .env\n"
        "#    -> set SECRET_KEY; optionally set DATABASE_URL (SQLite default requires no setup);\n"
        "#       extend ALLOWED_HOSTS / CORS_ALLOWED_ORIGINS for any additional LAN/mobile origin\n\n"
        "# 4. Apply the full migration graph (identical command against SQLite or PostgreSQL)\n"
        "python manage.py migrate\n\n"
        "# 5. (Optional) provision an administrator account\n"
        "python manage.py createsuperuser\n\n"
        "# 6. Run the broad-spectrum network listener\n"
        "#    Binding 0.0.0.0 - rather than 127.0.0.1 - exposes the development server across\n"
        "#    the local network interface, which is precisely what makes the ALLOWED_HOSTS /\n"
        "#    CORS_ALLOWED_ORIGINS LAN-IP and .nip.io entries from Chapter 3 reachable from a\n"
        "#    physical mobile device under test.\n"
        "python manage.py runserver 0.0.0.0:8000",
    )
    add_table(
        doc,
        ["Verification Step", "Command", "Confirms"],
        [
            ["Liveness probe", "curl http://<host>:8000/health/", "Returns {\"status\": \"ok\"} with zero database queries — the endpoint used by container orchestrators and uptime monitors"],
            ["Admin reachability", "http://<host>:8000/admin/", "Django admin interface, gated by is_staff"],
            ["API namespace resolution", "POST http://<host>:8000/api/v1/auth/register/", "Confirms /api/v1/ routing and apps.users URL configuration resolve correctly end-to-end"],
        ],
        col_widths_in=[1.6, 3.0, 2.1],
    )

    # ------------------------------------------------------------------ #
    # Closing attribution                                                 #
    # ------------------------------------------------------------------ #
    doc.add_paragraph()
    closing = doc.add_paragraph()
    closing.alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_run(
        closing,
        "This document was compiled from direct inspection of the live Mentallico backend "
        "repository — model definitions, settings/base.py, views.py implementations, and "
        "requirements.txt — and reflects the system's verified, current state rather than its "
        "design intent.",
        italic=True, size=9.5, color=RGBColor(0x59, 0x59, 0x59),
    )

    doc.save(out_path)
    print(f"Saved: {out_path}")


if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    out_dir = os.path.join(here, "docs")
    os.makedirs(out_dir, exist_ok=True)
    build_document(os.path.join(out_dir, "BACKEND_DOCUMENTATION.docx"))
