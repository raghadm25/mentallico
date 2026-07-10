import React, { useState } from "react";
import "./ReviewSection.css";

import starPurple from "../assets/Vector.png";
import starWhite from "../assets/Vector 2.png";
import arrowRight from "../assets/weui_arrow-filled (1).png";
import arrowLeft from "../assets/weui_arrow-filled (2).png";

const REVIEWS = [
  {
    id: 1,
    name: "Ahmed, 19",
    text: "“The AI is surprisingly empathetic. And when I needed more, it guided me to a real therapist. Best of both worlds.”",
  },
  {
    id: 2,
    name: "Mariam, 22",
    text: "“It feels like I finally have someone to listen, even at 3 AM. The AI chat keeps me grounded when I need it most.”",
  },
  {
    id: 3,
    name: "Jade, 30",
    text: "“It’s more than an app. It’s like a safe space I can carry in my pocket.”",
  },
  {
    id: 4,
    name: "Youssef, 25",
    text: "“Tracking my mood every day made me realize patterns I never noticed before. It’s changed how I take care of myself.”",
  },
  {
    id: 5,
    name: "Lina, 27",
    text: "“The community section made me feel so much less alone. People actually understand what you’re going through.”",
  },
  {
    id: 6,
    name: "Omar, 21",
    text: "“Booking a real expert through the app felt so much less intimidating than I expected. It was a great first step.”",
  },
  {
    id: 7,
    name: "Sophia, 34",
    text: "“Between work and the kids I never had time for therapy. Now I can check in with myself for five minutes and it actually helps.”",
  },
  {
    id: 8,
    name: "Karim, 23",
    text: "“The breathing exercises talked me down from a panic attack at 2 AM. I didn’t think an app could do that.”",
  },
  {
    id: 9,
    name: "Farida, 29",
    text: "“Journaling used to feel like a chore. Here it feels like a habit I actually want to keep.”",
  },
];

const ReviewSection = () => {
  const [startIndex, setStartIndex] = useState(0);
  const total = REVIEWS.length;

  const visibleReviews = [0, 1, 2].map(
    (offset) => REVIEWS[(startIndex + offset) % total]
  );

  const goPrev = () => {
    setStartIndex((i) => (i - 1 + total) % total);
  };

  const goNext = () => {
    setStartIndex((i) => (i + 1) % total);
  };

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

        <button className="arrow-btn left-arrow" onClick={goPrev} aria-label="Show previous reviews">
          <img src={arrowLeft} alt="Previous" />
        </button>


        <div className="cards-container">
          {visibleReviews.map((review, position) => {
            const isPrimary = position === 1;
            return (
              <div
                key={review.id}
                className={`review-card ${isPrimary ? "primary-card" : "base-card"}`}
              >
                {renderStars(isPrimary)}
                <p className="review-text">{review.text}</p>
                <div className="review-footer">
                  <span className="review-author">- {review.name}</span>
                </div>
              </div>
            );
          })}
        </div>


        <button className="arrow-btn right-arrow" onClick={goNext} aria-label="Show more reviews">
          <img src={arrowRight} alt="Next" />
        </button>
      </div>
    </section>
  );
};

export default ReviewSection;