"""
NLP analysis pipeline for diagnostic report generation.

Responsibilities
----------------
1. Sentiment analysis via TextBlob polarity/subjectivity.
2. TF-IDF keyword extraction via scikit-learn.
3. N-gram (bigram / trigram) frequency analysis via NLTK.
4. Domain-specific pattern detection using a keyword-to-category mapping.
5. Severity inference from combined signal scores.

All public functions are pure (no ORM interaction) so they can be unit-tested
independently.  The `run_analysis` function is the single integration point used
by the Celery task.
"""
import logging
import re
import string
from collections import Counter
from typing import Any

import nltk
from nltk.corpus import stopwords
from nltk.util import ngrams
from sklearn.feature_extraction.text import TfidfVectorizer
from textblob import TextBlob

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# NLTK resource bootstrap — runs once per worker process
# ---------------------------------------------------------------------------
_NLTK_RESOURCES = ["stopwords", "punkt", "punkt_tab"]


def _ensure_nltk_resources() -> None:
    for resource in _NLTK_RESOURCES:
        try:
            nltk.data.find(f"tokenizers/{resource}" if "punkt" in resource else f"corpora/{resource}")
        except LookupError:
            nltk.download(resource, quiet=True)


_ensure_nltk_resources()

# ---------------------------------------------------------------------------
# Domain-specific mental-health keyword patterns
# ---------------------------------------------------------------------------
PATTERN_KEYWORDS: dict[str, list[str]] = {
    "sleep_issues": [
        "insomnia", "sleep", "tired", "exhausted", "fatigue", "nightmares",
        "cannot sleep", "can't sleep", "restless", "oversleeping",
    ],
    "social_withdrawal": [
        "alone", "isolated", "lonely", "avoid", "withdrawn", "nobody",
        "no friends", "disconnected", "antisocial",
    ],
    "anxiety_indicators": [
        "anxious", "anxiety", "panic", "worry", "nervous", "fear", "dread",
        "overwhelmed", "stressed", "tension",
    ],
    "depressive_indicators": [
        "hopeless", "worthless", "empty", "sad", "depressed", "depression",
        "meaningless", "numb", "crying", "tearful", "despair",
    ],
    "crisis_indicators": [
        "suicidal", "suicide", "self-harm", "harm myself", "end my life",
        "kill myself", "don't want to live", "no reason to live",
    ],
    "positive_coping": [
        "exercise", "therapy", "meditation", "journaling", "support",
        "grateful", "hopeful", "better", "improving", "progress",
    ],
}

# ---------------------------------------------------------------------------
# Text cleaning
# ---------------------------------------------------------------------------
_STOP_WORDS: set[str] = set(stopwords.words("english"))


def clean_text(text: str) -> str:
    """Lowercase, remove punctuation, and strip extra whitespace."""
    text = text.lower()
    text = re.sub(r"https?://\S+|www\.\S+", " ", text)   # URLs
    text = text.translate(str.maketrans("", "", string.punctuation))
    text = re.sub(r"\s+", " ", text).strip()
    return text


def tokenize(text: str) -> list[str]:
    """Tokenize and remove stopwords."""
    tokens = nltk.word_tokenize(text)
    return [t for t in tokens if t not in _STOP_WORDS and len(t) > 2]


# ---------------------------------------------------------------------------
# Sentiment analysis
# ---------------------------------------------------------------------------
def analyze_sentiment(text: str) -> dict[str, Any]:
    """
    Compute polarity and subjectivity via TextBlob.

    Returns
    -------
    dict with keys: polarity, subjectivity, label
    """
    blob = TextBlob(text)
    polarity: float = round(blob.sentiment.polarity, 4)
    subjectivity: float = round(blob.sentiment.subjectivity, 4)

    if polarity >= 0.1:
        label = "positive"
    elif polarity <= -0.1:
        label = "negative"
    else:
        label = "neutral"

    return {
        "polarity": polarity,
        "subjectivity": subjectivity,
        "label": label,
    }


