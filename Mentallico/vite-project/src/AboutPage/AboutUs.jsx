import React from 'react';
import './AboutUs.css';
import Rectangle from './Rectangle';
import Frame from './Frame';

const AboutUs = () => {
  return (
    <div className="about-page">
      {/* Ellipse 20 - أخضر فوق */}
      <div className="ellipse ellipse-20"></div>
      
      {/* Ellipse 22 - Primary أزرق */}
      <div className="ellipse ellipse-22"></div>
    
      <header className="about-header">
        <h1>About Us</h1>
      </header>

     <Rectangle/>
      
    </div>
  );
};

export default AboutUs;