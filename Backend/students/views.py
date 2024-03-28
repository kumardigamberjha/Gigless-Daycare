
from rest_framework import generics
from .models import Child, Attendance, DailyActivity, ChildMedia, LearningResource
from .serializers import ChildSerializer, ChildSerializerGet, AttendanceSerializer, AttendanceSerializerStatus, DailyActivitySerializer, ChildMediaSerializer, LearningResourceSerializer
from rest_framework import serializers
from rest_framework.response import Response
from django.db import IntegrityError
from rest_framework import status
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from datetime import datetime, date, timedelta, timezone
from rest_framework.views import APIView
from rest_framework.decorators import api_view
from .serializers import AttendanceStatusSerializer
from django.views.decorators.csrf import csrf_exempt
import calendar
from authapp.models import CustomUser
from authapp.serializers import CustomUserSerializer
from rest_framework.permissions import IsAuthenticated
from django.views import View
from .tasks import save_images_and_videos_to_s3

class ChildListCreateView(generics.ListCreateAPIView):
    queryset = Child.objects.all()
    serializer_class = ChildSerializer

    def create(self, request, *args, **kwargs):
        try:
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            
            # Save the child instance to the database
            self.perform_create(serializer)

            return Response({'message': 'Child created successfully'}, status=201)
        except serializers.ValidationError as e:
            errors_dict = {}
            for field, errors in e.detail.items():
                if 'This field may not be blank.' in errors:
                    errors_dict[field] = f"{field.capitalize()} is required."
                    print(errors_dict[field])
                    return Response({'error':errors_dict[field]}, status=400)
                else:
                    print("No")
                    errors_dict[field] = errors[0]
            if 'unique' in str(e).lower():
                print(f"{errors_dict['name']} already exists.", e)
                return Response({'error': 'An unexpected error occurred while creating the child.'}, status=400)
            
            return Response({'error': str(e)}, status=400)
        except IntegrityError as e:
                return Response({'error': 'An unexpected error occurred while creating the child.'}, status=500)
        except Exception as e:
            print("Sp")
            return Response({'error': str(e)}, status=500)



class ChildListView(generics.ListAPIView):
    queryset = Child.objects.all()
    serializer_class = ChildSerializerGet


class ChildDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Child.objects.all()
    serializer_class = ChildSerializerGet




