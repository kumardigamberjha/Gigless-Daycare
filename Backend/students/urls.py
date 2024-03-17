from django.urls import path
from . import views

urlpatterns = [
    path('children/', views.ChildListCreateView.as_view(), name='child-list-create'),
    path('children/<int:pk>/', views.ChildDetailView.as_view(), name='child-detail'),
    path('child-list/', views.ChildListView.as_view(), name='child-list'),
    path('mark_attendance/', views.MarkAttendanceView.as_view(), name='mark-attendance'),
    # path('get-student-status/', views.get_student_status_on_date, name='get_student_status'),
    path('api/current-attendance/', views.CurrentAttendanceStatus.as_view(), name='current_attendance_status_api'),
    path('toggle-attendance/', views.toggle_attendance, name='toggle_attendance'),
    path('api/create-daily-activity/<int:child_id>/', views.create_daily_activity_view, name='create_daily-activity'),
    path('api/edit-daily-activity/<int:child_id>/', views.edit_daily_activity_view, name='edit_daily-activity'),

    path('api/daily-activity/<int:child_id>/', views.daily_activity_view, name='daily-activity'),
    path('child-media/', views.child_media_list, name="child_media"),
    path('child-media/<int:pk>/', views.child_media_detail, name="child_media_detail"),
    
    # Current User API View 
    path('api/user/', views.CustomUserAPIView.as_view(), name='api-user-detail'),

    # ########### Monthly Attendance ###############
    path('attendance/stats/<int:child_id>/', views.AttendanceStatsView.as_view(), name='attendance_stats'),
]