import React, { useEffect, useState } from 'react';
import PostCard from '../Community/PostCard';
import {
  listSavedPosts,
  listSavedResources,
  toggleLike,
  toggleSavePost,
  listComments,
  addComment,
  unsaveResource,
  deletePost,
} from '../services/api';
import '../StaticPages/tokens.css';
import './SavedCollection.css';

const DEFAULT_AVATAR = 'https://www.w3schools.com/howto/img_avatar.png';

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

function formatDate(isoString) {
  const d = new Date(isoString);
  return d.toLocaleDateString('en-US', { day: 'numeric', month: 'short', year: 'numeric' });
}

const SavedCollection = () => {
  const [tab, setTab] = useState('posts');

  const [posts, setPosts] = useState([]);
  const [postsLoading, setPostsLoading] = useState(true);
  const [error, setError] = useState(null);

  const [resources, setResources] = useState([]);
  const [resourcesLoading, setResourcesLoading] = useState(true);

  useEffect(() => {
    listSavedPosts()
      .then((data) => setPosts(data.map(toViewPost)))
      .catch((err) => setError(err.message || 'Could not load saved posts.'))
      .finally(() => setPostsLoading(false));

    listSavedResources()
      .then(setResources)
      .catch((err) => setError(err.message || 'Could not load saved resources.'))
      .finally(() => setResourcesLoading(false));
  }, []);

  const updatePost = (postId, updater) => {
    setPosts((prev) => prev.map((p) => (p.id === postId ? updater(p) : p)));
  };

  const handleLike = async (postId) => {
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

  const handleUnsavePost = async (postId) => {
    updatePost(postId, (p) => ({ ...p, savePending: true }));
    try {
      const data = await toggleSavePost(postId);
      if (!data.saved) {
        // Unsaved from within the saved-collection view — it no longer belongs here.
        setPosts((prev) => prev.filter((p) => p.id !== postId));
      }
    } catch (err) {
      updatePost(postId, (p) => ({ ...p, savePending: false }));
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

  const handleUnsaveResource = async (savedResourceId) => {
    try {
      await unsaveResource(savedResourceId);
      setResources((prev) => prev.filter((r) => r.id !== savedResourceId));
    } catch (err) {
      setError(err.message || 'Could not remove saved resource.');
    }
  };

  return (
    <div className="static-page saved-collection-page">
      <h1>Saved Collection</h1>
      <p className="static-subtitle">Everything you've bookmarked, in one place.</p>

      {error && <p className="saved-collection-error">{error}</p>}

      <div className="saved-collection-tabs">
        <button
          type="button"
          className={`saved-collection-tab ${tab === 'posts' ? 'active' : ''}`}
          onClick={() => setTab('posts')}
        >
          Saved Posts
        </button>
        <button
          type="button"
          className={`saved-collection-tab ${tab === 'resources' ? 'active' : ''}`}
          onClick={() => setTab('resources')}
        >
          Saved Resources
        </button>
      </div>

      {tab === 'posts' && (
        <div className="saved-collection-posts">
          {postsLoading && <p>Loading…</p>}
          {!postsLoading && posts.length === 0 && <p>You haven't saved any posts yet.</p>}
          {!postsLoading && posts.map((post) => (
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
              onSave={() => handleUnsavePost(post.id)}
              onToggleComments={() => handleToggleComments(post.id)}
              onAddComment={(text) => handleAddComment(post.id, text)}
              onDelete={() => handleDeletePost(post.id)}
            />
          ))}
        </div>
      )}

      {tab === 'resources' && (
        <div className="saved-collection-resources">
          {resourcesLoading && <p>Loading…</p>}
          {!resourcesLoading && resources.length === 0 && <p>You haven't saved any resources yet.</p>}
          {!resourcesLoading && resources.map((saved) => (
            <div key={saved.id} className="saved-resource-card">
              <div>
                <h2>{saved.article.title}</h2>
                <p>{saved.article.summary}</p>
                {saved.article.external_url && (
                  <a href={saved.article.external_url} target="_blank" rel="noopener noreferrer">
                    View resource →
                  </a>
                )}
              </div>
              <button
                type="button"
                className="saved-resource-remove"
                onClick={() => handleUnsaveResource(saved.id)}
              >
                Remove
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default SavedCollection;
