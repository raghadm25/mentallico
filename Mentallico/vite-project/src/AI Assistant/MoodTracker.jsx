import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './MoodTracker.css';


const BrainBase = ({ color = "#C77A9C" }) => (
  <g fill={color}>
    <circle cx="30" cy="55" r="16" />
    <circle cx="45" cy="40" r="18" />
    <circle cx="65" cy="35" r="20" />
    <circle cx="85" cy="45" r="18" />
    <circle cx="95" cy="60" r="16" />
    <circle cx="80" cy="75" r="15" />
    <circle cx="55" cy="78" r="17" />
    <circle cx="35" cy="72" r="15" />
    <rect x="30" y="45" width="60" height="30" />
  </g>
);


const AngrySVG = () => (
  <svg width="102" height="80" viewBox="0 0 102 80" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M51 10C35 10 20 20 15 35C5 35 2 45 2 55C2 65 10 75 25 75H77C92 75 100 65 100 55C100 45 97 35 87 35C82 20 67 10 51 10Z" fill="#C77A9C"/>
   
    <path d="M30 35C35 30 45 30 51 35M72 35C67 30 57 30 51 35M20 50C25 45 35 45 40 50M82 50C77 45 67 45 62 50" stroke="#9E5072" strokeWidth="1.5" strokeLinecap="round" opacity="0.6"/>
    
    <path d="M35 40L45 46" stroke="#333333" strokeWidth="3" strokeLinecap="round"/>
    <path d="M67 40L57 46" stroke="#333333" strokeWidth="3" strokeLinecap="round"/>
    <path d="M43 65C43 65 47 60 51 60C55 60 59 65 59 65" stroke="#333333" strokeWidth="3" strokeLinecap="round"/>
  </svg>
);


const SadSVG = () => (
  <svg width="102" height="80" viewBox="0 0 102 80" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M51 10C35 10 20 20 15 35C5 35 2 45 2 55C2 65 10 75 25 75H77C92 75 100 65 100 55C100 45 97 35 87 35C82 20 67 10 51 10Z" fill="#C77A9C"/>
    <path d="M30 35C35 30 45 30 51 35M72 35C67 30 57 30 51 35" stroke="#9E5072" strokeWidth="1.5" strokeLinecap="round" opacity="0.6"/>
    <circle cx="40" cy="45" r="3" fill="#333333"/>
    <circle cx="62" cy="45" r="3" fill="#333333"/>
    <path d="M40 52V58" stroke="#75D3F0" strokeWidth="3" strokeLinecap="round"/> {/* الدمعة */}
    <path d="M45 65C45 65 50 60 55 60C60 60 65 65 65 65" stroke="#333333" strokeWidth="2.5" strokeLinecap="round"/>
  </svg>
);


const ContentSVG = () => (
  <svg width="102" height="80" viewBox="0 0 102 80" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M51 10C35 10 20 20 15 35C5 35 2 45 2 55C2 65 10 75 25 75H77C92 75 100 65 100 55C100 45 97 35 87 35C82 20 67 10 51 10Z" fill="#C77A9C"/>
    <path d="M30 35C35 30 45 30 51 35M72 35C67 30 57 30 51 35" stroke="#9E5072" strokeWidth="1.5" strokeLinecap="round" opacity="0.6"/>
    <path d="M35 45C35 45 40 40 45 45" stroke="#333333" strokeWidth="3" strokeLinecap="round"/>
    <path d="M57 45C57 45 62 40 67 45" stroke="#333333" strokeWidth="3" strokeLinecap="round"/>
    <path d="M45 62C45 62 51 68 57 62" stroke="#333333" strokeWidth="3" strokeLinecap="round"/>
  </svg>
);


const NeutralSVG = () => (
  <svg width="102" height="80" viewBox="0 0 102 80" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M51 10C35 10 20 20 15 35C5 35 2 45 2 55C2 65 10 75 25 75H77C92 75 100 65 100 55C100 45 97 35 87 35C82 20 67 10 51 10Z" fill="#C77A9C"/>
    <path d="M30 35C35 30 45 30 51 35M72 35C67 30 57 30 51 35" stroke="#9E5072" strokeWidth="1.5" strokeLinecap="round" opacity="0.6"/>
    <circle cx="42" cy="48" r="3.5" fill="#333333"/>
    <circle cx="60" cy="48" r="3.5" fill="#333333"/>
    <rect x="42" y="62" width="18" height="4" rx="2" fill="#333333"/>
  </svg>
);


const FantasticSVG = () => (
  <svg width="102" height="80" viewBox="0 0 102 80" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M51 10C35 10 20 20 15 35C5 35 2 45 2 55C2 65 10 75 25 75H77C92 75 100 65 100 55C100 45 97 35 87 35C82 20 67 10 51 10Z" fill="#C77A9C"/>
    <path d="M30 35C35 30 45 30 51 35M72 35C67 30 57 30 51 35" stroke="#9E5072" strokeWidth="1.5" strokeLinecap="round" opacity="0.6"/>
    <path d="M40 38L43 45H50L44 49L46 56L40 52L34 56L36 49L30 45H37L40 38Z" fill="#FFE991"/>
    <path d="M62 38L65 45H72L66 49L68 56L62 52L56 56L58 49L52 45H59L62 38Z" fill="#FFE991"/>
    <path d="M42 65C42 65 51 72 60 65" stroke="#333333" strokeWidth="4" strokeLinecap="round"/>
  </svg>
);

const MoodTracker = () => {
  const navigate = useNavigate();
  const [selectedFeeling, setSelectedFeeling] = useState(null);


  const feelings = [
    { id: 1, label: 'angry', component: <AngrySVG /> },
    { id: 2, label: 'sad', component: <SadSVG /> },
    { id: 3, label: 'content', component: <ContentSVG /> },
    { id: 4, label: 'neutral', component: <NeutralSVG /> },
    { id: 5, label: 'fantastic', component: <FantasticSVG /> }
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
              {f.component}
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
  Let’s Start
</button>
      </div>
    </div>
  );
};

export default MoodTracker;