import React from "react";
import "./ExpertsSection.css"; 
import aliImg from "../assets/AliSamir.png";
import saraImg from "../assets/SaraHany.png";
import mariahImg from "../assets/MariahHolland.png";
import xavierImg from "../assets/XavierRoberto.png";

const ExpertsSection = () => {
  const experts = [
    {
      id: 1,
      name: "Dr. Ali Samir",
      specialty: "Depression & Anxiety",
      image: aliImg,
    },
    {
      id: 2,
      name: "Dr. Sara Hany",
      specialty: "Depression & Stress",
      image: saraImg,
    },
    {
      id: 3,
      name: "Dr. Mariah Holland",
      specialty: "Relationship Counseling",
      image: mariahImg,
    },
    {
      id: 4,
      name: "Dr. Xavier Roberto",
      specialty: "Trauma & PTSD",
      image: xavierImg,
    },
  ];

  return (
    <section className="experts-section">
      <h2>Meet Our Experts</h2>
      <div className="experts-container">
        {experts.map((expert) => (
          <div key={expert.id} className="expert-card">
            <div className="image-wrapper">
              <img src={expert.image} alt={expert.name} />
            </div>
            <h3>{expert.name}</h3>
            <p>{expert.specialty}</p>
          </div>
        ))}
      </div>
    </section>
  );
};

export default ExpertsSection;