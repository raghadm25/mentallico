import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './Therapist.css';
import searchIcon from '../assets/search-icon.png';
import BookingModal from './BookingModal';

// ─────────────────────────────────────────────────────────────
// Therapist data — enriched with specialty keywords, experience,
// languages, rating, review count, and session price so the
// profile page and search both work correctly.
// ─────────────────────────────────────────────────────────────
export const doctors = [
  {
    id: 1,
    name: "Dr. Ali Samir",
    title: "Psychotherapist (Anxiety & Depression)",
    specialty: "Anxiety, Depression, Stress Management",
    experience: 8,
    languages: ["English", "Arabic"],
    rating: 4.9,
    reviewCount: 128,
    price: 75,
    img: "https://xsgames.co/randomusers/assets/avatars/male/74.jpg",
    bio: "Dr. Ali Samir is a licensed psychotherapist who specializes in treating anxiety, depression, and emotional burnout. For over 8 years, he has guided individuals through their toughest moments using a mix of Cognitive Behavioral Therapy (CBT) and Mindfulness-based approaches. He believes therapy should feel like a conversation, not an interrogation — a safe space to explore feelings, ask difficult questions, and learn coping tools that last.",
  },
  {
    id: 2,
    name: "Dr. Sara Hany",
    title: "Clinical Counselor (Child Behavior)",
    specialty: "Child Behavior, Parenting, ADHD",
    experience: 8,
    languages: ["English", "Arabic"],
    rating: 4.8,
    reviewCount: 95,
    price: 70,
    img: "https://xsgames.co/randomusers/assets/avatars/female/24.jpg",
    bio: "Dr. Sara Hany works closely with children and families to address behavioral challenges. She uses play-based therapy and parent coaching to create lasting positive change.",
  },
  {
    id: 3,
    name: "Dr. Mariah Holland",
    title: "Couple & Family Therapist",
    specialty: "Couples Therapy, Family Conflict, Communication",
    experience: 12,
    languages: ["English", "French"],
    rating: 4.7,
    reviewCount: 112,
    price: 90,
    img: "https://xsgames.co/randomusers/assets/avatars/female/32.jpg",
    bio: "Dr. Mariah Holland is a certified couple and family therapist. She guides families through conflict resolution, communication improvement, and rebuilding trust.",
  },
  {
    id: 4,
    name: "Dr. Xavier Roberto",
    title: "Psychotherapist (Anxiety & Emotional)",
    specialty: "Emotional Regulation, Anxiety, Phobias",
    experience: 9,
    languages: ["English", "Spanish"],
    rating: 4.8,
    reviewCount: 87,
    price: 80,
    img: "https://xsgames.co/randomusers/assets/avatars/male/40.jpg",
    bio: "Dr. Xavier Roberto focuses on emotional regulation and anxiety disorders. He blends psychodynamic and cognitive approaches to help clients navigate complex emotional experiences.",
  },
  {
    id: 5,
    name: "Dr. Kareem El-Hadidy",
    title: "Trauma & Recovery Specialist",
    specialty: "PTSD, Trauma, Grief, Recovery",
    experience: 14,
    languages: ["English", "Arabic"],
    rating: 4.9,
    reviewCount: 201,
    price: 95,
    img: "https://xsgames.co/randomusers/assets/avatars/male/52.jpg",
    bio: "Dr. Kareem El-Hadidy is a trauma specialist with 14 years of experience in PTSD treatment and grief recovery. He uses EMDR and somatic therapy for deep healing.",
  },
  {
    id: 6,
    name: "Dr. Monica Hernandez",
    title: "Adolescent & Young Adult Psychologist",
    specialty: "Teen Mental Health, Identity, Peer Pressure",
    experience: 7,
    languages: ["English", "Spanish"],
    rating: 4.7,
    reviewCount: 74,
    price: 70,
    img: "https://xsgames.co/randomusers/assets/avatars/female/45.jpg",
    bio: "Dr. Monica Hernandez specializes in adolescent psychology, helping teens and young adults navigate identity challenges, peer pressure, and academic stress.",
  },
  {
    id: 7,
    name: "Dr. Hagar Osama",
    title: "Emotional Health Counselor",
    specialty: "Emotional Health, Self-Esteem, Life Transitions",
    experience: 6,
    languages: ["English", "Arabic"],
    rating: 4.6,
    reviewCount: 63,
    price: 65,
    img: "https://xsgames.co/randomusers/assets/avatars/female/18.jpg",
    bio: "Dr. Hagar Osama supports clients through life transitions, low self-esteem, and emotional struggles. Her warm, client-centered approach creates a safe space for healing.",
  },
  {
    id: 8,
    name: "Dr. George Matt",
    title: "Mindfulness Coach & Psychotherapist",
    specialty: "Mindfulness, Burnout, Stress, Meditation",
    experience: 11,
    languages: ["English"],
    rating: 4.8,
    reviewCount: 143,
    price: 85,
    img: "https://xsgames.co/randomusers/assets/avatars/male/65.jpg",
    bio: "Dr. George Matt integrates mindfulness-based cognitive therapy with traditional psychotherapy. He has helped hundreds of clients overcome burnout and chronic stress.",
  },
  {
    id: 9,
    name: "Dr. Ethan Brooks",
    title: "Behavioral Therapist (Addiction & Adult)",
    specialty: "Addiction, Behavioral Therapy, Adult Mental Health",
    experience: 13,
    languages: ["English"],
    rating: 4.9,
    reviewCount: 176,
    price: 90,
    img: "https://xsgames.co/randomusers/assets/avatars/male/22.jpg",
    bio: "Dr. Ethan Brooks is a leading behavioral therapist specializing in addiction recovery and adult mental health. He uses motivational interviewing and DBT.",
  },
  {
    id: 10,
    name: "Dr. Emily Carter",
    title: "Psychiatrist (Mood & Sleep Disorders)",
    specialty: "Bipolar Disorder, Insomnia, Mood Disorders",
    experience: 15,
    languages: ["English"],
    rating: 4.9,
    reviewCount: 218,
    price: 110,
    img: "https://xsgames.co/randomusers/assets/avatars/female/35.jpg",
    bio: "Dr. Emily Carter is a board-certified psychiatrist with 15 years of expertise in mood and sleep disorders. She provides comprehensive psychiatric evaluations and medication management.",
  },
  {
    id: 11,
    name: "Dr. Oliver Chen",
    title: "Clinical Psychologist (CBT Therapy)",
    specialty: "CBT, OCD, Panic Disorder, Social Anxiety",
    experience: 10,
    languages: ["English", "Mandarin"],
    rating: 4.8,
    reviewCount: 134,
    price: 80,
    img: "https://xsgames.co/randomusers/assets/avatars/male/12.jpg",
    bio: "Dr. Oliver Chen is a clinical psychologist specializing in CBT for OCD, panic disorder, and social anxiety. He draws on both Western and Eastern therapeutic traditions.",
  },
  {
    id: 12,
    name: "Dr. Jacob Miller",
    title: "Clinical Counselor (Stress & Burnout)",
    specialty: "Work Stress, Burnout, Anxiety, Career Transitions",
    experience: 8,
    languages: ["English"],
    rating: 4.7,
    reviewCount: 91,
    price: 75,
    img: "https://xsgames.co/randomusers/assets/avatars/male/15.jpg",
    bio: "Dr. Jacob Miller helps professionals manage work-related stress and burnout. His solution-focused counseling approach delivers practical tools for immediate relief.",
  },
];

