import React from 'react';
import './UserProfile.css';
import janeDoeImg from '../assets/JaneDoe.png';
import editIcon from "../assets/editIcon.png";
import SettingIcon from '../assets/SettingIcon.png';
import leftVector from "../assets/leftvector.png";
import rightVector from "../assets/rightvector.png";
import ellipse from "../assets/Ellipse66.png";
import trueCircle from "../assets/truecircle.png";

import star4 from '../assets/Star4.png'; 
import star5 from '../assets/Star5.png'; 
import r2  from '../assets/r2.png';
import group25 from '../assets/Group25.png';
import group16 from '../assets/Group16.png';
import group26 from '../assets/Group26.png';
import group18 from '../assets/Group18.png';
import group30 from '../assets/Group30.png';
import group17 from '../assets/Group17.png';
import group21 from '../assets/Group21.png';
import group20 from '../assets/Group20.png';
import group27 from '../assets/Group27.png';
import group34 from '../assets/Group34.png';
import group49 from '../assets/Group49.png';
import group52 from '../assets/Group52.png';
import group51 from '../assets/Group51.png';
import group41 from '../assets/Group41.png';
import group40 from '../assets/Group40.png';
import group50 from '../assets/Group50.png';
import group38 from '../assets/Group38.png';
import group35 from '../assets/Group35.png';
import group48 from '../assets/Group48.png';
import group47 from '../assets/Group47.png';
import group46 from '../assets/Group46.png';
import group45 from '../assets/Group45.png';
import group42 from '../assets/Group42.png';
import group43 from '../assets/Group43.png';

import greenheart from '../assets/greenheart.png';
import pinkbook from '../assets/pinkbook.png';
import bluebreathe from '../assets/bluebreathe.png';
import  halfblue from '../assets/halfblue.png';
import  halfgreen  from '../assets/halfgreen.png';
import  halfpink  from '../assets/halfpink.png';

