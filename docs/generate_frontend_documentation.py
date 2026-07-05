"""
Mentallico — Front-End Academic Documentation Compiler
========================================================

Programmatically generates `docs/FRONTEND_DOCUMENTATION.docx`, a five-chapter
academic technical report on the Mentallico React/Vite front-end.

Every technical claim embedded in this script's chapter text was verified
directly against the live source tree (`Mentallico/vite-project/src/**`,
`vite.config.js`) prior to being written — not inferred from a design brief.
Where the codebase contains a planned-but-not-yet-executed change (e.g. the
Therapist -> Expert naming pass), this is stated explicitly as a roadmap
item rather than presented as already complete.

Run with:  python generate_frontend_documentation.py
Requires:  pip install python-docx
"""

from docx import Document
from docx.shared import Pt, Inches, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

# ---------------------------------------------------------------------------
# Document-styling tokens (for the REPORT ITSELF — a presentation choice,
# independent of the application's own real design tokens, which are
# documented factually inside Chapter 4).
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
    run = add_run(h, text, bold=True, size=20, color=HEADING_COLOR)
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
    for item in items:
        p = doc.add_paragraph(style="List Bullet")
        p.paragraph_format.space_after = Pt(4)
        import re
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
    add_run(subtitle_p, "Front-End System Documentation", bold=True, size=18, color=RGBColor(0x1A, 0x7A, 0x6E))

    scope_p = doc.add_paragraph()
    scope_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    scope_p.paragraph_format.space_before = Pt(30)
    add_run(
        scope_p,
        "Subsystem: React 19 / Vite Single-Page Application Client\n"
        "Prepared as: Companion chapter set to the Backend and UI/UX Technical Reports",
        italic=True, size=11, color=BODY_COLOR,
    )

    add_note(
        doc,
        "Grounding statement.",
        "Every architectural claim in this document was verified directly against the live "
        "source tree (Mentallico/vite-project/src/**, vite.config.js) rather than inferred from "
        "design intent. Where a described change is planned but not yet executed in the "
        "repository, this is stated explicitly as a roadmap item.",
    )

    # ================================================================== #
    # CHAPTER 1                                                           #
    # ================================================================== #
    add_h1(doc, "Chapter 1 — Application Navigation Topology & UX Strategy")

    add_h2(doc, "1.1 Single-Page Application Architecture")
    add_rich_paragraph(
        doc,
        "The Mentallico client is architected as a Single-Page Application (SPA) built on the "
        "**React 19** component model and served through the **Vite** build system, which provides "
        "near-instantaneous Hot Module Replacement during development and a fully static, "
        "pre-bundled asset output for production. Client-side routing is delegated to "
        "`react-router-dom`, which resolves every navigable surface of the product — the "
        "marketing pages, the authenticated dashboard, the community feed, and the expert "
        "directory — inside a single document load, with route transitions handled entirely in "
        "the browser rather than through full-page server round-trips.",
    )
    add_rich_paragraph(
        doc,
        "Communication with the Django REST backend is centralized through a single asynchronous "
        "HTTP client tier, `services/api.js`, which wraps the native `fetch` API with a consistent "
        "contract: automatic `Authorization: Bearer` header injection from the locally-stored JWT, "
        "uniform JSON error-envelope parsing, and dedicated `postFormData`/`patchFormData` helpers "
        "for multipart uploads (profile pictures, community post images). No component issues a raw "
        "`fetch` call directly — every network interaction in the application passes through this "
        "single, auditable seam.",
    )
    add_rich_paragraph(
        doc,
        "Rather than propagating server round-trip latency into every user interaction, the "
        "client employs **optimistic local state updates** at every point where the UI can predict "
        "the server's eventual response with high confidence. The community feed's like and save "
        "toggles are the canonical example: the local `posts` state array is updated immediately on "
        "click — flipping `is_liked` and adjusting `like_count` — before the network request "
        "resolves, and is only rolled back to its prior value in the `catch` branch if the server "
        "call actually fails. This yields a perceived-latency profile close to zero for the "
        "highest-frequency interactions in the product, while preserving eventual consistency with "
        "the authoritative server state.",
    )

    add_h2(doc, "1.2 Global Navigation Structure")
    add_rich_paragraph(
        doc,
        "The primary navigation surface, rendered by `Navbar.jsx` on every marketing and "
        "authenticated route, exposes exactly four high-frequency destinations: **Home** (`/`), "
        "**About Us** (`/about`), **Community** (`/Community`), and the expert-directory route.",
    )
    add_note(
        doc,
        "Verified naming state.",
        "The expert-directory feature is mid-migration in the repository. The homepage teaser "
        "component is already correctly named `ExpertsSection.jsx`, reflecting the platform's "
        "intended terminology. The full directory listing and individual profile pages, however, "
        "have not yet completed the same rename — they remain implemented as `Therapist.jsx` "
        "(route `/Therapists`) and `TherapistProfile.jsx` (route `/therapist/:id`) at the time of "
        "writing. This documentation describes both components under their actual, current file "
        "and route names, and flags the Therapist -> Expert normalization across the directory as "
        "a planned, not-yet-executed refactor rather than a completed one.",
    )

    add_h2(doc, "1.3 Cognitive Load Reduction: The Avatar Dropdown Pattern")
    add_rich_paragraph(
        doc,
        "A deliberate information-architecture decision keeps the User Profile destination out of "
        "the primary navigation row entirely. Rather than adding a fifth top-level link — which "
        "would dilute the visual weight of the four primary marketing/product destinations and "
        "increase the decision cost of every page load for a returning user — the authenticated "
        "user's identity and account actions are encapsulated inside a disclosure component: the "
        "`.user-menu-wrapper` / `.user-greeting-btn` compound in `Navbar.jsx`, which expands into a "
        "`.user-dropdown` panel containing the account identity header, a link to `/UserProfile`, "
        "and the sign-out action.",
    )
    add_rich_paragraph(
        doc,
        "This is a direct application of **progressive disclosure** at the navigation-chrome "
        "level: the primary row communicates only \"where can I go,\" while account-scoped actions "
        "(\"who am I, how do I manage myself\") are deliberately one interaction deeper, since they "
        "are consulted far less frequently than the primary content destinations, and burying a "
        "secondary concern one level deep is a well-established technique for keeping the "
        "highest-frequency navigation pathway visually and cognitively uncluttered.",
    )

    add_h2(doc, "1.4 Progressive Disclosure: Dashboard vs. Community Surfaces")
    add_rich_paragraph(
        doc,
        "The same disclosure philosophy governs the relationship between the authenticated "
        "dashboard (`UserProfile.jsx`) and the community feed (`Community.jsx`). The dashboard "
        "surfaces the user's own, immediately actionable widgets — the day-pill journal entry "
        "strip, the monthly mood-tracker calendar, and the habit-progress rings — directly on "
        "first render, with zero additional navigation required, because these are single-user, "
        "self-referential tools the product expects to be consulted on effectively every visit.",
    )
    add_rich_paragraph(
        doc,
        "The community feed, by contrast, is a distinct, secondary route (`/Community`) rather "
        "than an inline widget on the dashboard. This is an intentional architectural boundary: "
        "peer-authored content carries a fundamentally different cognitive mode (browsing, social "
        "reciprocity) from the user's own private self-tracking tools, and collapsing the two into "
        "a single scrollable surface would force every dashboard visit to also load and render "
        "other users' content, regardless of whether the visitor has any intention of engaging "
        "with the social layer that session.",
    )

    # ================================================================== #
    # CHAPTER 2                                                           #
    # ================================================================== #
    add_h1(doc, "Chapter 2 — Figma-to-Code Layout Translation & Structural Layering")

    add_h2(doc, "2.1 Desktop Baseline and Container Convention")
    add_rich_paragraph(
        doc,
        "The application's page-level layouts are translated from Figma canvases onto a "
        "consistent desktop container convention: the majority of top-level page wrappers across "
        "the codebase — the User Profile dashboard, the About page, and the homepage's own "
        "sectional containers — are capped at a `max-width: 1440px` centered container "
        "(`margin: 0 auto`), with full-bleed decorative or color-block sections deliberately "
        "breaking out of that container via negative-margin techniques (`width: 100vw; "
        "margin-left: -50vw; margin-right: -50vw` relative to a `left: 50%` anchor) wherever the "
        "design calls for edge-to-edge color rather than content confined to the reading column.",
    )

    add_h2(doc, "2.2 Case Study: The 'Our Values' Full-Bleed Breakout Band")
    add_rich_paragraph(
        doc,
        "The `/about` route's **Our Values** section (`AboutPage/OurValues.jsx` / "
        "`OurValues.css`) is the clearest instance of this breakout pattern in the codebase, and "
        "was directly verified at runtime via headless-browser measurement rather than assumed "
        "from the stylesheet alone.",
    )
    add_rich_paragraph(
        doc,
        "The section's `.our-values` container is styled with `width: 100%; "
        "background-color: var(--primary-bg)`, where `--primary-bg: #7f89e9`. Rendered inside a "
        "1440px-wide desktop viewport, runtime measurement confirmed a computed background color "
        "of exactly `rgb(127, 137, 233)` spanning a rendered width of **1425px** — a full-bleed "
        "band occupying the entire viewport width, modulo the container's own horizontal padding, "
        "rather than a card confined to the page's normal reading column.",
    )
    add_rich_paragraph(
        doc,
        "Nested inside this full-bleed band, the three `.value-card` elements are each styled "
        "with `background-color: var(--card-bg)`, where `--card-bg: #f2f3fb` — a light "
        "gray-blue tone selected specifically to sit at high contrast against the saturated "
        "periwinkle-purple background band behind it. This two-layer composition (saturated "
        "full-bleed band as the section's structural background, light neutral cards as the "
        "foreground content surface) is the section's core legibility strategy: body text inside "
        "each card (`color: #6b7280`) remains comfortably readable against the light card "
        "surface, while the surrounding band communicates section identity and visual rhythm at "
        "the page-scroll level without requiring any text to be rendered directly against the "
        "saturated purple.",
    )

    add_h2(doc, "2.3 Figma Layout Model → CSS Primitive Translation")
    add_rich_paragraph(
        doc,
        "The following table documents the general translation methodology applied when "
        "converting a Figma frame's layout model into its corresponding CSS layout primitive "
        "during implementation:",
    )
    add_table(
        doc,
        ["Figma Layout Concept", "CSS Layout Primitive", "Representative Usage"],
        [
            ["Auto Layout (horizontal, wrap)", "`display: flex; flex-wrap: wrap; gap: <n>px`",
             "Expert/therapist card grids, habit-tile rows"],
            ["Auto Layout (vertical stack)", "`display: flex; flex-direction: column; gap: <n>px`",
             "Form field stacks, journal entry editor"],
            ["Grid frame (fixed columns)", "`display: grid; grid-template-columns: repeat(n, 1fr)`",
             "Mood-tracker calendar (7-column), \"What We Offer\" cards"],
            ["Absolute overlay (avatar-over-banner)", "`position: absolute` child inside a "
             "`position: relative` banner, with a negative `margin-top` pulling the element up "
             "over the banner edge",
             "Profile avatar overlapping the gradient header banner"],
            ["Full-bleed color fill", "`width: 100vw` + `left: 50%` + equal negative "
             "left/right margins, breaking out of a `max-width`-constrained parent",
             "\"Our Values\" band (§2.2), User Profile gradient header"],
            ["Fixed-size component (desktop mock)", "Fixed `px` dimensions at the base "
             "declaration, explicitly overridden inside `@media` breakpoints for narrower "
             "viewports",
             "Mood check-in card, habit progress rings"],
        ],
        col_widths_in=[2.0, 2.6, 2.0],
    )

    # ================================================================== #
    # CHAPTER 3                                                           #
    # ================================================================== #
    add_h1(doc, "Chapter 3 — Responsive Viewport Hardening & Touch Target Audit")

    add_h2(doc, "3.1 Audit Methodology")
    add_rich_paragraph(
        doc,
        "A comprehensive mobile-responsiveness audit was executed across every routed page in "
        "the application, verified at the two narrowest common device breakpoints — **375px** "
        "(a typical modern phone) and **320px** (the narrowest viewport still in meaningful "
        "circulation) — using a headless-Chrome, Chrome DevTools Protocol-driven verification "
        "harness rather than visual inspection alone.",
    )
    add_note(
        doc,
        "Methodology correction discovered mid-audit.",
        "The audit initially validated horizontal-overflow safety via `window.scrollX` "
        "immediately following a `window.scrollTo()` call, expecting a non-zero result to signal "
        "leaked horizontal scroll. Deeper investigation revealed that this application's global "
        "stylesheet sets `overflow-x: hidden` on both `html` and `body` without pairing it with an "
        "explicit `overflow-y` value — which, per the CSS Overflow specification's computed-value "
        "coupling rule, silently forces `overflow-y` to compute as `auto` on both elements. The "
        "practical effect is that `document.documentElement` (the element `window.scrollX` "
        "actually reads) becomes permanently locked to the exact viewport size, making the "
        "`window.scrollX` check a structural no-op. The audit was corrected to instead compare "
        "`document.body.scrollWidth` against the viewport's `innerWidth` — the metric that "
        "genuinely reflects clipped, off-screen content regardless of which element the browser "
        "considers the active scrolling context.",
    )

    add_h2(doc, "3.2 Component-Specific Viewport Hardening Fixes")
    add_rich_paragraph(
        doc,
        "**User Profile grid adaptation.** The dashboard's habit-progress grid, mood-tracker "
        "calendar, and journal day-pill strip were converted from fixed multi-column desktop "
        "layouts into adaptive single-column (or content-driven wrapping) arrangements below the "
        "1024px and 480px breakpoints, with the day-pill strip additionally gaining a scoped "
        "`overflow-x: auto` on its own container — a deliberate \"contained horizontal scroll\" "
        "escape hatch for the one row of content genuinely too dense to reflow into a single "
        "column without becoming illegible.",
    )
    add_rich_paragraph(
        doc,
        "**Mood-picker modal containment.** The mood-selection modal (`.mood-picker-panel`) was "
        "hardened with `max-height: 85vh` paired with `overflow-y: auto`, ensuring the ten-option "
        "mood grid can never force the modal taller than the viewport itself regardless of screen "
        "height; below the 480px breakpoint, the panel additionally widens to **94%** of the "
        "viewport width, converging the modal toward a near-full-width presentation on the "
        "narrowest devices rather than remaining a small, awkwardly-margined card.",
    )
    add_rich_paragraph(
        doc,
        "**Fixed-height touch-target defeat in `TherapistProfile.css`.** A scoped selector, "
        "`.similar-card .book-btn, .similar-card .profile-btn`, was found to declare a hard-coded "
        "`height: 34px` on the \"Similar Therapists\" card action buttons. Because this selector "
        "carries higher CSS specificity (two classes) than the sitewide `.book-btn, .profile-btn "
        "{ min-height: 44px }` touch-target rule (one class) defined on the parent directory "
        "page, it silently overrode the platform-wide accessibility minimum for that specific "
        "card variant. The fix replaced the fixed `height: 34px` with `min-height: 44px`, "
        "restoring the intended touch-target floor without otherwise altering the card's compact "
        "visual proportions.",
    )
    add_rich_paragraph(
        doc,
        "**Inline action stacking below 420px.** The profile page's primary call-to-action row "
        "(`.action-buttons`, containing the \"Book a session\" and \"Message\" buttons) was found "
        "capable of overflowing a 320px viewport in its default side-by-side `flex` "
        "configuration. A dedicated `@media (max-width: 420px)` rule converts the row to "
        "`flex-direction: column` with both buttons stretched to full container width, "
        "eliminating the overflow risk entirely rather than merely shrinking the buttons to fit.",
    )

    add_h2(doc, "3.3 Touch Target Compliance — 44×44px Minimum Hit-Box Enforcement")
    add_rich_paragraph(
        doc,
        "A systematic pass was made across every interactive close trigger, icon button, and "
        "navigation selector in the codebase to enforce a strict **44×44px** minimum interactive "
        "footprint — the WCAG-aligned minimum target size — even where the *visual* icon inside "
        "the control is deliberately smaller, by expanding the button's own box dimensions "
        "(`width`/`height`/`min-width`/`min-height`) independently of its child icon's rendered "
        "size:",
    )
    add_table(
        doc,
        ["Selector", "Prior State", "Corrected State"],
        [
            ["`.modal-x` (Booking modal close trigger)", "~35×35px effective hit box (icon-sized padding only)",
             "Explicit `width: 44px; height: 44px` box, icon centered inside via flex"],
            [".collection-nav (Saved Collection nav arrow)", "Icon shrank to 36×36px on mobile, "
             "shrinking the tap target with it",
             "`min-width: 44px; min-height: 44px` on the button itself, independent of the icon's visual size"],
            [".mood-picker-close / .mood-picker-option", "~30-32px effective height (padding-only sizing)",
             "`min-height: 44px` enforced on every option and the close/cancel control"],
            [".sidebar-toggle-btn (ChatBot mobile drawer trigger)", "Did not exist prior to the mobile "
             "drawer refactor", "Introduced at a fixed `44px x 44px`"],
        ],
        col_widths_in=[2.3, 2.5, 2.5],
    )

    # ================================================================== #
    # CHAPTER 4                                                           #
    # ================================================================== #
    add_h1(doc, "Chapter 4 — Design System Tokens & Component State Machines")

    add_h2(doc, "4.1 Typography Scale")
    add_rich_paragraph(
        doc,
        "The entire application typography system is built on a single font family, "
        "**Poppins**, loaded via Google Fonts `@import` and applied consistently across every "
        "page-level stylesheet in the codebase — no secondary typeface is introduced anywhere in "
        "the product surface. Weight and size are varied per content role rather than per "
        "component, yielding a small, consistent scale:",
    )
    add_table(
        doc,
        ["Role", "Representative Weight", "Representative Size Range"],
        [
            ["Display / section headers", "500-700 (Medium-Bold)", "36px - 75px (fluid via `clamp()` on key pages)"],
            ["Card / component titles", "500-600 (Medium-SemiBold)", "18px - 28px"],
            ["Body copy", "300-400 (Light-Regular)", "14px - 20px"],
            ["Captions / meta text", "400-500", "12px - 14px"],
            ["Primary call-to-action labels", "600 (SemiBold)", "16px - 18px"],
        ],
        col_widths_in=[2.3, 2.3, 2.7],
    )

    add_h2(doc, "4.2 Color Palette Tokens")
    add_note(
        doc,
        "Verified against source.",
        "The palette below reflects the application's actual, centrally-declared CSS custom "
        "properties (found consistently across `UserProfile.css`, `StaticPages/tokens.css`, and "
        "the majority of feature stylesheets) — not an idealized or aspirational token set.",
    )
    add_table(
        doc,
        ["Token Name", "Hex Value", "Role"],
        [
            ["--Primary", "#7F89E9", "Primary brand accent — buttons, links, active states, icon fills"],
            ["--Secondary", "#A87CC7", "Secondary accent — gradient endpoints, complementary highlights"],
            ["--Accent-Green", "#658852", "Tertiary gradient stop; positive/success-adjacent accents"],
            ["--Color-2 (emphasis)", "#1A2E12", "Dark-green near-black — primary heading and emphasis text color"],
            ["--Base", "#F0F0F0", "Primary light background surface"],
            ["--light-gray", "#D2D5DE", "Borders, muted surfaces, inactive-state fills"],
            ["Body text gray", "#595959 / #292929", "Secondary body copy and card text (used inline, not tokenized)"],
        ],
        col_widths_in=[2.0, 1.3, 3.3],
    )

    add_h2(doc, "4.3 Component Interaction State Machines")
    add_rich_paragraph(
        doc,
        "Interactive components across the codebase follow a consistent, repeated state-machine "
        "pattern rather than each component inventing its own transition logic:",
    )
    add_bullets(
        doc,
        [
            "**Hover** — a `transform: translateY(-Npx)` lift (typically 3-10px) combined with an "
            "`opacity` or `box-shadow` intensification, applied via a `transition: transform 0.2s-0.3s "
            "ease` (or `all 0.3s`) declaration on the resting state, so the transition is defined once "
            "and triggered purely by the `:hover` pseudo-class rather than by JavaScript.",
            "**Active / selected** — a dedicated modifier class (`.active`, `.selected`, `.completed`) "
            "swaps the background/border color and, where relevant (habit cards, day pills), applies a "
            "`box-shadow` ring or checkmark badge — never relying on the `:active` pseudo-class alone, "
            "since selection state in this application is typically persistent (server-backed) rather "
            "than a momentary press.",
            "**Loading** — asynchronous actions (message send, journal save, password change, profile "
            "update) drive a local `isLoading`/`saving` boolean that both disables the triggering "
            "control (`disabled={isLoading}`) and swaps its label text (e.g. `\"Saving…\"`), preventing "
            "duplicate submissions without introducing a separate spinner component or measurable "
            "layout shift.",
            "**Disabled** — a uniform `opacity: 0.6; cursor: default` pairing is applied via "
            "`:disabled` across essentially every button in the codebase, giving the disabled affordance "
            "a single consistent visual signature regardless of which feature area the control belongs "
            "to.",
        ],
    )
    add_rich_paragraph(
        doc,
        "This consistency is a deliberate performance and maintainability property: because "
        "every state transition is expressed as a CSS `transform`/`opacity`/color change rather "
        "than a layout-affecting property (`width`, `height`, `margin` outside of explicitly "
        "designed breakpoint rules), the browser can composite these transitions on the GPU "
        "without triggering synchronous layout reflow, keeping interaction feedback fluid even on "
        "lower-powered mobile hardware.",
    )

    # ================================================================== #
    # CHAPTER 5                                                           #
    # ================================================================== #
    add_h1(doc, "Chapter 5 — Network Engineering, Client Auth, and Local State Safeties")

    add_h2(doc, "5.1 Development Environment Engineering")
    add_rich_paragraph(
        doc,
        "The Vite development server is configured in `vite.config.js` with an explicit "
        "`server.port: 5173` and a request proxy for the `/api` path prefix, forwarding every "
        "matching request to the Django backend at `http://127.0.0.1:8000`. This proxy "
        "configuration is itself a deliberate CORS-avoidance strategy for local development: "
        "because the browser only ever communicates with `localhost:5173`, and Vite transparently "
        "relays the `/api/*` traffic server-side, no cross-origin preflight is ever triggered "
        "during same-machine development, regardless of the backend's own CORS configuration.",
    )
    add_note(
        doc,
        "LAN / mobile-device testing — corrected attribution.",
        "Cross-device testing from a physical mobile phone on the same Local Area Network is "
        "enabled not through Vite's own `server.host`/`allowedHosts` options — which are not "
        "configured in this project's `vite.config.js` — but through the **Django backend's** "
        "environment configuration: `ALLOWED_HOSTS` and `CORS_ALLOWED_ORIGINS` are extended with "
        "the development machine's LAN IP address and its corresponding `nip.io` wildcard-DNS "
        "hostname (a public DNS service that resolves any `<ip>.nip.io` subdomain directly to "
        "`<ip>`, avoiding any local `/etc/hosts` or router configuration). The front-end reaches "
        "that backend simply by being loaded, from the mobile device's browser, at the "
        "development machine's LAN IP and port `5173` directly — the Vite dev server binds to all "
        "interfaces by default in this project's invocation, which is sufficient for LAN "
        "reachability without any additional `allowedHosts` allow-list on the Vite side.",
    )

    add_h2(doc, "5.2 Client Authentication Pipelines")
    add_rich_paragraph(
        doc,
        "Social sign-in is implemented as a client-side token-acquisition step feeding directly "
        "into the same server-side verification contract used for every other authentication "
        "path. The `useSocialAuth` hook loads the Google Identity Services SDK "
        "(`google.accounts.oauth2.initTokenClient`) and the Facebook JavaScript SDK "
        "(`FB.login`) via static `<script>` tags in `index.html`, requests an OAuth **access "
        "token** directly from the provider inside the browser, and transmits only that access "
        "token — never a client-asserted identity claim — to the corresponding Django endpoint "
        "(`/api/v1/auth/google/` or `/api/v1/auth/facebook/`).",
    )
    add_rich_paragraph(
        doc,
        "Critically, the client performs **no independent trust decision** about the token's "
        "validity or the identity it represents: the backend re-verifies the access token "
        "directly against Google's `tokeninfo`/`userinfo` endpoints or Facebook's Graph API "
        "`debug_token`/`me` endpoints before issuing this application's own JWT pair. The "
        "client's only responsibilities are acquiring the token, transmitting it, and — on a "
        "successful response — persisting the returned `{access, refresh}` JWT pair to "
        "`localStorage` using the exact same storage contract as email/password login, so no "
        "other part of the client application needs to know or care which authentication path "
        "was used.",
    )

    add_h2(doc, "5.3 Asynchronous Memory & Local State Safeties")
    add_rich_paragraph(
        doc,
        "**Optimistic update rollback.** As established in §1.1, optimistic local state updates "
        "(community post likes/saves, habit-completion toggles) are always paired with an "
        "explicit rollback branch: the pre-update value is captured in a local variable before "
        "the state mutation is applied, and restored in the `catch` handler if the corresponding "
        "network call fails — ensuring the UI never persists a false-positive state indefinitely "
        "on a failed request.",
    )
    add_rich_paragraph(
        doc,
        "**MediaRecorder audio blob lifecycle.** Voice-message capture (`useAudioRecorder.js`, "
        "consumed by `ChatBot.jsx`) is, by verified design, an entirely **client-side, ephemeral** "
        "feature: the recorded audio never leaves the browser or reaches the Django backend "
        "(there is no corresponding upload call, and the backend's `ChatMessage` model has no "
        "audio-storage field). The lifecycle-correctness work in this subsystem was therefore "
        "about local blob-URL timing rather than post-upload cleanup: an earlier implementation "
        "called `URL.revokeObjectURL()` synchronously immediately after handing the recorded "
        "Blob's object URL to the chat message list, which — because `<audio>` element loading is "
        "asynchronous — could revoke the URL before the browser's audio decoder had finished "
        "reading it, producing an unplayable, zero-duration voice message. The corrected "
        "implementation removed that premature revocation entirely and restructured the \"send\" "
        "action itself to fire only from inside the `MediaRecorder.onstop` callback, once the "
        "final Blob (and, via the `fix-webm-duration` library, its corrected duration metadata) is "
        "fully materialized — eliminating the race condition at its source rather than working "
        "around it after the fact.",
    )
    add_rich_paragraph(
        doc,
        "**Session-affinity state, not component-lifecycle guards.** The codebase's approach to "
        "avoiding stale-response bugs during async operations is handled primarily through "
        "request/response shape design (each chat session round-trip resolves to a single, "
        "complete `{user_message, bot_message}` payload rather than a stream of partial updates) "
        "and optimistic-then-reconciled state (§1.1), rather than through an explicit "
        "component-unmount guard (e.g. an `isMounted` ref or `AbortController`) — no such pattern "
        "is present in `ChatBot.jsx` at the time of writing, and this documentation notes its "
        "absence rather than asserting it as an implemented safety measure.",
    )

    # ------------------------------------------------------------------ #
    # Closing attribution                                                 #
    # ------------------------------------------------------------------ #
    doc.add_paragraph()
    closing = doc.add_paragraph()
    closing.alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_run(
        closing,
        "This document was compiled from direct inspection of the live Mentallico front-end "
        "repository and reflects the system's verified, current state rather than its design "
        "intent.",
        italic=True, size=9.5, color=RGBColor(0x59, 0x59, 0x59),
    )

    doc.save(out_path)
    print(f"Saved: {out_path}")


if __name__ == "__main__":
    build_document("FRONTEND_DOCUMENTATION.docx")
