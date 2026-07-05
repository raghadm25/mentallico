"""
Views for the community feed: posts, likes, saves, and comments.

Reading the feed is public; acting on it (post / like / save / comment)
requires an authenticated user (JWT), consistent with a social feature
where anonymous actions would otherwise all collapse onto one shared identity.
"""
import logging

from rest_framework import mixins, permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import PermissionDenied
from rest_framework.response import Response

from .models import Post, PostComment, PostLike, PostSave
from .serializers import PostCommentSerializer, PostSerializer

logger = logging.getLogger(__name__)


class PostViewSet(
    mixins.ListModelMixin,
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    mixins.DestroyModelMixin,
    viewsets.GenericViewSet,
):
    """
    GET    /api/v1/community/posts/             list posts, newest first
    POST   /api/v1/community/posts/              create a post (auth required)
    GET    /api/v1/community/posts/{id}/         retrieve one post
    DELETE /api/v1/community/posts/{id}/         delete a post (author only)
    POST   /api/v1/community/posts/{id}/like/    toggle like (auth required)
    POST   /api/v1/community/posts/{id}/save/    toggle save-to-collection (auth required)
    GET    /api/v1/community/posts/{id}/comments/  list comments on the post
    POST   /api/v1/community/posts/{id}/comments/  add a comment (auth required)
    GET    /api/v1/community/posts/saved/        list the authenticated user's saved posts (auth required)
    """

    queryset = Post.objects.all()
    serializer_class = PostSerializer

    def get_permissions(self):
        read_only_action = self.action in ("list", "retrieve") or (
            self.action == "comments" and self.request.method == "GET"
        )
        if read_only_action:
            return [permissions.AllowAny()]
        return [permissions.IsAuthenticated()]

    def get_serializer_context(self):
        return {"request": self.request}

    def perform_create(self, serializer):
        user = self.request.user
        serializer.save(
            author=user,
            display_name=user.full_name or user.email.split("@")[0],
        )

    def perform_destroy(self, instance):
        if instance.author_id != self.request.user.id:
            raise PermissionDenied("You can only delete your own posts.")
        instance.delete()

    @action(detail=True, methods=["post"])
    def like(self, request, pk=None):
        post = self.get_object()
        like, created = PostLike.objects.get_or_create(post=post, user=request.user)
        if not created:
            like.delete()
        return Response(
            {"liked": created, "like_count": post.likes.count()},
            status=status.HTTP_200_OK,
        )

    @action(detail=True, methods=["post"])
    def save(self, request, pk=None):
        post = self.get_object()
        saved_obj, created = PostSave.objects.get_or_create(post=post, user=request.user)
        if not created:
            saved_obj.delete()
        return Response({"saved": created}, status=status.HTTP_200_OK)

    @action(detail=False, methods=["get"])
    def saved(self, request):
        queryset = Post.objects.filter(saves__user=request.user).order_by("-saves__created_at")
        serializer = PostSerializer(queryset, many=True, context=self.get_serializer_context())
        return Response(serializer.data)

    @action(detail=True, methods=["get", "post"])
    def comments(self, request, pk=None):
        post = self.get_object()

        if request.method == "GET":
            queryset = post.comments.all()
            return Response(PostCommentSerializer(queryset, many=True).data)

        content = (request.data.get("content") or "").strip()
        if not content:
            return Response(
                {"detail": "content must not be empty."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        user = request.user
        comment = PostComment.objects.create(
            post=post,
            author=user,
            display_name=user.full_name or user.email.split("@")[0],
            content=content,
        )
        logger.info("Comment added to post %s by %s", post.id, user.email)
        return Response(
            PostCommentSerializer(comment).data, status=status.HTTP_201_CREATED
        )
