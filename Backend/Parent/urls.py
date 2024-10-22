from django.urls import path
from . import views

urlpatterns = [
    path('', views.ChildDetailForParent, name='index'),  
    path('childroomforparents/<int:id>/', views.ChildRoomForParent, name='childroomforparents'),  

    path('childtodaysattendancep/', views.CurrentAttendanceStatusP.as_view(), name='childtodaysattendancep'),  
    path('createappointments/', views.create_parent_appointment, name='create-parent-appointment'),
    path('appointmentstatus/', views.parent_appointment_status, name='parent_appointment_status'),
    path('updateappointment/<int:appointment_id>/', views.update_appointment_status, name='update_appointment_status'),

    path('holidayslist/', views.calendarholidays, name='holidayslist'),
    path('ParentCurrentmonth_payments_list/', views.ParentCurrentmonth_payments_list, name='ParentCurrentmonth_payments_list'),

    path('dailyactivityforparent/<int:child_id>/', views.DailyActivityForParent, name='daily_activity_for_parent'),
    path('dailyactivitymediaforparent/<int:child_id>/', views.DailyActivityMediaForParent, name='daily_activity_media_for_parent'),

    path('Fees/<int:child_id>/', views.fees_list, name="fees_list_account_view_to_parent"),
]