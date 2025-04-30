from rest_framework import generics
from .models import Child, Attendance, DailyActivity, ChildMedia, LearningResource, Rooms, RoomMedia
from .serializers import ChildSerializer, ChildSerializerGet, AttendanceSerializer,  DailyActivitySerializer, ChildMediaSerializer, RoomSerializer, RoomMediaSerializer, MultipleRoomMediaUploadSerializer
from rest_framework import serializers
from rest_framework.response import Response
from django.db import IntegrityError
from rest_framework import status
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from datetime import datetime, date
from rest_framework.views import APIView
from rest_framework.decorators import api_view
from .serializers import AttendanceStatusSerializer
from django.views.decorators.csrf import csrf_exempt
import calendar
from authapp.models import CustomUser
from authapp.serializers import CustomUserSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import permission_classes
from django.views import View
from .tasks import save_images_and_videos_to_s3
from django.db.models import Prefetch

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
            # Extract validation errors
            errors_dict = {}
            for field, errors in e.detail.items():
                # Check for required field errors
                if 'This field may not be blank.' in errors:
                    errors_dict[field] = f"{field.capitalize()} is required."
                else:
                    # For other types of errors, just show the first error in the list
                    errors_dict[field] = errors[0]

            return Response({'error': errors_dict}, status=400)
        
        except IntegrityError as e:
            print("Error: ", e)
            # Handle unique constraint or database integrity issues
            return Response({'error': 'An integrity error occurred while creating the child.'}, status=400)
        
        except Exception as e:
            print("Error: ", e)
            # Generic exception handler for unexpected errors
            return Response({'error': str(e)}, status=500)


class ChildListView2(generics.ListAPIView):
    queryset = Child.objects.all()
    serializer_class = ChildSerializerGet


class ChildListView(APIView):
    permission_classes = [IsAuthenticated]  # Ensure the user is authenticated

    def get(self, request, *args, **kwargs):
        # Check if the user is a superuser
        if request.user.is_superuser:
            # Superusers can see all children
            children = Child.objects.all()
        else:
            try:
                # Retrieve children associated with the logged-in staff user's assigned room
                assigned_room = request.user.room
                children = Child.objects.filter(room=assigned_room)
            except AttributeError:
                # If the user does not have an assigned room, return an empty queryset
                children = Child.objects.none()

        # Count the number of children in the queryset
        no_of_children = children.count()

        # Serialize the children data
        serializer = ChildSerializerGet(children, many=True)

        # Return the response with the same structure as before
        return Response({
            'data': serializer.data,
            'no_of_rooms': no_of_children  # Use 'no_of_rooms' for consistency with frontend
        })
    

class ChildDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Child.objects.all()
    serializer_class = ChildSerializerGet

    def update(self, request, *args, **kwargs):
        try:
            id = request.data.get('id')

            first_name = request.data.get('first_name')
            last_name = request.data.get('last_name')
            date_of_birth = request.data.get('date_of_birth')
            gender = request.data.get('gender')
            blood_group = request.data.get('blood_group')
            medical_history = request.data.get('medical_history')
            image = request.data.get('image')
            child_fees = request.data.get('child_fees')
            address = request.data.get('address')
            unique_id = request.data.get('unique_id')

            city = request.data.get('city')
            state = request.data.get('state')
            zip_code = request.data.get('zip_code')
            parent1_name = request.data.get('parent1_name')
            parent1_contact_number = request.data.get('parent1_contact_number')
            parent2_name = request.data.get('parent2_name')
            parent2_contact_number = request.data.get('parent2_contact_number')
            is_active = request.data.get('is_active')
            room = request.data.get('room')

            data = Child.objects.get(id=id)
            data.first_name = first_name
            data.last_name = last_name
            data.date_of_birth = date_of_birth
            data.gender = gender
            data.blood_group = blood_group
            data.medical_history = medical_history
            print("Image: ", image)
            try:
                #if image and not image.startswith('/media'):
                    #data.image = image
                #    pass
                if image:
                    data.image = image
                    #pass
            except:
                #data.image = image
                pass
            
            data.unique_id = unique_id
            roomdata = Rooms.objects.get(id=room)
            data.room = roomdata
            data.child_fees = child_fees
            data.address = address
            data.city = city
            data.state = state
            data.zip_code = zip_code
            data.parent1_name = parent1_name
            data.parent1_contact_number = parent1_contact_number
            data.parent2_name = parent2_name
            data.parent2_contact_number = data.parent2_contact_number
            data.is_active = is_active
            data.save()
            print("Data: ", data)
            return Response("Saved")
        except serializers.ValidationError as ve:
            return Response({"detail": str(ve)}, status=status.HTTP_400_BAD_REQUEST)
        except Child.DoesNotExist:
            return Response({"detail": "Child not found."}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            print("Error: ", e)
            return Response({"detail": f"An unexpected error occurred: {e}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        

@api_view(['DELETE'])
def DeleteChildData(request, id):
    child = Child.objects.get(id = id)
    child.delete()
    return Response({'Status': "Success"}, status=200)



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
        children = Child.objects.filter(is_active=True)

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

    # Fetch the child and prefetch related daily activities for today
    try:
        child = Child.objects.prefetch_related(
            Prefetch('dailyactivity_set', queryset=DailyActivity.objects.filter(ondate=today))
        ).get(id=child_id)

        # Extract prefetched daily activities
        daily_activities = child.dailyactivity_set.all()

        # Serialize data
        serializer = DailyActivitySerializer(daily_activities, many=True)
        child_serializer = ChildSerializer(child)

        response_data = {
            'data': serializer.data,
            'user': child_serializer.data,
            'is_activity_saved': bool(daily_activities),  # Check if any activity exists
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
                #current_user = request.user.unique_id
                #user = CustomUser.objects.get(unique_id=current_user)
                #serializer = CustomUserSerializer(user)
                #return Response(serializer.data)
                current_user = request.user.unique_id  # Fetch the unique ID of the current user
                superuserstatus = request.user.is_superuser  # Check if the user is a superuser
                user = CustomUser.objects.get(unique_id=current_user)  # Get the user object using unique_id
                serializer = CustomUserSerializer(user)  # Serialize the user object
                response_data = serializer.data
                response_data['is_superuser'] = superuserstatus
                return Response(response_data)
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


@api_view(['GET'])
def room_list_user(request):
    rooms = Rooms.objects.all()
    no_of_rooms = rooms.count()
    serializer = RoomSerializer(rooms, many=True)
    return Response({'data':serializer.data, 'no_of_rooms':no_of_rooms})


@api_view(['GET'])
def room_list(request):
    # Check if the user is authenticated
    print('User: ', request.user)
    if not request.user.is_authenticated:
        return Response({"detail": "Authentication required."}, status=401)

    # Check if the user is a superuser
    if request.user.is_superuser:
        # Superusers can see all rooms
        rooms = Rooms.objects.all()
    else:
        # Staff users can only see their assigned room
        try:
            # Retrieve the room assigned to the logged-in staff user
            rooms = Rooms.objects.filter(id=request.user.room.id)
        except AttributeError:
            # If the user does not have an assigned room, return an empty queryset
            rooms = Rooms.objects.none()

    # Count the number of rooms in the queryset
    no_of_rooms = rooms.count()

    # Serialize the rooms data
    serializer = RoomSerializer(rooms, many=True)

    # Return the response
    return Response({'data': serializer.data, 'no_of_rooms': no_of_rooms})


@api_view(['POST'])
def room_create(request):
    serializer = RoomSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['PUT'])
def room_update(request, pk):
    try:
        room = Rooms.objects.get(pk=pk)
    except Rooms.DoesNotExist:
        return Response({'error': 'Room not found'}, status=status.HTTP_404_NOT_FOUND)

    serializer = RoomSerializer(room, data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
def room_delete(request, pk):
    try:
        room = Rooms.objects.get(pk=pk)
    except Rooms.DoesNotExist:
        return Response({'error': 'Room not found'}, status=status.HTTP_404_NOT_FOUND)

    room.delete()
    return Response(status=status.HTTP_204_NO_CONTENT)


from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Child

@api_view(['GET'])
def AllChildOfSelectedRoom(request, id):
    try:
        filter_children = Child.objects.filter(room=id).values('room_id', 'id','first_name', 'last_name', 'image', 'gender', 'parent1_contact_number', 'unique_id')
        
        # Convert the QuerySet to a list of dictionaries
        children_list = list(filter_children)
        
        return Response({'data': children_list}, status=200)
    except Exception as e:
        print("Error: ", e)
        return Response({'Error': f"{e}"}, status=400)



# ******************************************* 

@api_view(['POST'])
def upload_multiple_media_files(request, room_id):
    try:
        room = Rooms.objects.get(id=room_id)
    except Rooms.DoesNotExist:
        return Response({'error': 'Room not found'}, status=status.HTTP_404_NOT_FOUND)

    serializer = MultipleRoomMediaUploadSerializer(data=request.data, context={'room': room})
    
    if serializer.is_valid():
        media_instances = serializer.save()
        return Response({'success': 'Files uploaded successfully', 'message': 'New media has been uploaded to the room.', 'media': [RoomMediaSerializer(media).data for media in media_instances]}, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# READ: Get all media for a room
@api_view(['GET'])
def get_room_media(request, room_id):
    try:
        room = Rooms.objects.get(id=room_id)
    except Rooms.DoesNotExist:
        return Response({'error': 'Room not found'}, status=status.HTTP_404_NOT_FOUND)

    last_media_date = RoomMedia.objects.filter(room=room).last()
    print("Last Media Date: ", last_media_date)
    media = RoomMedia.objects.filter(room=room, uploaded_at=last_media_date.uploaded_at)
    serializer = RoomMediaSerializer(media, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


# READ: Get a specific media file by ID
@api_view(['GET'])
def get_media_file(request, room_id, media_id):
    try:
        # last_item = RoomMedia.objects.filter()
        media = RoomMedia.objects.get(room_id=room_id, id=media_id)
    except RoomMedia.DoesNotExist:
        return Response({'error': 'Media not found'}, status=status.HTTP_404_NOT_FOUND)

    serializer = RoomMediaSerializer(media)
    return Response(serializer.data, status=status.HTTP_200_OK)


# UPDATE: Update a specific media file
@api_view(['PUT'])
def update_media_file(request, room_id, media_id):
    try:
        media = RoomMedia.objects.get(room_id=room_id, id=media_id)
    except RoomMedia.DoesNotExist:
        return Response({'error': 'Media not found'}, status=status.HTTP_404_NOT_FOUND)

    serializer = RoomMediaSerializer(media, data=request.data)

    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# DELETE: Delete a specific media file
@api_view(['DELETE'])
def delete_media_file(request, room_id, media_id):
    try:
        media = RoomMedia.objects.get(room_id=room_id, id=media_id)
    except RoomMedia.DoesNotExist:
        return Response({'error': 'Media not found'}, status=status.HTTP_404_NOT_FOUND)

    media.delete()
    return Response({'success': 'Media deleted'}, status=status.HTTP_204_NO_CONTENT)



@api_view(['GET'])
def StaffWiseStudent(request, id):
    user = CustomUser.objects.get(id=id)
    room = user.room
    x = Child.objects.filter(room=room)
    ser = ChildSerializer(x, many=True)

    return Response({"data": ser.data})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def StaffRoomStudent(request):
    if request.user and request.user.is_authenticated:
        try:
            user = CustomUser.objects.get(id=request.user.id)
            room = user.room
            students = Child.objects.filter(room=room)
            serializer = ChildSerializer(students, many=True)
            return Response({"data": serializer.data}, status=200)
        except CustomUser.DoesNotExist:
            return Response({"error": "User not found."}, status=404)
        except Exception as e:
            return Response({"error": str(e)}, status=500)
    else:
        return Response({"error": "Authentication required."}, status=401)