# ---------------------------------------------------------------------------
# TF-IDF keyword extraction
# ---------------------------------------------------------------------------
def extract_keywords(texts: list[str], top_n: int = 15) -> list[dict[str, Any]]:
    """
    Extract the most significant terms from a list of documents using TF-IDF.

    Parameters
    ----------
    texts : list of cleaned user-turn strings
    top_n : maximum keywords to return

    Returns
    -------
    List of {"term": str, "score": float} dicts, sorted descending by score.
    """
    if not texts or all(not t.strip() for t in texts):
        return []

    vectorizer = TfidfVectorizer(
        max_features=200,
        ngram_range=(1, 1),
        stop_words="english",
        min_df=1,
    )
    try:
        tfidf_matrix = vectorizer.fit_transform(texts)
    except ValueError:
        return []

    feature_names = vectorizer.get_feature_names_out()
    scores = tfidf_matrix.sum(axis=0).A1  # aggregate across all docs
    keyword_scores = sorted(
        zip(feature_names, scores), key=lambda x: x[1], reverse=True
    )
    return [{"term": term, "score": round(float(score), 4)} for term, score in keyword_scores[:top_n]]


# ---------------------------------------------------------------------------
# N-gram analysis
# ---------------------------------------------------------------------------
def extract_ngrams(tokens: list[str], n: int, top_n: int = 10) -> list[dict[str, Any]]:
    """
    Return the most frequent n-grams from a token list.

    Returns
    -------
    List of {"ngram": str, "count": int} dicts.
    """
    if len(tokens) < n:
        return []
    gram_counts = Counter(ngrams(tokens, n))
    return [
        {"ngram": " ".join(gram), "count": count}
        for gram, count in gram_counts.most_common(top_n)
    ]


# ---------------------------------------------------------------------------
# Domain pattern detection
# ---------------------------------------------------------------------------
def detect_patterns(text: str) -> list[str]:
    """
    Identify which mental-health pattern categories appear in the text.

    Returns
    -------
    Sorted list of detected category names.
    """
    text_lower = text.lower()
    detected: list[str] = []
    for category, keywords in PATTERN_KEYWORDS.items():
        if any(kw in text_lower for kw in keywords):
            detected.append(category)
    return sorted(detected)


# ---------------------------------------------------------------------------
# Severity inference
# ---------------------------------------------------------------------------
def infer_severity(
    polarity: float,
    detected_patterns: list[str],
) -> str:
    """
    Derive a severity level from sentiment polarity and detected patterns.

    Logic
    -----
    - crisis_indicators → severe (unconditionally)
    - ≥3 negative patterns + negative polarity → severe
    - ≥2 negative patterns → moderate
    - ≥1 negative pattern or negative polarity → mild
    - otherwise → none
    """
    negative_patterns = {
        "sleep_issues",
        "social_withdrawal",
        "anxiety_indicators",
        "depressive_indicators",
        "crisis_indicators",
    }
    active_negative = [p for p in detected_patterns if p in negative_patterns]

    if "crisis_indicators" in detected_patterns:
        return "severe"
    if len(active_negative) >= 3 and polarity < -0.1:
        return "severe"
    if len(active_negative) >= 2:
        return "moderate"
    if active_negative or polarity < -0.1:
        return "mild"
    return "none"


