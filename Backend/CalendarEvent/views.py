# events/views.py

from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .serializers import EventSerializer
from .models import Event
from django.http import JsonResponse
import json
from django.views.decorators.csrf import csrf_exempt


@api_view(['POST'])
def create_event(request):
    if request.method == 'POST':
        serializer = EventSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



@api_view(['GET'])
def get_events(request):
    events = Event.objects.all()
    serializer = EventSerializer(events, many=True)
    return Response(serializer.data)


@csrf_exempt
@api_view(['POST'])
def edit_event(request):
    if request.method == 'POST':
        try:
            # Parse the JSON data from the request body
            data = json.loads(request.body)
            print("Data: ", data)
            event_id = data.get('id')
            new_name = data.get('name')

            print("Event Id: ", event_id)
            print("Event Name: ", new_name)
            
            # Retrieve the event from the database
            event = Event.objects.get(pk=event_id)
            print("Event: ", event)
            # Update the event name
            event.name = new_name
            event.save()
            
            return JsonResponse({'success': True})
        except Exception as e:
            return JsonResponse({'success': False, 'error': str(e)})
    else:
        return JsonResponse({'success': False, 'error': 'Only POST requests are allowed.'})


@csrf_exempt
def DeleteEvent(request, event_id):
    print("Event Id: ", event_id)
    try:
        event = Event.objects.get(id=event_id)
        print("Event: ", event)

        if request.method == 'DELETE':
            event.delete()
            return JsonResponse({'message': 'Event deleted successfully'})
        return JsonResponse({'error': 'Method not allowed'}, status=405)
    except Event.DoesNotExist:
        return JsonResponse({'error': 'Event not found'}, status=404)
