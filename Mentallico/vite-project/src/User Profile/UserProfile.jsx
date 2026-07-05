import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
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
import r2 from '../assets/r2.png';

import greenheart from '../assets/greenheart.png';
import pinkbook from '../assets/pinkbook.png';
import bluebreathe from '../assets/bluebreathe.png';

// Brain-mascot mood icons — verified by visual inspection, only 5 distinct
// expressions exist across the Group*.png set, reused here per matching mood.
import starEyesIcon from '../assets/Group21.png';   // star eyes, big open smile — excited
import motivatedIcon from '../assets/Group25.png';  // star eyes, big open smile — excited
import calmIcon from '../assets/Group16.png';       // closed eyes, gentle smile — content
import hopefulIcon from '../assets/Group27.png';    // closed eyes, gentle smile — content
import neutralIcon from '../assets/Group18.png';    // flat mouth, dot eyes — blank/low-energy
import numbIcon from '../assets/Group45.png';       // flat mouth, dot eyes — blank/low-energy
import angryIcon from '../assets/Group20.png';      // furrowed brow, red mark — angry/tense
import anxiousIcon from '../assets/Group41.png';    // furrowed brow, red mark — angry/tense
import cryingIcon from '../assets/Group17.png';     // single tear, sad mouth — crying
import sadIcon from '../assets/Group26.png';        // single tear, sad mouth — crying

import {
  getProfile,
  getJournalWeek,
  saveJournalEntry,
  getMoodCalendar,
  logMood,
  listHabits,
  toggleHabit,
} from '../services/api';

const DAY_LABELS = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"];
const CALENDAR_HEADER_DAYS = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
const RING_CIRCUMFERENCE = 722; // 2 * PI * 115, matches the SVG ring radius in CSS

const HABIT_VISUALS = {
  gratitude: { bgClass: 'gratitude-bg', progressClass: 'gratitude-progress', icon: greenheart, textClass: 'gratitude-text' },
  reading: { bgClass: 'reading-bg', progressClass: 'reading-progress', icon: pinkbook, textClass: 'reading-text' },
  breathing: { bgClass: 'breathing-bg', progressClass: 'breathing-progress', icon: bluebreathe, textClass: 'breathing-text' },
};

const MOOD_OPTIONS = [
  "happy", "calm", "motivated", "hopeful", "tired",
  "stressed", "anxious", "numb", "lonely", "sad",
];

const MOOD_ICONS = {
  happy: starEyesIcon,
  motivated: motivatedIcon,
  calm: calmIcon,
  hopeful: hopefulIcon,
  tired: neutralIcon,
  numb: numbIcon,
  stressed: angryIcon,
  anxious: anxiousIcon,
  lonely: cryingIcon,
  sad: sadIcon,
};

function pad(n) { return String(n).padStart(2, '0'); }

