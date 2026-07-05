import React, { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './Community.module.css';
import PostCard from './PostCard';
import {
  isLoggedIn,
  listPosts,
  createPost,
  toggleLike,
  toggleSavePost,
  listComments,
  addComment,
  deletePost,
} from '../services/api';

const DEFAULT_AVATAR = 'https://www.w3schools.com/howto/img_avatar.png';

function formatDate(isoString) {
  const d = new Date(isoString);
  const day = d.getDate();
  const suffix =
    day % 10 === 1 && day !== 11 ? 'st' :
    day % 10 === 2 && day !== 12 ? 'nd' :
    day % 10 === 3 && day !== 13 ? 'rd' : 'th';
  const month = d.toLocaleString('en-US', { month: 'short' });
  return `${day}${suffix} ${month} ${d.getFullYear()}`;
}

function toViewPost(post) {
  return {
    ...post,
    commentsOpen: false,
    commentsLoaded: false,
    comments: [],
    commentsLoading: false,
    likePending: false,
    savePending: false,
    commentPending: false,
    deletePending: false,
  };
}

const Community = () => {
  const navigate = useNavigate();
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [newPostText, setNewPostText] = useState('');
  const [posting, setPosting] = useState(false);
  const [selectedImage, setSelectedImage] = useState(null);
  const [imagePreviewUrl, setImagePreviewUrl] = useState(null);
  const fileInputRef = useRef(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const data = await listPosts();
        if (!cancelled) setPosts(data.map(toViewPost));
      } catch (err) {
        if (!cancelled) setError(err.message || 'Could not load the community feed.');
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => { cancelled = true; };
  }, []);

  const updatePost = (postId, updater) => {
    setPosts((prev) => prev.map((p) => (p.id === postId ? updater(p) : p)));
  };

  const handleLike = async (postId) => {
    if (!isLoggedIn()) { navigate('/login'); return; }
    const target = posts.find((p) => p.id === postId);
    if (!target || target.likePending) return;

    const optimisticLiked = !target.is_liked;
    const optimisticCount = target.like_count + (optimisticLiked ? 1 : -1);
    updatePost(postId, (p) => ({ ...p, is_liked: optimisticLiked, like_count: optimisticCount, likePending: true }));

    try {
      const data = await toggleLike(postId);
      updatePost(postId, (p) => ({ ...p, is_liked: data.liked, like_count: data.like_count, likePending: false }));
    } catch (err) {
      updatePost(postId, (p) => ({ ...p, is_liked: target.is_liked, like_count: target.like_count, likePending: false }));
      setError(err.message || 'Could not update like.');
    }
  };

  const handleSave = async (postId) => {
    if (!isLoggedIn()) { navigate('/login'); return; }
    const target = posts.find((p) => p.id === postId);
    if (!target || target.savePending) return;

    const optimisticSaved = !target.is_saved;
    updatePost(postId, (p) => ({ ...p, is_saved: optimisticSaved, savePending: true }));

    try {
      const data = await toggleSavePost(postId);
      updatePost(postId, (p) => ({ ...p, is_saved: data.saved, savePending: false }));
    } catch (err) {
      updatePost(postId, (p) => ({ ...p, is_saved: target.is_saved, savePending: false }));
      setError(err.message || 'Could not update saved collection.');
    }
  };

  const handleToggleComments = async (postId) => {
    const target = posts.find((p) => p.id === postId);
    if (!target) return;

    if (!target.commentsOpen && !target.commentsLoaded) {
      updatePost(postId, (p) => ({ ...p, commentsOpen: true, commentsLoading: true }));
      try {
        const comments = await listComments(postId);
        updatePost(postId, (p) => ({ ...p, comments, commentsLoaded: true, commentsLoading: false }));
      } catch (err) {
        updatePost(postId, (p) => ({ ...p, commentsLoading: false }));
        setError(err.message || 'Could not load comments.');
      }
      return;
    }

    updatePost(postId, (p) => ({ ...p, commentsOpen: !p.commentsOpen }));
  };

  const handleAddComment = async (postId, text) => {
    if (!isLoggedIn()) { navigate('/login'); return; }
    updatePost(postId, (p) => ({ ...p, commentPending: true }));

    try {
      const comment = await addComment(postId, text);
      updatePost(postId, (p) => ({
        ...p,
        comments: [...p.comments, comment],
        comment_count: p.comment_count + 1,
        commentPending: false,
      }));
    } catch (err) {
      updatePost(postId, (p) => ({ ...p, commentPending: false }));
      setError(err.message || 'Could not post comment.');
    }
  };

  const handleDeletePost = async (postId) => {
    updatePost(postId, (p) => ({ ...p, deletePending: true }));
    try {
      await deletePost(postId);
      setPosts((prev) => prev.filter((p) => p.id !== postId));
    } catch (err) {
      updatePost(postId, (p) => ({ ...p, deletePending: false }));
      setError(err.message || 'Could not delete post.');
    }
  };

  const handleSelectImage = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (imagePreviewUrl) URL.revokeObjectURL(imagePreviewUrl);
    setSelectedImage(file);
    setImagePreviewUrl(URL.createObjectURL(file));
  };

  const handleRemoveImage = () => {
    if (imagePreviewUrl) URL.revokeObjectURL(imagePreviewUrl);
    setSelectedImage(null);
    setImagePreviewUrl(null);
    if (fileInputRef.current) fileInputRef.current.value = '';
  };

  const handleCreatePost = async () => {
    const text = newPostText.trim();
    if (!text || posting) return;
    if (!isLoggedIn()) { navigate('/login'); return; }

    setPosting(true);
    setError(null);
    try {
      const post = await createPost(text, selectedImage);
      setPosts((prev) => [toViewPost(post), ...prev]);
      setNewPostText('');
      handleRemoveImage();
    } catch (err) {
      setError(err.message || 'Could not publish your post.');
    } finally {
      setPosting(false);
    }
  };

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

        {error && (
          <div className={styles.errorBanner}>{error}</div>
        )}

        <div className={styles.inputWrapper}>
          <div className={styles.inputCard}>
            <textarea
              placeholder="Share an experience to inspire others or ask for advice..."
              className={styles.textArea}
              value={newPostText}
              onChange={(e) => setNewPostText(e.target.value)}
              disabled={posting}
            />
            <button
              type="button"
              className={styles.attachmentIcon}
              onClick={() => fileInputRef.current?.click()}
              disabled={posting}
              aria-label="Attach an image"
            >
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#595959" strokeWidth="2">
                <path d="M21.44 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48"></path>
              </svg>
            </button>
            <input
              type="file"
              accept="image/*"
              ref={fileInputRef}
              onChange={handleSelectImage}
              style={{ display: 'none' }}
            />
            <button
              type="button"
              className={styles.postButton}
              onClick={handleCreatePost}
              disabled={posting || !newPostText.trim()}
              aria-label={posting ? 'Posting…' : 'Post'}
              title={posting ? 'Posting…' : 'Post'}
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <line x1="22" y1="2" x2="11" y2="13" strokeLinecap="round" strokeLinejoin="round"/>
                <polygon points="22 2 15 22 11 13 2 9 22 2" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </button>
            {imagePreviewUrl && (
              <div className={styles.imagePreviewRow}>
                <img src={imagePreviewUrl} alt="" className={styles.imagePreviewThumb} />
                <span className={styles.imagePreviewName}>{selectedImage?.name}</span>
                <button type="button" className={styles.imagePreviewRemove} onClick={handleRemoveImage}>
                  ×
                </button>
              </div>
            )}
          </div>
        </div>

        <div style={{
          marginTop: '30px',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          width: '100%'
        }}>
          {loading && <p>Loading posts…</p>}
          {!loading && posts.map((post) => (
            <PostCard
              key={post.id}
              name={post.display_name}
              date={formatDate(post.created_at)}
              avatar={post.avatar_url || DEFAULT_AVATAR}
              content={post.content}
              image={post.image}
              likeCount={post.like_count}
              commentCount={post.comment_count}
              isLiked={post.is_liked}
              isSaved={post.is_saved}
              isOwner={post.is_owner}
              likePending={post.likePending}
              savePending={post.savePending}
              deletePending={post.deletePending}
              commentsOpen={post.commentsOpen}
              comments={post.comments}
              commentsLoading={post.commentsLoading}
              commentPending={post.commentPending}
              onLike={() => handleLike(post.id)}
              onSave={() => handleSave(post.id)}
              onToggleComments={() => handleToggleComments(post.id)}
              onAddComment={(text) => handleAddComment(post.id, text)}
              onDelete={() => handleDeletePost(post.id)}
            />
          ))}
        </div>

      </div>
    </div>
  );
};

export default Community;
