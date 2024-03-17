from django.urls import path
from . import views

urlpatterns = [
    path('', views.AccountView, name="account_view"),

    path('dashboard/', views.DashboardView, name="dashboard_view"),
    path('Fees/<int:child_id>/', views.fees_list, name="fees_list_account_view"),
    path('total-payments-current-month/', views.Currentmonth_payments_list, name='total_payments_current_month'),
    path('total-payments-selected-month/', views.Selectedmonthly_payments_list, name='total_payments_selected_month'),
    path('current-year-payments/', views.current_year_payments, name='current_year_payments'),
]