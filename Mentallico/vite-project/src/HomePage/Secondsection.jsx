import React from "react";
import "./SecondSection.css";

const SecondSection = () => {
  const features = [
    { text: "Mood Tracking with smart insights" },
    { text: "Self-Help Resources for everyday guidance" },
    { text: "Licensed Therapists you can contact" },
    { text: "Wellness Exercises & Reminders picked for you" },
    { text: "Private & Secure messages" },
  ];

  return (
    <section className="second-section">
      <h2>More than just an app — it’s your safe space.</h2>
    
      <div className="wave-container">
        <svg
          className="wave-svg"
          viewBox="0 0 1440 320"
          preserveAspectRatio="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            fill="none"
            stroke="url(#waveGradient)"
            strokeWidth="120"
            strokeLinecap="round"
            d="M-50,280 C300,280 600,150 1500,50"
          />
          <defs>
            <linearGradient id="waveGradient" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" stopColor="#7F89E9" stopOpacity="0.8" />
              <stop offset="100%" stopColor="#A87CC7" stopOpacity="0.8" />
            </linearGradient>
          </defs>
        </svg>

        <div className="cards-row">
          {features.map((feature, index) => (
            <div key={index} className={`glass-card card-${index + 1}`}>
              <p>{feature.text}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default SecondSection;