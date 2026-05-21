from django.contrib import admin

from .models import Article, Category, SavedResource


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ("name", "slug", "created_at")
    prepopulated_fields = {"slug": ("name",)}
    search_fields = ("name",)


@admin.register(Article)
class ArticleAdmin(admin.ModelAdmin):
    list_display = (
        "title", "category", "content_type", "difficulty",
        "is_published", "is_crisis_resource", "reading_time_minutes", "created_at",
    )
    list_filter = ("is_published", "is_crisis_resource", "content_type", "difficulty", "category")
    search_fields = ("title", "summary", "body", "author")
    prepopulated_fields = {"slug": ("title",)}
    readonly_fields = ("created_at", "updated_at")
    list_editable = ("is_published", "is_crisis_resource")


@admin.register(SavedResource)
class SavedResourceAdmin(admin.ModelAdmin):
    list_display = ("user", "article", "saved_at")
    search_fields = ("user__email", "article__title")
    readonly_fields = ("saved_at",)
