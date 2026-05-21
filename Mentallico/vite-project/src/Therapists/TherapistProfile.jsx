import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { doctors } from './Therapist';
import BookingModal from './BookingModal';
import './TherapistProfile.css';

const TherapistProfile = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [showBooking, setShowBooking] = useState(false);

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

  return (
    <div className="profile-page">

      {/* ── Header banner ──────────────────────────────────── */}
      <div className="profile-header-bg">
        <button className="back-btn" onClick={() => navigate(-1)}>←</button>
        <div className="avatar-wrapper">
          <img src={doctor.img} alt={doctor.name} className="main-avatar" />
        </div>
      </div>

      <div className="profile-content">
        <h2 className="doc-name">{doctor.name}</h2>
        <p className="doc-title">{doctor.title}</p>
        <p className="doc-location">📍 Cairo, Egypt / Online</p>

        {/* ── Quick stats ──────────────────────────────────── */}
        <div style={{ display: 'flex', gap: 24, flexWrap: 'wrap', margin: '14px 0', fontSize: '0.88rem', color: '#666' }}>
          <span>⭐ {doctor.rating} <span style={{ color: '#aaa' }}>({doctor.reviewCount} reviews)</span></span>
          <span>🕐 {doctor.experience} yrs experience</span>
          <span>💬 {doctor.languages.join(' · ')}</span>
          <span>💲{doctor.price} / session</span>
        </div>

        {/* ── CTA buttons ──────────────────────────────────── */}
        <div className="action-buttons">
          <button className="book-btn-main" onClick={() => setShowBooking(true)}>
            Book a Session
          </button>
          <button className="message-btn">Message</button>
        </div>

        {/* ── Specialties ──────────────────────────────────── */}
        <div style={{ margin: '20px 0' }}>
          <h3 style={{ marginBottom: 8 }}>Specialties</h3>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
            {doctor.specialty.split(', ').map((s) => (
              <span key={s} style={{
                background: '#f3f1ff', color: '#5c4db8',
                borderRadius: 20, padding: '4px 14px', fontSize: '0.82rem', fontWeight: 500,
              }}>
                {s}
              </span>
            ))}
          </div>
        </div>

        <p className="quote">
          &ldquo;Everyone experiences anxiety and sadness at some point – but you do not have to
          face it alone. My role is to help you make sense of what you feel and regain
          emotional balance.&rdquo;
        </p>

        <hr className="divider" />

        {/* ── About ────────────────────────────────────────── */}
        <div className="about-section">
          <h3>About {doctor.name}</h3>
          <p>{doctor.bio}</p>
        </div>

        {/* ── Reviews ──────────────────────────────────────── */}
        <div className="recommendations-section">
          <h3>Patient Reviews</h3>
          <div className="recommendation-cards">
            <div className="rec-card">
              <span style={{ color: '#f5a623' }}>{stars}</span>
              <p>&ldquo;{doctor.name.split(' ')[1]} creates a very safe space. I always leave
              sessions feeling heard and understood.&rdquo;</p>
            </div>
            <div className="rec-card purple">
              <span style={{ color: '#f5a623' }}>{stars}</span>
              <p>&ldquo;What I appreciated most was how calm and patient they are. Highly
              recommend for anyone struggling with anxiety.&rdquo;</p>
            </div>
            <div className="rec-card">
              <span style={{ color: '#f5a623' }}>{stars}</span>
              <p>&ldquo;They listens carefully and never makes you feel rushed. Truly life-changing
              sessions.&rdquo;</p>
            </div>
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
