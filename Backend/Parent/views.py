from ipaddress import summarize_address_range
from django.shortcuts import get_object_or_404, render
from django.http import JsonResponse
from datetime import datetime, date, timedelta
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view, permission_classes
from rest_framework import serializers, status
from rest_framework.views import APIView
from django.utils import timezone
from django.db.models import Sum

#'''
from .models import ParentAppointment, ParentModel
from .serializers  import ParentAppointmentSerializer
from authapp.models import CustomUser
from students.models import Child, Attendance, DailyActivity, ChildMedia
from students.serializers import ChildSerializerGet, AttendanceStatusSerializer, DailyActivitySerializer, ChildSerializer, ChildMediaSerializer

from Accounts.models import Fee
from Accounts.serializers import FeeSerializer
#'''


# Create your views here.
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def ChildDetailForParent(request):
    user = request.user
    print("User: ", user)    
    childinfo = Child.objects.filter(parent1_contact_number__icontains=user.mobile_number)
    childser = ChildSerializerGet(childinfo, many=True)
    return Response({'error': childser.data}, status=200)


@permission_classes([IsAuthenticated])
class CurrentAttendanceStatusP(APIView):
    def get(self, request, format=None):
        current_date = date.today()
        user = request.user
        children = Child.objects.filter(parent1_contact_number__icontains=user.mobile_number)

        attendance_status_dict = {}

        for child in children:
            try:
                attendance = Attendance.objects.get(child=child, datemarked=current_date)
                is_present = attendance.is_present
            except Attendance.DoesNotExist:
                is_present = False

            attendance_status_dict[child.id] = {
                'child': ChildSerializerGet(child).data,
                'is_present': is_present
            }

        serializer = AttendanceStatusSerializer(attendance_status_dict.values(), many=True)

        return Response(serializer.data, status=200)



""" Appointment Schedule """
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_parent_appointment(request):
    if request.method == 'POST':
        current_user = request.user
        print("Current User: ", current_user, current_user.mobile_number)
        
        parent_id = current_user.id
        print("Paren Id: , ", parent_id)

        parent = CustomUser.objects.get(id=parent_id)       
        appointment_type = request.data.get('appointment_type')
        scheduled_time = request.data.get('scheduled_time')
        notes = request.data.get('notes')
        status = request.data.get('status')

        try:
            instance = ParentAppointment.objects.create(
                parent=CustomUser.objects.get(id=current_user.id),
                appointment_type=appointment_type,
                scheduled_time=scheduled_time,
                notes=notes,
                status = status
            )
            print("Form Saved")
            return Response("Form Saved", status=200)

        except Exception as e:
            print("Error: ", e)

            return Response("Error", status=status.HTTP_400_BAD_REQUEST)
        


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def parent_appointment_status(request):
    if request.method == 'GET':
        current_user = request.user
        print("Current User: ", current_user, current_user.mobile_number)
        
        try:
            if current_user.usertype == "Parent":
                parent = CustomUser.objects.get(id=current_user.id)       
                appointments = ParentAppointment.objects.filter(parent=parent)
            else:
                appointments = ParentAppointment.objects.all()
                
            
            serializer = ParentAppointmentSerializer(appointments, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)

        except CustomUser.DoesNotExist:
            return Response({"error": "Parent user does not exist"}, status=status.HTTP_404_NOT_FOUND)
        
        except Exception as e:
            print("Error: ", e)
            return Response({"error": "An error occurred"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)



@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_appointment_status(request, appointment_id):
    if request.method == 'PUT':
        try:
            appointment = ParentAppointment.objects.get(pk=appointment_id)
            print("Appointment: ", appointment)
            serializer = ParentAppointmentSerializer(appointment, data=request.data, partial=True)
            print("Serializer: ", serializer)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data, status=status.HTTP_200_OK)
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except ParentAppointment.DoesNotExist:
            return Response({"error": "Appointment not found"}, status=status.HTTP_404_NOT_FOUND)
        


# @api_view(['GET'])
# def  get_upcoming_appointments(request):
#     # Get the currently logged in user (parent)
#     current_user = request.user
    
