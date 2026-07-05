import React, { useState } from 'react';
import { FaGoogle, FaFacebookF } from 'react-icons/fa';
import { Link, useNavigate } from 'react-router-dom';
import './login.css';
import { login } from '../services/api';
import { useSocialAuth } from './useSocialAuth';

const Login = () => {
  const navigate = useNavigate();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const { googleLoading, facebookLoading, handleGoogleClick, handleFacebookClick } = useSocialAuth({
    onSuccess: () => navigate('/'),
    onError: setError,
  });

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (!email.trim() || !password.trim()) {
      setError('Please enter your email and password.');
      return;
    }

    setIsLoading(true);
    try {
      await login(email.trim(), password);
      navigate('/');
    } catch (err) {
      setError(err.message || 'Login failed. Please check your credentials.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="loginPageWrapper">
      <div className="loginContainer">
        <h1 className="loginTitle">Log In</h1>

        {error && <p className="loginError">{error}</p>}

        <form onSubmit={handleSubmit}>
          <label className="inputLabel">Email</label>
          <input
            type="email"
            placeholder="Enter Your Email"
            className="loginInput"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            disabled={isLoading}
            required
          />

          <label className="inputLabel">Password</label>
          <input
            type="password"
            placeholder="Enter Your Password"
            className="loginInput"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            disabled={isLoading}
            required
          />

          <button className="loginButton" type="submit" disabled={isLoading}>
            {isLoading ? 'Logging in…' : 'Log In'}
          </button>
        </form>

        <div className="socialIcons">
          <button
            type="button"
            className="socialIconBtn"
            onClick={handleGoogleClick}
            disabled={googleLoading}
            aria-label="Log in with Google"
            title="Log in with Google"
          >
            <FaGoogle className="icon" />
          </button>
          <button
            type="button"
            className="socialIconBtn"
            onClick={handleFacebookClick}
            disabled={facebookLoading}
            aria-label="Log in with Facebook"
            title="Log in with Facebook"
          >
            <FaFacebookF className="icon" />
          </button>
        </div>

        <p className="switch-text">
          Don&apos;t have an account? <Link to="/signup">Sign Up</Link>
        </p>
      </div>
    </div>
  );
};

export default Login;
