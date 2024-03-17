from rest_framework import serializers
from .models import Event

class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = ['id', 'name', 'date']  # Assuming 'name' and 'date' are fields in your Event model
        # Optionally, you can specify the date format to ensure it's compatible with Dart
        extra_kwargs = {'date': {'format': '%Y-%m-%d'}}