import React, { useState, useEffect, useRef } from "react";
import { Link, NavLink, useNavigate, useLocation } from "react-router-dom";
import "./Navbar.css";
import arrowIcon from "../assets/ri_arrow-drop-down-line.png";
import { logout, getStoredUserName } from "../services/api";

// Pages whose hero sits directly under the (transparent, absolutely
// positioned) navbar and uses the dark brand gradient banner — the logo
// needs the light color there so it doesn't blend into the background.
const DARK_BG_PATHS = ["/UserProfile"];
const isDarkBgPath = (pathname) =>
  DARK_BG_PATHS.includes(pathname) || pathname.startsWith("/therapist/");

const Navbar = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const onDarkBg = isDarkBgPath(location.pathname);

  // ── Community dropdown ─────────────────────────────────────
  const [communityOpen, setCommunityOpen] = useState(false);

  // ── Mobile hamburger drawer ──────────────────────────────────
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  // Close the drawer whenever the route changes (i.e. after following a link).
  useEffect(() => {
    setMobileMenuOpen(false);
  }, [location.pathname]);

  // Lock background scroll while the drawer is open.
  useEffect(() => {
    document.body.style.overflow = mobileMenuOpen ? "hidden" : "";
    return () => { document.body.style.overflow = ""; };
  }, [mobileMenuOpen]);

  // ── User menu ──────────────────────────────────────────────
  // Initialise directly from localStorage so the name is present
  // immediately on page refresh — no flash to "Sign Up".
  const [userName, setUserName] = useState(
    () => getStoredUserName()
  );
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const userMenuRef = useRef(null);

  // Close the user menu when the user clicks anywhere outside it.
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (userMenuRef.current && !userMenuRef.current.contains(e.target)) {
        setUserMenuOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // Keep the displayed name in sync when another tab logs in or out.
  useEffect(() => {
    const handleStorage = () => setUserName(getStoredUserName());
    window.addEventListener("storage", handleStorage);
    return () => window.removeEventListener("storage", handleStorage);
  }, []);

  // ── Handlers ───────────────────────────────────────────────
  const handleLogout = () => {
    logout();
    setUserName(null);
    setUserMenuOpen(false);
    navigate("/");
  };

  // First word only for the greeting ("Hi, Abdalla" not "Hi, Abdalla Smith")
  const firstName = userName ? userName.split(" ")[0] : "";

  // Initials avatar — first letter of the name, uppercase
  const initial = firstName ? firstName[0].toUpperCase() : "";

  // ─────────────────────────────────────────────────────────
  return (
    <header className="navbar">
      <h1 className={`navbar-logo ${onDarkBg ? "navbar-logo--on-dark" : ""}`}>
        <Link to="/" style={{ textDecoration: "none", color: "inherit" }}>
          Mentallico
        </Link>
      </h1>

      <button
        type="button"
        className={`hamburger-btn ${onDarkBg ? "hamburger-btn--on-dark" : ""} ${mobileMenuOpen ? "open" : ""}`}
        onClick={() => setMobileMenuOpen((open) => !open)}
        aria-label={mobileMenuOpen ? "Close menu" : "Open menu"}
        aria-expanded={mobileMenuOpen}
      >
        <span />
        <span />
        <span />
      </button>

      <nav>
        <ul className="navbar-links">
          <li>
            <NavLink to="/" className={({ isActive }) => isActive ? "active" : ""}>
              Home
            </NavLink>
          </li>

          <li>
            <NavLink to="/about" className={({ isActive }) => isActive ? "active" : ""}>
              About Us
            </NavLink>
          </li>

          {/* Community + sub-menu */}
          <li className="dropdown-container">
            <div className="nav-link-wrapper">
              <NavLink
                to="/Community"
                className={({ isActive }) => isActive ? "active" : ""}
              >
                Community
              </NavLink>
              <button
                className="arrow-toggle-btn"
                onClick={(e) => { e.preventDefault(); setCommunityOpen(!communityOpen); }}
              >
                <img
                  src={arrowIcon}
                  alt="dropdown arrow"
                  className={`nav-arrow ${communityOpen ? "rotated" : ""}`}
                />
              </button>
            </div>

            {communityOpen && (
              <ul className="dropdown-menu">
                <li>
                  <Link to="/ResourcesCenter" onClick={() => setCommunityOpen(false)}>
                    Resources
                  </Link>
                  <Link to="/UserProfile" onClick={() => setCommunityOpen(false)}>
                    User Profile
                  </Link>
                </li>
              </ul>
            )}
          </li>

          <li>
            <NavLink to="/ai-assistant" className={({ isActive }) => isActive ? "active" : ""}>
              AI Assistant
            </NavLink>
          </li>

          <li>
            <NavLink to="/Therapists" className={({ isActive }) => isActive ? "active" : ""}>
              Therapists
            </NavLink>
          </li>
        </ul>
      </nav>

      {/* ── Auth area ────────────────────────────────────────── */}
      {userName ? (
        // ── Logged-in: greeting + dropdown
        <div className="user-menu-wrapper" ref={userMenuRef}>
          <button
            className="user-greeting-btn"
            onClick={() => setUserMenuOpen(!userMenuOpen)}
            aria-expanded={userMenuOpen}
            aria-haspopup="true"
          >
            <span className="user-avatar-circle">{initial}</span>
            <span className="user-greeting-text">Hi, {firstName}</span>
            <svg
              className={`user-caret ${userMenuOpen ? "rotated" : ""}`}
              width="12" height="12" viewBox="0 0 12 12" fill="none"
            >
              <path d="M2 4l4 4 4-4" stroke="currentColor" strokeWidth="1.8"
                strokeLinecap="round" strokeLinejoin="round" />
            </svg>
          </button>

          {userMenuOpen && (
            <div className="user-dropdown" role="menu">
              {/* Identity header */}
              <div className="user-dropdown-header">
                <span className="user-dropdown-avatar">{initial}</span>
                <span className="user-dropdown-name">{userName}</span>
              </div>

              <div className="user-dropdown-divider" />

              <Link
                to="/UserProfile"
                className="user-dropdown-item"
                onClick={() => setUserMenuOpen(false)}
                role="menuitem"
              >
                <span className="dropdown-icon"></span>
                My Profile
              </Link>

              <Link
                to="/ai-assistant"
                className="user-dropdown-item"
                onClick={() => setUserMenuOpen(false)}
                role="menuitem"
              >
                <span className="dropdown-icon"></span>
                AI Assistant
              </Link>

              <div className="user-dropdown-divider" />

              <button
                className="user-dropdown-item logout-item"
                onClick={handleLogout}
                role="menuitem"
              >
                <span className="dropdown-icon"></span>
                Log Out
              </button>
            </div>
          )}
        </div>
      ) : (
        // ── Logged-out: sign-up button
        <Link to="/signup">
          <button className="signup-btn">Sign Up</button>
        </Link>
      )}

      {/* ── Mobile drawer (<768px only, see Navbar.css) ────────── */}
      {mobileMenuOpen && (
        <div className="mobile-menu-backdrop" onClick={() => setMobileMenuOpen(false)} />
      )}
      <div className={`mobile-drawer ${mobileMenuOpen ? "open" : ""}`}>
        <ul className="mobile-drawer-links">
          <li>
            <NavLink to="/" className={({ isActive }) => isActive ? "active" : ""}>
              Home
            </NavLink>
          </li>
          <li>
            <NavLink to="/about" className={({ isActive }) => isActive ? "active" : ""}>
              About Us
            </NavLink>
          </li>
          <li>
            <NavLink to="/Community" className={({ isActive }) => isActive ? "active" : ""}>
              Community
            </NavLink>
          </li>
          <li>
            <NavLink to="/ResourcesCenter" className={({ isActive }) => isActive ? "active" : ""}>
              Resources
            </NavLink>
          </li>
          <li>
            <NavLink to="/ai-assistant" className={({ isActive }) => isActive ? "active" : ""}>
              AI Assistant
            </NavLink>
          </li>
          <li>
            <NavLink to="/Therapists" className={({ isActive }) => isActive ? "active" : ""}>
              Therapists
            </NavLink>
          </li>
        </ul>

        <div className="mobile-drawer-divider" />

        {userName ? (
          <div className="mobile-drawer-account">
            <div className="mobile-drawer-identity">
              <span className="user-avatar-circle">{initial}</span>
              <span>{userName}</span>
            </div>
            <Link to="/UserProfile" className="mobile-drawer-account-link">
              My Profile
            </Link>
            <button type="button" className="mobile-drawer-account-link logout-item" onClick={handleLogout}>
              Log Out
            </button>
          </div>
        ) : (
          <Link to="/signup" className="mobile-drawer-signup">
            <button className="signup-btn">Sign Up</button>
          </Link>
        )}
      </div>
    </header>
  );
};

export default Navbar;
