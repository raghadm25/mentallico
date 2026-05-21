import React from "react";
import "./ReviewSection.css";

import starPurple from "../assets/Vector.png"; 
import starWhite from "../assets/Vector 2.png"; 
import arrowRight from "../assets/weui_arrow-filled (1).png"; 
import arrowLeft from "../assets/weui_arrow-filled (2).png"; 

const ReviewSection = () => {
  const reviews = [
    {
      id: 1,
      name: "Ahmed, 19",
      text: "“The AI is surprisingly empathetic. And when I needed more, it guided me to a real therapist. Best of both worlds.”",
      rating: 5,
      isPrimary: false,
    },
    {
      id: 2,
      name: "Mariam, 22",
      text: "“It feels like I finally have someone to listen, even at 3 AM. The AI chat keeps me grounded when I need it most.”",
      rating: 5,
      isPrimary: true, 
    },
    {
      id: 3,
      name: "Jade, 30",
      text: "“It’s more than an app. It’s like a safe space I can carry in my pocket.”",
      rating: 5,
      isPrimary: false,
    },
  ];

  const renderStars = (isPrimary) => {
    const starIcon = isPrimary ? starWhite : starPurple;
    return (
      <div className="stars-container">
        {[...Array(5)].map((_, index) => (
          <img key={index} src={starIcon} alt="star" className="star-icon" />
        ))}
      </div>
    );
  };

  return (
    <section className="review-section">
     
      <div className="ellipse-15"></div>
      <div className="ellipse-12"></div>

      <h2>What Our Users Say</h2>

      <div className="reviews-wrapper">
        
        <button className="arrow-btn left-arrow">
          <img src={arrowLeft} alt="Previous" />
        </button>

        
        <div className="cards-container">
          {reviews.map((review) => (
            <div
              key={review.id}
              className={`review-card ${review.isPrimary ? "primary-card" : "base-card"}`}
            >
              {renderStars(review.isPrimary)}
              <p className="review-text">{review.text}</p>
              <div className="review-footer">
                <span className="review-author">- {review.name}</span>
              </div>
            </div>
          ))}
        </div>

        
        <button className="arrow-btn right-arrow">
          <img src={arrowRight} alt="Next" />
        </button>
      </div>
    </section>
  );
};

export default ReviewSection;