from django.db import models
from django.utils.crypto import get_random_string
from students.models import Rooms

# Create your models here.
from django.contrib.auth.models import AbstractUser
from django.contrib.auth.models import Permission, Group

class CustomUser(AbstractUser):
    # other fields...
    unique_id = models.CharField(max_length=30, unique=True)
    email = models.EmailField(unique=True)
    mobile_number = models.CharField(unique=True, max_length=15, blank=True, null=True)
    usertype = models.CharField(max_length=20, default='Staff')  # Parent or Staff
    
    is_active = models.BooleanField(default=True)
    groups = models.ManyToManyField(Group, related_name='custom_user_set', blank=True, help_text='The groups this user belongs to. A user will get all permissions granted to each of their groups.')
    user_permissions = models.ManyToManyField(Permission, related_name='custom_user_set', blank=True, help_text='Specific permissions for this user.')
    room = models.ForeignKey(Rooms, on_delete=models.SET_NULL, null=True, blank=True)

    # def save(self, *args, **kwargs):
    #     if not self.unique_id:
    #         self.unique_id = self.generate_unique_id()
    #     super().save(*args, **kwargs)

    def save(self, *args, **kwargs):
        if not self.unique_id:
            self.unique_id = self.generate_unique_id()
        if self.usertype == 'Parent' and not self.pk:
            self.is_active = True  # Deactivate the account until approved
        super().save(*args, **kwargs)

    def generate_unique_id(self):
        # Generate a unique ID using a random string
        return get_random_string(length=10)
    
    def __str__(self):
        return f"{self.id} - {self.email}"
