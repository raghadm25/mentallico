"""
NLP analysis service for chat sessions.

This module exposes a single public function:  run_analysis(transcript)

CURRENT STATE — MOCK IMPLEMENTATION
-------------------------------------
The function below returns deterministic placeholder data so the full
request / response cycle can be developed and tested without NLP
dependencies.  Every return key matches exactly what the production
implementation will return, so callers require zero changes when the
real model is wired in.

TO REPLACE WITH REAL NLP
-------------------------
1. Install your NLP dependencies (already listed in requirements.txt:
   textblob, nltk, scikit-learn, gensim).
2. Import and call `apps.diagnostics.services.run_analysis` from here,
   or inline your own pipeline.
3. Delete or gate the mock block below.
4. Set DiagnosisReport.is_mock = False in the view/task that calls this.
"""
import logging
import re
import string

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Keyword maps used by the mock to produce semi-realistic output
# ---------------------------------------------------------------------------
_PATTERN_KEYWORDS: dict[str, list[str]] = {
    "anxiety_indicators": [
        "anxious", "anxiety", "panic", "nervous", "worry", "worried",
        "fear", "scared", "overwhelmed", "stress", "stressed",
    ],
    "depressive_indicators": [
        "sad", "depressed", "hopeless", "worthless", "empty", "numb",
        "crying", "despair", "meaningless", "lonely",
    ],
    "sleep_issues": [
        "insomnia", "sleep", "tired", "exhausted", "nightmares",
        "restless", "fatigue", "oversleeping",
    ],
    "social_withdrawal": [
        "alone", "isolated", "withdrawn", "avoid", "nobody",
        "disconnected", "no friends",
    ],
    "crisis_indicators": [
        "suicidal", "suicide", "self-harm", "harm myself",
        "end my life", "kill myself", "don't want to live",
    ],
    "positive_coping": [
        "better", "hopeful", "improving", "grateful", "exercise",
        "therapy", "meditation", "support",
    ],
}

_SEVERITY_ORDER = ["none", "mild", "moderate", "severe"]

_SEVERITY_MAP = {
    "crisis_indicators": "severe",
    "depressive_indicators": "moderate",
    "anxiety_indicators": "moderate",
    "sleep_issues": "mild",
    "social_withdrawal": "mild",
    "positive_coping": "none",
}


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

def _clean(text: str) -> str:
    text = text.lower()
    text = text.translate(str.maketrans("", "", string.punctuation))
    return re.sub(r"\s+", " ", text).strip()


def _mock_sentiment(text: str) -> tuple[float, str]:
    """
    Approximate polarity by counting positive vs negative signal words.
    Returns (score, label).  Range: [-1.0, +1.0].
    """
    positive_words = {
        "good", "great", "happy", "better", "hopeful", "grateful",
        "love", "joy", "calm", "well", "improving", "positive",
    }
    negative_words = {
        "bad", "worse", "sad", "depressed", "anxious", "scared",
        "terrible", "hopeless", "awful", "hate", "miserable", "pain",
    }

    words = _clean(text).split()
    pos = sum(1 for w in words if w in positive_words)
    neg = sum(1 for w in words if w in negative_words)
    total = pos + neg

    if total == 0:
        return 0.0, "neutral"

    score = round((pos - neg) / total, 4)
    label = "positive" if score > 0.1 else ("negative" if score < -0.1 else "neutral")
    return score, label


def _detect_patterns(text: str) -> list[str]:
    """Return sorted list of pattern categories found in text."""
    text_lower = text.lower()
    return sorted(
        category
        for category, keywords in _PATTERN_KEYWORDS.items()
        if any(kw in text_lower for kw in keywords)
    )


def _infer_severity(disorder_tags: list[str]) -> str:
    """Derive the highest severity level across all detected tags."""
    current_index = 0
    for tag in disorder_tags:
        level = _SEVERITY_MAP.get(tag, "none")
        idx = _SEVERITY_ORDER.index(level)
        if idx > current_index:
            current_index = idx
    return _SEVERITY_ORDER[current_index]


