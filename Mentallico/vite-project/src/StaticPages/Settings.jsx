import React, { useEffect, useState } from 'react';
import { getProfile, changePassword } from '../services/api';
import '../StaticPages/tokens.css';
import './Settings.css';

const Settings = () => {
  const [profile, setProfile] = useState(null);
  const [loadError, setLoadError] = useState(null);

  const [oldPassword, setOldPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [newPasswordConfirm, setNewPasswordConfirm] = useState('');
  const [passwordSaving, setPasswordSaving] = useState(false);
  const [passwordMessage, setPasswordMessage] = useState(null);
  const [passwordError, setPasswordError] = useState(null);

  const [notifyPosts, setNotifyPosts] = useState(true);
  const [notifyReminders, setNotifyReminders] = useState(true);

  useEffect(() => {
    getProfile()
      .then(setProfile)
      .catch((err) => setLoadError(err.message || 'Could not load your profile.'));
  }, []);

  const handleChangePassword = async (e) => {
    e.preventDefault();
    setPasswordMessage(null);
    setPasswordError(null);

    if (newPassword !== newPasswordConfirm) {
      setPasswordError('New passwords do not match.');
      return;
    }

    setPasswordSaving(true);
    try {
      await changePassword(oldPassword, newPassword, newPasswordConfirm);
      setPasswordMessage('Password updated successfully.');
      setOldPassword('');
      setNewPassword('');
      setNewPasswordConfirm('');
    } catch (err) {
      setPasswordError(err.message || 'Could not change password.');
    } finally {
      setPasswordSaving(false);
    }
  };

  return (
    <div className="static-page">
      <h1>Settings</h1>
      <p className="static-subtitle">Manage your account and preferences.</p>

      {loadError && <p className="settings-error">{loadError}</p>}

      <section className="settings-card">
        <h2>Account</h2>
        <p><strong>Email:</strong> {profile?.email || 'Loading…'}</p>
        <p><strong>Name:</strong> {profile ? `${profile.first_name} ${profile.last_name}`.trim() || '—' : 'Loading…'}</p>
      </section>

      <section className="settings-card">
        <h2>Change Password</h2>
        <form onSubmit={handleChangePassword} className="settings-form">
          <input
            type="password"
            placeholder="Current password"
            value={oldPassword}
            onChange={(e) => setOldPassword(e.target.value)}
            required
          />
          <input
            type="password"
            placeholder="New password"
            value={newPassword}
            onChange={(e) => setNewPassword(e.target.value)}
            required
          />
          <input
            type="password"
            placeholder="Confirm new password"
            value={newPasswordConfirm}
            onChange={(e) => setNewPasswordConfirm(e.target.value)}
            required
          />
          {passwordError && <p className="settings-error">{passwordError}</p>}
          {passwordMessage && <p className="settings-success">{passwordMessage}</p>}
          <button type="submit" className="settings-save-btn" disabled={passwordSaving}>
            {passwordSaving ? 'Saving…' : 'Update Password'}
          </button>
        </form>
      </section>

      <section className="settings-card">
        <h2>Notifications</h2>
        <label className="settings-toggle-row">
          <span>New posts from the community <em>(coming soon)</em></span>
          <input
            type="checkbox"
            checked={notifyPosts}
            onChange={(e) => setNotifyPosts(e.target.checked)}
          />
        </label>
        <label className="settings-toggle-row">
          <span>Wellness reminders <em>(coming soon)</em></span>
          <input
            type="checkbox"
            checked={notifyReminders}
            onChange={(e) => setNotifyReminders(e.target.checked)}
          />
        </label>
      </section>
    </div>
  );
};

export default Settings;