const specialties = [...new Set(doctors.map((e) => e.specialty))];

// ─────────────────────────────────────────────────────────────
const ITEMS_PER_PAGE = 6;

// Build a compact page-number array with ellipsis where needed.
function buildPageNumbers(current, total) {
  if (total <= 5) return Array.from({ length: total }, (_, i) => i + 1);
  const pages = new Set([1, total, current]);
  if (current > 1) pages.add(current - 1);
  if (current < total) pages.add(current + 1);
  const sorted = [...pages].sort((a, b) => a - b);
  const result = [];
  for (let i = 0; i < sorted.length; i++) {
    if (i > 0 && sorted[i] - sorted[i - 1] > 1) result.push('…');
    result.push(sorted[i]);
  }
  return result;
}

// ─────────────────────────────────────────────────────────────
const Therapist = () => {
  const navigate = useNavigate();

  const [searchQuery, setSearchQuery]   = useState('');
  const [currentPage, setCurrentPage]   = useState(1);
  const [bookingDoctor, setBookingDoctor] = useState(null);
  const [filterOpen, setFilterOpen] = useState(false);
  const [selectedSpecialty, setSelectedSpecialty] = useState(null);

  // ── Filtering ──────────────────────────────────────────────
  const query = searchQuery.trim().toLowerCase();
  const filtered = doctors.filter((d) => {
    const matchesQuery =
      !query ||
      d.name.toLowerCase().includes(query) ||
      d.title.toLowerCase().includes(query) ||
      d.specialty.toLowerCase().includes(query) ||
      d.languages.some((l) => l.toLowerCase().includes(query));
    const matchesSpecialty = !selectedSpecialty || d.specialty === selectedSpecialty;
    return matchesQuery && matchesSpecialty;
  });

  // ── Pagination ─────────────────────────────────────────────
  const totalPages   = Math.max(1, Math.ceil(filtered.length / ITEMS_PER_PAGE));
  const safePage     = Math.min(currentPage, totalPages);
  const startIndex   = (safePage - 1) * ITEMS_PER_PAGE;
  const visible      = filtered.slice(startIndex, startIndex + ITEMS_PER_PAGE);
  const pageNumbers  = buildPageNumbers(safePage, totalPages);

  const goToPage = (page) => {
    if (page < 1 || page > totalPages) return;
    setCurrentPage(page);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleSearch = (e) => {
    setSearchQuery(e.target.value);
    setCurrentPage(1);
  };

  const handleSelectSpecialty = (specialty) => {
    setSelectedSpecialty(specialty);
    setCurrentPage(1);
    setFilterOpen(false);
  };

  // ─────────────────────────────────────────────────────────
  return (
    <div className="therapist-page-container">

      {/* ── Header ──────────────────────────────────────────── */}
      <div className="therapist-header">
        <h1>You&apos;re <span className="purple-highlight">Not</span> Alone in This.</h1>
        <p>
          When it&apos;s time to talk to a real person, our licensed therapists
          step in to provide personalized care, therapy sessions, and
          professional support.
        </p>

        <div className="search-filter-section">
          <div className="search-wrapper">
            <span className="search-icon">
              <img src={searchIcon} alt="search" className="search-img" />
            </span>
            <input
              type="text"
              placeholder="Search by name, specialty, or language…"
              value={searchQuery}
              onChange={handleSearch}
            />
          </div>
          <div className="filter-wrapper">
            <button className="btn-filter" onClick={() => setFilterOpen((open) => !open)}>
              {selectedSpecialty || 'Filter by'}
            </button>
            {filterOpen && (
              <div className="filter-dropdown">
                <button
                  className={`filter-option ${!selectedSpecialty ? 'active' : ''}`}
                  onClick={() => handleSelectSpecialty(null)}
                >
                  All specialties
                </button>
                {specialties.map((s) => (
                  <button
                    key={s}
                    className={`filter-option ${selectedSpecialty === s ? 'active' : ''}`}
                    onClick={() => handleSelectSpecialty(s)}
                  >
                    {s}
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* ── Grid ────────────────────────────────────────────── */}
      {visible.length === 0 ? (
        <p style={{ textAlign: 'center', padding: '48px 0', color: '#888' }}>
          No therapists match &ldquo;{searchQuery}&rdquo;. Try a different name or specialty.
        </p>
      ) : (
        <div className="therapists-grid">
          {visible.map((doc) => (
            <div
              key={doc.id}
              className="therapist-card"
              onClick={() => navigate(`/therapist/${doc.id}`)}
            >
              <div className="avatar-container">
                <img src={doc.img} alt={doc.name} className="avatar-img" />
              </div>
              <h3 className="therapist-name">{doc.name}</h3>
              <p className="therapist-specialty">{doc.title}</p>

              {/* Rating */}
              <p style={{ fontSize: '0.82rem', color: '#f5a623', margin: '4px 0 10px' }}>
                {'★'.repeat(Math.round(doc.rating))}
                <span style={{ color: '#888', marginLeft: 4 }}>
                  {doc.rating} ({doc.reviewCount})
                </span>
              </p>

              <div className="card-footer-btns">
                <button
                  className="book-btn"
                  onClick={(e) => {
                    e.stopPropagation();
                    setBookingDoctor(doc);
                  }}
                >
                  Book Session
                </button>
                <button
                  className="profile-btn"
                  onClick={(e) => {
                    e.stopPropagation();
                    navigate(`/therapist/${doc.id}`);
                  }}
                >
                  View Profile
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* ── Pagination ──────────────────────────────────────── */}
      {totalPages > 1 && (
        <div className="pagination">
          <button
            className="nav-arrow nav-prev"
            disabled={safePage === 1}
            onClick={() => goToPage(safePage - 1)}
          >
            <img src="/src/assets/Arrowleft.png" alt="Previous" />
            <span>Previous</span>
          </button>

          <div className="page-numbers">
            {pageNumbers.map((p, i) =>
              p === '…' ? (
                <span key={`ellipsis-${i}`} className="dots">…</span>
              ) : (
                <button
                  key={p}
                  className={`page-num ${p === safePage ? 'active' : ''}`}
                  onClick={() => goToPage(p)}
                >
                  {p}
                </button>
              )
            )}
          </div>

          <button
            className="nav-arrow nav-next"
            disabled={safePage === totalPages}
            onClick={() => goToPage(safePage + 1)}
          >
            <span>Next</span>
            <img src="/src/assets/Arrowright.png" alt="Next" />
          </button>
        </div>
      )}

      {/* ── Booking modal ───────────────────────────────────── */}
      {bookingDoctor && (
        <BookingModal
          doctor={bookingDoctor}
          onClose={() => setBookingDoctor(null)}
        />
      )}
    </div>
  );
};

export default Therapist;
