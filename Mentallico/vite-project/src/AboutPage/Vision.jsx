import React from 'react';
import './Vision.css';
import illustration from '../assets/illustration 2.png'; 

const Vision = () => {
  return (
    <section className="vision-section">
      <div className="vision-container">
        <div className="vision-image-wrapper">
          <img src={illustration} alt="Vision Illustration" className="vision-img" />
        </div>

        <div className="vision-content">
          <h2 className="vision-title">Our Vision</h2>
          <p className="vision-text">
            To create a world where seeking help is seen as strength, not
            weakness. A world where every individual — no matter where they are
            or what they're going through — can find peace, hope, and healing
            through empathy, innovation, and connection.
          </p>
        </div>
      </div>
    </section>
  );
};

export default Vision;