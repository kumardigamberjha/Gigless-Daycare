from django.db import models
from django.utils.crypto import get_random_string
from PIL import Image
from django.core.files.uploadedfile import InMemoryUploadedFile
import io, os
import ffmpeg
from django.core.files.base import ContentFile
from io import BytesIO
from authapp.models import CustomUser
from django.conf import settings
import subprocess
from moviepy.editor import VideoFileClip
import boto3 
s3_client = boto3.client('s3')


class Rooms(models.Model):
    name = models.CharField(max_length=55)

    def __str__(self):
        return self.name

class Child(models.Model):
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    date_of_birth = models.DateField()
    gender = models.CharField(max_length=10)
    blood_group = models.CharField(max_length=5, blank=True, null=True)
    medical_history = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    image = models.ImageField(blank=True, null=True)
    unique_id = models.CharField(max_length=30, unique=True, blank=True)  # Ensure blank=True so it can be set programmatically
    room = models.ForeignKey('Rooms', on_delete=models.SET_NULL, null=True, blank=True) 
    child_fees = models.FloatField(default=0)
    
    # Address Information
    address = models.CharField(max_length=255, blank=True, null=True)
    city = models.CharField(max_length=100, blank=True, null=True)
    state = models.CharField(max_length=100, blank=True, null=True)
    zip_code = models.CharField(max_length=10, blank=True, null=True)
    
    parent1_name = models.CharField(max_length=100)
    parent1_contact_number = models.CharField(max_length=15)
    parent2_name = models.CharField(max_length=100, blank=True, null=True)
    parent2_contact_number = models.CharField(max_length=15, blank=True, null=True)
    
    is_active = models.BooleanField(default=True, blank=True)

    class Meta:
        unique_together = ['first_name', 'last_name', 'date_of_birth', 'parent1_contact_number']

    def save(self, *args, **kwargs):
        # Generate a unique ID if it hasn't been set
        if not self.unique_id:
            self.unique_id = self.generate_unique_id()

        # Optionally compress image if one is uploaded
        if self.image:
            img = Image.open(self.image)
            output = io.BytesIO()
            img.save(output, format='JPEG', quality=60)  # Adjust quality for compression
            output.seek(0)
            self.image = InMemoryUploadedFile(output, 'ImageField', self.image.name, 'image/jpeg', output.getbuffer().nbytes, None)
        
        super().save(*args, **kwargs)

    def generate_unique_id(self):
        # Generate a unique 10-character alphanumeric string
        return get_random_string(length=10)

    def __str__(self):
        return f"{self.first_name} {self.last_name}"





############################# Attendance ###############################
class Attendance(models.Model):
    child = models.ForeignKey('Child', on_delete=models.CASCADE)
    is_present = models.BooleanField(default=False)
    datemarked = models.DateField(auto_now_add=True)

    def __str__(self):
        return f"{self.child} - {self.datemarked}"



############################# Daily Activity ###############################

class DailyActivity(models.Model):
    child = models.ForeignKey(Child, on_delete=models.CASCADE)
    ondate = models.DateField(auto_now=True)
    meal_description = models.TextField(blank=True, null=True)
    nap_duration = models.DurationField(blank=True, null=True)
    playtime_activities = models.TextField(blank=True, null=True)
    bathroom_breaks = models.PositiveIntegerField(default=0, blank=True, null=True)
    mood = models.CharField(max_length=20, blank=True, null=True)
    temperature = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    medication_given = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.child} - {self.ondate}"
    

class ChildMedia(models.Model):
    MEDIA_TYPES = (
        ('Image', 'Image'),
        ('Video', 'Video'),
    )

    ACTIVITY_TYPES = (
        ('Meal', 'Meal'),
        ('Nap', 'Nap'),
        ('Playtime', 'Playtime'),
        ('Bathroom', 'Bathroom'),
        ('Other', 'Other'),
    )

    child = models.ForeignKey(Child, on_delete=models.CASCADE, related_name='media')
    media_type = models.CharField(max_length=10, choices=MEDIA_TYPES, blank=True, null=True)
    file = models.FileField(upload_to='child_media/')
    uploaded_at = models.DateTimeField(auto_now_add=True)
    activity_type = models.CharField(max_length=20, choices=ACTIVITY_TYPES, default='other')
    desc = models.CharField(max_length=500,blank=True, null=True)

    def __str__(self):
        return f"{self.get_media_type_display()} of {self.child.first_name} {self.child.last_name} uploaded at {self.uploaded_at} for {self.get_activity_type_display()}"
    




# ####################################### Resources #######################


class LearningResource(models.Model):
    title = models.CharField(max_length=100)
    description = models.TextField()
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title


class LearningResourceMedia(models.Model):
    lrid = models.ForeignKey(LearningResource, on_delete=models.CASCADE)
    title = models.CharField(max_length=100, blank=True, null=True)
    file = models.FileField(upload_to='learning_resources/')

    def __str__(self):
        return self.title