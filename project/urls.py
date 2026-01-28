"""
URL configuration for project project.
"""
from django.contrib import admin
from django.urls import path
from branch.views import BranchListCreateAPIView, BranchDetailAPIView
from vigilant.views import VigilantListCreateAPIView, VigilantDetailAPIView
from history.views import HistoryListCreateAPIView, HistoryDetailAPIView


urlpatterns = [
    path('admin/', admin.site.urls),
    
    # Branch endpoi
    path('api/branches/', BranchListCreateAPIView.as_view(), name='branch-list-create'),
    path('api/branches/<int:pk>/', BranchDetailAPIView.as_view(), name='branch-detail'),
    
    # Vigilant endpoints
    path('api/vigilants/', VigilantListCreateAPIView.as_view(), name='vigilant-list-create'),
    path('api/vigilants/<int:pk>/', VigilantDetailAPIView.as_view(), name='vigilant-detail'),
    
    # History endpoints
    path('api/histories/', HistoryListCreateAPIView.as_view(), name='history-list-create'),
    path('api/histories/<int:pk>/', HistoryDetailAPIView.as_view(), name='history-detail'),
]
