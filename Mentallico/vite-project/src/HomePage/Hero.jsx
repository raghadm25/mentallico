import React from "react";
import { Link } from "react-router-dom";
import "./Hero.css";
import illustration from "../assets/illustration.png";

const Hero = () => {
  return (
    <section className="hero">
      
      <div className="hero-content">
        <h1>
          Your Path to <br />
          <span className="gradient-text">Mental Wellness</span>
          <br />
          Starts Here
        </h1>

        <p>Feel heard, supported, and guided — anytime, anywhere</p>

        <div className="hero-buttons">
          {/* Start for Free → mood check-in → chatbot */}
          <Link to="/ai-assistant">
            <button className="btn primary">Start for Free</button>
          </Link>
          {/* Learn More → about page */}
          <Link to="/about">
            <button className="btn secondary">Learn More</button>
          </Link>
        </div>
      </div>

   
      <div className="hero-right">
      
        <div className="hero-shape">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 804 741"
            fill="none"
          >
            <path
              d="M47.6872 -0.348877H803.829V740.641H47.6872C47.6872 740.641 -72.1447 570.016 68.1076 386.624C208.36 203.232 47.6872 -0.348877 47.6872 -0.348877Z"
              fill="url(#paint0_linear)"
            />
            <defs>
              <linearGradient
                id="paint0_linear"
                x1="47.6869"
                y1="432.167"
                x2="899.237"
                y2="431.25"
                gradientUnits="userSpaceOnUse"
              >
                <stop stopColor="#7F89E9" />
                <stop offset="0.5" stopColor="#A87CC7" />
                <stop offset="1" stopColor="#658852" />
              </linearGradient>
            </defs>
          </svg>
        </div>

        
        <img
          src={illustration}
          alt="Therapy Illustration"
          className="hero-illustration"
        />
      </div>
    </section>
  );
};

export default Hero;
