import React from 'react';
import { useNavigate } from 'react-router-dom';
import './Frame.css';
import blobTopRight from '../assets/Ellipse 21.png';
import blobBottomLeft from '../assets/Ellipse 28.png';

const Frame = () => {
  const navigate = useNavigate();

  return (
    <section className="frame-section-wrapper">
      <div className="blob-wrapper-top">
         <img src={blobTopRight} alt="" className="blob-floating-top" />
      </div>

      <div className="frame-container-box">
        <div className="frame-content">
          <p className="frame-text">
            We invite you to be part of this journey, because your mental
            health matters, your story deserves to be heard, and your healing
            begins the moment you decide you don't have to face it all alone.
          </p>
          
          <button className="frame-button" onClick={() => navigate('/signup')}>
            Start your Journey
          </button>
        </div>
      </div>

      <div className="blob-wrapper-bottom">
        <img src={blobBottomLeft} alt="" className="blob-floating-bottom" />
      </div>

    </section>
  );
};

export default Frame;