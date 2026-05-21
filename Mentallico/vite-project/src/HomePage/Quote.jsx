import React from "react";
import { FaQuoteLeft, FaQuoteRight } from "react-icons/fa";
import "./Quote.css";

const Quote = () => {
  return (
    <section className="quote-section">
      <div className="quote-container">
        
        <FaQuoteLeft className="quote-icon left" />
        
        <p className="quote-text">
          “Healing doesn’t mean the damage never existed. <br />
          It means it no longer controls your life.”
        </p>
        
        <FaQuoteRight className="quote-icon right" />
      </div>
    </section>
  );
};

export default Quote;