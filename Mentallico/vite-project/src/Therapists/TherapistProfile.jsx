import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { doctors } from './Therapist';
import BookingModal from './BookingModal';
import './TherapistProfile.css';

const REVIEWS = [
  {
    name: 'Huda M.',
    age: 27,
    mentionsDoctor: true,
    text: 'creates a very safe space. Even when I didn’t know how to explain what I was feeling, he helped me find the words. I always leave sessions feeling lighter.',
  },
  {
    name: 'Lina K.',
    age: 25,
    text: 'What I appreciated most was how calm and patient he is. He helped me organize my thoughts instead of overwhelming me with advice.',
  },
  {
    name: 'Julie S.',
    age: 31,
    text: 'He listens carefully and never makes you feel rushed or judged. I felt understood for the first time in a long while.',
  },
  {
    name: 'Mark T.',
    age: 34,
    text: 'Talking to him every week has completely changed how I handle stress at work. I never feel judged, just supported.',
  },
  {
    name: 'Salma R.',
    age: 22,
    text: 'I was nervous about starting therapy, but he made me feel comfortable from the very first session.',
  },
  {
    name: 'Omar K.',
    age: 29,
    text: 'He mixes practical advice with real empathy. For the first time, I feel like I actually have tools to manage my anxiety.',
  },
];

const REVIEWS_PER_PAGE = 3;

const TherapistProfile = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [showBooking, setShowBooking] = useState(false);
  const [reviewPage, setReviewPage] = useState(0);

  useEffect(() => {
    setReviewPage(0);
  }, [id]);

  const doctor = doctors.find((d) => d.id === parseInt(id));

  if (!doctor) {
    return (
      <div className="not-found" style={{ textAlign: 'center', padding: '80px 20px' }}>
        <h2>Therapist not found.</h2>
        <button onClick={() => navigate('/Therapists')} style={{ marginTop: 16 }}>
          Back to Therapists
        </button>
      </div>
    );
  }

  const stars = '★'.repeat(Math.round(doctor.rating)) + '☆'.repeat(5 - Math.round(doctor.rating));
  const firstName = doctor.name.replace(/^Dr\.\s*/, '').split(' ')[0];
  const similar = doctors.filter((d) => d.id !== doctor.id).slice(0, 3);

  const pageCount = Math.ceil(REVIEWS.length / REVIEWS_PER_PAGE);
  const visibleReviews = REVIEWS.slice(
    reviewPage * REVIEWS_PER_PAGE,
    reviewPage * REVIEWS_PER_PAGE + REVIEWS_PER_PAGE
  );
  const goToPrevReviews = () => setReviewPage((p) => (p - 1 + pageCount) % pageCount);
  const goToNextReviews = () => setReviewPage((p) => (p + 1) % pageCount);

  return (
    <div className="profile-page">

      {/* ── Header banner ──────────────────────────────────── */}
      <div className="profile-header-bg">
        <div className="avatar-wrapper">
          <img src={doctor.img} alt={doctor.name} className="main-avatar" />
        </div>
      </div>

      <div className="profile-content">
        <h2 className="doc-name">{doctor.name}</h2>
        <p className="doc-title">{doctor.title}</p>
        <p className="doc-location">Location: Cairo, Egypt / Online</p>

        {/* ── CTA buttons ──────────────────────────────────── */}
        <div className="action-buttons">
          <button className="book-btn-main" onClick={() => setShowBooking(true)}>
            Book a session
          </button>
          <button className="message-btn" onClick={() => navigate('/chat')}>Message</button>
        </div>

        <p className="quote">
          &ldquo;Everyone experiences anxiety and sadness at some point &mdash; but you don&apos;t have to
          face it alone. My role is to help you make sense of what you feel, regain
          emotional balance, and rebuild confidence step by step.&rdquo;
        </p>

        <hr className="divider" />

        {/* ── About ────────────────────────────────────────── */}
        <div className="about-section">
          <h3>About Dr. {firstName}</h3>
          <p>{doctor.bio}</p>
        </div>

        <hr className="divider" />

        {/* ── Reviews ──────────────────────────────────────── */}
        <div className="recommendations-section">
          <h3>Users Recommendations</h3>
          <div className="recommendation-row">
            <button className="rec-nav rec-nav-prev" aria-label="Previous reviews" onClick={goToPrevReviews}>❮</button>
            <div className="recommendation-cards">
              {visibleReviews.map((review, index) => (
                <div key={review.name} className={`rec-card${index === 1 ? ' purple' : ''}`}>
                  <span className="rec-stars">{stars}</span>
                  <p>&ldquo;{review.mentionsDoctor ? `Dr. ${firstName} ${review.text}` : review.text}&rdquo;</p>
                  <span className="rec-author">&mdash; {review.name}, {review.age}</span>
                </div>
              ))}
            </div>
            <button className="rec-nav rec-nav-next" aria-label="Next reviews" onClick={goToNextReviews}>❯</button>
          </div>
        </div>

        <hr className="divider" />

        {/* ── Similar Therapists ──────────────────────────────── */}
        <div className="similar-section">
          <h3>Similar Therapists</h3>
          <div className="similar-cards">
            {similar.map((doc) => (
              <div key={doc.id} className="similar-card">
                <div className="avatar-container">
                  <img src={doc.img} alt={doc.name} className="avatar-img" />
                </div>
                <h4 className="similar-name">{doc.name}</h4>
                <p className="similar-specialty">{doc.title}</p>
                <div className="card-footer-btns">
                  <button className="book-btn" onClick={() => navigate(`/therapist/${doc.id}`)}>
                    Book a session
                  </button>
                  <button className="profile-btn" onClick={() => navigate(`/therapist/${doc.id}`)}>
                    View Profile
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* ── Booking modal ────────────────────────────────────── */}
      {showBooking && (
        <BookingModal doctor={doctor} onClose={() => setShowBooking(false)} />
      )}
    </div>
  );
};

export default TherapistProfile;



