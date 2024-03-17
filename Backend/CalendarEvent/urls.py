from django.urls import path
from . import views

urlpatterns = [
    path('api/create-event/', views.create_event, name='create-event'),
    path('api/events/', views.get_events, name='get-events'),
    path('edit-event/', views.edit_event, name='edit_event'),
    path('DeleteEvent/<int:event_id>/', views.DeleteEvent, name='deleteEvent'),
]