from django.urls import path
from . import views
from django.contrib.auth import views as auth_views
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.views import LogoutView


urlpatterns = [
    path('home/', views.HomeView.as_view(), name ='home'),
    path('tokens/', views.CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    # path('token/refresh/', views.CustomTokenObtainPairView.as_view(), name='token_refresh'),
    path('register/', views.register_user, name='register_user'),
    # path('logout/', views.LogoutView.as_view(), name='logout'),
    path('logout/', views.logout_view, name='logout'),
    path('get_username/', views.get_username, name='get_username'),
    # path('get_token_validation/<str:token>/', views.is_token_valid, name='get_token_validation'),
    path('validate-token/', views.TokenValidationView.as_view(), name='token-validation'),
    path('userslist/', views.user_list, name='user-list'),
    path('ParentList/', views.parent_list, name='parent-list'),
    path('ParentListDetail/<int:parent_id>/', views.parent_detail_list, name='parent-detail-list'),

    # path('', csrf_exempt(LogoutView), name='logout'),
]