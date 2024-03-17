from rest_framework import serializers
from .models import ParentAppointment


class ParentAppointmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = ParentAppointment
        fields = "__all__"