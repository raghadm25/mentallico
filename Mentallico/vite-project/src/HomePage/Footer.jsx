import React from "react";
import "./Footer.css";
import { Link } from "react-router-dom"; 
import footerImage from "../assets/Footerimg.png";
import facebookIcon from "../assets/facebook.png";
import instagramIcon from "../assets/instagram.png";
import xIcon from "../assets/X.png";

const Footer = () => {
  return (
    <footer className="footer">
      <h1 className="footer-logo">Mentallico</h1>
      <p className="footer-slogan">Your partner in mental wellness</p>

      <h4 className="footer-newsletter-title">Subscribe our newsletter</h4>
      <form className="footer-subscribe" onSubmit={(e) => e.preventDefault()}>
        <input type="email" placeholder="Enter your Email" required
        
        
        />
        <button type="submit">Subscribe</button>
      </form>

      
      <div className="footer-company footer-section">
        <h4>Company</h4>
        <Link to="/about">About us</Link>
        <Link to="/community">Community</Link>
        <Link to="/ai-assistant">AI Assistant</Link>
        <Link to="/Therapists">Therapists</Link>
      </div>

      <div className="footer-links footer-section">
        <h4>Helpful Links</h4>
        <Link to="/faqs">FAQs</Link>
        <Link to="/services">Services</Link>
        <Link to="/terms">Terms & Condition</Link>
        <Link to="/privacy">Privacy Policy</Link>
      </div>

      <div className="footer-contact footer-section">
        <h4>Contact us</h4>
        <p><a href="tel:+919999999999">+91 9999 999 999</a></p>
        <p><a href="mailto:mentallico@gmail.com">mentallico@gmail.com</a></p>
      </div>

      <div className="footer-app-section">
        <h4 className="footer-app-title">Download our app</h4>
        <img src={footerImage} alt="Footer illustration" className="footer-img" />
      </div>

      <div className="footer-bottom">
        <p className="footer-copy">© 2025 Mentallico. All rights reserved.</p>
        
        <div className="footer-social">
         
          <a href="https://www.facebook.com/login" target="_blank" rel="noreferrer">
            <img src={facebookIcon} alt="Facebook" />
          </a>
          <a href="https://www.instagram.com/accounts/login/" target="_blank" rel="noreferrer">
            <img src={instagramIcon} alt="Instagram" />
          </a>
          <a href="https://x.com/i/flow/login" target="_blank" rel="noreferrer">
            <img src={xIcon} alt="X" />
          </a>
        </div>
      </div>
    </footer>
  );
};

export default Footer;