import React, { useState } from 'react';
import './BookingModal.css';

const TIME_SLOTS = [
  '09:00 AM', '10:00 AM', '11:00 AM',
  '01:00 PM', '02:00 PM', '03:00 PM',
  '05:00 PM', '06:00 PM',
];

const SESSION_TYPES = [
  { value: 'video', label: 'Video Call' },
  { value: 'voice', label: 'Voice Call' },
  { value: 'in_person', label: 'In-Person' },
];

const BookingModal = ({ doctor, onClose }) => {
  const today = new Date().toISOString().split('T')[0];

  const [date, setDate] = useState('');
  const [time, setTime] = useState('');
  const [sessionType, setSessionType] = useState('video');
  const [notes, setNotes] = useState('');
  const [submitted, setSubmitted] = useState(false);
  const [errors, setErrors] = useState({});

  const validate = () => {
    const e = {};
    if (!date) e.date = 'Please select a date.';
    if (!time) e.time = 'Please choose a time slot.';
    return e;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const e_ = validate();
    if (Object.keys(e_).length) { setErrors(e_); return; }
    setSubmitted(true);
  };

  // Trap focus inside modal and close on Escape
  const handleKeyDown = (e) => {
    if (e.key === 'Escape') onClose();
  };

  if (submitted) {
    return (
      <div className="modal-backdrop" onClick={onClose} onKeyDown={handleKeyDown}>
        <div className="modal-box confirmation" onClick={(e) => e.stopPropagation()}>
          <div className="confirmation-icon">✓</div>
          <h2>Session Booked!</h2>
          <p>
            Your <strong>{SESSION_TYPES.find(s => s.value === sessionType)?.label}</strong> session
            with <strong>{doctor.name}</strong> is confirmed for:
          </p>
          <p className="confirmation-datetime">
            {new Date(date + 'T00:00:00').toLocaleDateString('en-US', {
              weekday: 'long', year: 'numeric', month: 'long', day: 'numeric',
            })}
            &nbsp;at&nbsp;<strong>{time}</strong>
          </p>
          <p className="confirmation-note">A confirmation will be sent to your registered email.</p>
          <button className="modal-close-btn" onClick={onClose}>Done</button>
        </div>
      </div>
    );
  }

  return (
    <div className="modal-backdrop" onClick={onClose} onKeyDown={handleKeyDown}>
      <div className="modal-box" onClick={(e) => e.stopPropagation()}>

        {/* Header */}
        <div className="modal-header">
          <img src={doctor.img} alt={doctor.name} className="modal-avatar" />
          <div>
            <h2 className="modal-doctor-name">{doctor.name}</h2>
            <p className="modal-doctor-title">{doctor.title}</p>
          </div>
          <button className="modal-x" onClick={onClose} aria-label="Close">✕</button>
        </div>

        <form onSubmit={handleSubmit} className="modal-form">

          {/* Date */}
          <div className="form-group">
            <label>Select Date</label>
            <input
              type="date"
              min={today}
              value={date}
              onChange={(e) => { setDate(e.target.value); setErrors(p => ({ ...p, date: '' })); }}
              className={errors.date ? 'input-error' : ''}
            />
            {errors.date && <span className="field-error">{errors.date}</span>}
          </div>

          {/* Time slots */}
          <div className="form-group">
            <label>Available Time Slots</label>
            <div className="time-slots">
              {TIME_SLOTS.map(slot => (
                <button
                  key={slot}
                  type="button"
                  className={`time-slot ${time === slot ? 'selected' : ''}`}
                  onClick={() => { setTime(slot); setErrors(p => ({ ...p, time: '' })); }}
                >
                  {slot}
                </button>
              ))}
            </div>
            {errors.time && <span className="field-error">{errors.time}</span>}
          </div>

          {/* Session type */}
          <div className="form-group">
            <label>Session Type</label>
            <div className="session-types">
              {SESSION_TYPES.map(type => (
                <label key={type.value} className={`type-option ${sessionType === type.value ? 'selected' : ''}`}>
                  <input
                    type="radio"
                    name="sessionType"
                    value={type.value}
                    checked={sessionType === type.value}
                    onChange={() => setSessionType(type.value)}
                  />
                  {type.label}
                </label>
              ))}
            </div>
          </div>

          {/* Optional notes */}
          <div className="form-group">
            <label>Notes <span className="optional">(optional)</span></label>
            <textarea
              rows={3}
              placeholder="Anything you'd like the therapist to know beforehand..."
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
            />
          </div>

          {/* Price summary */}
          <div className="price-summary">
            <span>Session fee</span>
            <span className="price">${doctor.price ?? 80} / session</span>
          </div>

          <button type="submit" className="confirm-btn">Confirm Booking</button>
        </form>
      </div>
    </div>
  );
};

export default BookingModal;
