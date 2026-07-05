import React from 'react';
import './Mission.css';
import illustration from '../assets/illustration 1.png';
import greenBlob from '../assets/Ellipse 19.png'; 
import purpleBlob from '../assets/Ellipse 23.png'; 

const Mission = () => {
  return (
    <section className="mission-section">
   
      <img src={greenBlob} alt="" className="blob-right" />
      <img src={purpleBlob} alt="" className="blob-left" />

      <div className="mission-container">
        <div className="mission-content">
          <h2 className="mission-title">Our Mission</h2>
          <p className="mission-text">
            To bring comfort, understanding, and real help to every person who
            feels unheard. We exist to bridge the gap between technology and
            humanity, offering instant AI support and real human connection when it
            matters most. Because mental health care should be simple, safe,
            and always within reach.
          </p>
        </div>
        
        <div className="mission-image-wrapper">
          <img src={illustration} alt="Mission Archery Illustration" className="mission-img" />
        </div>
      </div>
    </section>
  );
};

export default Mission;