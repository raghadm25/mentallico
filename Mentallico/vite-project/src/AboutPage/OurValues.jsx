import React from "react";
import "./OurValues.css";

import heartIcon from "../assets/heart (2).png";
import handshakeIcon from "../assets/handshake (2).png";
import aiIcon from "../assets/elements.png";

const valuesData = [
  {
    id: 1,
    icon: heartIcon,
    title: "Compassion First",
    text:
      "We lead with empathy, always putting people's emotions and needs at the center.",
  },
  {
    id: 2,
    icon: handshakeIcon,
    title: "Accessibility for All",
    text:
      "Mental health care should not be a privilege — it should be available anytime, anywhere, for everyone.",
  },
  {
    id: 3,
    icon: aiIcon,
    title: "Human + AI Harmony",
    text:
      "We believe in the balance of technology and human care, ensuring support is instant yet genuinely human when it matters most.",
  },
];

const OurValues = () => {
  return (
    <section className="our-values">
      <h2 className="our-values-title">Our Values</h2>

      <div className="values-cards">
        {valuesData.map((item) => (
          <div key={item.id} className="value-card">
            <div className="value-icon">
              <img src={item.icon} alt={item.title} />
            </div>

            <h3 className="value-title">{item.title}</h3>
            <p className="value-text">{item.text}</p>
          </div>
        ))}
      </div>
    </section>
  );
};

export default OurValues;