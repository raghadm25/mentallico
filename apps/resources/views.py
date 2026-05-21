"""
Views for the mental health resource library.
"""
from rest_framework import filters, permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Article, Category, SavedResource
from .serializers import (
    ArticleDetailSerializer,
    ArticleListSerializer,
    CategorySerializer,
    SavedResourceSerializer,
)


class CategoryViewSet(viewsets.ReadOnlyModelViewSet):
    """
    GET /api/v1/resources/categories/
    GET /api/v1/resources/categories/{id}/
    """

    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]


class ArticleViewSet(viewsets.ReadOnlyModelViewSet):
    """
    List and retrieve published articles with filtering and search.

    GET /api/v1/resources/articles/
    GET /api/v1/resources/articles/{id}/
    GET /api/v1/resources/articles/crisis/   — crisis-flagged resources only
    """

    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["title", "summary", "body", "tags", "author"]
    ordering_fields = ["created_at", "reading_time_minutes", "title"]
    ordering = ["-created_at"]

    def get_queryset(self):
        qs = Article.objects.filter(is_published=True).select_related("category")

        category_slug = self.request.query_params.get("category")
        if category_slug:
            qs = qs.filter(category__slug=category_slug)

        content_type = self.request.query_params.get("content_type")
        if content_type:
            qs = qs.filter(content_type=content_type)

        difficulty = self.request.query_params.get("difficulty")
        if difficulty:
            qs = qs.filter(difficulty=difficulty)

        tag = self.request.query_params.get("tag")
        if tag:
            qs = qs.filter(tags__contains=[tag])

        return qs

    def get_serializer_class(self):
        if self.action == "retrieve":
            return ArticleDetailSerializer
        return ArticleListSerializer

    @action(detail=False, methods=["get"], url_path="crisis")
    def crisis(self, request):
        """Return crisis-flagged resources regardless of other filters."""
        queryset = Article.objects.filter(
            is_published=True, is_crisis_resource=True
        ).select_related("category")
        serializer = ArticleListSerializer(
            queryset, many=True, context={"request": request}
        )
        return Response(serializer.data)


class SavedResourceViewSet(viewsets.ModelViewSet):
    """
    Manage the authenticated user's bookmarked articles.

    GET    /api/v1/resources/saved/
    POST   /api/v1/resources/saved/
    GET    /api/v1/resources/saved/{id}/
    DELETE /api/v1/resources/saved/{id}/
    """

    serializer_class = SavedResourceSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ["get", "post", "delete", "head", "options"]

    def get_queryset(self):
        return SavedResource.objects.filter(
            user=self.request.user
        ).select_related("article", "article__category")

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
