import React, { useRef, useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import whereToStartImg from '../assets/WhereToStart.png';
import bodyKeepsScoreImg from '../assets/TheBodyKeepsTheScore.png';
import maybeTalkImg from '../assets/MaybeYouShouldTalk.png';
import psychologyPodcastImg from '../assets/ThePsychologyPodcast.png';
import mentalIllnessImg from '../assets/MentalIllnessHour.png';
import psychology20sImg from '../assets/PsychologyOfYour20s.png';
import therapyThoughtsImg from '../assets/TherapyThoughts.png';
import {
  isLoggedIn,
  listResourcesByTag,
  listSavedResources,
  saveResource,
  unsaveResource,
  listHabits,
  createOrGetHabit,
  toggleHabit,
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
  // are just not-started — clicking one creates it and marks today done.
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

  const handleToggleHabit = async (name, iconKey) => {
    if (!isLoggedIn()) { navigate('/login'); return; }
    if (togglingHabit) return;

    setTogglingHabit(name);
    try {
      const habit = habitsByName[name] || (await createOrGetHabit(name, iconKey));
      const updated = await toggleHabit(habit.id);
      setHabitsByName((prev) => ({ ...prev, [name]: updated }));
    } catch {
      // Non-critical enhancement — leave the tile as it was if this fails.
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
            className={`habit-box h-green${habitsByName['Quit Smoking']?.is_completed_today ? ' completed' : ''}`}
            onClick={() => handleToggleHabit('Quit Smoking', 'smoking')}
            disabled={togglingHabit === 'Quit Smoking'}
          >
            <div className="habit-svg-holder">{<svg xmlns="http://www.w3.org/2000/svg" width="138" height="138" viewBox="0 0 138 138" fill="none">
  <path d="M97.0312 69H101.344V81.9375H97.0312V69ZM30.1875 81.9375H67.275L54.3375 69H30.1875V81.9375Z" fill="#1A2E12"/>
  <path d="M98.2441 16.1988C98.1363 16.1449 98.0555 16.091 97.9746 16.0371C95.0367 14.4199 91.9102 13.1531 88.7027 12.048L87.2473 11.5629C81.4793 9.73008 75.3609 8.625 69 8.625C35.659 8.625 8.625 35.659 8.625 69C8.625 91.7215 21.1852 111.478 39.7289 121.774C39.8367 121.828 39.9176 121.909 40.0254 121.963C42.9633 123.58 46.0898 124.847 49.2973 125.952L50.7527 126.437C56.5207 128.27 62.6121 129.375 69 129.375C102.341 129.375 129.375 102.341 129.375 69C129.375 46.2785 116.815 26.4949 98.2441 16.1988ZM69 114.928C66.4934 114.928 64.0406 114.686 61.6688 114.281C59.0273 113.85 56.4668 113.176 53.9871 112.314C53.475 112.152 52.9629 111.99 52.4777 111.802C50.7258 111.128 49.0008 110.373 47.3566 109.484C32.9098 101.748 23.0719 86.5195 23.0719 68.973C23.0719 58.9465 26.4141 49.7285 31.8855 42.1816L95.8184 106.114C88.2445 111.586 79.0266 114.928 69 114.928ZM106.141 95.7914L42.2086 31.8586C49.7555 26.4141 58.9465 23.0719 69 23.0719C71.5066 23.0719 73.9324 23.3145 76.3313 23.7188C78.9727 24.15 81.5332 24.8238 84.0129 25.6863C84.498 25.848 85.0102 26.0098 85.5223 26.1984C87.1934 26.8453 88.8105 27.5461 90.3738 28.3816C104.982 36.0633 114.955 51.3727 114.955 69.027C114.928 79.0535 111.586 88.2445 106.141 95.7914Z" fill="#1A2E12"/>
  <path d="M94.8754 80.3205V69.0002H83.5551L94.8754 80.3205ZM103.5 69.0002H107.813V81.9377H103.5V69.0002ZM97.0586 57.3295C94.6867 56.2244 91.1289 55.7932 84.768 55.7932H83.7977C80.3746 55.8201 79.5121 55.7662 78.407 54.149C77.6523 53.017 78.1375 50.16 79.4043 48.2463C79.8355 47.5994 79.8895 46.7369 79.5121 46.0361C79.1348 45.3354 78.407 44.9041 77.6254 44.8771C77.5984 44.8771 75.0918 44.8502 72.693 43.826C69.8359 42.6131 68.4883 40.5646 68.4883 37.5998C68.4883 30.6459 74.3641 30.1338 74.6336 30.1338V25.8213C71.3992 25.8213 64.1758 28.7861 64.1758 37.5998C64.1758 42.3166 66.6016 45.9553 71.1027 47.842C72.2348 48.3002 73.3668 48.6236 74.3371 48.8123C73.4477 51.4537 73.3668 54.4455 74.7953 56.5478C77.2211 60.1326 80.2668 60.1057 83.7707 60.0787H84.7141C91.8027 60.0787 94.0398 60.6986 95.1988 61.2377C96.7352 61.9385 97.0316 64.3373 96.9777 66.5475V66.817H101.29V66.5475C101.29 64.6338 101.371 59.324 97.0586 57.3295Z" fill="#1A2E12"/>
  <path d="M107.812 66.8437C107.812 59.9167 107.004 55.1999 105.36 52.3968C103.042 48.5155 99.3223 46.3593 94.875 46.3593H90.1852C90.9668 44.1222 91.6406 41.0226 91.1285 38.0308C90.266 32.9636 85.9805 29.9448 79.5117 29.9448V34.2573C85.1719 34.2573 86.5465 36.7101 86.8969 38.7585C87.5707 42.6667 85.0641 47.4105 85.0371 47.4644C84.6598 48.1382 84.6867 48.9468 85.0641 49.5937C85.4414 50.2405 86.1691 50.6448 86.9238 50.6448H94.875C97.8129 50.6448 100.104 51.9655 101.64 54.58C102.476 56.0085 103.5 59.2968 103.5 66.8167H107.812V66.8437Z" fill="#1A2E12"/>
</svg>}</div>
            <span className="habit-label">Quit Smoking</span>
            {habitsByName['Quit Smoking']?.is_completed_today && <span className="habit-check-badge">✓</span>}
          </button>
          <button
            type="button"
            className={`habit-box h-purple${habitsByName['Do Meditation Exercises']?.is_completed_today ? ' completed' : ''}`}
            onClick={() => handleToggleHabit('Do Meditation Exercises', 'meditation')}
            disabled={togglingHabit === 'Do Meditation Exercises'}
          >
            <div className="habit-svg-holder">{<svg xmlns="http://www.w3.org/2000/svg" width="153" height="109" viewBox="0 0 153 109" fill="none">
  <path d="M151.018 72.9916C144.946 71.7503 138.776 71.0444 132.581 70.8822C141.294 55.6295 131.589 29.0006 131.13 27.7635C130.594 27.1475 129.909 26.6798 129.14 26.4053C128.371 26.1308 127.545 26.0588 126.74 26.1961C118.894 28.9712 111.448 32.7734 104.598 37.5035C102.834 28.9937 96.9234 9.57903 78.7354 0.27774C78.3901 0.102395 78.0097 0.00758882 77.6226 0.000437114C77.2355 -0.00671459 76.8518 0.0739738 76.5004 0.236446C76.1489 0.0739738 75.7652 -0.00671459 75.3781 0.000437114C74.991 0.00758882 74.6106 0.102395 74.2653 0.27774C56.0773 9.57903 50.1665 28.9937 48.4025 37.5035C41.5523 32.7746 34.1069 28.9736 26.2602 26.1995C25.8133 26.0633 25.3377 26.052 24.8848 26.1669C24.2743 26.0191 23.6309 26.1003 23.0761 26.3951C22.5214 26.69 22.0939 27.178 21.8744 27.767C21.4153 29.004 11.7101 55.6399 20.425 70.8874C14.2279 71.0481 8.05681 71.7523 1.98257 72.9916C1.61249 73.0815 1.26672 73.2518 0.969812 73.4904C0.672899 73.7291 0.432123 74.0302 0.264579 74.3724C0.0970357 74.7147 0.00683205 75.0896 0.000373212 75.4707C-0.00608563 75.8517 0.071359 76.2295 0.227208 76.5772C15.3704 111.831 54.8033 112.606 76.5004 105.355C98.2558 112.6 137.594 111.845 152.773 76.5755C152.929 76.2279 153.006 75.8502 153 75.4694C152.993 75.0886 152.903 74.7138 152.735 74.3718C152.568 74.0298 152.327 73.7289 152.03 73.4903C151.734 73.2518 151.388 73.0815 151.018 72.9916ZM43.8345 96.7403C53.7425 98.8756 61.3382 101.019 66.4891 102.644C51.9872 105.436 21.8417 107.045 6.37011 77.4048C17.841 75.4744 56.7942 71.1919 70.7718 98.5985C62.2859 95.831 53.6556 93.5283 44.9193 91.7009C44.2665 91.5942 43.5976 91.7427 43.0511 92.1156C42.5045 92.4885 42.122 93.0573 41.9827 93.7044C41.8434 94.3516 41.9579 95.0276 42.3026 95.5926C42.6472 96.1576 43.1956 96.5685 43.8345 96.7403ZM73.8596 93.5831C70.6031 88.1445 66.1363 83.5313 60.807 80.1026C47.9486 71.0732 43.8585 60.423 44.1422 60.5452C43.9559 59.8865 43.5158 59.3288 42.9187 58.9948C42.3216 58.6609 41.6163 58.578 40.9581 58.7644C40.2999 58.9508 39.7427 59.3912 39.409 59.9888C39.0753 60.5864 38.9924 61.2921 39.1787 61.9508C40.7128 66.2631 43.0767 70.2327 46.1365 73.6351C39.8107 71.937 33.3034 71.008 26.7554 70.8685C17.6433 60.7912 23.8464 38.369 26.0298 31.5573C33.9352 34.4306 41.3967 38.404 48.1945 43.3603C48.4938 43.7814 48.9133 44.1023 49.398 44.2808C62.1428 53.995 74.8258 69.7208 73.8596 93.5831ZM76.4832 39.2878C75.7992 39.2878 75.1432 39.5597 74.6596 40.0437C74.176 40.5277 73.9043 41.1841 73.9043 41.8686V66.6118C69.1336 56.4698 61.9706 47.6404 53.0325 40.8844C53.9282 35.4888 58.5341 14.2039 76.5004 4.93871C94.4597 14.2039 99.0725 35.4888 99.9682 40.8844C91.0069 47.6587 83.831 56.5172 79.062 66.6927V41.8686C79.062 41.1841 78.7903 40.5277 78.3067 40.0437C77.8231 39.5597 77.1671 39.2878 76.4832 39.2878ZM103.598 44.2773C104.082 44.0988 104.502 43.778 104.801 43.3569C111.599 38.3993 119.061 34.4259 126.967 31.5539C129.154 38.3621 135.369 60.7723 126.24 70.8633C119.694 71.0051 113.189 71.9357 106.866 73.6351C109.925 70.2316 112.288 66.2615 113.822 61.9491C113.997 61.2942 113.908 60.5965 113.574 60.0069C113.239 59.4174 112.686 58.9832 112.034 58.7983C111.382 58.6134 110.684 58.6926 110.09 59.0189C109.496 59.3451 109.054 59.8921 108.86 60.5417C109.135 60.4247 105.095 71.0199 92.1972 80.0975C86.8655 83.5259 82.3974 88.1405 79.1411 93.5814C78.1766 69.7208 90.8596 53.995 103.598 44.2842V44.2773ZM86.5374 102.635C91.6866 101.014 99.2719 98.8721 109.166 96.7403C109.497 96.6691 109.811 96.5332 110.09 96.3406C110.368 96.1479 110.606 95.9022 110.79 95.6175C110.974 95.3328 111.1 95.0146 111.161 94.6812C111.222 94.3478 111.216 94.0057 111.145 93.6743C111.074 93.343 110.938 93.0289 110.746 92.7501C110.553 92.4712 110.308 92.2331 110.023 92.0492C109.739 91.8653 109.421 91.7393 109.088 91.6783C108.754 91.6174 108.413 91.6227 108.081 91.694C99.3449 93.5237 90.7147 95.8286 82.2289 98.5985C96.2082 71.1919 135.163 75.4744 146.629 77.4048C131.188 106.979 101.053 105.408 86.5374 102.635Z" fill="#471C66"/>
</svg>}</div>
            <span className="habit-label habit-label-purple">Do Meditation Exercises</span>
            {habitsByName['Do Meditation Exercises']?.is_completed_today && <span className="habit-check-badge">✓</span>}
          </button>
          <button
            type="button"
            className={`habit-box h-blue${habitsByName['Workout']?.is_completed_today ? ' completed' : ''}`}
            onClick={() => handleToggleHabit('Workout', 'workout')}
            disabled={togglingHabit === 'Workout'}
          >
            <div className="habit-svg-holder">{<svg xmlns="http://www.w3.org/2000/svg" width="139" height="139" viewBox="0 0 139 139" fill="none">
  <path d="M48.6521 127.767C49.1809 128.341 49.4621 129.099 49.4346 129.879C49.4071 130.658 49.0731 131.396 48.5051 131.93L42.1194 137.901C41.5492 138.431 40.792 138.713 40.0142 138.685C39.2364 138.657 38.5015 138.321 37.9711 137.751L0.783006 97.6734C0.254539 97.0997 -0.0261555 96.3406 0.00192045 95.5611C0.0299964 94.7815 0.364574 94.0446 0.932946 93.5104L7.32745 87.548C7.60961 87.2854 7.94076 87.0809 8.30199 86.9462C8.66322 86.8116 9.04744 86.7495 9.43269 86.7634C9.81794 86.7773 10.1967 86.867 10.5472 87.0274C10.8978 87.1878 11.2133 87.4156 11.4758 87.698L48.6521 127.767ZM96.1037 52.3562C96.6322 52.93 96.9128 53.6891 96.8848 54.4686C96.8567 55.2481 96.5221 55.9851 95.9537 56.5193L55.764 94.0631C55.1937 94.5928 54.4366 94.8746 53.6588 94.8465C52.8809 94.8184 52.1461 94.4827 51.6156 93.9131L42.0224 83.5614C41.4939 82.9877 41.2132 82.2286 41.2413 81.4491C41.2694 80.6695 41.604 79.9326 42.1723 79.3984L82.3533 41.8546C82.6352 41.592 82.9661 41.3875 83.3271 41.2529C83.6881 41.1184 84.0721 41.0562 84.4571 41.0702C84.8421 41.0841 85.2206 41.1738 85.5709 41.3341C85.9212 41.4944 86.2365 41.7222 86.4987 42.0045L96.1037 52.3562ZM62.326 114.987C63.4256 116.172 63.358 118.045 62.1761 119.15L55.7816 125.118C55.4994 125.381 55.1683 125.585 54.807 125.72C54.4458 125.855 54.0616 125.917 53.6764 125.903C53.2911 125.889 52.9124 125.799 52.5618 125.639C52.2112 125.479 51.8957 125.251 51.6333 124.968L14.4658 84.8903C13.9369 84.3169 13.6557 83.5581 13.6832 82.7785C13.7108 81.999 14.0448 81.2619 14.6128 80.7272L20.9955 74.762C21.5657 74.2322 22.3229 73.9504 23.1007 73.9786C23.8785 74.0067 24.6134 74.3424 25.1438 74.9119L62.326 114.987ZM124.251 53.7939C124.779 54.368 125.06 55.1273 125.031 55.9069C125.002 56.6864 124.667 57.4231 124.098 57.9569L117.707 63.9251C117.136 64.4555 116.379 64.7378 115.601 64.7103C114.822 64.6827 114.087 64.3475 113.556 63.7781L76.3822 23.7089C75.8526 23.1359 75.5709 22.3768 75.5984 21.5971C75.626 20.8173 75.9605 20.0801 76.5292 19.5458L82.9384 13.5629C83.2203 13.3004 83.5512 13.0959 83.9122 12.9613C84.2732 12.8267 84.6571 12.7646 85.0422 12.7786C85.4272 12.7925 85.8056 12.8822 86.156 13.0425C86.5063 13.2028 86.8216 13.4306 87.0838 13.7129L124.251 53.7939ZM137.905 41.0343C138.433 41.6089 138.713 42.3683 138.685 43.1481C138.657 43.9278 138.323 44.6652 137.755 45.2003L131.375 51.1655C131.093 51.4283 130.762 51.633 130.402 51.7678C130.041 51.9026 129.657 51.965 129.272 51.9514C128.887 51.9377 128.508 51.8483 128.158 51.6882C127.807 51.5282 127.492 51.3006 127.229 51.0185L90.062 10.9316C89.5337 10.3575 89.2529 9.59824 89.2804 8.81848C89.3079 8.03871 89.6415 7.30119 90.209 6.76566L96.5947 0.788642C96.876 0.525602 97.2064 0.320694 97.5671 0.185675C97.9278 0.0506555 98.3115 -0.0118175 98.6964 0.00184023C99.0813 0.0154979 99.4597 0.105018 99.8099 0.265263C100.16 0.425508 100.475 0.653325 100.737 0.935641L137.905 41.0343Z" fill="#1C4466"/>
</svg>}</div>
            <span className="habit-label habit-label-blue">Workout</span>
            {habitsByName['Workout']?.is_completed_today && <span className="habit-check-badge">✓</span>}
          </button>
          <button
            type="button"
            className={`habit-box h-olive${habitsByName['Daily Gratitude']?.is_completed_today ? ' completed' : ''}`}
            onClick={() => handleToggleHabit('Daily Gratitude', 'gratitude')}
            disabled={togglingHabit === 'Daily Gratitude'}
          >
            <div className="habit-svg-holder">{<svg xmlns="http://www.w3.org/2000/svg" width="138" height="138" viewBox="0 0 138 138" fill="none">
  <path d="M97.0312 69H101.344V81.9375H97.0312V69ZM30.1875 81.9375H67.275L54.3375 69H30.1875V81.9375Z" fill="#2C2E12"/>
  <path d="M98.2441 16.1988C98.1363 16.1449 98.0555 16.091 97.9746 16.0371C95.0367 14.4199 91.9102 13.1531 88.7027 12.048L87.2473 11.5629C81.4793 9.73008 75.3609 8.625 69 8.625C35.659 8.625 8.625 35.659 8.625 69C8.625 91.7215 21.1852 111.478 39.7289 121.774C39.8367 121.828 39.9176 121.909 40.0254 121.963C42.9633 123.58 46.0898 124.847 49.2973 125.952L50.7527 126.437C56.5207 128.27 62.6121 129.375 69 129.375C102.341 129.375 129.375 102.341 129.375 69C129.375 46.2785 116.815 26.4949 98.2441 16.1988ZM69 114.928C66.4934 114.928 64.0406 114.686 61.6688 114.281C59.0273 113.85 56.4668 113.176 53.9871 112.314C53.475 112.152 52.9629 111.99 52.4777 111.802C50.7258 111.128 49.0008 110.373 47.3566 109.484C32.9098 101.748 23.0719 86.5195 23.0719 68.973C23.0719 58.9465 26.4141 49.7285 31.8855 42.1816L95.8184 106.114C88.2445 111.586 79.0266 114.928 69 114.928ZM106.141 95.7914L42.2086 31.8586C49.7555 26.4141 58.9465 23.0719 69 23.0719C71.5066 23.0719 73.9324 23.3145 76.3313 23.7188C78.9727 24.15 81.5332 24.8238 84.0129 25.6863C84.498 25.848 85.0102 26.0098 85.5223 26.1984C87.1934 26.8453 88.8105 27.5461 90.3738 28.3816C104.982 36.0633 114.955 51.3727 114.955 69.027C114.928 79.0535 111.586 88.2445 106.141 95.7914Z" fill="#2C2E12"/>
  <path d="M94.8754 80.3205V69.0002H83.5551L94.8754 80.3205ZM103.5 69.0002H107.813V81.9377H103.5V69.0002ZM97.0586 57.3295C94.6867 56.2244 91.1289 55.7932 84.768 55.7932H83.7977C80.3746 55.8201 79.5121 55.7662 78.407 54.149C77.6523 53.017 78.1375 50.16 79.4043 48.2463C79.8355 47.5994 79.8895 46.7369 79.5121 46.0361C79.1348 45.3354 78.407 44.9041 77.6254 44.8771C77.5984 44.8771 75.0918 44.8502 72.693 43.826C69.8359 42.6131 68.4883 40.5646 68.4883 37.5998C68.4883 30.6459 74.3641 30.1338 74.6336 30.1338V25.8213C71.3992 25.8213 64.1758 28.7861 64.1758 37.5998C64.1758 42.3166 66.6016 45.9553 71.1027 47.842C72.2348 48.3002 73.3668 48.6236 74.3371 48.8123C73.4477 51.4537 73.3668 54.4455 74.7953 56.5478C77.2211 60.1326 80.2668 60.1057 83.7707 60.0787H84.7141C91.8027 60.0787 94.0398 60.6986 95.1988 61.2377C96.7352 61.9385 97.0316 64.3373 96.9777 66.5475V66.817H101.29V66.5475C101.29 64.6338 101.371 59.324 97.0586 57.3295Z" fill="#2C2E12"/>
  <path d="M107.812 66.8437C107.812 59.9167 107.004 55.1999 105.36 52.3968C103.042 48.5155 99.3223 46.3593 94.875 46.3593H90.1852C90.9668 44.1222 91.6406 41.0226 91.1285 38.0308C90.266 32.9636 85.9805 29.9448 79.5117 29.9448V34.2573C85.1719 34.2573 86.5465 36.7101 86.8969 38.7585C87.5707 42.6667 85.0641 47.4105 85.0371 47.4644C84.6598 48.1382 84.6867 48.9468 85.0641 49.5937C85.4414 50.2405 86.1691 50.6448 86.9238 50.6448H94.875C97.8129 50.6448 100.104 51.9655 101.64 54.58C102.476 56.0085 103.5 59.2968 103.5 66.8167H107.812V66.8437Z" fill="#2C2E12"/>
</svg>}</div>
            <span className="habit-label">Daily Gratitude</span>
            {habitsByName['Daily Gratitude']?.is_completed_today && <span className="habit-check-badge">✓</span>}
          </button>
        </div>
      </section>

    </div>
  );
};

export default ResourcesCenter;