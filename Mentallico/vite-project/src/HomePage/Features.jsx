import React from "react";
import "./Features.css";
import aiIcon from "../assets/artificial-intelligence.png";
import peopleIcon from "../assets/fluent_people.png";
import trendIcon from "../assets/TrendUpStreamline.png";

const Features = () => {
  return (
    <section className="features">
      <div className="ellipse-17"></div>

      <h2>Mental health support, designed for you.</h2>

      <div className="features-cards">
        <div className="feature-card">
          <div className="icon-wrapper">
            <img src={aiIcon} alt="AI Support" className="icon-img" />
          </div>
          <h3>AI Powered Support</h3>
          <p>
            Our AI assistant provides 24/7 support, offering personalized
            guidance and resources.
          </p>
        </div>

        <div className="feature-card">
          <div className="icon-wrapper">
            <img src={peopleIcon} alt="Community" className="icon-img" />
          </div>
          <h3>Safe Peer Community</h3>
          <p>
            Join a supportive community where people share experiences and
            positivity all in a safe environment.
          </p>
        </div>

        <div className="feature-card">
          <div className="icon-wrapper">
            <img src={trendIcon} alt="Progress" className="icon-img" />
          </div>
          <h3>Track Your Progress</h3>
          <p>
            Monitor your mental health journey with our intuitive tools. Get access to
            our wellness library.
          </p>
        </div>
      </div>
    </section>
  );
};

export default Features;