const days = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"];
const UserProfile = () => {
const todayJS = new Date().getDay(); 
const jsDay = new Date().getDay();
const dayMap = {
  6: 0, // Sat
  0: 1, // Sun
  1: 2, // Mon
  2: 3, // Tue
  3: 4, // Wed
  4: 5, // Thu
  5: 6, // Fri
};
const todayIndex = dayMap[jsDay];
console.log("JS Day:", new Date().getDay());
console.log("Today Index:", todayIndex);


const calendarData = [
  { type: 'day', value: '28' },
  { type: 'day', value: '29' },
  { type: 'day', value: '30' },
  { type: 'day', value: '31' },
  { type: 'image', src: group25 }, // Col 5
  { type: 'image', src: group16 }, // Col 6
  { type: 'image', src: group26 }, // Col 7
  
  { type: 'image', src: group18 }, // Row 2, Col 1
  { type: 'image', src: group30 }, // Row 2, Col 2
  { type: 'image', src: group17 }, // Row 2, Col 3
  { type: 'chip', value: 'Tired' }, // Row 2, Col 4
  { type: 'image', src: group21 },
  { type: 'image', src: group20 },
  { type: 'image', src: group27 },

  { type: 'image', src: group34 }, // Row 3
  { type: 'chip', value: 'Stressed' },
  { type: 'image', src: group49 },
  { type: 'image', src: group52 },
  { type: 'image', src: group26 }, 
  { type: 'chip', value: 'Numb' },
  { type: 'image', src: group51 },

  { type: 'image', src: group41 }, // Row 4
  { type: 'image', src: group40 },
  { type: 'chip', value: 'Motivated' },
  { type: 'image', src: group50 },
  { type: 'image', src: group38 },
  { type: 'image', src: group35 },
  { type: 'chip', value: 'Hopeful' },

  { type: 'image', src: group48 }, // Row 5
  { type: 'image', src: group47 },
  { type: 'image', src: group46 },
  { type: 'chip', value: 'Lonely' },
  { type: 'image', src: group45 },
  { type: 'image', src: group42 },
  { type: 'image', src: group43 },
];


  return (
    <div className="profile-page-container">
      
      {/* 1. Header Background with Noise Filter */}
      <div className="user-background">
        <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="440" viewBox="0 0 1440 440" fill="none">
          <g filter="url(#filter0_n_889_1089)">
            <rect width="1440" height="440" fill="url(#paint0_linear_889_1089)"/>
          </g>
          <defs>
            <filter id="filter0_n_889_1089" x="0" y="0" width="1440" height="440" filterUnits="userSpaceOnUse">
              <feTurbulence type="fractalNoise" baseFrequency="10 10" numOctaves="3" result="noise" seed="7515"/>
              <feColorMatrix in="noise" type="luminanceToAlpha" result="alphaNoise"/>
              <feComposite operator="in" in2="SourceGraphic" in="alphaNoise" result="noise1Clipped"/>
              <feFlood flood-color="rgba(26, 52, 16, 0.21)" result="color1Flood"/>
              <feComposite operator="in" in2="noise1Clipped" in="color1Flood" result="color1"/>
              <feMerge>
                <feMergeNode in="SourceGraphic"/>
                <feMergeNode in="color1"/>
              </feMerge>
            </filter>
            <linearGradient id="paint0_linear_889_1089" x1="85.4275" y1="256.828" x2="1610.9" y2="251.871" gradientUnits="userSpaceOnUse">
              <stop stop-color="#7F89E9"/>
              <stop offset="0.504808" stop-color="#A87CC7"/>
              <stop offset="0.9999" stop-color="#658852"/>
            </linearGradient>
          </defs>
        </svg>
      </div>

         <div className="action-buttons">
          <button className="edit-profile-btn">
            <img src={editIcon} alt="edit" width="24" />
            Edit profile
          </button>
          
          <button className="settings-btn">
            
            <img src={SettingIcon} alt="settings" width="24" />
            
          </button>
        </div>

      {/* 2. Profile Info Section */}
     <section className="profile-info-header">
  <div 
    className="profile-pic" 
    style={{ backgroundImage: `url(${janeDoeImg})` }}
  ></div>
  <h1 className="user-name">Jane Doe</h1>
        
     
      </section>

      {/* 3. Today's Reminder */}
      <section className="reminder-section">
        <p className="reminder-title">💡 Today's Reminder:</p>
        <p className="reminder-text">
          "Some days, the bravest thing you'll do is simply keep going and that's enough"
        </p>
      </section>

    {/* 4. Journal Entries */}
<section className="journal-section">
  <div className="journal-header">
    <h2 className="section-title">Journal Entries</h2>
    <div className="date-chip">Jan 2026</div>
  </div>

  <div className="week-journal-container">

    {/* Left Arrow */}
    <img src={leftVector} alt="left" className="nav-arrow" />

    {/* Days */}
     <div className="days-wrapper">
  {days.map((day, index) => {
   const isActive =
  index === todayIndex ||
  (todayIndex > 0 && index === todayIndex - 1);


    return (
      <div key={index} className="day-item">
        <div className={`day-pill ${isActive ? "active" : "inactive"}`}>
          <div className="pill-icons">
            <img src={ellipse} alt="" className="ellipse-bg" />
            {isActive && (
              <img src={trueCircle} alt="" className="true-circle" />
            )}
          </div>
        </div>

        <span className="day-name">{day}</span>
      </div>
    );
  })}
</div>



    {/* Right Arrow */}
    <img src={rightVector} alt="right" className="nav-arrow" />

  </div>
</section>

{/* 5. Mood Tracker Section */}
<section className="mood-tracker-section">
<br />

<div className="outer-mood-header">
    <hr className="header-divider" />
    <br />
    <br />
    <h2 className="outer-section-title">Mood Tracker</h2>
  </div>
<br />
<br />
  <div className="calendar-card">
    
    {/* 1. العنوان والأسهم داخل الكارد */}
    <div className="inner-calendar-header">
  <h2 className="inner-section-title">January 2026</h2>
  <div className="mood-nav-icons">
     {/* استخدام الصور الجديدة مباشرة */}
     <img src={star4} alt="prev" className="mood-star-icon" />
     <img src={star5} alt="next" className="mood-star-icon" />
  </div>
</div>

    {/* 2. أسماء الأيام (7 أعمدة) */}
    {["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"].map(day => (
      <div key={day} className="calendar-header-day">{day}</div>
    ))}

    {/* 3. محتوى الجدول */}
    {calendarData.map((item, index) => (
      <div key={index} className="calendar-cell">
        {item.type === 'day' && <span className="inactive-day">{item.value}</span>}
        {item.type === 'chip' && (
          <div className="mood-status-chip">{item.value}</div>
        )}
        {item.type === 'image' && (
          <img src={item.src} alt="mood icon" className="mood-group-img" />
        )}
      </div>
    ))}

    {/* 4. نص الإحصائيات في الأسفل يمتد على كامل العرض */}
    <p className="inner-mood-insight">
      Your mood is 17.8% better than last month
    </p>
  </div>
  <br />
  <br />
<div className="collection-header">
    <h2 className="outer-section-title">Saved Collection</h2>
    <div className="collection-nav">
    
      <img src={r2} alt="r2" className="collection-arrow-icon" />
    </div>
  </div>
  <hr className="header-divider" />
</section>

{/* 6. Habits Progress Section - UPDATED */}
<section className="habits-progress-section">
      <h2 className="mood-title-text">Habits' Progress</h2>

      <div className="habits-container">
        {/* Daily Gratitude */}
        <div className="habit-item">
          <div className="habit-card gratitude-bg">
            <svg className="progress-ring" viewBox="0 0 270 270">
              <circle
                className="progress-ring-circle progress-ring-bg"
                cx="135"
                cy="135"
                r="115"
              />
              <circle
                className="progress-ring-circle progress-ring-progress gratitude-progress"
                cx="135"
                cy="135"
                r="115"
              />
            </svg>
            <img src={greenheart} alt="Gratitude" className="habit-icon" />
          </div>
          <p className="habit-name gratitude-text">Daily Gratitude</p>
        </div>

        {/* 1 Hour Of Reading */}
        <div className="habit-item">
          <div className="habit-card reading-bg">
            <svg className="progress-ring" viewBox="0 0 270 270">
              <circle
                className="progress-ring-circle progress-ring-bg"
                cx="135"
                cy="135"
                r="115"
              />
              <circle
                className="progress-ring-circle progress-ring-progress reading-progress"
                cx="135"
                cy="135"
                r="115"
              />
            </svg>
            <img src={pinkbook} alt="Reading" className="habit-icon" />
          </div>
          <p className="habit-name reading-text">1 Hour Of Reading</p>
        </div>

        {/* Breathing Exercises */}
        <div className="habit-item">
          <div className="habit-card breathing-bg">


            <svg className="progress-ring" viewBox="0 0 270 270">
              <circle
                className="progress-ring-circle progress-ring-bg"
                cx="135"
                cy="135"
                r="115"
              />
              <circle
                className="progress-ring-circle progress-ring-progress breathing-progress"
                cx="135"
                cy="135"
                r="115"
              />

            </svg>
            <div className="breathing-icon-placeholder">
              <img src={bluebreathe} alt="breathing" className= "habit-icon"/>
            </div>
          </div>
          <p className="habit-name breathing-text">Breathing Exercises</p>
        </div>


      </div>
    </section>

    </div>
  );
};

export default UserProfile;