#     # Check that they are a parent and retrieve their details from the database
#     if isinstance(current_user, ParentUser):
#         parent = current_user
#     elif isinstance(current_user, ChildUser):
#         child = current_user
#         parent = ChildToParent.objects.filter(child=child).first().parent
#     else:
#         return Response({"error":"Invalid User Type"} , status=status.HTTP_4)


@api_view(['GET'])
def calendarholidays(request):
    import http.client

    conn = http.client.HTTPSConnection("public-holiday.p.rapidapi.com")

    headers = {
        'X-RapidAPI-Key': "cd0f910956mshe62d604f26dacedp107b85jsnbfd956d0aeff",
        'X-RapidAPI-Host': "public-holiday.p.rapidapi.com"
    }

    conn.request("GET", "/2024/ca", headers=headers)

    res = conn.getresponse()
    data = res.read()

    print(data.decode("utf-8"))
    return Response({'holidays':data}, status=200)






'''##############################################################################
                              Daily Activity
##############################################################################'''

@api_view(['GET'])
def DailyActivityForParent(request, child_id):
    today = date.today()
    print("Today: ", today)
    try:
        qs = get_object_or_404(Child, id=child_id)
        daily_activities = DailyActivity.objects.filter(child=qs, ondate=today)
        # Serialize daily activities
        serializer = DailyActivitySerializer(daily_activities, many=True)
        
        # Check if any daily activity exists for today
        is_activity_saved = daily_activities.exists()

        # Serialize child details (single instance)
        child_ser = ChildSerializer(qs)
        response_data = {
            'data': serializer.data,
            'user': child_ser.data,  # Access serialized data attribute for a single instance
            'is_activity_saved': is_activity_saved,
        }

        return Response(response_data, status=status.HTTP_200_OK)
    except Child.DoesNotExist:
        return Response({'error': 'Child not found'}, status=status.HTTP_404_NOT_FOUND)
    


@api_view(['GET'])
def DailyActivityMediaForParent(request, child_id):
    today = date.today()
    print("Today: ", today)
    try:
        qs = get_object_or_404(Child, id=child_id)
        daily_activities = ChildMedia.objects.filter(child=qs, uploaded_at=today)
        # Serialize daily activities
        serializer = ChildMediaSerializer(daily_activities, many=True)
        
        # Check if any daily activity exists for today
        is_activity_saved = daily_activities.exists()

        # Serialize child details (single instance)
        child_ser = ChildSerializer(qs)
        response_data = {
            'data': serializer.data,
            'user': child_ser.data,  # Access serialized data attribute for a single instance
            'is_activity_saved': is_activity_saved,
        }

        return Response(response_data, status=status.HTTP_200_OK)
    except Child.DoesNotExist:
        return Response({'error': 'Child not found'}, status=status.HTTP_404_NOT_FOUND)
    



'''##############################################################################
                                 Accounts
##############################################################################'''

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def ParentCurrentmonth_payments_list(request):
    # Get the current month and year
    parent_id = request.user

    fees = Fee.objects.filter(child_id__parent1_contact_number=parent_id.mobile_number)
    print("Fees: ", fees)
    parent = CustomUser.objects.get(id=parent_id.id)  
    current_month = timezone.now().month
    current_year = timezone.now().year

    # Filter payments for the current month
    payments = Fee.objects.filter(child_id__parent1_contact_number=parent_id.mobile_number, date_paid__month=current_month, date_paid__year=current_year, ).order_by('date_paid')

    # Serialize payments data
    payments_data = [{'date_paid': payment.date_paid, 'amount': payment.amount} for payment in payments]

    # Calculate the total payments for the current month
    total_payments = payments.aggregate(total_amount=Sum('amount'))['total_amount'] or 0

    # Return JSON response
    return JsonResponse({'payments': payments_data, 'total_payments': total_payments})




@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def fees_list(request, child_id):
    if request.method == 'GET':
        try:
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
            print("Total Fees: ", total_fees_paid_this_month)

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