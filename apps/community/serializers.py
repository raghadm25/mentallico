"""
Serializers for the community feed.
"""
from rest_framework import serializers

from .models import Post, PostComment


class PostCommentSerializer(serializers.ModelSerializer):
    class Meta:
        model = PostComment
        fields = ("id", "display_name", "content", "created_at")
        read_only_fields = ("id", "display_name", "created_at")


class PostSerializer(serializers.ModelSerializer):
    like_count = serializers.IntegerField(source="likes.count", read_only=True)
    comment_count = serializers.IntegerField(source="comments.count", read_only=True)
    is_liked = serializers.SerializerMethodField()
    is_saved = serializers.SerializerMethodField()
    is_owner = serializers.SerializerMethodField()

    class Meta:
        model = Post
        fields = (
            "id",
            "display_name",
            "avatar_url",
            "content",
            "image",
            "like_count",
            "comment_count",
            "is_liked",
            "is_saved",
            "is_owner",
            "created_at",
        )
        read_only_fields = ("id", "display_name", "avatar_url", "created_at")

    def _request_user(self):
        request = self.context.get("request")
        return getattr(request, "user", None)

    def get_is_liked(self, obj):
        user = self._request_user()
        if not user or not user.is_authenticated:
            return False
        return obj.likes.filter(user=user).exists()

    def get_is_saved(self, obj):
        user = self._request_user()
        if not user or not user.is_authenticated:
            return False
        return obj.saves.filter(user=user).exists()

    def get_is_owner(self, obj):
        user = self._request_user()
        if not user or not user.is_authenticated:
            return False
        return obj.author_id == user.id
