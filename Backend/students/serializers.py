from rest_framework import serializers
from .models import Child, Attendance, DailyActivity, ChildMedia, LearningResource, Rooms, RoomMedia


class ChildSerializer(serializers.ModelSerializer):
    class Meta:
        model = Child
        # fields = '__all__'
        exclude = ['unique_id']


class ChildSerializerGet(serializers.ModelSerializer):
    roomname = serializers.CharField(source='room.name', required=False, allow_blank=True, allow_null=True)
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



class LearningResourceSerializer(serializers.ModelSerializer):
    class Meta:
        model = LearningResource
        fields = '__all__'


class RoomSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rooms
        fields = '__all__'


class RoomMediaSerializer(serializers.ModelSerializer):
    class Meta:
        model = RoomMedia
        fields = '__all__'


class MultipleRoomMediaUploadSerializer(serializers.Serializer):
    media_files = serializers.ListField(
        child=serializers.FileField(),
        write_only=True
    )

    def create(self, validated_data):
        room = self.context['room']
        media_files = validated_data.pop('media_files')
        media_instances = []
        
        for media_file in media_files:
            media_instance = RoomMedia.objects.create(room=room, media_file=media_file)
            media_instances.append(media_instance)

        return media_instances
