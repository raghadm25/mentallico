"""
Serializers for the resource library.
"""
from rest_framework import serializers

from .models import Article, Category, SavedResource


class CategorySerializer(serializers.ModelSerializer):
    article_count = serializers.IntegerField(
        source="articles.count", read_only=True
    )

    class Meta:
        model = Category
        fields = ("id", "name", "slug", "description", "icon", "article_count")


class ArticleListSerializer(serializers.ModelSerializer):
    """Compact representation for list views."""

    category_name = serializers.CharField(source="category.name", read_only=True)

    class Meta:
        model = Article
        fields = (
            "id",
            "title",
            "slug",
            "category_name",
            "content_type",
            "difficulty",
            "summary",
            "thumbnail",
            "tags",
            "is_crisis_resource",
            "reading_time_minutes",
            "author",
            "created_at",
        )


class ArticleDetailSerializer(ArticleListSerializer):
    """Full representation including article body."""

    class Meta(ArticleListSerializer.Meta):
        fields = ArticleListSerializer.Meta.fields + ("body", "external_url", "updated_at")


class SavedResourceSerializer(serializers.ModelSerializer):
    """Serializes a user's bookmarked article with article detail nested."""

    article = ArticleListSerializer(read_only=True)
    article_id = serializers.PrimaryKeyRelatedField(
        queryset=Article.objects.filter(is_published=True),
        write_only=True,
        source="article",
    )

    class Meta:
        model = SavedResource
        fields = ("id", "article", "article_id", "notes", "saved_at")
        read_only_fields = ("id", "saved_at")

    def validate(self, attrs):
        user = self.context["request"].user
        article = attrs.get("article")
        if SavedResource.objects.filter(user=user, article=article).exists():
            raise serializers.ValidationError(
                {"article_id": "You have already saved this resource."}
            )
        return attrs
