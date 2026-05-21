import React from "react";
import "./Rectangle.css";

const Rectangle = () => {
  return (
    <section className="about-hero-section">
      {/* Background Blurs */}
      <div className="ellipse-blur ellipse-20"></div>
      <div className="ellipse-blur ellipse-22"></div>

      {/* Quote Rectangle */}
      <div className="quote-rectangle">
        <div className="quote-container">
          <span className="quote-mark left">"</span>

          <p className="quote-text">
            We know how heavy it can feel to carry your struggles alone. Everyone
            deserves a safe space to talk, reflect, and heal. That's why we
            created <span className="highlight">Mentallico</span> — a companion
            that listens, understands, and connects you to the help you need.
          </p>

          <span className="quote-mark right">"</span>
        </div>
      </div>
    </section>
  );
};

export default Rectangle;