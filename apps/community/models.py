"""
Community feed models: posts, likes, saves, and comments.
"""
import uuid

from django.conf import settings
from django.db import models


class Post(models.Model):
    """
    A single community post.

    `display_name` / `avatar_url` are snapshotted at creation time so posts
    keep showing the name the author had when they posted (and so seeded /
    anonymous posts don't require a real user account).
    """

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="community_posts",
    )
    display_name = models.CharField(max_length=150)
    avatar_url = models.URLField(blank=True)
    content = models.TextField()
    image = models.ImageField(upload_to="community_posts/", null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "post"
        verbose_name_plural = "posts"
        ordering = ["-created_at"]

    def __str__(self):
        preview = self.content[:50] + "..." if len(self.content) > 50 else self.content
        return f"{self.display_name}: {preview}"


class PostLike(models.Model):
    """One user's like on one post. Existence = liked; row deleted = unliked."""

    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name="likes")
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="post_likes"
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "post like"
        verbose_name_plural = "post likes"
        unique_together = ("post", "user")

    def __str__(self):
        return f"{self.user.email} likes {self.post_id}"


class PostSave(models.Model):
    """One user's bookmark ('Save to collection') on one post."""

    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name="saves")
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="saved_posts"
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "post save"
        verbose_name_plural = "post saves"
        unique_together = ("post", "user")

    def __str__(self):
        return f"{self.user.email} saved {self.post_id}"


class PostComment(models.Model):
    """A comment on a post. `display_name` is snapshotted like Post.display_name."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name="comments")
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="community_comments",
    )
    display_name = models.CharField(max_length=150)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "post comment"
        verbose_name_plural = "post comments"
        ordering = ["created_at"]

    def __str__(self):
        preview = self.content[:50] + "..." if len(self.content) > 50 else self.content
        return f"{self.display_name}: {preview}"