# ---------------------------------------------------------------------------
# Recommendation generator
# ---------------------------------------------------------------------------
def generate_recommendations(
    severity: str,
    detected_patterns: list[str],
) -> list[str]:
    """
    Map severity and detected patterns to resource/action recommendations.

    Returns a list of recommendation tag strings (e.g. "article:sleep_hygiene").
    """
    recs: list[str] = []

    severity_map = {
        "severe": [
            "action:contact_emergency_services",
            "action:contact_primary_emergency_contact",
            "article:crisis_hotlines",
        ],
        "moderate": [
            "action:schedule_therapist_appointment",
            "article:cbt_techniques",
        ],
        "mild": [
            "article:mindfulness_basics",
            "article:self_care_guide",
        ],
        "none": [
            "article:mental_wellness_tips",
        ],
    }
    recs.extend(severity_map.get(severity, []))

    pattern_map = {
        "sleep_issues": "article:sleep_hygiene",
        "social_withdrawal": "article:building_social_connections",
        "anxiety_indicators": "article:managing_anxiety",
        "depressive_indicators": "article:understanding_depression",
        "positive_coping": "article:strengthening_coping_skills",
    }
    for pattern in detected_patterns:
        tag = pattern_map.get(pattern)
        if tag and tag not in recs:
            recs.append(tag)

    return recs


# ---------------------------------------------------------------------------
# Summary narrative builder
# ---------------------------------------------------------------------------
def build_summary(
    sentiment: dict[str, Any],
    severity: str,
    detected_patterns: list[str],
    top_keywords: list[dict[str, Any]],
) -> str:
    """
    Compose a concise textual summary from the analysis results.
    """
    keyword_terms = ", ".join(kw["term"] for kw in top_keywords[:5]) or "N/A"
    pattern_labels = ", ".join(detected_patterns) or "none identified"

    severity_narrative = {
        "severe": "The session content indicates significant distress requiring immediate attention.",
        "moderate": "The session content reflects moderate emotional difficulty.",
        "mild": "The session content suggests mild emotional challenges.",
        "none": "The session content does not indicate notable emotional distress.",
    }.get(severity, "")

    return (
        f"Overall sentiment: {sentiment['label']} "
        f"(polarity={sentiment['polarity']}, subjectivity={sentiment['subjectivity']}). "
        f"Severity: {severity}. "
        f"{severity_narrative} "
        f"Key themes: {keyword_terms}. "
        f"Patterns detected: {pattern_labels}."
    )


# ---------------------------------------------------------------------------
# Main entry point
# ---------------------------------------------------------------------------
def run_analysis(transcript: list[tuple[str, str]]) -> dict[str, Any]:
    """
    Execute the full NLP pipeline on a chat transcript.

    Parameters
    ----------
    transcript : list of (role, content) tuples ordered chronologically.

    Returns
    -------
    dict matching the fields of DiagnosticReport that the task will persist.
    """
    # Separate user turns (exclude AI responses from NLP target corpus)
    user_texts = [content for role, content in transcript if role == "user"]

    if not user_texts:
        return {
            "overall_sentiment_score": 0.0,
            "sentiment_label": "neutral",
            "subjectivity_score": 0.0,
            "top_keywords": [],
            "bigrams": [],
            "trigrams": [],
            "identified_patterns": [],
            "severity_level": "none",
            "summary": "No user messages found in session.",
            "recommendations": [],
        }

    combined_text = " ".join(user_texts)
    cleaned = clean_text(combined_text)
    tokens = tokenize(cleaned)

    sentiment = analyze_sentiment(combined_text)
    keywords = extract_keywords([clean_text(t) for t in user_texts])
    bi_grams = extract_ngrams(tokens, n=2)
    tri_grams = extract_ngrams(tokens, n=3)
    patterns = detect_patterns(combined_text)
    severity = infer_severity(sentiment["polarity"], patterns)
    recommendations = generate_recommendations(severity, patterns)
    summary = build_summary(sentiment, severity, patterns, keywords)

    return {
        "overall_sentiment_score": sentiment["polarity"],
        "sentiment_label": sentiment["label"],
        "subjectivity_score": sentiment["subjectivity"],
        "top_keywords": keywords,
        "bigrams": bi_grams,
        "trigrams": tri_grams,
        "identified_patterns": patterns,
        "severity_level": severity,
        "summary": summary,
        "recommendations": recommendations,
    }