def _build_summary(
    sentiment_label: str,
    sentiment_score: float,
    disorder_tags: list[str],
    severity: str,
) -> str:
    tag_text = ", ".join(disorder_tags) if disorder_tags else "none identified"
    severity_text = {
        "severe": "The conversation reflects significant distress. Immediate support is recommended.",
        "moderate": "The conversation reflects moderate emotional difficulty.",
        "mild": "The conversation suggests mild emotional challenges.",
        "none": "No notable distress indicators were detected.",
    }.get(severity, "")
    return (
        f"Sentiment: {sentiment_label} (score={sentiment_score}). "
        f"Severity: {severity}. "
        f"{severity_text} "
        f"Detected patterns: {tag_text}."
    )


def _build_recommendations(severity: str, disorder_tags: list[str]) -> list[str]:
    recs: list[str] = []
    severity_recs = {
        "severe": [
            "action:contact_emergency_services",
            "action:contact_primary_emergency_contact",
            "article:crisis_hotlines",
        ],
        "moderate": [
            "action:schedule_therapist_appointment",
            "article:cbt_techniques",
        ],
        "mild": ["article:mindfulness_basics", "article:self_care_guide"],
        "none": ["article:mental_wellness_tips"],
    }
    recs.extend(severity_recs.get(severity, []))
    tag_recs = {
        "sleep_issues": "article:sleep_hygiene",
        "social_withdrawal": "article:building_social_connections",
        "anxiety_indicators": "article:managing_anxiety",
        "depressive_indicators": "article:understanding_depression",
        "positive_coping": "article:strengthening_coping_skills",
    }
    for tag in disorder_tags:
        rec = tag_recs.get(tag)
        if rec and rec not in recs:
            recs.append(rec)
    return recs


# ---------------------------------------------------------------------------
# Public interface
# ---------------------------------------------------------------------------

def run_analysis(transcript: list[tuple[str, str]]) -> dict:
    """
    Analyse a chat session transcript and return a structured result dict.

    Parameters
    ----------
    transcript : list of (role, content) tuples, ordered chronologically.
                 role is 'user' or 'assistant'.

    Returns
    -------
    dict with keys that map 1-to-1 onto DiagnosisReport fields:
        sentiment_score   float   [-1.0, +1.0]
        sentiment_label   str     'positive' | 'neutral' | 'negative'
        disorder_tags     list    detected pattern labels
        severity          str     'none' | 'mild' | 'moderate' | 'severe'
        summary           str     human-readable narrative
        recommendations   list    resource / action tag strings
        is_mock           bool    always True in this implementation

    Notes
    -----
    Only user turns are analysed; assistant messages are ignored so that
    the bot's own wording does not pollute the sentiment signal.
    """
    user_texts = [content for role, content in transcript if role == "user"]

    if not user_texts:
        logger.warning("run_analysis called with no user messages in transcript.")
        return {
            "sentiment_score": 0.0,
            "sentiment_label": "neutral",
            "disorder_tags": [],
            "severity": "none",
            "summary": "No patient messages were found in this session.",
            "recommendations": ["article:mental_wellness_tips"],
            "is_mock": True,
        }

    combined = " ".join(user_texts)
    sentiment_score, sentiment_label = _mock_sentiment(combined)
    disorder_tags = _detect_patterns(combined)
    severity = _infer_severity(disorder_tags)
    summary = _build_summary(sentiment_label, sentiment_score, disorder_tags, severity)
    recommendations = _build_recommendations(severity, disorder_tags)

    logger.debug(
        "Mock analysis complete — severity=%s, tags=%s", severity, disorder_tags
    )

    return {
        "sentiment_score": sentiment_score,
        "sentiment_label": sentiment_label,
        "disorder_tags": disorder_tags,
        "severity": severity,
        "summary": summary,
        "recommendations": recommendations,
        "is_mock": True,
    }
