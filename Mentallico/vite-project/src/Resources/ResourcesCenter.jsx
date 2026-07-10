import React, { useRef, useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import whereToStartImg from '../assets/WhereToStart.png';
import bodyKeepsScoreImg from '../assets/TheBodyKeepstheScore.png';
import maybeTalkImg from '../assets/MaybeYouShouldTalk.png';
import psychologyPodcastImg from '../assets/ThePsychologyPodcast.png';
import mentalIllnessImg from '../assets/MentalIllnessHour.png';
import psychology20sImg from '../assets/PsychologyOfYour20s.png';
import therapyThoughtsImg from '../assets/TherapyThoughts.png';
import quitSmokingTileImg from '../assets/quitsmokeing1.png';
import meditationTileImg from '../assets/meditation1.png';
import workoutTileImg from '../assets/workout1.png';
import dailyGratitudeTileImg from '../assets/daily1.png';
import {
  isLoggedIn,
  listResourcesByTag,
  listSavedResources,
  saveResource,
  unsaveResource,
  listHabits,
  createOrGetHabit,
} from '../services/api';
import './ResourcesCenter.css';

const ResourcesCenter = () => {
 
  const booksRef = useRef(null);
  const podcastRef = useRef(null);
  const tedRef = useRef(null);
  const navigate = useNavigate();

  const scroll = (ref, direction) => {
    if (direction === 'left') {
      ref.current.scrollBy({ left: -350, behavior: 'smooth' });
    } else {
      ref.current.scrollBy({ left: 350, behavior: 'smooth' });
    }
  };


 const books = [
  {
    id: 1,
    slug: "where-to-start",
    title: "Where To Start",
    author: "MHA",
    img: whereToStartImg, 
    link: "https://www.goodreads.com/book/show/61612877-where-to-start"
  },
  {
    id: 2,
    slug: "the-body-keeps-the-score",
    title: "The Body Keeps the Score",
    author: "Bessel",
    img: bodyKeepsScoreImg,
    link: "https://www.goodreads.com/book/show/18693771-the-body-keeps-the-score"
  },
  {
    id: 3,
    slug: "maybe-you-should-talk",
    title: "Maybe You Should Talk",
    author: "Lori",
    img: maybeTalkImg,
    link: "https://www.goodreads.com/book/show/37570546-maybe-you-should-talk-to-someone"
  },
  {
    id: 4,
    slug: "reasons-to-stay-alive",
    title: "Reasons to Stay Alive",
    author: "Matt Haig",
    img: "https://covers.openlibrary.org/b/isbn/9780143128724-L.jpg",
    link: "https://www.goodreads.com/book/show/25733573-reasons-to-stay-alive"
  },
  {
    id: 5,
    slug: "lost-connections",
    title: "Lost Connections",
    author: "Johann Hari",
    img: "https://covers.openlibrary.org/b/isbn/9781632868305-L.jpg",
    link: "https://www.goodreads.com/book/show/34921573-lost-connections"
  },
];

  // Maps a book's local `slug` to the backend Article id / SavedResource id
  // so the heart button can call the real /resources/saved/ endpoint.
  const [savedState, setSavedState] = useState({}); // { [slug]: { articleId, savedResourceId, pending } }

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const articles = await listResourcesByTag('community_picks');
        let savedByArticleId = {};
        if (isLoggedIn()) {
          const saved = await listSavedResources();
          savedByArticleId = Object.fromEntries(
            saved.map((s) => [s.article.id, s.id])
          );
        }
        if (cancelled) return;
        const next = {};
        for (const article of articles) {
          next[article.slug] = {
            articleId: article.id,
            savedResourceId: savedByArticleId[article.id] || null,
            pending: false,
          };
        }
        setSavedState(next);
      } catch {
        // Resource save-state is a non-critical enhancement — leave hearts
        // inactive rather than breaking the page if this fetch fails.
      }
    })();
    return () => { cancelled = true; };
  }, []);

  const handleToggleSave = async (book) => {
    if (!isLoggedIn()) { navigate('/login'); return; }
    const entry = savedState[book.slug];
    if (!entry || !entry.articleId || entry.pending) return;

    setSavedState((prev) => ({ ...prev, [book.slug]: { ...entry, pending: true } }));
    try {
      if (entry.savedResourceId) {
        await unsaveResource(entry.savedResourceId);
        setSavedState((prev) => ({
          ...prev,
          [book.slug]: { ...entry, savedResourceId: null, pending: false },
        }));
      } else {
        const saved = await saveResource(entry.articleId);
        setSavedState((prev) => ({
          ...prev,
          [book.slug]: { ...entry, savedResourceId: saved.id, pending: false },
        }));
      }
    } catch {
      setSavedState((prev) => ({ ...prev, [book.slug]: { ...entry, pending: false } }));
    }
  };

  // Maps a habit's display name (e.g. "Workout") to its live backend record,
  // once one exists for the current user. Boxes with no matching record yet
  // are just not-started — clicking one creates it, then sends the user to
  // the User Profile page's Habits' Progress section, which is the single
  // canonical place to view/adjust progress, mark days done, or remove it.
  const [habitsByName, setHabitsByName] = useState({});
  const [togglingHabit, setTogglingHabit] = useState(null);

  useEffect(() => {
    if (!isLoggedIn()) return;
    listHabits()
      .then((habits) => {
        setHabitsByName(Object.fromEntries(habits.map((h) => [h.name, h])));
      })
      .catch(() => {});
  }, []);

  const handleGoToHabit = async (name, iconKey) => {
    if (!isLoggedIn()) { navigate('/login'); return; }
    if (togglingHabit) return;

    setTogglingHabit(name);
    try {
      const habit = habitsByName[name] || (await createOrGetHabit(name, iconKey));
      navigate('/UserProfile', { state: { focusHabitName: habit.name } });
    } catch {
      // Non-critical enhancement — stay on this page if this fails.
    } finally {
      setTogglingHabit(null);
    }
  };