##################################### Attendance #################################
class MarkAttendanceView(generics.CreateAPIView):
    queryset = Attendance.objects.all()
    serializer_class = AttendanceSerializer

    def create(self, request, *args, **kwargs):
        try:
            print("Hello")
            child_id = request.data.get('child_id')
            print("Child Id: ", child_id)
            is_present = request.data.get('is_present', False)

            # Assume that Child model has a field named 'id'
            child = Child.objects.get(id=child_id)
            print("Hello", child)

            # Create an attendance entry
            attendance = Attendance(child=child, is_present=is_present)
            attendance.save()

            return Response({'message': 'Attendance marked successfully'}, status=status.HTTP_200_OK)
        except Child.DoesNotExist:
            return Response({'error': 'Child not found'}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        


class CurrentAttendanceStatus(APIView):
    def get(self, request, format=None):
        current_date = date.today()
        children = Child.objects.all()

        attendance_status_dict = {}

        for child in children:
            try:
                attendance = Attendance.objects.get(child=child, datemarked=current_date)
                is_present = attendance.is_present
            except Attendance.DoesNotExist:
                is_present = False

            attendance_status_dict[child.id] = {
                'child': ChildSerializer(child).data,
                'is_present': is_present
            }

        serializer = AttendanceStatusSerializer(attendance_status_dict.values(), many=True)

        return Response(serializer.data, status=status.HTTP_200_OK)



import json
@csrf_exempt
def toggle_attendance(request):
    try:
        data = json.loads(request.body.decode('utf-8'))
        child_id = data.get('child_id')
        is_present = data.get('is_present')

        # Retrieve the child and attendance record
        child = Child.objects.get(id=child_id)
        attendance, created = Attendance.objects.get_or_create(child=child, datemarked=date.today())
        attendance.is_present = is_present
        attendance.save()

        return JsonResponse({'status': 'success'})
    except Child.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Child not found'})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})
    


############################### Track Child Attendance ################ # 

class AttendanceStatsView(View):
    def get(self, request, child_id):
        print("Hello View")
        # Get the current month
        current_month = datetime.now().month
        current_year = datetime.now().year

        # Calculate the number of days in the current month
        num_days_in_month = calendar.monthrange(current_year, current_month)[1]

        # Calculate the number of days the child was present in the current month
        present_dates = list(Attendance.objects.filter(child_id=child_id, datemarked__month=current_month, is_present=True).values_list('datemarked', flat=True))

        # Calculate the number of Sundays (holidays) in the current month
        holiday_dates = [datetime(current_year, current_month, day).strftime('%Y-%m-%d') for day in range(1, num_days_in_month + 1) if datetime(current_year, current_month, day).weekday() == 6]

        # Calculate the number of absent days (leaves) in the current month
        all_dates = [datetime(current_year, current_month, day).strftime('%Y-%m-%d') for day in range(1, num_days_in_month + 1)]
        absent_dates = list(set(all_dates) - set(present_dates) - set(holiday_dates))

        # Prepare the response
        response_data = {
            'num_days_in_month': num_days_in_month,
            'num_days_present': len(present_dates),
            'num_holidays': len(holiday_dates),
            'num_leaves': len(absent_dates),
            'present_dates': present_dates,
            'holiday_dates': holiday_dates,
            'absent_dates': absent_dates
        }

        return JsonResponse(response_data)



# ########################## Daily Activity ######################
@api_view(['POST'])
def create_daily_activity_view(request, child_id):
        child = get_object_or_404(Child, id=child_id)
        serializer = DailyActivitySerializer(data=request.data)
        print("Serializer: ", serializer)
        try:
            if serializer.is_valid():
                serializer.save()
                print("Saved")
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            else:
                print("Serializer Error: ", serializer.errors)
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            print("Exception: ", e)
            return Response({'error': 'An error occurred'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
def edit_daily_activity_view(request, child_id):
    today = date.today()
    daily_activity = get_object_or_404(DailyActivity, child_id=child_id, ondate=today)
    serializer = DailyActivitySerializer(instance=daily_activity, data=request.data)
    print("Serializer: ", serializer)
    try:
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        else:
            print("Serializer Error: ", serializer.errors)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
def daily_activity_view(request, child_id):
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
    


@api_view(['GET', 'POST'])
def child_media_list(request):
    if request.method == 'GET':
        # Get the current date
        today = date.today()
        
        # Filter child media uploaded on today's date
        child_media = ChildMedia.objects.filter(uploaded_at__date=today)
        
        serializer = ChildMediaSerializer(child_media, many=True)
        return Response(serializer.data)


    elif request.method == 'POST':
        try:
            child_id = request.data.get('child')
            print("Child Id: ", child_id)

            file = request.data.get('file')
            print("file: ", file)


            # Check if 'child' and 'file' are present in the request data
            if not (child_id and file):
                return Response("Missing 'child' or 'file' data", status=status.HTTP_400_BAD_REQUEST)

            serializer = ChildMediaSerializer(data=request.data)
            print("Serializer: ", serializer)

            # Call is_valid() to validate the serializer
            if serializer.is_valid():
                print("Valid")
                serializer.save()
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            else:
                print("Error: ", serializer.errors)
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            print("Exception: ", e)
            return Response(f"Error: {e}", status=status.HTTP_400_BAD_REQUEST)



@api_view(['GET'])
def child_media_detail(request, pk):
    today = date.today()
    try:
        child = Child.objects.get(id=pk)
        child_media = ChildMedia.objects.filter(child=child.id, uploaded_at__date=today)
        print("Child Media: ", child_media)
        serializer = ChildMediaSerializer(child_media, many=True)
        
        # Serialize child details (single instance)
        response_data = {
            'data': serializer.data,
        }
        return Response(response_data, status=status.HTTP_200_OK)
    
    except ChildMedia.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)



class CustomUserAPIView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        print("CUstom User: ", request.user)
        try:
            try:
                current_user = request.user.unique_id
                user = CustomUser.objects.get(unique_id=current_user)
                serializer = CustomUserSerializer(user)
                return Response(serializer.data)
            except:
                return Response("Sign in First")
        except CustomUser.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        


# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#                   Learning Resources
# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

@api_view(['POST'])
def create_learning_resource(request):
    if request.method == 'POST':
        title = request.data.get('title')
        description = request.data.get('description')
        image_file = request.FILES.get('image')  # Assuming the field name for the image is 'image'
        video_file = request.FILES.get('video')  # Assuming the field name for the video is 'video'

        try:
            # Save text fields first
            learning_resource = LearningResource.objects.create(
                title=title,
                description=description,
            )

            # Call Celery task to save images and videos asynchronously
            save_images_and_videos_to_s3.delay(learning_resource.id, image_file, video_file)

            return Response({"message": "Learning resource created successfully"}, status=status.HTTP_201_CREATED)
        except Exception as e:
            print("Error: ", e)
            return Response({"message": "Failed to create learning resource"}, status=status.HTTP_400_BAD_REQUEST)