function toISODate(d) {
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

/** Most recent Saturday on/before `d`, matching this page's Sat-first day order. */
function startOfDisplayWeek(d) {
  const start = new Date(d);
  const diff = (start.getDay() + 1) % 7; // days since the last Saturday
  start.setDate(start.getDate() - diff);
  start.setHours(0, 0, 0, 0);
  return start;
}

function buildMonthGrid(year, month) {
  const firstWeekday = new Date(year, month - 1, 1).getDay(); // 0=Sun aligns with Su-first header
  const daysInMonth = new Date(year, month, 0).getDate();
  const daysInPrevMonth = new Date(year, month - 1, 0).getDate();

  const cells = [];
  for (let i = firstWeekday - 1; i >= 0; i--) {
    cells.push({ inMonth: false, day: daysInPrevMonth - i });
  }
  for (let d = 1; d <= daysInMonth; d++) {
    cells.push({ inMonth: true, day: d, date: `${year}-${pad(month)}-${pad(d)}` });
  }
  let nextDay = 1;
  while (cells.length % 7 !== 0) {
    cells.push({ inMonth: false, day: nextDay++ });
  }
  return cells;
}

const UserProfile = () => {
  const navigate = useNavigate();
  const today = new Date();
  const todayISO = toISODate(today);

  // ── Real profile ──────────────────────────────────────────
  const [profile, setProfile] = useState(null);

  useEffect(() => {
    getProfile().then(setProfile).catch(() => {});
  }, []);

  // ── Journal Entries ───────────────────────────────────────
  const [weekStart, setWeekStart] = useState(() => startOfDisplayWeek(today));
  const [journalEntries, setJournalEntries] = useState({}); // { [date]: content }
  const [selectedDate, setSelectedDate] = useState(todayISO);
  const [entryDraft, setEntryDraft] = useState('');
  const [journalSaving, setJournalSaving] = useState(false);

  const weekDates = DAY_LABELS.map((_, i) => {
    const d = new Date(weekStart);
    d.setDate(d.getDate() + i);
    return toISODate(d);
  });

  useEffect(() => {
    getJournalWeek(toISODate(weekStart), 7)
      .then((data) => {
        const map = {};
        data.entries.forEach((e) => { map[e.date] = e.content; });
        setJournalEntries((prev) => ({ ...prev, ...map }));
      })
      .catch(() => {});
  }, [weekStart]);

  useEffect(() => {
    setEntryDraft(journalEntries[selectedDate] || '');
  }, [selectedDate, journalEntries]);

  const handlePrevWeek = () => {
    const d = new Date(weekStart);
    d.setDate(d.getDate() - 7);
    setWeekStart(d);
  };

  const handleNextWeek = () => {
    const d = new Date(weekStart);
    d.setDate(d.getDate() + 7);
    setWeekStart(d);
  };

  const handleSaveEntry = async () => {
    const text = entryDraft.trim();
    if (!text) return;
    setJournalSaving(true);
    try {
      await saveJournalEntry(selectedDate, text);
      setJournalEntries((prev) => ({ ...prev, [selectedDate]: text }));
    } catch {
      // Non-critical inline feature — fail silently, entry just won't persist.
    } finally {
      setJournalSaving(false);
    }
  };

  // ── Mood Tracker calendar ─────────────────────────────────
  const [calendarYear, setCalendarYear] = useState(today.getFullYear());
  const [calendarMonth, setCalendarMonth] = useState(today.getMonth() + 1); // 1-12
  const [moodEntries, setMoodEntries] = useState({}); // { [date]: mood }
  const [moodPickerDate, setMoodPickerDate] = useState(null);

  useEffect(() => {
    getMoodCalendar(calendarYear, calendarMonth)
      .then((data) => {
        const map = {};
        data.entries.forEach((e) => { map[e.date] = e.mood; });
        setMoodEntries(map);
      })
      .catch(() => {});
  }, [calendarYear, calendarMonth]);

  const handlePrevMonth = () => {
    if (calendarMonth === 1) {
      setCalendarMonth(12);
      setCalendarYear((y) => y - 1);
    } else {
      setCalendarMonth((m) => m - 1);
    }
  };

  const handleNextMonth = () => {
    if (calendarMonth === 12) {
      setCalendarMonth(1);
      setCalendarYear((y) => y + 1);
    } else {
      setCalendarMonth((m) => m + 1);
    }
  };

  const handleLogMood = async (mood) => {
    if (!moodPickerDate) return;
    try {
      await logMood(mood, moodPickerDate);
      setMoodEntries((prev) => ({ ...prev, [moodPickerDate]: mood }));
    } catch {
      // Non-critical inline feature — picker just closes without saving.
    } finally {
      setMoodPickerDate(null);
    }
  };

  const monthCells = buildMonthGrid(calendarYear, calendarMonth);
  const monthName = new Date(calendarYear, calendarMonth - 1, 1)
    .toLocaleString('en-US', { month: 'long', year: 'numeric' });

  // ── Habits ─────────────────────────────────────────────────
  const [habits, setHabits] = useState([]);
  const [togglingHabitId, setTogglingHabitId] = useState(null);

  useEffect(() => {
    // This section only has visuals for the 3 core habits — habits started
    // elsewhere (e.g. the Resources page's "Start and Quit Habits" tiles)
    // share the same backend table but shouldn't spill into this list.
    listHabits()
      .then((data) => setHabits(data.filter((h) => h.icon_key in HABIT_VISUALS)))
      .catch(() => {});
  }, []);

  const handleToggleHabit = async (habitId) => {
    if (togglingHabitId) return;
    setTogglingHabitId(habitId);
    try {
      const updated = await toggleHabit(habitId);
      setHabits((prev) => prev.map((h) => (h.id === habitId ? updated : h)));
    } catch {
      // Non-critical inline feature — toggle just doesn't stick.
    } finally {
      setTogglingHabitId(null);
    }
  };

  const displayName = profile
    ? (`${profile.first_name} ${profile.last_name}`.trim() || profile.email)
    : 'Loading…';
  const avatarUrl = profile?.profile_picture || janeDoeImg;

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

      {/* 2. Profile Info Section */}
      <section className="profile-info-header">
        <div className="profile-pic-row">
          <div
            className="profile-pic"
            style={{ backgroundImage: `url(${avatarUrl})` }}
          ></div>

          <div className="profile-action-buttons">
            <button className="edit-profile-btn" onClick={() => navigate('/edit-profile')}>
              <img src={editIcon} alt="edit" width="24" />
              Edit profile
            </button>

            <button className="settings-btn" onClick={() => navigate('/settings')}>
              <img src={SettingIcon} alt="settings" width="24" />
            </button>
          </div>
        </div>
        <h1 className="profile-user-name">{displayName}</h1>
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
          <h2 className="profile-section-title">Journal Entries</h2>
          <div className="date-chip">
            {new Date(weekStart).toLocaleString('en-US', { month: 'short', year: 'numeric' })}
          </div>
        </div>

        <div className="week-journal-container">
          <img
            src={leftVector}
            alt="previous week"
            className="profile-nav-arrow"
            onClick={handlePrevWeek}
            style={{ cursor: 'pointer' }}
          />

          <div className="days-wrapper">
            {DAY_LABELS.map((day, index) => {
              const date = weekDates[index];
              const isSelected = date === selectedDate;
              const hasEntry = !!journalEntries[date];
              return (
                <div key={date} className="day-item" onClick={() => setSelectedDate(date)} style={{ cursor: 'pointer' }}>
                  <div className={`day-pill ${(isSelected || hasEntry) ? "active" : "inactive"}`}>
                    <div className="pill-icons">
                      <img src={ellipse} alt="" className="ellipse-bg" />
                      {hasEntry && (
                        <img src={trueCircle} alt="" className="true-circle" />
                      )}
                    </div>
                  </div>
                  <span className="day-name">{day}</span>
                </div>
              );
            })}
          </div>

          <img
            src={rightVector}
            alt="next week"
            className="profile-nav-arrow"
            onClick={handleNextWeek}
            style={{ cursor: 'pointer' }}
          />
        </div>

        <div className="journal-entry-editor">
          <p className="journal-entry-date">
            {new Date(selectedDate).toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}
          </p>
          <textarea
            className="journal-entry-textarea"
            placeholder="Write about your day…"
            value={entryDraft}
            onChange={(e) => setEntryDraft(e.target.value)}
            rows={3}
          />
          <button
            className="journal-entry-save-btn"
            onClick={handleSaveEntry}
            disabled={journalSaving || !entryDraft.trim()}
          >
            {journalSaving ? 'Saving…' : 'Save entry'}
          </button>
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

          <div className="inner-calendar-header">
            <h2 className="inner-section-title">{monthName}</h2>
            <div className="mood-nav-icons">
              <img src={star4} alt="previous month" className="mood-star-icon" onClick={handlePrevMonth} style={{ cursor: 'pointer' }} />
              <img src={star5} alt="next month" className="mood-star-icon" onClick={handleNextMonth} style={{ cursor: 'pointer' }} />
            </div>
          </div>

          {CALENDAR_HEADER_DAYS.map(day => (
            <div key={day} className="calendar-header-day">{day}</div>
          ))}

          {monthCells.map((cell, index) => (
            <div key={index} className="calendar-cell">
              {cell.inMonth ? (
                moodEntries[cell.date] ? (
                  <button
                    type="button"
                    className="mood-icon-btn"
                    onClick={() => setMoodPickerDate(cell.date)}
                    title={moodEntries[cell.date]}
                  >
                    <img
                      src={MOOD_ICONS[moodEntries[cell.date]]}
                      alt={moodEntries[cell.date]}
                      className="mood-group-img"
                    />
                  </button>
                ) : (
                  <button
                    type="button"
                    className={`inactive-day-btn${cell.date === todayISO ? ' today' : ''}`}
                    onClick={() => setMoodPickerDate(cell.date)}
                  >
                    {cell.day}
                  </button>
                )
              ) : (
                <span className="inactive-day dim">{cell.day}</span>
              )}
            </div>
          ))}

          {moodPickerDate && (
            <div className="mood-picker-overlay" onClick={() => setMoodPickerDate(null)}>
              <div className="mood-picker-panel" onClick={(e) => e.stopPropagation()}>
                <p className="mood-picker-title">
                  How were you feeling on {new Date(moodPickerDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}?
                </p>
                <div className="mood-picker-options">
                  {MOOD_OPTIONS.map((mood) => (
                    <button key={mood} className="mood-picker-option" onClick={() => handleLogMood(mood)}>
                      {mood}
                    </button>
                  ))}
                </div>
                <button className="mood-picker-close" onClick={() => setMoodPickerDate(null)}>Cancel</button>
              </div>
            </div>
          )}

          <p className="inner-mood-insight">
            Tap any day to log or update how you were feeling.
          </p>
        </div>
        <br />
        <br />
        <div className="collection-header">
          <h2 className="outer-section-title">Saved Collection</h2>
          <button type="button" className="collection-nav" onClick={() => navigate('/saved-collection')}>
            <img src={r2} alt="r2" className="collection-arrow-icon" />
          </button>
        </div>
        <hr className="header-divider" />
      </section>

      {/* 6. Habits Progress Section */}
      <section className="habits-progress-section">
        <h2 className="mood-title-text">Habits' Progress</h2>

        <div className="habits-container">
          {habits.map((habit) => {
            const visuals = HABIT_VISUALS[habit.icon_key] || HABIT_VISUALS.gratitude;
            const dashoffset = RING_CIRCUMFERENCE * (1 - habit.completion_rate / 100);
            return (
              <div className="habit-item" key={habit.id}>
                <div
                  className={`habit-card ${visuals.bgClass}${habit.is_completed_today ? ' completed' : ''}`}
                  onClick={() => handleToggleHabit(habit.id)}
                  style={{ cursor: togglingHabitId ? 'default' : 'pointer' }}
                  title={habit.is_completed_today ? 'Completed today — click to undo' : 'Click to mark as done today'}
                >
                  <svg className="progress-ring" viewBox="0 0 270 270">
                    <circle className="progress-ring-circle progress-ring-bg" cx="135" cy="135" r="115" />
                    <circle
                      className={`progress-ring-circle progress-ring-progress ${visuals.progressClass}`}
                      cx="135"
                      cy="135"
                      r="115"
                      style={{ strokeDashoffset: dashoffset }}
                    />
                  </svg>
                  <img src={visuals.icon} alt={habit.name} className="habit-icon" />
                  {habit.is_completed_today && <span className="habit-checkmark">✓</span>}
                </div>
                <p className={`habit-name ${visuals.textClass}`}>{habit.name}</p>
              </div>
            );
          })}
        </div>
      </section>

    </div>
  );
};

export default UserProfile;
