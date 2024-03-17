from rest_framework import serializers
from .models import Child, Attendance, DailyActivity, ChildMedia


class ChildSerializer(serializers.ModelSerializer):
    class Meta:
        model = Child
        # fields = '__all__'
        exclude = ['unique_id']


class ChildSerializerGet(serializers.ModelSerializer):
    class Meta:
        model = Child
        fields = '__all__'


class AttendanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Attendance
        fields = '__all__'
        

class AttendanceSerializerStatus(serializers.Serializer):
    date = serializers.DateField()
    is_present = serializers.BooleanField()


class AttendanceStatusSerializer(serializers.Serializer):
    child_id = serializers.IntegerField(source='child.id')
    child_name = serializers.SerializerMethodField()
    is_present = serializers.BooleanField()

    def get_child_name(self, obj):
        child_data = obj['child']
        return f"{child_data['first_name']} {child_data['last_name']}"

    class Meta:
        fields = ['child_id', 'child_name', 'is_present']



class DailyActivitySerializer(serializers.ModelSerializer):
    # child = ChildSerializer()

    class Meta:
        model = DailyActivity
        fields = '__all__'



class ChildMediaSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChildMedia
        fields = '__all__'