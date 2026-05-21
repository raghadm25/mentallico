import React from 'react';
import './PostCard.css';
// استيراد الصور (تأكدي من صحة المسار)
import likeIcon from '../assets/like.png';
import commentIcon from '../assets/comment.png';
import savedIcon from '../assets/saved.png';

const PostCard = ({ name, date, content, avatar }) => {
  return (
    <div className="post-container">
      <div className="post-main-card">
        <div className="post-header">
          <div className="user-info">
            <img src={avatar} className="user-avatar" alt={name} />
            <div>
              <h3 className="user-name">{name}</h3>
              <p style={{ color: '#595959', fontSize: '14px', margin: 0 }}>{date}</p>
            </div>
          </div>
          <svg width="25.687" height="25.687" viewBox="0 0 24 24" fill="none" stroke="#595959" strokeWidth="2">
            <circle cx="12" cy="12" r="1"/><circle cx="12" cy="5" r="1"/><circle cx="12" cy="19" r="1"/>
          </svg>
        </div>
        <div className="post-content">{content}</div>
      </div>

      <div className="post-actions-bar">
        {/* زر اللايك مع الأيقونة */}
        <button className="action-btn">
          <img src={likeIcon} alt="Like" className="action-icon like-icon-style" />
          Like
        </button>
        
        <div className="divider"></div>
        
        {/* زر التعليق مع الأيقونة */}
        <button className="action-btn">
          <img src={commentIcon} alt="Comment" className="action-icon" />
          Comment
        </button>
        
        <div className="divider"></div>
        
        {/* زر الحفظ مع الأيقونة */}
        <button className="action-btn">
          <img src={savedIcon} alt="Save" className="action-icon" />
          Save to collection
        </button>
      </div>
    </div>
  );
};

export default PostCard;