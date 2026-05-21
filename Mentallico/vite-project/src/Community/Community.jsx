import React from 'react';
import styles from './Community.module.css';
import PostCard from './PostCard';

const Community = () => {
  const posts = [
    {
      name: "Anna B.",
      date: "12th Nov 2025",
      avatar: "https://randomuser.me/api/portraits/women/1.jpg",
      content: "Proud of Myself 💛 I went for a short walk this morning even though I didn’t feel motivated. It wasn’t long, but it helped clear my mind. What are you proud of today?"
    },
    {
      name: "Anonymous",
      date: "12th Nov 2025",
      avatar: "https://www.w3schools.com/howto/img_avatar2.png",
      content: "University has been overwhelming lately. I’m exhausted and scared I’m falling behind. Any gentle advice from people who’ve been through this?"
    },
    {
      name: "Albert G.",
      date: "12th Nov 2025",
      avatar: "https://randomuser.me/api/portraits/men/1.jpg",
      content: "I’m trying to build a consistent morning routine. Even simple things feel hard sometimes. What’s one small habit that made your mornings better?"
    },
    {
      name: "Yara S.",
      date: "12th Nov 2025",
      avatar: "https://randomuser.me/api/portraits/women/2.jpg",
      content: "Mini Declutter Challenge — Day 3 Pick one tiny thing to tidy today: your desk, your bag, your photo gallery… anything. Share your before/after or describe the moment."
    },
    {
      name: "Anonymous",
      date: "12th Nov 2025",
      avatar: "https://www.w3schools.com/howto/img_avatar.png",
      content: "I’ve been feeling disconnected from my friends lately. It’s like I’m there, but not really there. Does anyone else feel this sometimes?"
    },
    {
      name: "Zayn M.",
      date: "12th Nov 2025",
      avatar: "https://randomuser.me/api/portraits/men/2.jpg",
      content: "Write one sentence to yourself 6 months from now. Not advice — but a promise. I’ll start: I promise to rest when I need to, not only when I break."
    }
  ];

  return (
    <div className={styles.container}>
      <div className={`${styles.ellipse} ${styles.ellipse19}`}></div>
      <div className={`${styles.ellipse} ${styles.ellipse23}`}></div>
      <div className={`${styles.ellipse} ${styles.ellipse24}`}></div>
      <div className={`${styles.ellipse} ${styles.ellipse21}`}></div>
      <div className={`${styles.ellipse} ${styles.ellipse25}`}></div>
      <div className={`${styles.ellipse} ${styles.ellipse26}`}></div>

     
      <div className={styles.contentWrapper}>
        
        <header className={styles.headerSection}>
          <h1 className={styles.mainTitle}>
            Welcome to <span className={styles.gradientText}>Mentallico</span> Community!
          </h1>
          <p className={styles.subtitle}>
            Here you can be yourself and share every little achievement. 
            Find thousands of inspiring journeys and connect with people with the same experience!
          </p>
        </header>

<div className={styles.inputWrapper}>
  <div className={styles.inputCard}>
    <textarea 
      placeholder="Share an experience to inspire others or ask for advice..."
      className={styles.textArea}
    />
    <div className={styles.attachmentIcon}>
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#595959" strokeWidth="2">
        <path d="M21.44 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48"></path>
      </svg>
    </div>
  </div>
</div>
        <div style={{ 
          marginTop: '30px', 
          display: 'flex', 
          flexDirection: 'column', 
          alignItems: 'center',
          width: '100%'
        }}>
          {posts.map((post, index) => (
            <PostCard 
              key={index} 
              name={post.name}
              date={post.date}
              avatar={post.avatar}
              content={post.content}
            />
          ))}
        </div>

      </div> 
    </div>
  );
};

export default Community;