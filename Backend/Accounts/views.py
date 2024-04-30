from django.shortcuts import render, HttpResponse
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Fee
from .serializers import FeeSerializer
from rest_framework.decorators import api_view
from students.models import Child
from django.http import JsonResponse
from django.db.models import Sum
from datetime import datetime, date
from django.utils import timezone
from collections import defaultdict
from students.models import Child, Attendance
from students.serializers import ChildSerializer, AttendanceSerializer

@api_view(['GET'])
def AccountView(request):
    return HttpResponse("Hello World")

@api_view(['GET'])
def DashboardView(request):
    """ Monthly  dashboard view for the admin to see all fees collected in a month"""
    current_month = timezone.now().month
    current_year = timezone.now().year
    today = date.today()
    students = Child.objects.filter(is_active=True).count()
    present_today = Attendance.objects.filter(datemarked=today).count()
    # present_ser = AttendanceSerializer(present_today, many=True)
    print("Present Today: ", present_today)
    print("Students: ", students)
    absent = students - present_today
    # Filter payments for the current month
    payments = Fee.objects.filter(date_paid__month=current_month, date_paid__year=current_year)

    # Calculate the total payments for the current month
    month_payments = payments.aggregate(total_amount=Sum('amount'))['total_amount'] or 0
    print("Total Payments")

    # *******************************************************
                    # Yearly Payment 
    # *******************************************************
    # Filter payments for the current year
    accounts = Fee.objects.filter(date_paid__year=current_year)
    yearly_payments = accounts.aggregate(total_amount=Sum('amount'))['total_amount'] or 0
    print("Yearly Amounts: ", yearly_payments)

    return JsonResponse({'total_payments': month_payments, 'year_amount': yearly_payments, 'students': students, 'present': present_today, 'absent': absent})



@api_view(['GET', 'POST'])
def fees_list(request, child_id):
    if request.method == 'GET':
        try:
            # Retrieve fees for the specified child_id
            fees = Fee.objects.filter(child_id=child_id)
            # Retrieve child record for the specified child_id
            child_record = Child.objects.get(id=child_id)
            
            # Serialize fees data
            fee_serializer = FeeSerializer(fees, many=True)
            
            # Extract child's name and fees
            child_name = child_record.first_name
            child_fees = child_record.child_fees
            
            current_month = datetime.now().month
            current_year = datetime.now().year
            
            # Get the start and end dates of the current month
            start_date = date(current_year, current_month, 1)
            end_date = date(current_year, current_month + 1, 1)

            total_fees_paid_this_month = Fee.objects.filter(child_id=child_id, date_paid__gte=start_date, date_paid__lt=end_date).aggregate(Sum('amount'))['amount__sum'] or 0

            # Prepare data to be returned
            response_data = {
                'fees': fee_serializer.data,
                'child_name': child_name,
                'child_fees': child_fees,  # Include child fees in the response data
                'total_fees_paid_this_month': total_fees_paid_this_month
            }

            return Response(response_data)
        except Child.DoesNotExist:
            return Response({'error': 'Child not found'}, status=404)
        except Exception as e:
            return Response({'error': str(e)}, status=500)

    elif request.method == 'POST':
        print("Called...")
        serializer = FeeSerializer(data=request.data)

        print("Serializer: ", serializer)
        try:
            try:
                if serializer.is_valid():
                    serializer.save()  # Set the child_id from the URL parameter
                    return Response(serializer.data, status=status.HTTP_201_CREATED)
                else:
                    print("Serializer: ", serializer.errors)

            except Exception as e:
                print("Error: ", e)
        except Exception as e:
            print("Exception as e:", e)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



@api_view(['GET'])
def Currentmonth_payments_list(request):
    # Get the current month and year
    current_month = timezone.now().month
    current_year = timezone.now().year

    # Filter payments for the current month
    payments = Fee.objects.filter(date_paid__month=current_month, date_paid__year=current_year)

    # Serialize payments data
    payments_data = [{'date_paid': payment.date_paid, 'amount': payment.amount} for payment in payments]

    # Calculate the total payments for the current month
    total_payments = payments.aggregate(total_amount=Sum('amount'))['total_amount'] or 0

    # Return JSON response
    return JsonResponse({'payments': payments_data, 'total_payments': total_payments})



@api_view(['GET'])
def Selectedmonthly_payments_list(request):
    # Get the month and year from query parameters
    month = request.GET.get('month')
    year = request.GET.get('year', timezone.now().year)

    # If month is not provided, use the current month
    if not month:
        month = timezone.now().month

    # Filter payments for the selected month and year
    payments = Fee.objects.filter(date_paid__month=month, date_paid__year=year)

    # Serialize payments data
    payments_data = [{'date_paid': payment.date_paid, 'amount': payment.amount, 'child_name': payment.child.first_name} for payment in payments]

    # Calculate the total payments for the selected month and year
    total_payments = payments.aggregate(total_amount=Sum('amount'))['total_amount'] or 0

    # Return JSON response
    return JsonResponse({'payments': payments_data, 'total_payments': total_payments})


@api_view(['GET'])
def current_year_payments(request):
    current_year = timezone.now().year

    # Filter payments for the current year
    accounts = Fee.objects.filter(date_paid__year=current_year)

    # Group payments by month
    payments_by_month = defaultdict(list)
    for account in accounts:
        month_year = account.date_paid.strftime('%Y-%m')
        child_name = account.child.first_name
        payments_by_month[month_year].append({
            'date': account.date_paid.strftime('%Y-%m-%d'),
            'child_name': child_name,
            'amount': float(account.amount),  # Ensure amount is converted to float
        })

    # Serialize payments data
    payments_data = []
    total_amount = 0
    for month_year, payments in payments_by_month.items():
        total_amount_month = sum(payment['amount'] for payment in payments)
        payments_data.append({
            'month_year': month_year,
            'payments': payments,
            'total_amount_month': round(total_amount_month, 2),  # Round to two decimal places
        })
        total_amount += total_amount_month

    # Convert total_amount to string with two decimal places
    total_amount_str = "{:.2f}".format(total_amount)

    # Return JSON response
    return JsonResponse({'payments_by_month': payments_data, 'total_amount': total_amount_str})