import React, { useState } from 'react';
import './PostCard.css';
import likeIcon from '../assets/like.png';
import commentIcon from '../assets/comment.png';
import savedIcon from '../assets/saved.png';

const PostCard = ({
  postId,
  name,
  date,
  content,
  avatar,
  image,
  likeCount,
  commentCount,
  isLiked,
  isSaved,
  isOwner,
  likePending,
  savePending,
  deletePending,
  commentsOpen,
  comments,
  commentsLoading,
  commentPending,
  highlighted,
  onLike,
  onSave,
  onToggleComments,
  onAddComment,
  onDelete,
  onOpenPost,
}) => {
  const [commentText, setCommentText] = useState('');

  const handleCommentSubmit = (e) => {
    e.preventDefault();
    const text = commentText.trim();
    if (!text) return;
    onAddComment(text);
    setCommentText('');
  };

  const handleDeleteClick = (e) => {
    e.stopPropagation();
    if (window.confirm('Delete this post? This cannot be undone.')) {
      onDelete();
    }
  };

  return (
    <div
      className={`post-container${highlighted ? ' post-container-highlighted' : ''}`}
      data-post-id={postId}
    >
      <div
        className="post-main-card"
        onClick={onOpenPost}
        style={onOpenPost ? { cursor: 'pointer' } : undefined}
      >
        <div className="post-header">
          <div className="user-info">
            <img src={avatar} className="user-avatar" alt={name} />
            <div>
              <h3 className="user-name">{name}</h3>
              <p style={{ color: '#595959', fontSize: '14px', margin: 0 }}>{date}</p>
            </div>
          </div>
          {isOwner ? (
            <button
              type="button"
              className="post-delete-btn"
              onClick={handleDeleteClick}
              disabled={deletePending}
              aria-label="Remove post"
              title="Remove post"
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M3 6h18M8 6V4a2 2 0 012-2h4a2 2 0 012 2v2m3 0-1 14a2 2 0 01-2 2H7a2 2 0 01-2-2L4 6h16z" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </button>
          ) : (
            <svg width="25.687" height="25.687" viewBox="0 0 24 24" fill="none" stroke="#595959" strokeWidth="2">
              <circle cx="12" cy="12" r="1"/><circle cx="12" cy="5" r="1"/><circle cx="12" cy="19" r="1"/>
            </svg>
          )}
        </div>
        <div className="post-content">{content}</div>
        {image && <img src={image} alt="" className="post-image" />}
      </div>

      <div className="post-actions-bar">
        <button
          type="button"
          className={`action-btn${isLiked ? ' active' : ''}`}
          onClick={onLike}
          disabled={likePending}
        >
          <img src={likeIcon} alt="Like" className="action-icon like-icon-style" />
          {isLiked ? 'Liked' : 'Like'}{likeCount > 0 ? ` (${likeCount})` : ''}
        </button>

        <div className="divider"></div>

        <button type="button" className="action-btn" onClick={onToggleComments}>
          <img src={commentIcon} alt="Comment" className="action-icon" />
          Comment{commentCount > 0 ? ` (${commentCount})` : ''}
        </button>

        <div className="divider"></div>

        <button
          type="button"
          className={`action-btn${isSaved ? ' active' : ''}`}
          onClick={onSave}
          disabled={savePending}
        >
          <img src={savedIcon} alt="Save" className="action-icon" />
          {isSaved ? 'Saved' : 'Save to collection'}
        </button>
      </div>

      {commentsOpen && (
        <div className="comments-section">
          {commentsLoading ? (
            <p className="comments-loading">Loading comments…</p>
          ) : (
            <div className="comments-list">
              {comments.length === 0 && (
                <p className="comments-empty">No comments yet — be the first to reply.</p>
              )}
              {comments.map((c) => (
                <div key={c.id} className="comment-item">
                  <span className="comment-author">{c.display_name}</span>
                  <span className="comment-text">{c.content}</span>
                </div>
              ))}
            </div>
          )}

          <form className="comment-form" onSubmit={handleCommentSubmit}>
            <input
              type="text"
              className="comment-input"
              placeholder="Write a comment…"
              value={commentText}
              onChange={(e) => setCommentText(e.target.value)}
              disabled={commentPending}
            />
            <button type="submit" className="comment-submit-btn" disabled={commentPending || !commentText.trim()}>
              Post
            </button>
          </form>
        </div>
      )}
    </div>
  );
};

export default PostCard;
