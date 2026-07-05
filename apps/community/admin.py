from django.contrib import admin

from .models import Post, PostComment, PostLike, PostSave


class PostCommentInline(admin.TabularInline):
    model = PostComment
    extra = 0
    fields = ("display_name", "content", "created_at")
    readonly_fields = ("created_at",)


@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ("display_name", "author", "has_image", "like_count", "comment_count", "created_at")
    search_fields = ("display_name", "content", "author__email")
    readonly_fields = ("id", "created_at", "updated_at")

    def has_image(self, obj):
        return bool(obj.image)
    has_image.boolean = True
    inlines = [PostCommentInline]

    def like_count(self, obj):
        return obj.likes.count()

    def comment_count(self, obj):
        return obj.comments.count()


@admin.register(PostLike)
class PostLikeAdmin(admin.ModelAdmin):
    list_display = ("post", "user", "created_at")
    search_fields = ("user__email",)


@admin.register(PostSave)
class PostSaveAdmin(admin.ModelAdmin):
    list_display = ("post", "user", "created_at")
    search_fields = ("user__email",)
