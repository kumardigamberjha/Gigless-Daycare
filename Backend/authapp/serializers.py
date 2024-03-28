from rest_framework import serializers
# from django.contrib.auth.models import User
from .models import CustomUser


class CurrentUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ('id', 'username', 'email', 'usertype')


from .models import CustomUser

class CustomUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ('id', 'email', 'username', 'password', 'mobile_number', 'usertype', 'unique_id')  # Add 'mobile_number' field
        # extra_kwargs = {'password': {'write_only': True}}
        extra_kwargs = {
            'password': {'write_only': True},  # Ensure password is write-only
            'unique_id': {'read_only': True},  # Exclude unique_id from validation
        }   

    def create(self, validated_data):
        email = validated_data.get('email', '')
        username = email.split('@')[0]

        print("Email: ", email)
        print("Username: ", username)

        # Add the generated username to the validated data
        validated_data['username'] = username
        user = CustomUser.objects.create_user(**validated_data)
        return user