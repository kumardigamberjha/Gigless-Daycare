from django.urls import path
from . import views

urlpatterns = [
    path('children/', views.ChildListCreateView.as_view(), name='child-list-create'),
    path('children/<int:pk>/', views.ChildDetailView.as_view(), name='child-detail'),
    path('child-list/', views.ChildListView.as_view(), name='child-list'),
    path('child-list2/', views.ChildListView2.as_view(), name='child-list2'),

    path('delete-child-data/<int:id>/', views.DeleteChildData, name='delete-child-data'),

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
    path('api/resources/', views.create_learning_resource, name='create_learning_resource'),


    # Rooms
    path('rooms/', views.room_list, name='room-list'),
    path('rooms_list_2/', views.room_list_user, name='room-list_user'),

    path('rooms/create/', views.room_create, name='room-create'),
    path('rooms/update/<int:pk>/', views.room_update, name='room-update'),
    path('rooms/delete/<int:pk>/', views.room_delete, name='room-delete'),

    # AllChildOfSelectedRoom
    path('rooms/children/<int:id>/', views.AllChildOfSelectedRoom, name='room-children'),

    # Room Media 
    path('rooms/<int:room_id>/upload/', views.upload_multiple_media_files, name='upload_multiple_media_files'),
    path('rooms/<int:room_id>/media/', views.get_room_media, name='get_room_media'),
    path('rooms/<int:room_id>/media/<int:media_id>/', views.get_media_file, name='get_media_file'),
    path('rooms/<int:room_id>/media/<int:media_id>/update/', views.update_media_file, name='update_media_file'),
    path('rooms/<int:room_id>/media/<int:media_id>/delete/', views.delete_media_file, name='delete_media_file'),

]