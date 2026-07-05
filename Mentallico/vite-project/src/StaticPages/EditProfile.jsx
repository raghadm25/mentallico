import React, { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getProfile, updateProfile, updateProfileWithPicture } from '../services/api';
import '../StaticPages/tokens.css';
import './EditProfile.css';

const GENDER_OPTIONS = [
  { value: '', label: 'Prefer not to answer' },
  { value: 'male', label: 'Male' },
  { value: 'female', label: 'Female' },
  { value: 'non_binary', label: 'Non-Binary' },
  { value: 'prefer_not_to_say', label: 'Prefer not to say' },
];

const EditProfile = () => {
  const navigate = useNavigate();
  const fileInputRef = useRef(null);

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);

  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [bio, setBio] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [dateOfBirth, setDateOfBirth] = useState('');
  const [gender, setGender] = useState('');
  const [currentPictureUrl, setCurrentPictureUrl] = useState(null);
  const [newPicture, setNewPicture] = useState(null);
  const [newPicturePreview, setNewPicturePreview] = useState(null);

  useEffect(() => {
    getProfile()
      .then((data) => {
        setFirstName(data.first_name || '');
        setLastName(data.last_name || '');
        setBio(data.bio || '');
        setPhoneNumber(data.phone_number || '');
        setDateOfBirth(data.date_of_birth || '');
        setGender(data.gender || '');
        setCurrentPictureUrl(data.profile_picture || null);
      })
      .catch((err) => setError(err.message || 'Could not load your profile.'))
      .finally(() => setLoading(false));
  }, []);

  const handlePictureChange = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (newPicturePreview) URL.revokeObjectURL(newPicturePreview);
    setNewPicture(file);
    setNewPicturePreview(URL.createObjectURL(file));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    setError(null);

    const fields = {
      first_name: firstName,
      last_name: lastName,
      bio,
      phone_number: phoneNumber,
      date_of_birth: dateOfBirth || null,
      gender,
    };

    try {
      if (newPicture) {
        await updateProfileWithPicture(fields, newPicture);
      } else {
        await updateProfile(fields);
      }
      navigate('/UserProfile');
    } catch (err) {
      setError(err.message || 'Could not save your profile.');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <div className="static-page"><p>Loading…</p></div>;
  }

  return (
    <div className="static-page">
      <h1>Edit My Profile</h1>
      <p className="static-subtitle">Update your account details.</p>

      <form onSubmit={handleSubmit} className="edit-profile-form">
        <div className="edit-profile-picture-row">
          <img
            src={newPicturePreview || currentPictureUrl || 'https://www.w3schools.com/howto/img_avatar.png'}
            alt="Profile"
            className="edit-profile-avatar"
          />
          <button type="button" className="edit-profile-picture-btn" onClick={() => fileInputRef.current?.click()}>
            Change photo
          </button>
          <input
            type="file"
            accept="image/*"
            ref={fileInputRef}
            style={{ display: 'none' }}
            onChange={handlePictureChange}
          />
        </div>

        <div className="edit-profile-grid">
          <label>
            First name
            <input value={firstName} onChange={(e) => setFirstName(e.target.value)} required />
          </label>
          <label>
            Last name
            <input value={lastName} onChange={(e) => setLastName(e.target.value)} />
          </label>
          <label>
            Phone number
            <input value={phoneNumber} onChange={(e) => setPhoneNumber(e.target.value)} />
          </label>
          <label>
            Date of birth
            <input type="date" value={dateOfBirth || ''} onChange={(e) => setDateOfBirth(e.target.value)} />
          </label>
          <label>
            Gender
            <select value={gender} onChange={(e) => setGender(e.target.value)}>
              {GENDER_OPTIONS.map((opt) => (
                <option key={opt.value} value={opt.value}>{opt.label}</option>
              ))}
            </select>
          </label>
        </div>

        <label className="edit-profile-bio-label">
          Bio
          <textarea value={bio} onChange={(e) => setBio(e.target.value)} rows={4} />
        </label>

        {error && <p className="edit-profile-error">{error}</p>}

        <button type="submit" className="edit-profile-save-btn" disabled={saving}>
          {saving ? 'Saving…' : 'Save Changes'}
        </button>
      </form>
    </div>
  );
};

export default EditProfile;
