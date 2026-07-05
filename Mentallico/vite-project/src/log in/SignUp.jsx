import React, { useState } from 'react';
import { FaGoogle, FaFacebookF } from 'react-icons/fa';
import { Link, useNavigate } from 'react-router-dom';
import './SignUp.css';
import { register } from '../services/api';
import { useSocialAuth } from './useSocialAuth';

const SignUp = () => {
  const navigate = useNavigate();

  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const { googleLoading, facebookLoading, handleGoogleClick, handleFacebookClick } = useSocialAuth({
    onSuccess: () => navigate('/'),
    onError: setError,
  });

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (!name.trim() || !email.trim() || !password || !confirmPassword) {
      setError('Please fill in all fields.');
      return;
    }
    if (password !== confirmPassword) {
      setError('Passwords do not match.');
      return;
    }
    if (password.length < 8) {
      setError('Password must be at least 8 characters.');
      return;
    }

    setIsLoading(true);
    try {
      await register(name.trim(), email.trim(), password, confirmPassword);
      navigate('/login');
    } catch (err) {
      setError(err.message || 'Registration failed. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="signup-container">
      <div className="signup-card">
        {error && <p className="signup-error">{error}</p>}

        <h1 className="signup-title">Sign Up</h1>

        <form className="signup-form" onSubmit={handleSubmit}>
          <label className="input-label">Name</label>
          <div className="input-group">
            <input
              type="text"
              placeholder="Enter Your Name"
              className="custom-input"
              value={name}
              onChange={(e) => setName(e.target.value)}
              disabled={isLoading}
              required
            />
          </div>

          <label className="input-label">Email</label>
          <div className="input-group">
            <input
              type="email"
              placeholder="Enter Your Email"
              className="custom-input"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              disabled={isLoading}
              required
            />
          </div>

          <label className="input-label">Password</label>
          <div className="input-group">
            <input
              type="password"
              placeholder="Enter Your Password"
              className="custom-input"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              disabled={isLoading}
              required
            />
          </div>

          <label className="input-label">Confirm Password</label>
          <div className="input-group">
            <input
              type="password"
              placeholder="Confirm Your Password"
              className="custom-input"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              disabled={isLoading}
              required
            />
          </div>

          {/* row 10 is an intentional empty spacer row, matching the Figma grid */}
          <div className="grid-spacer" aria-hidden="true" />

          <button type="submit" className="create-account-btn" disabled={isLoading}>
            {isLoading ? 'Creating account…' : 'Create Account'}
          </button>
        </form>

        <div className="social-icons">
          <button
            type="button"
            className="social-icon-btn"
            onClick={handleGoogleClick}
            disabled={googleLoading}
            aria-label="Sign up with Google"
            title="Sign up with Google"
          >
            <FaGoogle />
          </button>
          <button
            type="button"
            className="social-icon-btn"
            onClick={handleFacebookClick}
            disabled={facebookLoading}
            aria-label="Sign up with Facebook"
            title="Sign up with Facebook"
          >
            <FaFacebookF />
          </button>
        </div>
      </div>

      <p className="signup-switch-text">
        Already have an account? <Link to="/login">Log In</Link>
      </p>
    </div>
  );
};

export default SignUp;