const podcasts = [
  { 
    id: 1, 
    title: "The Psychology Podcast", 
    img: psychologyPodcastImg, 
    link: "https://podcasts.apple.com/gb/podcast/the-psychology-podcast/id942777522" 
  },
  { 
    id: 2, 
    title: "Mental Illness Hour", 
    img: mentalIllnessImg, 
    link: "https://podcasts.apple.com/gb/podcast/mental-illness-happy-hour/id427377900" 
  },
  { 
    id: 3, 
    title: "Psychology Of Your 20s", 
    img: psychology20sImg, 
    link: "https://podcasts.apple.com/gb/podcast/the-psychology-of-your-20s/id1573710078" 
  },
  {
    id: 4,
    title: "Therapy Thoughts",
    img: therapyThoughtsImg,
    link: "https://podcasts.apple.com/gb/podcast/what-your-therapist-thinks/id1837783166"
  },
];

const tedTalks = [
  {
    id: 1,
    title: "How to manage your mental health",
    speaker: "Leon Taylor",
    channel: "TEDxClapham",
    thumbnail: "https://img.youtube.com/vi/rkZl2gsLUp4/hqdefault.jpg",
    link: "https://www.youtube.com/watch?v=rkZl2gsLUp4",
  },
  {
    id: 2,
    title: "How to talk to the worst parts of yourself",
    speaker: "Karen Faith",
    channel: "TEDxKC",
    thumbnail: "https://img.youtube.com/vi/gUV5DJb6KGs/hqdefault.jpg",
    link: "https://www.youtube.com/watch?v=gUV5DJb6KGs",
  },
  {
    id: 3,
    title: "How to make stress your friend",
    speaker: "Kelly McGonigal",
    channel: "TEDGlobal",
    thumbnail: "https://img.youtube.com/vi/RcGyVTAoXEU/hqdefault.jpg",
    link: "https://www.youtube.com/watch?v=RcGyVTAoXEU",
  },
  {
    id: 4,
    title: "There's no shame in taking care of your mental health",
    speaker: "Sangu Delle",
    channel: "TED",
    thumbnail: "https://img.youtube.com/vi/BvpmZktlBFs/hqdefault.jpg",
    link: "https://www.youtube.com/watch?v=BvpmZktlBFs",
  },
];

  return (
    <div className="resources-page-wrapper">
      
      {/* 1. رسالة الترحيب - في البداية خالص */}
      <header className="res-header">
        <h1>Welcome to <span className="brand-color">Mentallico</span> <br/> Resources Center</h1>
      </header>

      {/* 2. What we offer - تحت الترحيب مباشرة بنفس ألوان  */}
      <section className="offers-section">
        <h3 className="section-title">What we offer</h3>
        <div className="offers-grid">
          
          <div className="offer-card purple-bg">
            <div className="offer-icon">
              {<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64" fill="none">
  <path d="M23.9997 13.3333C23.9997 12.626 23.7187 11.9478 23.2186 11.4477C22.7185 10.9476 22.0403 10.6666 21.333 10.6666H15.9997C15.2924 10.6666 14.6142 10.9476 14.1141 11.4477C13.614 11.9478 13.333 12.626 13.333 13.3333V50.6666C13.333 51.3739 13.614 52.0521 14.1141 52.5522C14.6142 53.0523 15.2924 53.3333 15.9997 53.3333H21.333C22.0403 53.3333 22.7185 53.0523 23.2186 52.5522C23.7187 52.0521 23.9997 51.3739 23.9997 50.6666M23.9997 13.3333V50.6666M23.9997 13.3333C23.9997 12.626 24.2806 11.9478 24.7807 11.4477C25.2808 10.9476 25.9591 10.6666 26.6663 10.6666H31.9997C32.7069 10.6666 33.3852 10.9476 33.8853 11.4477C34.3854 11.9478 34.6663 12.626 34.6663 13.3333V50.6666C34.6663 51.3739 34.3854 52.0521 33.8853 52.5522C33.3852 53.0523 32.7069 53.3333 31.9997 53.3333H26.6663C25.9591 53.3333 25.2808 53.0523 24.7807 52.5522C24.2806 52.0521 23.9997 51.3739 23.9997 50.6666M13.333 21.3333H23.9997M23.9997 42.6666H34.6663" stroke="#D2D5DE" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M37.3326 24L47.9992 21.3334M42.6659 42.6667L53.1272 40.0534M36.8072 12.16L42.6312 10.7467C44.1299 10.3867 45.6526 11.2534 46.0499 12.6987L55.9032 48.48C56.0771 49.1351 56.0001 49.8315 55.6874 50.4327C55.3746 51.034 54.8487 51.4969 54.2126 51.7307L53.8579 51.84L48.0339 53.2534C46.5352 53.6134 45.0126 52.7467 44.6152 51.3014L34.7619 15.52C34.5881 14.865 34.665 14.1686 34.9778 13.5673C35.2905 12.966 35.8164 12.5032 36.4526 12.2694L36.8072 12.16Z" stroke="#D2D5DE" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
</svg>}
              {/* <svg width="45" height="45" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="1.5"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg> */}
            </div>
            <p>Books and articles carefully chosen to help you understand your emotions</p>
          </div>

          <div className="offer-card grey-bg">
            <div className="offer-icon">
              {<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64" fill="none">
  <path d="M34.6663 45.3333C34.6663 44.626 34.3854 43.9478 33.8853 43.4477C33.3852 42.9476 32.7069 42.6666 31.9997 42.6666C31.2924 42.6666 30.6142 42.9476 30.1141 43.4477C29.614 43.9478 29.333 44.626 29.333 45.3333L30.6663 57.3333C30.6663 57.6869 30.8068 58.0261 31.0569 58.2761C31.3069 58.5262 31.6461 58.6666 31.9997 58.6666C32.3533 58.6666 32.6924 58.5262 32.9425 58.2761C33.1925 58.0261 33.333 57.6869 33.333 57.3333L34.6663 45.3333Z" fill="#A87CC7" stroke="#A87CC7" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M44.9333 49.5466C49.3051 46.7499 52.6525 42.6115 54.4737 37.7518C56.2949 32.8921 56.4918 27.573 55.0349 22.592C53.5779 17.6109 50.5456 13.2363 46.3927 10.1241C42.2397 7.01183 37.1897 5.32959 32 5.32959C26.8103 5.32959 21.7603 7.01183 17.6073 10.1241C13.4544 13.2363 10.4221 17.6109 8.96515 22.592C7.50821 27.573 7.70511 32.8921 9.52633 37.7518C11.3475 42.6115 14.6949 46.7499 19.0667 49.5466" stroke="#A87CC7" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M21.3337 37.3333C19.848 35.3524 18.9432 32.9969 18.7209 30.5307C18.4985 28.0646 18.9673 25.5852 20.0746 23.3705C21.182 21.1557 22.8842 19.2931 24.9906 17.9913C27.0969 16.6895 29.5242 16 32.0003 16C34.4765 16 36.9037 16.6895 39.0101 17.9913C41.1164 19.2931 42.8187 21.1557 43.926 23.3705C45.0334 25.5852 45.5022 28.0646 45.2798 30.5307C45.0574 32.9969 44.1527 35.3524 42.667 37.3333" stroke="#A87CC7" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M31.9997 32C33.4724 32 34.6663 30.8061 34.6663 29.3333C34.6663 27.8605 33.4724 26.6666 31.9997 26.6666C30.5269 26.6666 29.333 27.8605 29.333 29.3333C29.333 30.8061 30.5269 32 31.9997 32Z" fill="#A87CC7" stroke="#A87CC7" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
</svg>}
              {/* <svg width="45" height="45" viewBox="0 0 24 24" fill="none" stroke="#7F89E9" strokeWidth="1.5"><circle cx="12" cy="12" r="9"/><path d="M12 8v8M8 12h8"/></svg> */}
            </div>
            <p>Podcasts and short audio exercises for moments when reading feels too heavy.</p>
          </div>

          <div className="offer-card purple-bg">
            <div className="offer-icon">
              {<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64" fill="none">
  <path d="M29.3335 5.33337C34.514 5.33258 39.5178 7.21686 43.4109 10.6345C47.3041 14.0522 49.8206 18.7698 50.4909 23.9067L56.4909 33.344C56.8855 33.9654 56.8055 34.8907 55.8909 35.2854L50.6669 37.52V45.3334C50.6669 46.7479 50.105 48.1044 49.1048 49.1046C48.1046 50.1048 46.748 50.6667 45.3335 50.6667H40.0029L40.0002 58.6667H16.0002V48.816C16.0002 45.6694 14.8375 42.6907 12.6802 40.0027C10.1674 36.8653 8.59214 33.0817 8.13591 29.088C7.67968 25.0943 8.36105 21.053 10.1015 17.4297C11.842 13.8063 14.5707 10.7485 17.9733 8.60835C21.3759 6.46823 25.3139 5.33297 29.3335 5.33337ZM27.9202 20.7014C27.0402 19.8511 25.8615 19.3805 24.6379 19.3909C23.4143 19.4013 22.2438 19.8918 21.3784 20.7569C20.5129 21.622 20.0219 22.7923 20.011 24.0159C20.0002 25.2395 20.4703 26.4184 21.3202 27.2987L29.3335 35.3147L37.3469 27.2987C37.7925 26.8681 38.1479 26.3531 38.3924 25.7837C38.6368 25.2143 38.7654 24.6019 38.7707 23.9823C38.776 23.3627 38.6578 22.7482 38.423 22.1747C38.1882 21.6012 37.8416 21.0803 37.4034 20.6422C36.9651 20.2041 36.444 19.8577 35.8704 19.6232C35.2969 19.3886 34.6823 19.2707 34.0627 19.2762C33.4431 19.2817 32.8307 19.4106 32.2614 19.6553C31.6921 19.9 31.1773 20.2556 30.7469 20.7014L29.3335 22.1147L27.9202 20.7014Z" fill="#D2D5DE"/>
</svg>}
              {/* <svg width="45" height="45" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="1.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg> */}
            </div>
            <p>Get resource suggestions based on how you're feeling in the moment.</p>
          </div>

        </div>
      </section>

      
      <section className="res-section">
        <div className="res-section-top">
          <h3>Books That Understand You</h3>
          <div className="slider-controls">
            <button className="arrow-btn" onClick={() => scroll(booksRef, 'left')}>❮</button>
            <button className="arrow-btn" onClick={() => scroll(booksRef, 'right')}>❯</button>
          </div>
        </div>
        <div className="horizontal-list" ref={booksRef}>
          {books.map(book => (
            <a href={book.link} target="_blank" rel="noopener noreferrer" className="card-item" key={book.id}>
              <div className="img-container">
                <img src={book.img} alt={book.title} />
                <button
                  type="button"
                  className={`heart-btn${savedState[book.slug]?.savedResourceId ? ' saved' : ''}`}
                  disabled={savedState[book.slug]?.pending}
                  onClick={(e) => {
                    e.preventDefault();
                    e.stopPropagation();
                    handleToggleSave(book);
                  }}
                >
                  ❤
                </button>
              </div>
              <div className="card-info">
                <h4>{book.title}</h4>
                <p>{book.author}</p>
              </div>
            </a>
          ))}
        </div>
        <a
          href="https://www.goodreads.com/shelf/show/mental-health"
          target="_blank"
          rel="noopener noreferrer"
          className="see-more-link"
        >
          See More →
        </a>
      </section>


      <section className="res-section">
        <div className="res-section-top">
          <h3>Top podcasts</h3>
          <div className="slider-controls">
            <button className="arrow-btn" onClick={() => scroll(podcastRef, 'left')}>❮</button>
            <button className="arrow-btn" onClick={() => scroll(podcastRef, 'right')}>❯</button>
          </div>
        </div>
        <div className="horizontal-list" ref={podcastRef}>
          {podcasts.map(pod => (
            <a href={pod.link} target="_blank" rel="noopener noreferrer" className="card-item square-card" key={pod.id}>
              <div className="img-container">
                <img src={pod.img} alt={pod.title} />
              </div>
              <div className="card-info">
                <h4>{pod.title}</h4>
              </div>
            </a>
          ))}
        </div>
        <a
          href="https://podcasts.apple.com/us/genre/1517"
          target="_blank"
          rel="noopener noreferrer"
          className="see-more-link"
        >
          See More →
        </a>
      </section>

      <section className="res-section">
        <div className="res-section-top">
          <h3>Our Favorite TED Talks This Month</h3>
          <div className="slider-controls">
            <button className="arrow-btn" onClick={() => scroll(tedRef, 'left')}>❮</button>
            <button className="arrow-btn" onClick={() => scroll(tedRef, 'right')}>❯</button>
          </div>
        </div>
        <div className="horizontal-list" ref={tedRef}>
          {tedTalks.map(talk => (
            <a href={talk.link} target="_blank" rel="noopener noreferrer" className="card-item wide-card" key={talk.id}>
              <div className="img-container">
                <img src={talk.thumbnail} alt={talk.title} />
              </div>
              <div className="card-info">
                <h4>{talk.title} | {talk.speaker} | {talk.channel}</h4>
              </div>
            </a>
          ))}
        </div>
        <a
          href="https://www.ted.com/topics/mental+health"
          target="_blank"
          rel="noopener noreferrer"
          className="see-more-link"
        >
          See More →
        </a>
      </section>


      {/* 5. Habits Section */}
      <section className="habits-section">
        <h3>Start and Quit Habits with Mentallico</h3>
        <div className="habits-grid">
          <button
            type="button"
            className={`habit-tile-img-btn${(habitsByName['Quit Smoking']?.progress >= 100) ? ' completed' : ''}`}
            onClick={() => handleGoToHabit('Quit Smoking', 'smoking')}
            disabled={togglingHabit === 'Quit Smoking'}
          >
            <img src={quitSmokingTileImg} alt="Quit Smoking" className="habit-tile-img" />
            {(habitsByName['Quit Smoking']?.progress >= 100) && <span className="habit-check-badge">✓</span>}
          </button>
          <button
            type="button"
            className={`habit-tile-img-btn${(habitsByName['Do Meditation Exercises']?.progress >= 100) ? ' completed' : ''}`}
            onClick={() => handleGoToHabit('Do Meditation Exercises', 'meditation')}
            disabled={togglingHabit === 'Do Meditation Exercises'}
          >
            <img src={meditationTileImg} alt="Do Meditation Exercises" className="habit-tile-img" />
            {(habitsByName['Do Meditation Exercises']?.progress >= 100) && <span className="habit-check-badge">✓</span>}
          </button>
          <button
            type="button"
            className={`habit-tile-img-btn${(habitsByName['Workout']?.progress >= 100) ? ' completed' : ''}`}
            onClick={() => handleGoToHabit('Workout', 'workout')}
            disabled={togglingHabit === 'Workout'}
          >
            <img src={workoutTileImg} alt="Workout" className="habit-tile-img" />
            {(habitsByName['Workout']?.progress >= 100) && <span className="habit-check-badge">✓</span>}
          </button>
          <button
            type="button"
            className={`habit-tile-img-btn${(habitsByName['Daily Gratitude']?.progress >= 100) ? ' completed' : ''}`}
            onClick={() => handleGoToHabit('Daily Gratitude', 'gratitude')}
            disabled={togglingHabit === 'Daily Gratitude'}
          >
            <img src={dailyGratitudeTileImg} alt="Daily Gratitude" className="habit-tile-img" />
            {(habitsByName['Daily Gratitude']?.progress >= 100) && <span className="habit-check-badge">✓</span>}
          </button>
        </div>
      </section>

    </div>
  );
};

export default ResourcesCenter;