"""
URL routes for the resources app.
"""
from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import ArticleViewSet, CategoryViewSet, SavedResourceViewSet

router = DefaultRouter()
router.register(r"categories", CategoryViewSet, basename="resource-category")
router.register(r"articles", ArticleViewSet, basename="resource-article")
router.register(r"saved", SavedResourceViewSet, basename="saved-resource")

urlpatterns = [
    path("", include(router.urls)),
]
