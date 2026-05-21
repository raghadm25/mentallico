import React, { useState } from 'react';
import { FaGoogle, FaFacebookF } from 'react-icons/fa';
import { Link, useNavigate } from 'react-router-dom';
import './login.css';
import { login } from '../services/api';

const Login = () => {
  const navigate = useNavigate();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

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

        {error && (
          <p style={{ color: '#c0392b', marginBottom: '12px', fontSize: '14px' }}>
            {error}
          </p>
        )}

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
          <FaGoogle className="icon" />
          <FaFacebookF className="icon" />
        </div>

        <p className="switch-text">
          Don&apos;t have an account? <Link to="/signup">Sign Up</Link>
        </p>
      </div>
    </div>
  );
};

export default Login;
