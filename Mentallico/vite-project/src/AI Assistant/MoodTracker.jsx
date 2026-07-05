import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import angryIcon from '../assets/MoodAngry.svg';
import sadIcon from '../assets/MoodSad.svg';
import neutralIcon from '../assets/MoodNeutral.svg';
import contentIcon from '../assets/MoodContent.svg';
import fantasticIcon from '../assets/MoodFantastic.svg';
import './MoodTracker.css';

const MoodTracker = () => {
  const navigate = useNavigate();
  const [selectedFeeling, setSelectedFeeling] = useState(null);

  const feelings = [
    { id: 1, label: 'angry', icon: angryIcon },
    { id: 2, label: 'sad', icon: sadIcon },
    { id: 3, label: 'neutral', icon: neutralIcon },
    { id: 4, label: 'content', icon: contentIcon },
    { id: 5, label: 'fantastic', icon: fantasticIcon },
  ];

  const tags = ['Grateful', 'Tired', 'Lonely', 'Motivated', 'Overwhelmed', 'Confused', 'Stressed', 'Numb', 'Hopeful'];

  return (
    <div className="outer-bg">
      <div className="main-wrapper">
        <h1 className="title">How are you feeling today?</h1>

        <div className="brains-row">
          {feelings.map((f) => (
            <div
              key={f.id}
              className={`brain-item ${selectedFeeling === f.label ? 'selected' : ''}`}
              onClick={() => setSelectedFeeling(f.label)}
            >
              <img src={f.icon} alt={f.label} draggable="false" />
            </div>
          ))}
        </div>

        <div className="tags-container">
          {tags.map(tag => (
            <button
              key={tag}
              className={`tag ${selectedFeeling === tag.toLowerCase() ? 'active-tag' : ''}`}
              onClick={() => setSelectedFeeling(tag.toLowerCase())}
            >
              {tag}
            </button>
          ))}
        </div>

        <button className="chat-btn" onClick={() => navigate('/chat')}>
          Let's Start
        </button>
      </div>
    </div>
  );
};

export default MoodTracker;
